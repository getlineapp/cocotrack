# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cocotrack is a macOS menu bar + window app for Clockify time tracking, published by Cocolab sp. z o.o. Built with Swift 6.2 and SwiftUI, targeting macOS 13+. It uses Swift Package Manager (no Xcode project file). The UI language is Polish by default, with English localization.

Cocotrack is an independent third-party client and is not affiliated with CAKE.com or Clockify. The app uses the public Clockify REST API with a user-supplied API key.

## Build & Run Commands

```bash
# Build (debug)
swift build

# Build (release)
swift build -c release

# Build distributable .app bundle, .zip, and .dmg (direct distribution)
./scripts/build_direct_distribution.sh

# Build Mac App Store .pkg (requires APP_SIGN_IDENTITY, INSTALLER_SIGN_IDENTITY, PROVISION_PROFILE env vars)
./scripts/build_mas.sh

# Optional for direct distribution: set SIGN_IDENTITY and NOTARIZE_PROFILE env vars for Developer ID signing + notarization
```

Tests live in `Tests/cocotrackTests/` (Swift Testing / XCTest).

## Architecture

Single-target SwiftUI app with no external dependencies.

**State management:** `AppState` is an `@MainActor ObservableObject` shared via `@EnvironmentObject` to both the main window (`ContentView`) and the menu bar popover (`MenuBarView`). It owns all Clockify API interaction, timer state, and user settings.

**API layer:** `ClockifyAPIClient` is a stateless struct wrapping URLSession. It communicates with the Clockify REST API v1 (`https://api.clockify.me/api/v1`) using the `X-Api-Key` header. Custom ISO 8601 date coding lives in `Formatters.swift` (handles both fractional and non-fractional seconds from the API).

**Key data flow:**
- `AppState.connectAndRefresh()` authenticates and loads initial data
- Running timer is polled from the API; elapsed time updates locally every 1s via `elapsedTask`
- Auto-refresh fetches entries every 30s via `autoRefreshTask`
- Settings (API key, base URL, workspace override, favorites) persist in `UserDefaults`

**UI structure (all in ContentView.swift):**
- `ContentView` — main window with timer hero, favorites, quick-start templates, recent entries grouped by day
- `SettingsSheet` — API configuration modal with non-affiliation disclaimer
- `EntryEditSheet` — edit time entry description/dates
- `MenuBarView` — compact menu bar popover for start/stop

**Models:** `ClockifyModels.swift` contains all Codable request/response types. Internal type names keep the `Clockify*` prefix — these refer to the external API, not the Cocotrack brand.

## Conventions

- Swift concurrency (`async/await`, structured concurrency with `async let`) throughout — no Combine
- Error messages and UI strings are in Polish by default, English via localization
- The app entry point is `CocotrackApp.swift` (`@main struct CocotrackApp`)
- Design system lives in `DesignSystem.swift` — warm-neutral palette with terracotta accent (`#D27B4D` / dark `#EB9067`)
- BG colors: `#FBF9F5` (light) / `#2A2620` (dark)
- Bundle identifier: `com.cocolab.cocotrack`
- GitHub: `getlineapp/cocotrack`

## Branding guardrails

- User-visible strings must refer to the product as "Cocotrack", never "Clockify"
- "Clockify" may only appear in: (a) the API endpoint URL, (b) helper/error text that tells the user which external service they are connecting to (nominative fair use), (c) the non-affiliation disclaimer in Settings
- Never include Clockify logos, Clockify brand colors, or anything that imitates CAKE.com/Clockify branding in icons, screenshots, or marketing copy
