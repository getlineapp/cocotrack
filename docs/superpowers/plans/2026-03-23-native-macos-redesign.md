# Native macOS Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the web-app-looking UI with a native macOS aesthetic — system colors, compact toolbar, merged quick start list, no recent entries section.

**Architecture:** Single-file UI rewrite of `ContentView.swift` (layout, row structs, sheets tint), a new computed property in `AppState.swift`, and L10n key cleanup. No API, model, or menu bar changes.

**Tech Stack:** Swift 6.2, SwiftUI (macOS 13+), semantic NSColor bridging

**Spec:** `docs/superpowers/specs/2026-03-23-native-macos-redesign-design.md`

---

### Task 1: Add `quickStartItems` to AppState

**Files:**
- Modify: `Sources/cocotrack/AppState.swift` (add computed property + supporting struct around line 85-133)

- [ ] **Step 1: Add `QuickStartItem` struct and `quickStartItems` computed property**

Add after the existing `QuickStartTemplate` struct (around line 13):

```swift
struct QuickStartItem: Identifiable {
    let description: String
    let lastUsed: Date
    let projectId: String?
    let isFavorite: Bool

    var id: String { description }
}
```

Add to `AppState` class, after the existing `favoriteTemplates` computed property (around line 133):

```swift
var quickStartItems: [QuickStartItem] {
    // 1. Favorites sorted by lastUsed descending
    let favItems = favoriteTemplates.map { template in
        QuickStartItem(
            description: template.description,
            lastUsed: template.lastUsed,
            projectId: template.projectId,
            isFavorite: true
        )
    }

    // 2. Recent unique templates, deduped against favorites
    let favDescriptions = Set(favItems.map { $0.description.lowercased() })
    let recentItems = quickStartTemplates
        .filter { !favDescriptions.contains($0.description.lowercased()) }
        .map { template in
            QuickStartItem(
                description: template.description,
                lastUsed: template.lastUsed,
                projectId: template.projectId,
                isFavorite: false
            )
        }

    // 3. Concatenate and cap at 10
    return Array((favItems + recentItems).prefix(10))
}
```

- [ ] **Step 2: Build and verify**

Run: `swift build 2>&1 | tail -5`
Expected: Build Succeeded

- [ ] **Step 3: Commit**

```bash
git add Sources/cocotrack/AppState.swift
git commit -m "Add quickStartItems merging favorites and recent templates"
```

---

### Task 2: Update L10n keys

**Files:**
- Modify: `Sources/cocotrack/L10n.swift`
- Modify: `Sources/cocotrack/Resources/pl.lproj/Localizable.strings`
- Modify: `Sources/cocotrack/Resources/en.lproj/Localizable.strings`

- [ ] **Step 1: Add `configureConnection` and `editLastEntry` keys to L10n.swift**

Add in the "Timer hero" section (after line 17):

```swift
static let configureConnection = NSLocalizedString("timer.configureConnection", bundle: .module, comment: "Prompt to configure connection")
static let editLastEntry = NSLocalizedString("entry.editLast", bundle: .module, comment: "Context menu: edit last entry")
```

- [ ] **Step 2: Remove unused keys from L10n.swift**

Remove these lines:
- `static let favorites` (line ~20)
- `static let favoritesEmpty` (line ~21)
- `static let recentEntries` (line ~24)
- `static let recentEntriesEmpty` (line ~25)
- `static let today` (line ~28)
- `static let yesterday` (line ~29)
- `static let thisWeek` (line ~30)
- `static let older` (line ~31)
- `static let noLastUse` (line ~36)
- `static let timerHint` (line ~16)
- `static let appSubtitle` (line ~6)
- `static func lastUsed` (line ~108-110)

Keep: `quickStart`, `quickStartEmpty` (both reused in new layout)

- [ ] **Step 3: Add new keys to pl.lproj/Localizable.strings**

Add in the Timer hero section:
```
"timer.configureConnection" = "Skonfiguruj polaczenie z Clockify";
"entry.editLast" = "Edytuj ostatni wpis";
```

Remove the unused keys matching L10n removals:
- `app.subtitle`
- `section.favorites`, `section.favorites.empty`
- `section.recentEntries`, `section.recentEntries.empty`
- `time.today`, `time.yesterday`, `time.thisWeek`, `time.older`
- `entry.noLastUse`, `entry.lastUsed`
- `timer.hint`

