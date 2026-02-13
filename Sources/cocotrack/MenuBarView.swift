import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(appState.isTracking ? "Timer aktywny" : "Timer zatrzymany")
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
                TextField("Opis", text: $appState.timerDraftDescription)
                    .textFieldStyle(.roundedBorder)

                Button("Start") {
                    Task { await appState.startTimer() }
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            HStack {
                Button("Odswiez") {
                    Task { await appState.refreshEntries() }
                }

                Button("Otworz app") {
                    openWindow(id: "main")
                }

                Spacer()

                Button("Wyjdz") {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(12)
        .frame(minWidth: 320)
    }
}
