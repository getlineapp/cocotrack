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
            Color(.windowBackgroundColor)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    toolbar
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 12)

                    timerCard
                        .padding(.horizontal, 18)

                    Divider()
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)

                    quickStartSection
                        .padding(.horizontal, 18)

                    if !appState.recentEntryGroups.isEmpty {
                        Divider()
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)

                        RecentTimeLogSection(onEditEntry: { entry in
                            editingEntry = entry
                        })
                        .padding(.horizontal, 18)
                    }

                    Spacer(minLength: 12)

                    statusBar
                        .padding(.horizontal, 18)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(minWidth: 480, idealWidth: 520, maxWidth: 600, minHeight: 400)
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

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Circle()
                    .fill(appState.isConnected ? Color.green : (appState.isConfigured ? Color.orange : Color.gray))
                    .frame(width: 8, height: 8)

                Text("Cocotrack")
                    .font(.system(size: 13, weight: .semibold))

                if !appState.userName.isEmpty {
                    Text("· \(appState.userName)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                Task { await appState.refreshEntries() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(appState.isLoading || !appState.isConnected)

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    // MARK: - Timer card

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !appState.isConnected {
                VStack(spacing: 10) {
                    Text(L10n.configureConnection)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button(L10n.settings) {
                        showSettings = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else if appState.isTracking {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text(L10n.timerActive)
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }

                Text(appState.runningDescription)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)

                if let entry = appState.runningEntry {
                    ProjectPickerMenu(
                        projects: appState.projects,
                        selectedProjectId: entry.projectId,
                        onSelect: { newId in
                            Task { await appState.changeEntryProject(entryId: entry.id, projectId: newId) }
                        }
                    )
                }

                if appState.forceProjects && appState.runningEntry?.projectId == nil {
                    Text(L10n.projectRequiredForStop)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }

                HStack {
                    Text(appState.elapsedText)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                        .onTapGesture {
                            if let entry = appState.runningEntry {
                                editingEntry = entry
                            }
                        }
                        .help("Kliknij aby edytować wpis")

                    Spacer()

                    Button {
                        Task { await appState.stopTimer() }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .controlSize(.regular)
                    .disabled(!appState.canStopTimer)
                }
            } else {
                Text(L10n.timerNew)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    TextField(L10n.timerPlaceholder, text: $customDescription)
                        .textFieldStyle(.roundedBorder)

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
                    .controlSize(.regular)
                    .disabled(!appState.canStartTimer || (appState.forceProjects && selectedProjectId == nil))
                }

                HStack(spacing: 8) {
                    ProjectPickerMenu(
                        projects: appState.projects,
                        selectedProjectId: selectedProjectId,
                        onSelect: { selectedProjectId = $0 }
                    )

                    if appState.forceProjects && selectedProjectId == nil {
                        Text(L10n.projectRequiredHint)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Spacer()

                    Button {
                        showCreateProject = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Quick start

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.quickStart)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            if appState.quickStartItems.isEmpty {
                Text(L10n.quickStartEmpty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 2) {
                    ForEach(appState.quickStartItems) { item in
                        QuickStartRow(
                            item: item,
                            projectName: appState.projectName(for: item.projectId),
                            projectColorHex: appState.projectColorHex(for: item.projectId),
                            onToggleFavorite: {
                                appState.toggleFavorite(description: item.description)
                            },
                            onStart: {
                                Task { await appState.startTimer(using: item.description, projectId: item.projectId) }
                            },
                            onEditLastEntry: {
                                if let entry = appState.recentEntries.first(where: {
                                    ($0.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == item.description
                                }) {
                                    editingEntry = entry
                                }
                            },
                            isStartDisabled: !appState.canStartTimer || (appState.forceProjects && item.projectId == nil)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Status bar

    private var statusBar: some View {
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
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Quick start row

private struct QuickStartRow: View {
    let item: QuickStartItem
    let projectName: String?
    let projectColorHex: String?
    let onToggleFavorite: () -> Void
    let onStart: () -> Void
    let onEditLastEntry: () -> Void
    let isStartDisabled: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(item.isFavorite ? .yellow : Color(.tertiaryLabelColor))
            }
            .buttonStyle(.plain)

            Text(item.description)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            if let projectName {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: projectColorHex ?? "") ?? .gray)
                        .frame(width: 6, height: 6)
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                onStart()
            } label: {
                Text("Start")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isStartDisabled)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color(.quaternaryLabelColor) : .clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button(L10n.editLastEntry) {
                onEditLastEntry()
            }
        }
    }
}

// MARK: - Project picker menu

private struct ProjectPickerMenu: View {
    let projects: [ClockifyProject]
    let selectedProjectId: String?
    let onSelect: (String?) -> Void

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
                        .frame(width: 7, height: 7)
                    Text(project.name)
                        .font(.caption.weight(.medium))
                } else {
                    Image(systemName: "folder")
                        .font(.caption)
                    Text(L10n.noProject)
                        .font(.caption.weight(.medium))
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.quaternaryLabelColor), in: Capsule())
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
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
                .tint(.accentColor)
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
                .tint(.accentColor)
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
                .tint(.accentColor)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving || appState.isLoading)
            }
        }
        .padding(16)
        .frame(minWidth: 360)
    }
}
