// TARGET: TaskWidgetExtension (Widget Extension)
// Minimum deployment target: iOS 17 (required for Button(intent:) in widgets)

import SwiftUI
import WidgetKit
import AppIntents

/// Lock Screen widget UI — `.accessoryRectangular` only.
///
/// Layout:
///   Top row  : [📁 Note title ──────────] [⟫ cycle button]
///   Divider
///   Bottom row: [○ Top task title ────────────────────────]
///
/// Tapping the note title area opens the app (via Link/widgetURL).
/// Tapping the cycle chevron fires CycleNoteIntent (no app launch).
/// Tapping the task row fires CompleteTaskIntent (no app launch).
/// Long-press is reserved by iOS for the Lock Screen editor — not interceptable.
struct TaskWidgetView: View {

    let entry: TaskWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            noteRow
            Divider()
            taskRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Note row

    /// The note title is a Link — tapping it deep-links directly into that note.
    /// The cycle chevron is a separate intent Button — fires without opening the app.
    private var noteRow: some View {
        HStack(spacing: 0) {

            // Left: tap → open app at the active note
            Link(destination: entry.noteLaunchURL) {
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .font(.caption2.bold())
                    Text(entry.noteTitle)
                        .font(.caption.bold())
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
            }
            .foregroundStyle(.primary)

            Spacer(minLength: 4)

            // Right: tap → cycle to next note (no app launch)
            Button(intent: CycleNoteIntent()) {
                Image(systemName: "chevron.right.2")
                    .font(.caption2)
                    .padding(.leading, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Task row (Complete intent or empty state)

    @ViewBuilder
    private var taskRow: some View {
        if let taskTitle = entry.topTaskTitle,
           let taskID = entry.topTaskIDString {
            Button(intent: CompleteTaskIntent(taskID: taskID)) {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "circle")
                        .font(.caption)
                        .padding(.top, 1)
                    Text(taskTitle)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
        } else {
            // All tasks done or no tasks — tapping deep-links into the note
            Link(destination: entry.noteLaunchURL) {
                HStack(spacing: 4) {
                    Image(systemName: entry.noteTitle == "No Notes"
                          ? "plus.circle" : "checkmark.circle.fill")
                        .font(.caption)
                    Text(entry.noteTitle == "No Notes"
                         ? "Open app to add notes"
                         : "All done! Tap to add more")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryRectangular) {
    TaskWidget()
} timeline: {
    TaskWidgetEntry.placeholder
    TaskWidgetEntry(
        date: .now,
        noteTitle: "Personal",
        noteColor: .stickyPurple,
        noteIDString: nil,
        topTaskTitle: nil,
        topTaskIDString: nil
    )
}
