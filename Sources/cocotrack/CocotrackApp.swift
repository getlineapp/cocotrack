import AppKit
import SwiftUI

@main
struct CocotrackApp: App {
    @StateObject private var appState = AppState()

    init() {
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
