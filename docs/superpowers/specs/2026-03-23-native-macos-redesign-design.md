# Cocotrack — Native macOS Redesign

## Problem

The current UI looks like a web app ported to macOS: dark gradient timer blob, orange accent buttons, excessive sections (favorites + quick start + recent entries), and too much visual weight. For a power user who opens the window briefly to start/stop/edit and then closes it, the interface needs to be fast, calm, and native-feeling.

## Design Decisions

### User profile
- Long work sessions, 2-3 project switches per day
- Window opened on-demand (start/stop/edit), then closed — menu bar for monitoring
- Favorites and quick start templates used interchangeably — should be one list
- Recent entries list not needed in main view (Clockify web for browsing)

### Visual direction
- **Native macOS** — system background color, semantic cards, system separators
- **Supports system dark/light mode** — no `.preferredColorScheme` override. All colors use semantic NSColor values that adapt automatically.
- **Inspired by Linear/Things** — clean typography, generous spacing, subtle borders
- **Timer in a card** with subtle shadow (uses `Color(.controlBackgroundColor)` — white in light mode, dark gray in dark mode)
- **System accent color** (`.accentColor`) for primary actions — respects user's system accent color preference
- **Red only for Stop** — ghost-style button (border + light fill, not solid)
- **No hardcoded colors** for backgrounds — use SwiftUI semantic colors

## Architecture

### Layout structure (ContentView)

```
Window (minWidth: 480, minHeight: 400, maxWidth: 600)
├── Toolbar bar (compact)
│   ├── Connection dot + "Cocotrack" + user name
│   └── Refresh button + Settings button (icon-only, .bordered)
│
├── Timer Card (semantic card bg, rounded, shadow)
│   ├── [tracking] Status label "Aktywny timer" with green dot
│   ├── [tracking] Description (15pt semibold)
│   ├── [tracking] Project pill (clickable, picker)
│   ├── [tracking] Elapsed time (32pt tabular nums) + Stop ghost button
│   │
│   ├── [idle] Label "Nowy timer"
│   ├── [idle] TextField + Start button (inline HStack)
│   ├── [idle] Project picker pill + Create Project button (plus icon)
│   │
│   ├── [not connected] Disabled state — show "Skonfiguruj połączenie" prompt
│   └── [not connected] Settings button inline to open configuration
│
├── Separator
│
├── Quick Start list (merged favorites + recent templates)
│   ├── Section header "Szybki start" (.caption.weight(.semibold), .textCase(.uppercase), .secondary)
│   └── Rows: [star toggle] [description] [project dot + name] [▶ Start]
│       - Favorites (★ yellow, filled) sorted by lastUsed, then
│         recent templates (☆ gray, outline) — deduped against favorites
│       - Combined list capped at 10 items
│       - Empty descriptions filtered out (same as current quickStartTemplates)
│       - Tapping ★/☆ toggles favorite status
│       - Hover highlight: `.onHover` + conditional background `Color(.quaternaryLabelColor)`
│       - Single click on row or ▶ starts timer
│
└── Status bar
    ├── Left: statusMessage (same as current AppState.statusMessage) + spinner when loading
    └── Right: "Odświeżanie co 30s" label
```

### Connection states in toolbar
- **Connected**: green dot, "Cocotrack · {userName}"
- **Configured but not connected**: orange dot, "Cocotrack · Łączenie..."
- **Not configured**: gray dot, "Cocotrack"

When not connected, the timer card shows a disabled state with a prompt to open settings.

### Sheets — accent color update
All three sheets (`SettingsSheet`, `EntryEditSheet`, `CreateProjectSheet`) remain in `ContentView.swift` but their `.tint(Color(red: 1.0, green: 0.39, blue: 0.29))` is replaced with `.tint(.accentColor)` for consistency. No layout changes to sheets.

### Entry editing
`EntryEditSheet` and the `editingEntry` state remain. The edit trigger moves from the removed `RecentEntryRow` to a **context menu on `QuickStartRow`**: right-click → "Edytuj ostatni wpis" looks up the most recent entry matching that description and opens the edit sheet. The `.sheet(item: $editingEntry)` modifier stays on the window.

### What gets removed
1. **`timerHero` dark gradient block** — replaced by semantic card
2. **`favoritesSection`** — merged into unified quick start
3. **`quickStartSection`** — merged into unified quick start
4. **`recentEntriesSection`** — removed entirely
5. **`groupedRecentEntries` computed property** — removed
6. **`RecentEntrySection` struct** — removed
7. **`SectionShell` wrapper** — removed (not needed with flat layout)
8. **Large "Cocotrack" title (34px)** — replaced by compact toolbar
9. **`connectionPill`** — replaced by dot in toolbar
10. **Orange accent color** — replaced by `.accentColor`
11. **`FavoriteRow`** — replaced by `QuickStartRow`
12. **`QuickStartMinimalRow`** — replaced by `QuickStartRow`
13. **`RecentEntryRow`** — removed (no recent entries section)
14. **`ProjectPickerMenu.onDarkBackground` parameter** — always false now, remove parameter

