import Foundation

struct QuickStartTemplate: Identifiable {
    let description: String
    let lastUsed: Date

    var id: String { description }
}

@MainActor
final class AppState: ObservableObject {
    @Published var apiKey: String
    @Published var baseURL: String
    @Published var workspaceOverride: String

    @Published var userName: String = ""
    @Published var userId: String = ""
    @Published var workspaceId: String = ""

    @Published var recentEntries: [ClockifyTimeEntry] = []
    @Published var runningEntry: ClockifyTimeEntry?
    @Published var timerDraftDescription: String = ""
    @Published var statusMessage: String = ""
    @Published var isLoading: Bool = false
    @Published private(set) var favoriteDescriptions: Set<String>

    @Published private(set) var elapsedText: String = "00:00:00"

    private var elapsedTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?

    init() {
        let defaults = UserDefaults.standard
        self.apiKey = defaults.string(forKey: Keys.apiKey) ?? ""
        self.baseURL = defaults.string(forKey: Keys.baseURL) ?? "https://api.clockify.me/api/v1"
        self.workspaceOverride = defaults.string(forKey: Keys.workspaceOverride) ?? ""
        self.favoriteDescriptions = Set(defaults.stringArray(forKey: Keys.favoriteDescriptions) ?? [])

        if !apiKey.isEmpty {
            Task {
                await connectAndRefresh()
            }
        }
    }

    deinit {
        elapsedTask?.cancel()
        autoRefreshTask?.cancel()
    }

    var isTracking: Bool {
        runningEntry != nil
    }

    var isConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isConnected: Bool {
        !userId.isEmpty && !workspaceId.isEmpty
    }