Keep: `section.quickStart`, `section.quickStart.empty` (both reused)

- [ ] **Step 4: Add new keys to en.lproj/Localizable.strings**

Add:
```
"timer.configureConnection" = "Configure Clockify connection";
"entry.editLast" = "Edit last entry";
```

Remove same unused keys as pl.lproj (keep `section.quickStart` and `section.quickStart.empty`).

- [ ] **Step 5: Build and verify**

Run: `swift build 2>&1 | tail -5`
Expected: Build Succeeded (with warnings about unused L10n properties — will resolve when ContentView is rewritten)

- [ ] **Step 6: Commit**

```bash
git add Sources/cocotrack/L10n.swift Sources/cocotrack/Resources/pl.lproj/Localizable.strings Sources/cocotrack/Resources/en.lproj/Localizable.strings
git commit -m "Update L10n keys for native redesign"
```

---

### Task 3: Rewrite ContentView — full layout replacement

**Files:**
- Modify: `Sources/cocotrack/ContentView.swift` (replace body, topBar, connectionPill, timerHero, runningProjectPicker, favoritesSection, quickStartSection, recentEntriesSection, statusSection, and all old row structs)

This task replaces the entire ContentView layout in one pass: toolbar, timer card, quick start list, status bar, and all supporting row structs. Done atomically so the body can reference all new views without intermediate broken states.

- [ ] **Step 1: Replace the body and topBar**

Replace the `body` computed property (lines 12-52) with:

```swift
var body: some View {
    ZStack {
        Color(.windowBackgroundColor)
            .ignoresSafeArea()

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                toolbar
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                timerCard
                    .padding(.horizontal, 18)

                Divider()
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)

                quickStartSection
                    .padding(.horizontal, 18)

                Spacer(minLength: 12)

                statusBar
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)
            }
        }
    }
    .frame(minWidth: 480, idealWidth: 520, maxWidth: 600, minHeight: 400)
    .sheet(item: $editingEntry) { entry in
        EntryEditSheet(entry: entry) { description, start, end, projectId in
            await appState.saveEntryEdits(
                entryId: entry.id,
                description: description,
                start: start,
                end: end,
                projectId: projectId
            )
        }
        .environmentObject(appState)
    }
    .sheet(isPresented: $showSettings) {
        SettingsSheet()
            .environmentObject(appState)
    }
    .sheet(isPresented: $showCreateProject) {
        CreateProjectSheet()
            .environmentObject(appState)
    }
}
```

- [ ] **Step 2: Replace topBar and connectionPill with compact toolbar**

Delete `topBar` (lines 54-85) and `connectionPill` (lines 87-103). Replace with:

```swift
private var toolbar: some View {
    HStack(alignment: .center) {
        HStack(spacing: 8) {
            Circle()
                .fill(appState.isConnected ? Color.green : (appState.isConfigured ? Color.orange : Color.gray))
                .frame(width: 8, height: 8)

            Text("Cocotrack")
                .font(.system(size: 13, weight: .semibold))

            if !appState.userName.isEmpty {
                Text("· \(appState.userName)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }

        Spacer()

        Button {
            Task { await appState.refreshEntries() }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .disabled(appState.isLoading || !appState.isConnected)

        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}
```

- [ ] **Step 3: Replace timerHero and runningProjectPicker with timerCard**

Delete `timerHero` (lines 105-235) and `runningProjectPicker` (lines 237-249). Replace with:

