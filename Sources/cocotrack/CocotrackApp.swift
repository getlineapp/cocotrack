import AppKit
import SwiftUI

@main
struct CocotrackApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Distribution .app gets its icon from Info.plist + Assets.car automatically —
        // macOS applies the rounded-rectangle mask. Don't override with applicationIconImage.
        // For `swift run` (no Assets.car), fall back to the raw PNG from the SPM resource bundle.
        if NSImage(named: "AppIcon") == nil,
           let url = Bundle.localized.url(
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