    var quickStartTemplates: [QuickStartTemplate] {
        var seen = Set<String>()
        var templates: [QuickStartTemplate] = []

        for entry in recentEntries {
            let trimmed = (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            guard seen.insert(trimmed.lowercased()).inserted else { continue }

            templates.append(QuickStartTemplate(description: trimmed, lastUsed: entry.timeInterval.start))
            if templates.count == 10 {
                break
            }
        }

        return templates
    }

    var favoriteTemplates: [QuickStartTemplate] {
        var lastUsedByDescription: [String: Date] = [:]

        for entry in recentEntries {
            let trimmed = (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if let current = lastUsedByDescription[trimmed] {
                if entry.timeInterval.start > current {
                    lastUsedByDescription[trimmed] = entry.timeInterval.start
                }
            } else {
                lastUsedByDescription[trimmed] = entry.timeInterval.start
            }
        }

        return favoriteDescriptions
            .map { description in
                QuickStartTemplate(description: description, lastUsed: lastUsedByDescription[description] ?? .distantPast)
            }
            .sorted { $0.lastUsed > $1.lastUsed }
    }

    var menuBarTitle: String {
        guard isTracking else { return "Clockify" }

        let description = runningDescription
        let shortDescription: String
        if description.count > 20 {
            shortDescription = String(description.prefix(20)) + "..."
        } else {
            shortDescription = description
        }

        return "\(shortDescription) \(elapsedText)"
    }

    var runningDescription: String {
        let value = runningEntry?.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let value, !value.isEmpty {
            return value
        }

        return "Bez opisu"
    }

    func connectAndRefresh() async {
        await runLoadingTask {
            persistSettings()

            let client = try makeClient()
            let user = try await client.fetchCurrentUser()

            let resolvedWorkspace = resolvedWorkspaceId(user: user)
            guard let resolvedWorkspace else {
                throw ClockifyAPIError.httpError(statusCode: 400, message: "Nie udalo sie ustalic workspace ID.")
            }

            userId = user.id
            workspaceId = resolvedWorkspace
            userName = user.name ?? user.email ?? user.id

            async let running = client.fetchRunningTimeEntry(workspaceId: resolvedWorkspace, userId: user.id)
            async let recent = client.fetchRecentTimeEntries(workspaceId: resolvedWorkspace, userId: user.id, limit: 25)

            runningEntry = try await running
            recentEntries = try await recent
            statusMessage = "Polaczono jako \(userName)."

            restartElapsedTaskIfNeeded()
            restartAutoRefreshIfNeeded()
        }
    }

    func refreshEntries() async {
        await runLoadingTask {
            let context = try contextOrThrow()
            async let running = context.client.fetchRunningTimeEntry(workspaceId: context.workspaceId, userId: context.userId)
            async let recent = context.client.fetchRecentTimeEntries(workspaceId: context.workspaceId, userId: context.userId, limit: 25)

            runningEntry = try await running
            recentEntries = try await recent
            statusMessage = "Dane odswiezone."

            restartElapsedTaskIfNeeded()
        }
    }

    func startTimer() async {
        await runLoadingTask {
            let context = try contextOrThrow()
            let text = timerDraftDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            let description = text.isEmpty ? "Bez opisu" : text

            _ = try await context.client.startTimer(
                workspaceId: context.workspaceId,
                description: description,
                start: Date()
            )

            timerDraftDescription = ""
            statusMessage = "Timer uruchomiony."

            await refreshEntriesWithoutSpinner(context: context)
        }
    }

    func startTimer(using description: String) async {
        timerDraftDescription = description
        await startTimer()
    }

    func isFavorite(_ description: String) -> Bool {
        let normalized = description.trimmingCharacters(in: .whitespacesAndNewlines)
        return favoriteDescriptions.contains(normalized)
    }

    func toggleFavorite(description: String) {
        let normalized = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }

        if favoriteDescriptions.contains(normalized) {
            favoriteDescriptions.remove(normalized)
        } else {
            favoriteDescriptions.insert(normalized)
        }

        persistFavorites()
    }

    func stopTimer() async {
        await runLoadingTask {
            let context = try contextOrThrow()
            _ = try await context.client.stopRunningTimer(
                workspaceId: context.workspaceId,
                userId: context.userId,
                end: Date()
            )

            statusMessage = "Timer zatrzymany."
            await refreshEntriesWithoutSpinner(context: context)
        }
    }

    func saveEntryEdits(entryId: String, description: String, start: Date, end: Date?) async {
        await runLoadingTask {
            let context = try contextOrThrow()
            let payload = [
                ClockifyBulkEditTimeEntryRequest(
                    id: entryId,
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    start: start.clockifyISO8601String,
                    end: end?.clockifyISO8601String
                )
            ]

            _ = try await context.client.bulkEditTimeEntries(
                workspaceId: context.workspaceId,
                userId: context.userId,
                payload: payload
            )

            statusMessage = "Wpis zaktualizowany."
            await refreshEntriesWithoutSpinner(context: context)
        }
    }

    private func runLoadingTask(_ operation: @MainActor () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await operation()
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func refreshEntriesWithoutSpinner(context: Context) async {
        do {
            async let running = context.client.fetchRunningTimeEntry(workspaceId: context.workspaceId, userId: context.userId)
            async let recent = context.client.fetchRecentTimeEntries(workspaceId: context.workspaceId, userId: context.userId, limit: 25)

            runningEntry = try await running
            recentEntries = try await recent
            restartElapsedTaskIfNeeded()
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func contextOrThrow() throws -> Context {
        guard !userId.isEmpty, !workspaceId.isEmpty else {
            throw ClockifyAPIError.httpError(statusCode: 400, message: "Najpierw kliknij Polacz.")
        }

        let client = try makeClient()
        return Context(client: client, userId: userId, workspaceId: workspaceId)
    }

    private func makeClient() throws -> ClockifyAPIClient {
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedApiKey.isEmpty else {
            throw ClockifyAPIError.httpError(statusCode: 400, message: "Uzupelnij API key Clockify.")
        }

        return try ClockifyAPIClient(baseURLString: baseURL, apiKey: trimmedApiKey)
    }

    private func resolvedWorkspaceId(user: ClockifyUser) -> String? {
        let override = workspaceOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        if !override.isEmpty {
            return override
        }

        if let defaultWorkspace = user.defaultWorkspace, !defaultWorkspace.isEmpty {
            return defaultWorkspace
        }

        if let activeWorkspace = user.activeWorkspace, !activeWorkspace.isEmpty {
            return activeWorkspace
        }

        return nil
    }

    private func persistSettings() {
        let defaults = UserDefaults.standard
        defaults.set(apiKey, forKey: Keys.apiKey)
        defaults.set(baseURL, forKey: Keys.baseURL)
        defaults.set(workspaceOverride, forKey: Keys.workspaceOverride)
    }

    private func persistFavorites() {
        UserDefaults.standard.set(Array(favoriteDescriptions).sorted(), forKey: Keys.favoriteDescriptions)
    }

    private func restartElapsedTaskIfNeeded() {
        elapsedTask?.cancel()
        elapsedTask = nil

        guard runningEntry != nil else {
            elapsedText = "00:00:00"
            return
        }

        updateElapsedText()

        elapsedTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    self?.updateElapsedText()
                }
            }
        }
    }

    private func updateElapsedText() {
        guard let start = runningEntry?.timeInterval.start else {
            elapsedText = "00:00:00"
            return
        }

        let seconds = max(0, Int(Date().timeIntervalSince(start)))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        elapsedText = String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }

    private func restartAutoRefreshIfNeeded() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil

        guard isConnected else { return }

        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))

                if Task.isCancelled {
                    return
                }

                await self?.autoRefreshTick()
            }
        }
    }

    private func autoRefreshTick() async {
        do {
            let context = try contextOrThrow()
            await refreshEntriesWithoutSpinner(context: context)
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

private extension AppState {
    struct Context {
        let client: ClockifyAPIClient
        let userId: String
        let workspaceId: String
    }

    enum Keys {
        static let apiKey = "clockify.apiKey"
        static let baseURL = "clockify.baseURL"
        static let workspaceOverride = "clockify.workspaceOverride"
        static let favoriteDescriptions = "clockify.favoriteDescriptions"
    }
}
