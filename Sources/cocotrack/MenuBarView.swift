import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(appState.isTracking ? L10n.menuTimerActive : L10n.menuTimerStopped)
                .font(.headline)

            if appState.isTracking {
                Text(appState.runningDescription)
                    .lineLimit(2)

                if let entry = appState.runningEntry {
                    runningProjectMenu(entry: entry)
                }

                if appState.forceProjects && appState.runningEntry?.projectId == nil {
                    Text(L10n.projectRequiredForStop)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Text(appState.elapsedText)
                    .font(.system(.title3, design: .monospaced).weight(.semibold))

                Button("Stop") {
                    Task { await appState.stopTimer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appState.canStopTimer)
            } else {
                TextField(L10n.editEntryDescription, text: $appState.timerDraftDescription)
                    .textFieldStyle(.roundedBorder)

                draftProjectMenu

                if appState.forceProjects && appState.timerDraftProjectId == nil {
                    Text(L10n.projectRequiredHint)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Button("Start") {
                    Task { await appState.startTimer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appState.canStartTimer || (appState.forceProjects && appState.timerDraftProjectId == nil))
            }

            Divider()

            HStack {
                Button(L10n.refresh) {
                    Task { await appState.refreshEntries() }
                }
                .disabled(appState.isLoading || !appState.isConnected)

                Button(L10n.openApp) {
                    openWindow(id: "main")
                }

                Spacer()

                Button(L10n.quit) {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(12)
        .frame(minWidth: 320)
    }

    @ViewBuilder
    private func runningProjectMenu(entry: ClockifyTimeEntry) -> some View {
        Menu {
            Button {
                Task { await appState.changeEntryProject(entryId: entry.id, projectId: nil) }
            } label: {
                if entry.projectId == nil {
                    Label(L10n.noProject, systemImage: "checkmark")
                } else {
                    Text(L10n.noProject)
                }
            }
            Divider()
            ForEach(appState.projects) { project in
                Button {
                    Task { await appState.changeEntryProject(entryId: entry.id, projectId: project.id) }
                } label: {
                    if entry.projectId == project.id {
                        Label(project.name, systemImage: "checkmark")
                    } else {
                        Text(project.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let name = appState.projectName(for: entry.projectId) {
                    Circle()
                        .fill(Color(hex: appState.projectColorHex(for: entry.projectId) ?? "") ?? .gray)
                        .frame(width: 8, height: 8)
                    Text(name)
                } else {
                    Image(systemName: "folder")
                    Text(L10n.noProject)
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private var draftProjectMenu: some View {
        Menu {
            Button {
                appState.timerDraftProjectId = nil
            } label: {
                if appState.timerDraftProjectId == nil {
                    Label(L10n.noProject, systemImage: "checkmark")
                } else {
                    Text(L10n.noProject)
                }
            }
            Divider()
            ForEach(appState.projects) { project in
                Button {
                    appState.timerDraftProjectId = project.id
                } label: {
                    if appState.timerDraftProjectId == project.id {
                        Label(project.name, systemImage: "checkmark")
                    } else {
                        Text(project.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let id = appState.timerDraftProjectId,
                   let project = appState.projects.first(where: { $0.id == id }) {
                    Circle()
                        .fill(Color(hex: project.color ?? "") ?? .gray)
                        .frame(width: 8, height: 8)
                    Text(project.name)
                } else {
                    Image(systemName: "folder")
                    Text(L10n.noProject)
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
