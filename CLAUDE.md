# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cocotrack is a macOS menu bar + window app for Clockify time tracking. Built with Swift 6.2 and SwiftUI, targeting macOS 13+. It uses Swift Package Manager (no Xcode project file). The UI language is Polish.

## Build & Run Commands

```bash
# Build (debug)
swift build

# Build (release)
swift build -c release

# Build distributable .app bundle, .zip, and .dmg
./scripts/build_direct_distribution.sh

# Optional: set SIGN_IDENTITY and NOTARIZE_PROFILE env vars for code signing/notarization
```

There are no tests configured yet.

## Architecture

Single-target SwiftUI app with no external dependencies.

**State management:** `AppState` is an `@MainActor ObservableObject` shared via `@EnvironmentObject` to both the main window (`ContentView`) and the menu bar popover (`MenuBarView`). It owns all Clockify API interaction, timer state, and user settings.

**API layer:** `ClockifyAPIClient` is a stateless struct wrapping URLSession. It communicates with the Clockify REST API v1 using the `X-Api-Key` header. Custom ISO 8601 date coding lives in `Formatters.swift` (handles both fractional and non-fractional seconds from the API).

**Key data flow:**
- `AppState.connectAndRefresh()` authenticates and loads initial data
- Running timer is polled from the API; elapsed time updates locally every 1s via `elapsedTask`
- Auto-refresh fetches entries every 30s via `autoRefreshTask`
- Settings (API key, base URL, workspace override, favorites) persist in `UserDefaults`

**UI structure (all in ContentView.swift):**
- `ContentView` — main window with timer hero, favorites, quick-start templates, recent entries grouped by day
- `SettingsSheet` — API configuration modal
- `EntryEditSheet` — edit time entry description/dates
- `MenuBarView` — compact menu bar popover for start/stop

**Models:** `ClockifyModels.swift` contains all Codable request/response types.

## Conventions

- Swift concurrency (`async/await`, structured concurrency with `async let`) throughout — no Combine
- Error messages and UI strings are in Polish
- The app entry point is `CocotrackApp.swift` (`@main`)
- Accent color: `Color(red: 1.0, green: 0.39, blue: 0.29)` (Clockify orange-red)
- Background dark gradient: `Color(red: 0.11, green: 0.15, blue: 0.23)` to `Color(red: 0.16, green: 0.23, blue: 0.34)`