```swift
private var timerCard: some View {
    VStack(alignment: .leading, spacing: 12) {
        if !appState.isConnected {
            // Not connected state
            VStack(spacing: 10) {
                Text(L10n.configureConnection)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button(L10n.settings) {
                    showSettings = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } else if appState.isTracking {
            // Tracking state
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text(L10n.timerActive)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }

            Text(appState.runningDescription)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(2)

            if let entry = appState.runningEntry {
                ProjectPickerMenu(
                    projects: appState.projects,
                    selectedProjectId: entry.projectId,
                    onSelect: { newId in
                        Task { await appState.changeEntryProject(entryId: entry.id, projectId: newId) }
                    }
                )
            }

            if appState.forceProjects && appState.runningEntry?.projectId == nil {
                Text(L10n.projectRequiredForStop)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
            }

            HStack {
                Text(appState.elapsedText)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .monospacedDigit()

                Spacer()

                Button {
                    Task { await appState.stopTimer() }
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.regular)
                .disabled(!appState.canStopTimer)
            }
        } else {
            // Idle state
            Text(L10n.timerNew)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField(L10n.timerPlaceholder, text: $customDescription)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task {
                        let started = await appState.startTimer(using: customDescription, projectId: selectedProjectId)
                        if started {
                            customDescription = ""
                            selectedProjectId = nil
                        }
                    }
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(!appState.canStartTimer || (appState.forceProjects && selectedProjectId == nil))
            }

            HStack(spacing: 8) {
                ProjectPickerMenu(
                    projects: appState.projects,
                    selectedProjectId: selectedProjectId,
                    onSelect: { selectedProjectId = $0 }
                )

                if appState.forceProjects && selectedProjectId == nil {
                    Text(L10n.projectRequiredHint)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Spacer()

                Button {
                    showCreateProject = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.body)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }
    .padding(16)
    .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Color(.separatorColor), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
}
```

- [ ] **Step 4: Replace all section views with `quickStartSection` and `statusBar`**

Delete `favoritesSection`, `quickStartSection` (old version), `recentEntriesSection`, `groupedRecentEntries`, `normalizedDescription(for:)`, and `statusSection`. Replace with:

```swift
private var quickStartSection: some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(L10n.quickStart)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)

        if appState.quickStartItems.isEmpty {
            Text(L10n.quickStartEmpty)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else {
            VStack(spacing: 2) {
                ForEach(appState.quickStartItems) { item in
                    QuickStartRow(
                        item: item,
                        projectName: appState.projectName(for: item.projectId),
                        projectColorHex: appState.projectColorHex(for: item.projectId),
                        onToggleFavorite: {
                            appState.toggleFavorite(description: item.description)
                        },
                        onStart: {
                            Task { await appState.startTimer(using: item.description, projectId: item.projectId) }
                        },
                        onEditLastEntry: {
                            if let entry = appState.recentEntries.first(where: {
                                ($0.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == item.description
                            }) {
                                editingEntry = entry
                            }
                        },
                        isStartDisabled: !appState.canStartTimer || (appState.forceProjects && item.projectId == nil)
                    )
                }
            }
        }
    }
}

private var statusBar: some View {
    HStack(spacing: 10) {
        if appState.isLoading {
            ProgressView()
                .controlSize(.small)
        }

        Text(appState.statusMessage.isEmpty ? L10n.statusReady : appState.statusMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)

        Spacer()

        Text(L10n.autoRefresh)
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
}
```

- [ ] **Step 5: Delete old row structs and supporting types**

Delete these structs from ContentView.swift:
- `RecentEntrySection`
- `SectionShell`
- `FavoriteRow`
- `QuickStartMinimalRow`
- `RecentEntryRow`

- [ ] **Step 6: Add `QuickStartRow` struct**

Add in the `// MARK: - Supporting types` section:

```swift
private struct QuickStartRow: View {
    let item: QuickStartItem
    let projectName: String?
    let projectColorHex: String?
    let onToggleFavorite: () -> Void
    let onStart: () -> Void
    let onEditLastEntry: () -> Void
    let isStartDisabled: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(item.isFavorite ? .yellow : Color(.tertiaryLabelColor))
            }
            .buttonStyle(.plain)

            Text(item.description)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            if let projectName {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: projectColorHex ?? "") ?? .gray)
                        .frame(width: 6, height: 6)
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                onStart()
            } label: {
                Text("Start")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isStartDisabled)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color(.quaternaryLabelColor) : .clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button(L10n.editLastEntry) {
                onEditLastEntry()
            }
        }
    }
}
```

- [ ] **Step 7: Build and verify**

Run: `swift build 2>&1 | tail -10`
Expected: Build Succeeded

- [ ] **Step 8: Commit**

```bash
git add Sources/cocotrack/ContentView.swift
git commit -m "Rewrite ContentView with native macOS design"
```

---

### Task 4: Update ProjectPickerMenu and sheets

