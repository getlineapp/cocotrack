import Foundation

enum L10n {
    // MARK: - Top bar
    static let appSubtitle = NSLocalizedString("app.subtitle", bundle: .module, comment: "App subtitle in top bar")
    static let settings = NSLocalizedString("settings", bundle: .module, comment: "Settings button label")

    // MARK: - Connection pill
    static let statusConnected = NSLocalizedString("status.connected", bundle: .module, comment: "Connection status: connected")
    static let statusNeedsConnection = NSLocalizedString("status.needsConnection", bundle: .module, comment: "Connection status: needs connection")
    static let statusNotConfigured = NSLocalizedString("status.notConfigured", bundle: .module, comment: "Connection status: not configured")

    // MARK: - Timer hero
    static let timerActive = NSLocalizedString("timer.active", bundle: .module, comment: "Active timer heading")
    static let timerNew = NSLocalizedString("timer.new", bundle: .module, comment: "New timer heading")
    static let timerHint = NSLocalizedString("timer.hint", bundle: .module, comment: "Hint text when timer is not running")
    static let timerPlaceholder = NSLocalizedString("timer.placeholder", bundle: .module, comment: "Timer description placeholder")

    // MARK: - Sections
    static let favorites = NSLocalizedString("section.favorites", bundle: .module, comment: "Favorites section title")
    static let favoritesEmpty = NSLocalizedString("section.favorites.empty", bundle: .module, comment: "Favorites section empty hint")
    static let quickStart = NSLocalizedString("section.quickStart", bundle: .module, comment: "Quick start section title")
    static let quickStartEmpty = NSLocalizedString("section.quickStart.empty", bundle: .module, comment: "Quick start section empty hint")
    static let recentEntries = NSLocalizedString("section.recentEntries", bundle: .module, comment: "Recent entries section title")
    static let recentEntriesEmpty = NSLocalizedString("section.recentEntries.empty", bundle: .module, comment: "Recent entries section empty hint")

    // MARK: - Time grouping
    static let today = NSLocalizedString("time.today", bundle: .module, comment: "Today group label")
    static let yesterday = NSLocalizedString("time.yesterday", bundle: .module, comment: "Yesterday group label")
    static let thisWeek = NSLocalizedString("time.thisWeek", bundle: .module, comment: "This week group label")
    static let older = NSLocalizedString("time.older", bundle: .module, comment: "Older group label")

    // MARK: - Entry details
    static let noDescription = NSLocalizedString("entry.noDescription", bundle: .module, comment: "Placeholder for entries without description")
    static let inProgress = NSLocalizedString("entry.inProgress", bundle: .module, comment: "Label for entry still in progress")
    static let noLastUse = NSLocalizedString("entry.noLastUse", bundle: .module, comment: "Label when favorite has no last use date")
    static let edit = NSLocalizedString("entry.edit", bundle: .module, comment: "Edit menu item")

    // MARK: - Status bar
    static let statusReady = NSLocalizedString("status.ready", bundle: .module, comment: "Ready status label")
    static let autoRefresh = NSLocalizedString("status.autoRefresh", bundle: .module, comment: "Auto refresh label")

    // MARK: - Settings sheet
    static let settingsTitle = NSLocalizedString("settings.title", bundle: .module, comment: "Settings sheet title")
    static let settingsSubtitle = NSLocalizedString("settings.subtitle", bundle: .module, comment: "Settings sheet subtitle")
    static let settingsWorkspaceHint = NSLocalizedString("settings.workspaceHint", bundle: .module, comment: "Workspace ID field placeholder")
    static let settingsClose = NSLocalizedString("settings.close", bundle: .module, comment: "Close button")
    static let settingsSaveConnect = NSLocalizedString("settings.saveConnect", bundle: .module, comment: "Save and connect button")

    // MARK: - Entry edit sheet
    static let editEntryTitle = NSLocalizedString("editEntry.title", bundle: .module, comment: "Edit entry sheet title")
    static let editEntryDescription = NSLocalizedString("editEntry.description", bundle: .module, comment: "Description field label")
    static let editEntryHasEnd = NSLocalizedString("editEntry.hasEnd", bundle: .module, comment: "Toggle for end time")
    static let editEntryEnd = NSLocalizedString("editEntry.end", bundle: .module, comment: "End date label")
    static let editEntryCancel = NSLocalizedString("editEntry.cancel", bundle: .module, comment: "Cancel button")
    static let editEntrySave = NSLocalizedString("editEntry.save", bundle: .module, comment: "Save button")

