import AppKit
import SwiftUI

@main
struct CocotrackApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Distribution .app has Assets.car compiled by actool — NSImage(named:) works.
        // When running via `swift run`, fall back to the raw PNG from the SPM resource bundle.
        if let image = NSImage(named: "AppIcon") {
            NSApplication.shared.applicationIconImage = image
        } else if let url = Bundle.module.url(
            forResource: "icon_512x512@2x",
            withExtension: "png",
            subdirectory: "cocotrack.xcassets/AppIcon.appiconset"
        ), let image = NSImage(contentsOf: url) {
            NSApplication.shared.applicationIconImage = image
        }
    }

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
