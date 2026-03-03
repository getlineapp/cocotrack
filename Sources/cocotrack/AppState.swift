import Foundation

struct QuickStartTemplate: Identifiable {
    let description: String
    let lastUsed: Date
    let projectId: String?

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
    @Published var projects: [ClockifyProject] = []
    @Published var timerDraftDescription: String = ""
    @Published var timerDraftProjectId: String?
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

    var canStartTimer: Bool {
        isConnected && !isTracking && !isLoading
    }

    var canStopTimer: Bool {
        isConnected && isTracking && !isLoading
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

            templates.append(QuickStartTemplate(
                description: trimmed,
                lastUsed: entry.timeInterval.start,
                projectId: entry.projectId
            ))
            if templates.count == 10 {
                break
            }
        }

        return templates
    }

    var favoriteTemplates: [QuickStartTemplate] {
        var lastUsedByDescription: [String: (date: Date, projectId: String?)] = [:]

        for entry in recentEntries {
            let trimmed = (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if let current = lastUsedByDescription[trimmed] {
                if entry.timeInterval.start > current.date {
                    lastUsedByDescription[trimmed] = (date: entry.timeInterval.start, projectId: entry.projectId)
                }
            } else {
                lastUsedByDescription[trimmed] = (date: entry.timeInterval.start, projectId: entry.projectId)
            }
        }

        return favoriteDescriptions
            .map { description in
                let info = lastUsedByDescription[description]
                return QuickStartTemplate(
                    description: description,
                    lastUsed: info?.date ?? .distantPast,
                    projectId: info?.projectId
                )
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

        return "\(shortDescription) [\(elapsedText)]"
    }

    var runningDescription: String {
        let value = runningEntry?.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let value, !value.isEmpty {
            return value
        }

        return L10n.noDescription
    }

    func projectName(for id: String?) -> String? {
        guard let id else { return nil }
        return projects.first(where: { $0.id == id })?.name
    }

    func projectColorHex(for id: String?) -> String? {
        guard let id else { return nil }
        return projects.first(where: { $0.id == id })?.color
    }

    func connectAndRefresh() async {
        await runLoadingTask {
            persistSettings()

            let client = try makeClient()
            let user = try await client.fetchCurrentUser()

            let resolvedWorkspace = resolvedWorkspaceId(user: user)
            guard let resolvedWorkspace else {
                throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.workspaceError)
            }

            userId = user.id
            workspaceId = resolvedWorkspace
            userName = user.name ?? user.email ?? user.id

            async let running = client.fetchRunningTimeEntry(workspaceId: resolvedWorkspace, userId: user.id)
            async let recent = client.fetchRecentTimeEntries(workspaceId: resolvedWorkspace, userId: user.id, limit: 25)
            async let projectsList = client.fetchProjects(workspaceId: resolvedWorkspace)

            runningEntry = try await running
            recentEntries = try await recent
            projects = try await projectsList
            statusMessage = L10n.connectedAs(userName)

            restartElapsedTaskIfNeeded()
            restartAutoRefreshIfNeeded()
        }
    }

    func refreshEntries() async {
        await runLoadingTask {
            let context = try contextOrThrow()
            async let running = context.client.fetchRunningTimeEntry(workspaceId: context.workspaceId, userId: context.userId)
            async let recent = context.client.fetchRecentTimeEntries(workspaceId: context.workspaceId, userId: context.userId, limit: 25)
            async let projectsList = context.client.fetchProjects(workspaceId: context.workspaceId)

            runningEntry = try await running
            recentEntries = try await recent
            projects = try await projectsList
            statusMessage = L10n.dataRefreshed

            restartElapsedTaskIfNeeded()
        }
    }

    @discardableResult
    func startTimer() async -> Bool {
        var didStart = false

        await runLoadingTask {
            guard !isTracking else {
                throw ClockifyAPIError.httpError(statusCode: 409, message: L10n.timerAlreadyRunning)
            }

            let context = try contextOrThrow()
            let text = timerDraftDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            let description = text.isEmpty ? L10n.noDescription : text

            _ = try await context.client.startTimer(
                workspaceId: context.workspaceId,
                description: description,
                projectId: timerDraftProjectId,
                start: Date()
            )
            didStart = true

            timerDraftDescription = ""
            timerDraftProjectId = nil
            statusMessage = L10n.timerStarted

            await refreshEntriesWithoutSpinner(context: context)
        }

        return didStart
    }

    @discardableResult
    func startTimer(using description: String, projectId: String? = nil) async -> Bool {
        timerDraftDescription = description
        timerDraftProjectId = projectId
        return await startTimer()
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
            guard isTracking else {
                throw ClockifyAPIError.httpError(statusCode: 409, message: L10n.noRunningTimer)
            }

            let context = try contextOrThrow()
            _ = try await context.client.stopRunningTimer(
                workspaceId: context.workspaceId,
                userId: context.userId,
                end: Date()
            )

            statusMessage = L10n.timerStopped
            await refreshEntriesWithoutSpinner(context: context)
        }
    }

    @discardableResult
    func saveEntryEdits(entryId: String, description: String, start: Date, end: Date?, projectId: String?) async -> Bool {
        var didSave = false

        await runLoadingTask {
            if let end, end < start {
                throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.endBeforeStart)
            }

            let context = try contextOrThrow()
            let payload = ClockifyUpdateTimeEntryRequest(
                start: start.clockifyISO8601String,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                end: end?.clockifyISO8601String,
                projectId: projectId
            )

            _ = try await context.client.updateTimeEntry(
                workspaceId: context.workspaceId,
                entryId: entryId,
                payload: payload
            )
            didSave = true

            statusMessage = L10n.entryUpdated
            await refreshEntriesWithoutSpinner(context: context)
        }

        return didSave
    }

    func changeEntryProject(entryId: String, projectId: String?) async {
        let entry = runningEntry?.id == entryId ? runningEntry : recentEntries.first(where: { $0.id == entryId })
        guard let entry else { return }

        await runLoadingTask {
            if let projectId, !projects.contains(where: { $0.id == projectId }) {
                throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.projectNotFound)
            }

            let context = try contextOrThrow()
            let payload = ClockifyUpdateTimeEntryRequest(
                start: entry.timeInterval.start.clockifyISO8601String,
                description: entry.description ?? "",
                end: entry.timeInterval.end?.clockifyISO8601String,
                projectId: projectId
            )

            _ = try await context.client.updateTimeEntry(
                workspaceId: context.workspaceId,
                entryId: entryId,
                payload: payload
            )

            statusMessage = L10n.projectUpdated
            await refreshEntriesWithoutSpinner(context: context)
        }
    }

    @discardableResult
    func createProject(name: String, color: String?) async -> Bool {
        var didCreate = false

        await runLoadingTask {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.projectNameRequired)
            }

            let context = try contextOrThrow()
            let project = try await context.client.createProject(
                workspaceId: context.workspaceId,
                name: trimmedName,
                color: color
            )
            didCreate = true

            projects.append(project)
            statusMessage = L10n.projectCreated
        }

        return didCreate
    }

    private func runLoadingTask(_ operation: @MainActor () async throws -> Void) async {
        guard !isLoading else {
            statusMessage = L10n.operationInProgress
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await operation()
        } catch is CancellationError {
            // Ignore cancellation and keep current status message.
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func refreshEntriesWithoutSpinner(context: Context) async {
        do {
            async let running = context.client.fetchRunningTimeEntry(workspaceId: context.workspaceId, userId: context.userId)
            async let recent = context.client.fetchRecentTimeEntries(workspaceId: context.workspaceId, userId: context.userId, limit: 25)
            async let projectsList = context.client.fetchProjects(workspaceId: context.workspaceId)

            runningEntry = try await running
            recentEntries = try await recent
            projects = try await projectsList
            restartElapsedTaskIfNeeded()
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func contextOrThrow() throws -> Context {
        guard !userId.isEmpty, !workspaceId.isEmpty else {
            throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.connectFirst)
        }

        let client = try makeClient()
        return Context(client: client, userId: userId, workspaceId: workspaceId)
    }

    private func makeClient() throws -> ClockifyAPIClient {
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedApiKey.isEmpty else {
            throw ClockifyAPIError.httpError(statusCode: 400, message: L10n.fillApiKey)
        }

        return try ClockifyAPIClient(
            baseURLString: baseURL.trimmingCharacters(in: .whitespacesAndNewlines),
            apiKey: trimmedApiKey
        )
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
        guard !isLoading else { return }

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