    // MARK: - AppState status messages
    static let timerStarted = NSLocalizedString("appState.timerStarted", bundle: .module, comment: "Status after starting timer")
    static let timerStopped = NSLocalizedString("appState.timerStopped", bundle: .module, comment: "Status after stopping timer")
    static let dataRefreshed = NSLocalizedString("appState.dataRefreshed", bundle: .module, comment: "Status after refreshing data")
    static let entryUpdated = NSLocalizedString("appState.entryUpdated", bundle: .module, comment: "Status after updating entry")
    static let connectFirst = NSLocalizedString("appState.connectFirst", bundle: .module, comment: "Error: not connected yet")
    static let fillApiKey = NSLocalizedString("appState.fillApiKey", bundle: .module, comment: "Error: API key missing")
    static let workspaceError = NSLocalizedString("appState.workspaceError", bundle: .module, comment: "Error: workspace ID not determined")
    static let operationInProgress = NSLocalizedString("appState.operationInProgress", bundle: .module, comment: "Operation already in progress")
    static let timerAlreadyRunning = NSLocalizedString("appState.timerAlreadyRunning", bundle: .module, comment: "Error: timer already running")
    static let noRunningTimer = NSLocalizedString("appState.noRunningTimer", bundle: .module, comment: "Error: no running timer")
    static let endBeforeStart = NSLocalizedString("appState.endBeforeStart", bundle: .module, comment: "Error: entry end is before start")
    static let projectNotFound = NSLocalizedString("appState.projectNotFound", bundle: .module, comment: "Error: selected project is missing")
    static let projectNameRequired = NSLocalizedString("appState.projectNameRequired", bundle: .module, comment: "Error: project name required")

    // MARK: - Menu bar
    static let menuTimerActive = NSLocalizedString("menu.timerActive", bundle: .module, comment: "Menu bar: timer active")
    static let menuTimerStopped = NSLocalizedString("menu.timerStopped", bundle: .module, comment: "Menu bar: timer stopped")
    static let refresh = NSLocalizedString("menu.refresh", bundle: .module, comment: "Refresh button")
    static let openApp = NSLocalizedString("menu.openApp", bundle: .module, comment: "Open app button")
    static let quit = NSLocalizedString("menu.quit", bundle: .module, comment: "Quit button")

    // MARK: - Force projects
    static let projectRequired = NSLocalizedString("appState.projectRequired", bundle: .module, comment: "Error: workspace requires a project")
    static let projectRequiredForStop = NSLocalizedString("appState.projectRequiredForStop", bundle: .module, comment: "Error: assign project before stopping")
    static let projectRequiredHint = NSLocalizedString("project.requiredHint", bundle: .module, comment: "Hint: workspace requires project selection")

    // MARK: - Projects
    static let noProject = NSLocalizedString("project.none", bundle: .module, comment: "No project label")
    static let projectLabel = NSLocalizedString("project.label", bundle: .module, comment: "Project picker label")
    static let createProjectTitle = NSLocalizedString("project.create.title", bundle: .module, comment: "Create project sheet title")
    static let createProjectName = NSLocalizedString("project.create.name", bundle: .module, comment: "Project name field placeholder")
    static let createProjectColor = NSLocalizedString("project.create.color", bundle: .module, comment: "Color picker label")
    static let createProjectButton = NSLocalizedString("project.create.button", bundle: .module, comment: "Create project button")
    static let projectUpdated = NSLocalizedString("appState.projectUpdated", bundle: .module, comment: "Status after updating project")
    static let projectCreated = NSLocalizedString("appState.projectCreated", bundle: .module, comment: "Status after creating project")

    // MARK: - API errors
    static let errorInvalidBaseURL = NSLocalizedString("api.error.invalidBaseURL", bundle: .module, comment: "Invalid base URL error")
    static let errorMissingData = NSLocalizedString("api.error.missingData", bundle: .module, comment: "Missing data error")
    static let errorInvalidResponse = NSLocalizedString("api.error.invalidResponse", bundle: .module, comment: "Invalid response error")
    static let errorUnknownApi = NSLocalizedString("api.error.unknown", bundle: .module, comment: "Unknown API error")
    static let apiDecodingError = NSLocalizedString("api.error.decoding", bundle: .module, comment: "API decoding error")

    // MARK: - Interpolated strings

    static func connectedAs(_ name: String) -> String {
        String(format: NSLocalizedString("appState.connectedAs", bundle: .module, comment: "Status: connected as user"), name)
    }

    static func lastUsed(_ dateString: String) -> String {
        String(format: NSLocalizedString("entry.lastUsed", bundle: .module, comment: "Last used date for favorite"), dateString)
    }

    static func userLabel(_ name: String) -> String {
        String(format: NSLocalizedString("settings.userLabel", bundle: .module, comment: "User label in settings"), name)
    }

    static func apiError(_ code: Int, _ message: String) -> String {
        String(format: NSLocalizedString("api.error.http", bundle: .module, comment: "HTTP API error with code and message"), code, message)
    }

    static func apiNetworkError(_ message: String) -> String {
        String(format: NSLocalizedString("api.error.network", bundle: .module, comment: "Network API error"), message)
    }
}
