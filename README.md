# Cocotrack

A lightweight macOS menu bar app for [Clockify](https://clockify.me) time tracking. Start, stop, and manage timers without leaving your workflow.

## Features

- **Menu bar timer** — see your running timer and elapsed time right in the macOS menu bar
- **One-click start/stop** — start tracking from the menu bar popover or the main window
- **Quick start templates** — reuse descriptions from your recent time entries
- **Favorites** — pin frequently used timer descriptions for instant access
- **Entry editing** — edit descriptions and timestamps of existing entries
- **Auto-refresh** — entries sync from Clockify every 30 seconds
- **Zero dependencies** — pure Swift + SwiftUI, no third-party libraries

## Requirements

- macOS 13.0 (Ventura) or later
- A [Clockify](https://clockify.me) account and API key

## Installation

### Download

Grab the latest `.dmg` or `.zip` from the [Releases](../../releases) page.

### Build from source

```bash
# Clone the repository
git clone https://github.com/getlineapp/cocotrack.git
cd cocotrack

# Build and run
swift build
swift run

# Or build a distributable .app bundle
./scripts/build_direct_distribution.sh
```

The build script produces `dist/Cocotrack.app`, a `.zip`, and a `.dmg`. Set `SIGN_IDENTITY` and `NOTARIZE_PROFILE` environment variables for code signing and notarization.

## Setup

1. Launch Cocotrack
2. Open **Settings** (gear icon)
3. Paste your Clockify API key — get one at [clockify.me/user/settings](https://clockify.me/user/settings)
4. Click **Save & Connect**

The app uses your default Clockify workspace. To use a different one, enter its workspace ID in Settings.

## Architecture

```
Sources/cocotrack/
├── CocotrackApp.swift      # App entry point, window + menu bar scenes
├── AppState.swift           # Central state: API calls, timer, settings
├── ClockifyAPIClient.swift  # Stateless REST client for Clockify API v1
├── ClockifyModels.swift     # Codable request/response types
├── Formatters.swift         # ISO 8601 date coding, display formatters
├── ContentView.swift        # Main window UI (timer, favorites, history)
└── MenuBarView.swift        # Menu bar popover UI
```

The app is built with Swift concurrency (`async/await`) and SwiftUI. `AppState` is the single source of truth, shared to both UI surfaces via `@EnvironmentObject`. No Combine, no external frameworks.

## License

MIT License — see [LICENSE](LICENSE) for details.
