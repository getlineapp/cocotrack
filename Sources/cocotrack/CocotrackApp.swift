import SwiftUI

@main
struct CocotrackApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(appState)
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Text(appState.menuBarTitle)
        }
        .menuBarExtraStyle(.window)
    }
}