**Files:**
- Modify: `Sources/cocotrack/ContentView.swift` (ProjectPickerMenu, SettingsSheet, EntryEditSheet, CreateProjectSheet)

- [ ] **Step 1: Remove `onDarkBackground` from ProjectPickerMenu**

In the `ProjectPickerMenu` struct, remove:
- The `var onDarkBackground: Bool = false` property
- All `onDarkBackground ? ... : ...` ternary expressions — replace with the light-mode branch (the `nil` or non-dark variant)

The capsule background becomes: `Color(.quaternaryLabelColor)` (replacing both the dark and light variants).

Updated `body`:

```swift
var body: some View {
    Menu {
        Button {
            onSelect(nil)
        } label: {
            if selectedProjectId == nil {
                Label(L10n.noProject, systemImage: "checkmark")
            } else {
                Text(L10n.noProject)
            }
        }
        Divider()
        ForEach(projects) { project in
            Button {
                onSelect(project.id)
            } label: {
                if selectedProjectId == project.id {
                    Label(project.name, systemImage: "checkmark")
                } else {
                    Text(project.name)
                }
            }
        }
    } label: {
        HStack(spacing: 6) {
            if let id = selectedProjectId,
               let project = projects.first(where: { $0.id == id }) {
                Circle()
                    .fill(Color(hex: project.color ?? "") ?? .gray)
                    .frame(width: 7, height: 7)
                Text(project.name)
                    .font(.caption.weight(.medium))
            } else {
                Image(systemName: "folder")
                    .font(.caption)
                Text(L10n.noProject)
                    .font(.caption.weight(.medium))
            }
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.quaternaryLabelColor), in: Capsule())
    }
    .menuStyle(.borderlessButton)
    .fixedSize()
}
```

- [ ] **Step 2: Update sheet tints**

In `SettingsSheet`, `EntryEditSheet`, and `CreateProjectSheet`, replace all instances of:
```swift
.tint(Color(red: 1.0, green: 0.39, blue: 0.29))
```
with:
```swift
.tint(.accentColor)
```

There are 3 occurrences (one per sheet). The old settings button tint (`Color(red: 0.13, green: 0.27, blue: 0.48)`) was in the deleted `topBar` and no longer exists.

- [ ] **Step 3: Build and verify**

Run: `swift build 2>&1 | tail -10`
Expected: Build Succeeded

- [ ] **Step 4: Commit**

```bash
git add Sources/cocotrack/ContentView.swift
git commit -m "Remove onDarkBackground and switch sheets to system accent color"
```

---

### Task 5: Final build verification and cleanup

**Files:**
- All modified files

- [ ] **Step 1: Full clean build**

Run: `swift build 2>&1`
Expected: Build Succeeded with no errors. Warnings about unused `appSubtitle` L10n key are acceptable (it was removed from the toolbar but may still be referenced — check and remove if so).

- [ ] **Step 2: Check for remaining references to removed L10n keys**

Grep for any remaining usage of removed keys in Swift files:
- `L10n.favorites` (not `L10n.favoriteDescriptions` or `favoriteTemplates`)
- `L10n.favoritesEmpty`
- `L10n.recentEntries`
- `L10n.recentEntriesEmpty`
- `L10n.today`, `L10n.yesterday`, `L10n.thisWeek`, `L10n.older`
- `L10n.noLastUse`
- `L10n.lastUsed`
- `L10n.timerHint`
- `L10n.quickStartEmpty`
- `L10n.appSubtitle`

Fix any remaining references.

- [ ] **Step 3: Check for old hardcoded colors**

Grep ContentView.swift for:
- `Color(red:` — should be zero occurrences
- `Color.white` — should be zero occurrences (replaced by semantic colors)
- `opacity(0.` — verify any remaining are intentional (shadow opacity is OK)

- [ ] **Step 4: Verify window sizing**

Confirm the `.frame()` modifier on body uses:
```swift
.frame(minWidth: 480, idealWidth: 520, maxWidth: 600, minHeight: 400)
```

- [ ] **Step 5: Build release**

Run: `swift build -c release 2>&1 | tail -10`
Expected: Build Succeeded

- [ ] **Step 6: Commit any cleanup**

```bash
git add -A
git commit -m "Final cleanup: remove stale references and verify native redesign"
```
