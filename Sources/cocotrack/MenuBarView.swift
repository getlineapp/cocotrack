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
                Text(appState.elapsedText)
                    .font(.system(.title3, design: .monospaced).weight(.semibold))

                Button("Stop") {
                    Task { await appState.stopTimer() }
                }
                .buttonStyle(.borderedProminent)
            } else {
                TextField(L10n.editEntryDescription, text: $appState.timerDraftDescription)
                    .textFieldStyle(.roundedBorder)

                Button("Start") {
                    Task { await appState.startTimer() }
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            HStack {
                Button(L10n.refresh) {
                    Task { await appState.refreshEntries() }
                }

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
}
