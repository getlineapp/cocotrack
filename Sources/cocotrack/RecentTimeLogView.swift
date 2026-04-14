import SwiftUI

struct RecentTimeLogSection: View {
    @EnvironmentObject private var appState: AppState
    let onEditEntry: (ClockifyTimeEntry) -> Void

    var body: some View {
        if appState.recentEntryGroups.isEmpty {
            Text(L10n.recentLogEmpty)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(appState.recentEntryGroups) { group in
                    VStack(alignment: .leading, spacing: 6) {
                        DayGroupHeader(label: group.label, totalSeconds: group.totalSeconds)

                        ForEach(group.entries) { entry in
                            TimeEntryRow(
                                entry: entry,
                                projectName: appState.projectName(for: entry.projectId),
                                projectColorHex: appState.projectColorHex(for: entry.projectId),
                                isRunning: entry.timeInterval.end == nil,
                                onEdit: { onEditEntry(entry) },
                                onStart: {
                                    Task {
                                        await appState.startTimer(
                                            using: entry.description ?? "",
                                            projectId: entry.projectId
                                        )
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Day group header

private struct DayGroupHeader: View {
    let label: String
    let totalSeconds: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack { Divider() }

            Text(totalSeconds.formattedDuration)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 2)
    }
}

// MARK: - Time entry row

private struct TimeEntryRow: View {
    let entry: ClockifyTimeEntry
    let projectName: String?
    let projectColorHex: String?
    let isRunning: Bool
    let onEdit: () -> Void
    let onStart: () -> Void

    @State private var isHovered = false

    private var descriptionText: String {
        let raw = entry.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? L10n.noDescription : raw
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(hex: projectColorHex ?? "") ?? Color(.separatorColor))
                .frame(width: 3, height: 36)
                .padding(.trailing, 10)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(descriptionText)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if let projectName {
                        Text(projectName)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    if projectName != nil {
                        Text("·")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }

                    Text(entry.timeRangeText)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Duration
            if isRunning {
                Text(L10n.inProgress)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.green)
            } else if let seconds = entry.durationSeconds {
                Text(seconds.formattedDuration)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color(.quaternaryLabelColor) : .clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onEdit()
        }
        .contextMenu {
            Button(L10n.edit) {
                onEdit()
            }
            Button("Start") {
                onStart()
            }
        }
    }
}
