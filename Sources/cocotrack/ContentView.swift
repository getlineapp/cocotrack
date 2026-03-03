import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var editingEntry: ClockifyTimeEntry?
    @State private var showSettings: Bool = false
    @State private var showCreateProject: Bool = false
    @State private var customDescription: String = ""
    @State private var selectedProjectId: String?

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
            EntryEditSheet(entry: entry) { description, start, end, projectId in
                await appState.saveEntryEdits(
                    entryId: entry.id,
                    description: description,
                    start: start,
                    end: end,
                    projectId: projectId
                )
            }
            .environmentObject(appState)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectSheet()
                .environmentObject(appState)
        }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cocotrack")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text(L10n.appSubtitle)
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
            .disabled(appState.isLoading || !appState.isConnected)

            Button {
                showSettings = true
            } label: {
                Label(L10n.settings, systemImage: "gearshape")
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

            Text(appState.isConnected ? L10n.statusConnected : (appState.isConfigured ? L10n.statusNeedsConnection : L10n.statusNotConfigured))
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
                Text(appState.isTracking ? L10n.timerActive : L10n.timerNew)
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

                runningProjectPicker

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
                .disabled(!appState.canStopTimer)
            } else {
                Text(L10n.timerHint)
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 10) {
                    TextField(L10n.timerPlaceholder, text: $customDescription)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(.white)

                    Button {
                        Task {
                            let started = await appState.startTimer(using: customDescription, projectId: selectedProjectId)
                            if started {
                                customDescription = ""
                                selectedProjectId = nil
                            }
                        }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
                    .disabled(!appState.canStartTimer)
                }

                HStack(spacing: 8) {
                    ProjectPickerMenu(
                        projects: appState.projects,
                        selectedProjectId: selectedProjectId,
                        onSelect: { selectedProjectId = $0 },
                        onDarkBackground: true
                    )

                    Button {
                        showCreateProject = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.7))
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

    @ViewBuilder
    private var runningProjectPicker: some View {
        if let entry = appState.runningEntry {
            ProjectPickerMenu(
                projects: appState.projects,
                selectedProjectId: entry.projectId,
                onSelect: { newId in
                    Task { await appState.changeEntryProject(entryId: entry.id, projectId: newId) }
                },
                onDarkBackground: true
            )
        }
    }

    private var favoritesSection: some View {
        SectionShell(title: L10n.favorites) {
            if appState.favoriteTemplates.isEmpty {
                Text(L10n.favoritesEmpty)
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
                            subtitle: template.lastUsed == .distantPast ? L10n.noLastUse : L10n.lastUsed(template.lastUsed.shortDateTime),
                            projectName: appState.projectName(for: template.projectId),
                            projectColorHex: appState.projectColorHex(for: template.projectId),
                            onUnfavorite: { appState.toggleFavorite(description: template.description) },
                            onStart: { Task { await appState.startTimer(using: template.description, projectId: template.projectId) } },
                            isStartDisabled: !appState.canStartTimer
                        )
                    }
                }
            }
        }
    }

    private var quickStartSection: some View {
        SectionShell(title: L10n.quickStart) {
            if appState.quickStartTemplates.isEmpty {
                Text(L10n.quickStartEmpty)
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
                            projectName: appState.projectName(for: template.projectId),
                            projectColorHex: appState.projectColorHex(for: template.projectId),
                            onStart: { Task { await appState.startTimer(using: template.description, projectId: template.projectId) } },
                            isStartDisabled: !appState.canStartTimer
                        )
                    }
                }
            }
        }
    }

    private var recentEntriesSection: some View {
        SectionShell(title: L10n.recentEntries) {
            if groupedRecentEntries.isEmpty {
                Text(L10n.recentEntriesEmpty)
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
                                        projectName: appState.projectName(for: entry.projectId),
                                        projectColorHex: appState.projectColorHex(for: entry.projectId),
                                        isFavorite: appState.isFavorite(normalizedDescription(for: entry)),
                                        onToggleFavorite: {
                                            appState.toggleFavorite(description: normalizedDescription(for: entry))
                                        },
                                        onStart: {
                                            Task { await appState.startTimer(using: normalizedDescription(for: entry), projectId: entry.projectId) }
                                        },
                                        onEdit: {
                                            editingEntry = entry
                                        },
                                        isStartDisabled: !appState.canStartTimer
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
        if !today.isEmpty { result.append(RecentEntrySection(title: L10n.today, entries: today)) }
        if !yesterday.isEmpty { result.append(RecentEntrySection(title: L10n.yesterday, entries: yesterday)) }
        if !thisWeek.isEmpty { result.append(RecentEntrySection(title: L10n.thisWeek, entries: thisWeek)) }
        if !older.isEmpty { result.append(RecentEntrySection(title: L10n.older, entries: older)) }

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

            Text(appState.statusMessage.isEmpty ? L10n.statusReady : appState.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Text(L10n.autoRefresh)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }
}

// MARK: - Reusable project picker menu

private struct ProjectPickerMenu: View {
    let projects: [ClockifyProject]
    let selectedProjectId: String?
    let onSelect: (String?) -> Void
    var onDarkBackground: Bool = false

    var body: some View {
        Menu {
            Button {
                onSelect(nil)
            } label: {
                if selectedProjectId == nil {
                    Label(L10n.noProject, systemImage: "checkmark")
                } else {
                    Text(L10n.noProject)
                }
            }
            Divider()
            ForEach(projects) { project in
                Button {
                    onSelect(project.id)
                } label: {
                    if selectedProjectId == project.id {
                        Label(project.name, systemImage: "checkmark")
                    } else {
                        Text(project.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let id = selectedProjectId,
                   let project = projects.first(where: { $0.id == id }) {
                    Circle()
                        .fill(Color(hex: project.color ?? "") ?? .gray)
                        .frame(width: 8, height: 8)
                    Text(project.name)
                        .font(.caption.weight(.medium))
                        .foregroundColor(onDarkBackground ? .white : nil)
                } else {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundColor(onDarkBackground ? .white : nil)
                    Text(L10n.noProject)
                        .font(.caption.weight(.medium))
                        .foregroundColor(onDarkBackground ? .white : nil)
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundColor(onDarkBackground ? .white : nil)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                onDarkBackground ? Color.white.opacity(0.2) : Color.primary.opacity(0.12),
                in: Capsule()
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}

// MARK: - Supporting types

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
    let projectName: String?
    let projectColorHex: String?
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

                HStack(spacing: 8) {
                    if let projectName {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: projectColorHex ?? "") ?? .gray)
                                .frame(width: 8, height: 8)
                            Text(projectName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    let projectName: String?
    let projectColorHex: String?
    let onStart: () -> Void
    let isStartDisabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.circle")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                if let projectName {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: projectColorHex ?? "") ?? .gray)
                            .frame(width: 8, height: 8)
                        Text(projectName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

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
    let projectName: String?
    let projectColorHex: String?
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onStart: () -> Void
    let onEdit: () -> Void
    let isStartDisabled: Bool

    private var description: String {
        let value = (entry.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? L10n.noDescription : value
    }

    private var timeRange: String {
        entry.timeInterval.start.shortDateTime + " - " + (entry.timeInterval.end?.shortDateTime ?? L10n.inProgress)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let projectName {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: projectColorHex ?? "") ?? .gray)
                                .frame(width: 8, height: 8)
                            Text(projectName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(timeRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
                Button(L10n.edit) {
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

// MARK: - Settings sheet

private struct SettingsSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.settingsTitle)
                .font(.title3.weight(.semibold))

            Text(L10n.settingsSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField("API key", text: $appState.apiKey)
                .textFieldStyle(.roundedBorder)

            TextField("Base URL", text: $appState.baseURL)
                .textFieldStyle(.roundedBorder)

            TextField(L10n.settingsWorkspaceHint, text: $appState.workspaceOverride)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button(L10n.settingsClose) {
                    dismiss()
                }

                Spacer()

                Button(L10n.settingsSaveConnect) {
                    Task {
                        await appState.connectAndRefresh()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
            }

            if !appState.userName.isEmpty {
                Text(L10n.userLabel(appState.userName))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(width: 460)
    }
}

// MARK: - Entry edit sheet

private struct EntryEditSheet: View {
    @EnvironmentObject private var appState: AppState
    let entry: ClockifyTimeEntry
    let onSave: (_ description: String, _ start: Date, _ end: Date?, _ projectId: String?) async -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var description: String
    @State private var start: Date
    @State private var hasEndDate: Bool
    @State private var end: Date
    @State private var selectedProjectId: String?
    @State private var isSaving: Bool = false

    private var isValid: Bool {
        !hasEndDate || end >= start
    }

    init(entry: ClockifyTimeEntry, onSave: @escaping (_ description: String, _ start: Date, _ end: Date?, _ projectId: String?) async -> Bool) {
        self.entry = entry
        self.onSave = onSave
        _description = State(initialValue: entry.description ?? "")
        _start = State(initialValue: entry.timeInterval.start)
        _selectedProjectId = State(initialValue: entry.projectId)

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
            Text(L10n.editEntryTitle)
                .font(.headline)

            TextField(L10n.editEntryDescription, text: $description)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 8) {
                Text(L10n.projectLabel)
                    .font(.subheadline)

                ProjectPickerMenu(
                    projects: appState.projects,
                    selectedProjectId: selectedProjectId,
                    onSelect: { selectedProjectId = $0 }
                )
            }

            DatePicker("Start", selection: $start)

            Toggle(L10n.editEntryHasEnd, isOn: $hasEndDate)

            if hasEndDate {
                DatePicker(L10n.editEntryEnd, selection: $end)
            }

            HStack {
                Spacer()
                Button(L10n.editEntryCancel) {
                    dismiss()
                }
                .disabled(isSaving)

                Button(L10n.editEntrySave) {
                    guard !isSaving else { return }

                    isSaving = true
                    Task {
                        let saved = await onSave(description, start, hasEndDate ? end : nil, selectedProjectId)
                        isSaving = false

                        if saved {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
                .disabled(!isValid || isSaving || appState.isLoading)
            }
        }
        .padding(16)
        .frame(minWidth: 420)
    }
}

// MARK: - Create project sheet

private struct CreateProjectSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedColor: String = "#0b83d9"
    @State private var isSaving: Bool = false

    private let presetColors = [
        "#0b83d9", "#9c27b0", "#e91e63", "#e67e22",
        "#2ecc71", "#1abc9c", "#3498db", "#8e44ad",
        "#e74c3c", "#f39c12", "#27ae60", "#16a085"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.createProjectTitle)
                .font(.headline)

            TextField(L10n.createProjectName, text: $name)
                .textFieldStyle(.roundedBorder)

            Text(L10n.createProjectColor)
                .font(.subheadline.weight(.medium))

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(28), spacing: 8), count: 6), spacing: 8) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color) ?? .gray)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2.5 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            HStack {
                Spacer()
                Button(L10n.editEntryCancel) {
                    dismiss()
                }
                .disabled(isSaving)

                Button(L10n.createProjectButton) {
                    guard !isSaving else { return }

                    isSaving = true
                    Task {
                        let created = await appState.createProject(name: name, color: selectedColor)
                        isSaving = false

                        if created {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.39, blue: 0.29))
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving || appState.isLoading)
            }
        }
        .padding(16)
        .frame(minWidth: 360)
    }
}