### What gets added/changed
1. **Compact toolbar** — connection dot, app name, user, icon buttons
2. **Timer card** — `Color(.controlBackgroundColor)`, 1px `Color(.separatorColor)` border, subtle shadow, two states (tracking/idle) + disabled state when not connected
3. **Ghost Stop button** — `.buttonStyle(.bordered)` + `.tint(.red)` instead of solid `.borderedProminent`
4. **Unified `QuickStartRow`** — handles both favorites and templates, with star toggle and context menu
5. **System colors throughout** — `Color(.windowBackgroundColor)`, `.accentColor`, `Color(.separatorColor)`, `Color(.controlBackgroundColor)`
6. **Hover states** on quick start rows using `.onHover` + conditional background
7. **Inline new timer input** — TextField + Start button + project picker, all inside the card
8. **Create Project button** — small `+` icon next to project picker in idle state (preserves existing functionality)

### Color mapping (old → new)

| Element | Old | New |
|---------|-----|-----|
| Window background | `Color(red: 0.95, green: 0.96, blue: 0.98)` | `Color(.windowBackgroundColor)` |
| Timer background | Dark gradient | `Color(.controlBackgroundColor)` + border |
| Primary action | `Color(red: 1.0, green: 0.39, blue: 0.29)` | `.accentColor` |
| Stop button | Solid orange `.borderedProminent` | `.buttonStyle(.bordered)` + `.tint(.red)` |
| Separators | `Color.black.opacity(0.06)` | `Color(.separatorColor)` |
| Cards | `Color.white` hardcoded | `Color(.controlBackgroundColor)` |
| Section headers | `.headline` | `.caption.weight(.semibold)` + `.textCase(.uppercase)` + `.secondary` |
| Sheet buttons | `.tint(Color(red: 1.0, green: 0.39, blue: 0.29))` | `.tint(.accentColor)` |

### Typography mapping (old → new)

| Element | Old | New |
|---------|-----|-----|
| App title | `.system(size: 34, weight: .bold, design: .rounded)` | `.system(size: 13, weight: .semibold)` (in toolbar) |
| Timer description | `.system(size: 30, weight: .semibold, design: .rounded)` | `.system(size: 15, weight: .semibold)` |
| Elapsed time | `.system(size: 54, weight: .black, design: .monospaced)` | `.system(size: 32, weight: .bold, design: .monospaced)` + `.monospacedDigit()` |
| Section headers | `.headline` | `.caption.weight(.semibold)` |

### Merged quick start logic (`AppState.quickStartItems`)

Replaces both `favoriteTemplates` and `quickStartTemplates`:

1. Collect favorites sorted by `lastUsed` descending (same as current `favoriteTemplates`)
2. Collect recent unique templates (same as current `quickStartTemplates` logic — deduped, non-empty descriptions)
3. Remove from recent templates any that already appear in favorites (dedup by normalized description)
4. Concatenate: favorites first, then remaining recent templates
5. Cap at 10 items total
6. Each item carries `isFavorite: Bool` for the row to display ★ vs ☆

### L10n keys — cleanup

**Remove (unused after redesign):**
- `favorites`, `favoritesEmpty`, `quickStartEmpty`
- `recentEntries`, `recentEntriesEmpty`
- `today`, `yesterday`, `thisWeek`, `older`
- `noLastUse`, `timerHint`
- `lastUsed(_:)` function

**Keep as-is:**
- `quickStart` (reused for section header)
- All timer, settings, edit, project, status, menu, API error keys

**Add:**
- `configureConnection` — prompt shown in timer card when not connected

### Files changed
- **`ContentView.swift`** — full rewrite of layout; remove old section views and row structs; add new toolbar, timer card, QuickStartRow; update sheets' tint; remove `onDarkBackground` from `ProjectPickerMenu`
- **`AppState.swift`** — add `quickStartItems` computed property; keep `favoriteTemplates` and `quickStartTemplates` as private (or remove if unused)
- **`L10n.swift`** — remove unused keys, add `configureConnection`

### Files not changed
- `ClockifyModels.swift`, `ClockifyAPIClient.swift`, `MenuBarView.swift`, `CocotrackApp.swift`, `Formatters.swift`

## Window sizing
- `minWidth: 480` (was 540)
- `minHeight: 400` (was 700)
- `idealWidth: 520` (was 580)
- `maxWidth: 600` (preserved from current inner content frame)
