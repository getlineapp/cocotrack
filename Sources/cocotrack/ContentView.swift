import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var editingEntry: ClockifyTimeEntry?
    @State private var showSettings: Bool = false
    @State private var customDescription: String = ""

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    timerHero
                    favoritesSection
                    quickStartSection
                    recentEntriesSection
                    statusSection
                }
                .padding(20)
                .frame(maxWidth: 600, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(minWidth: 540, idealWidth: 580, minHeight: 700)
        .sheet(item: $editingEntry) { entry in
            EntryEditSheet(entry: entry) { description, start, end in
                Task {
                    await appState.saveEntryEdits(
                        entryId: entry.id,
                        description: description,
                        start: start,
                        end: end
                    )
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .environmentObject(appState)
        }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cocotrack")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("Timer-first workflow. Auto odswiezanie historii co 30s.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            connectionPill

            Button {
                Task { await appState.refreshEntries() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.bordered)

            Button {
                showSettings = true
            } label: {
                Label("Ustawienia", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.13, green: 0.27, blue: 0.48))
        }
    }

    private var connectionPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(appState.isConnected ? Color.green : (appState.isConfigured ? Color.orange : Color.gray))
                .frame(width: 9, height: 9)

            Text(appState.isConnected ? "Polaczono" : (appState.isConfigured ? "Wymaga polaczenia" : "Brak konfiguracji"))
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var timerHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(appState.isTracking ? "Aktywny timer" : "Nowy timer")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Text(appState.isTracking ? "LIVE" : "READY")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(appState.isTracking ? Color.green.opacity(0.2) : Color.white.opacity(0.12), in: Capsule())
                    .foregroundStyle(.white)
            }

            if appState.isTracking {
                Text(appState.runningDescription)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(appState.elapsedText)
                    .font(.system(size: 54, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)

                Button {
                    Task { await appState.stopTimer() }
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            } else {
                Text("Wpisz opis i kliknij Start albo odpal gotowy timer z listy nizej.")
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 10) {
                    TextField("Nad czym pracujesz?", text: $customDescription)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(.white)

                    Button {
                        Task {
                            await appState.startTimer(using: customDescription)
                            customDescription = ""
                        }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.11, green: 0.15, blue: 0.23), Color(red: 0.16, green: 0.23, blue: 0.34)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 14, y: 7)
    }

    private var favoritesSection: some View {
        SectionShell(title: "Ulubione") {
            if appState.favoriteTemplates.isEmpty {
                Text("Przypnij timer gwiazdka z historii, a bedzie zawsze na gorze.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(appState.favoriteTemplates) { template in
                        FavoriteRow(
                            title: template.description,
                            subtitle: template.lastUsed == .distantPast ? "Brak ostatniego uzycia" : "Ostatnio: \(template.lastUsed.shortDateTime)",
                            onUnfavorite: { appState.toggleFavorite(description: template.description) },
                            onStart: { Task { await appState.startTimer(using: template.description) } },
                            isStartDisabled: appState.isTracking
                        )
                    }
                }
            }
        }
    }

    private var quickStartSection: some View {
        SectionShell(title: "Szybki start") {
            if appState.quickStartTemplates.isEmpty {
                Text("Brak historii. Po kilku wpisach pojawia sie tu gotowe timery.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(appState.quickStartTemplates) { template in
                        QuickStartMinimalRow(
                            title: template.description,
                            onStart: { Task { await appState.startTimer(using: template.description) } },
                            isStartDisabled: appState.isTracking
                        )
                    }
                }
            }
        }
    }

    private var recentEntriesSection: some View {
        SectionShell(title: "Ostatnie wpisy") {
            if groupedRecentEntries.isEmpty {
                Text("Brak wpisow do wyswietlenia.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(groupedRecentEntries) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            LazyVStack(spacing: 8) {
                                ForEach(section.entries) { entry in
                                    RecentEntryRow(
                                        entry: entry,
                                        isFavorite: appState.isFavorite(normalizedDescription(for: entry)),
                                        onToggleFavorite: {
                                            appState.toggleFavorite(description: normalizedDescription(for: entry))
                                        },
                                        onStart: {
                                            Task { await appState.startTimer(using: normalizedDescription(for: entry)) }
                                        },
                                        onEdit: {
                                            editingEntry = entry
                                        },
                                        isStartDisabled: appState.isTracking
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var groupedRecentEntries: [RecentEntrySection] {
        guard !appState.recentEntries.isEmpty else { return [] }

        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? .distantPast

        var today: [ClockifyTimeEntry] = []
        var yesterday: [ClockifyTimeEntry] = []
        var thisWeek: [ClockifyTimeEntry] = []
        var older: [ClockifyTimeEntry] = []

        for entry in appState.recentEntries {
            let start = entry.timeInterval.start

            if calendar.isDateInToday(start) {
                today.append(entry)
            } else if calendar.isDateInYesterday(start) {
                yesterday.append(entry)
            } else if start >= weekStart {
                thisWeek.append(entry)
            } else {
                older.append(entry)
            }
        }

        var result: [RecentEntrySection] = []
        if !today.isEmpty { result.append(RecentEntrySection(title: "Dzis", entries: today)) }
        if !yesterday.isEmpty { result.append(RecentEntrySection(title: "Wczoraj", entries: yesterday)) }
        if !thisWeek.isEmpty { result.append(RecentEntrySection(title: "W tym tygodniu", entries: thisWeek)) }
        if !older.isEmpty { result.append(RecentEntrySection(title: "Starsze", entries: older)) }

        return result
    }

    private func normalizedDescription(for entry: ClockifyTimeEntry) -> String {
        (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var statusSection: some View {
        HStack(spacing: 10) {
            if appState.isLoading {
                ProgressView()
                    .controlSize(.small)
            }

            Text(appState.statusMessage.isEmpty ? "Gotowe" : appState.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Text("Auto refresh: 30s")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }
}

private struct RecentEntrySection: Identifiable {
    let title: String
    let entries: [ClockifyTimeEntry]

    var id: String { title }
}

private struct SectionShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            content
        }
    }
}

private struct FavoriteRow: View {
    let title: String
    let subtitle: String
    let onUnfavorite: () -> Void
    let onStart: () -> Void
    let isStartDisabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onUnfavorite()
            } label: {
                Image(systemName: "star.fill")
            }
            .buttonStyle(.bordered)

            Button("Start") {
                onStart()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            .disabled(isStartDisabled)
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct QuickStartMinimalRow: View {
    let title: String
    let onStart: () -> Void
    let isStartDisabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.circle")
                .foregroundStyle(.secondary)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Spacer()

            Button("Start") {
                onStart()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            .disabled(isStartDisabled)
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct RecentEntryRow: View {
    let entry: ClockifyTimeEntry
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onStart: () -> Void
    let onEdit: () -> Void
    let isStartDisabled: Bool

    private var description: String {
        let value = (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Bez opisu" : value
    }

    private var timeRange: String {
        entry.timeInterval.start.shortDateTime + " - " + (entry.timeInterval.end?.shortDateTime ?? "w toku")
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(timeRange)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
            }
            .buttonStyle(.bordered)

            Button("Start") {
                onStart()
            }
            .buttonStyle(.bordered)
            .disabled(isStartDisabled)

            Menu {
                Button("Edytuj") {
                    onEdit()
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct SettingsSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ustawienia Clockify")
                .font(.title3.weight(.semibold))

            Text("Konfiguracja API jest schowana tutaj, zeby glowny ekran byl skupiony na timerach.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField("API key", text: $appState.apiKey)
                .textFieldStyle(.roundedBorder)

            TextField("Base URL", text: $appState.baseURL)
                .textFieldStyle(.roundedBorder)

            TextField("Workspace ID (opcjonalnie)", text: $appState.workspaceOverride)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Zamknij") {
                    dismiss()
                }

                Spacer()

                Button("Zapisz i polacz") {
                    Task {
                        await appState.connectAndRefresh()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            }

            if !appState.userName.isEmpty {
                Text("User: \(appState.userName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(width: 460)
    }
}

private struct EntryEditSheet: View {
    let entry: ClockifyTimeEntry
    let onSave: (_ description: String, _ start: Date, _ end: Date?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var description: String
    @State private var start: Date
    @State private var hasEndDate: Bool
    @State private var end: Date

    init(entry: ClockifyTimeEntry, onSave: @escaping (_ description: String, _ start: Date, _ end: Date?) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _description = State(initialValue: entry.description ?? "")
        _start = State(initialValue: entry.timeInterval.start)

        if let endDate = entry.timeInterval.end {
            _hasEndDate = State(initialValue: true)
            _end = State(initialValue: endDate)
        } else {
            _hasEndDate = State(initialValue: false)
            _end = State(initialValue: Date())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edycja wpisu")
                .font(.headline)

            TextField("Opis", text: $description)
                .textFieldStyle(.roundedBorder)

            DatePicker("Start", selection: $start)

            Toggle("Wpis ma czas zakonczenia", isOn: $hasEndDate)

            if hasEndDate {
                DatePicker("Koniec", selection: $end)
            }

            HStack {
                Spacer()
                Button("Anuluj") {
                    dismiss()
                }
                Button("Zapisz") {
                    onSave(description, start, hasEndDate ? end : nil)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            }
        }
        .padding(16)
        .frame(minWidth: 420)
    }
}
