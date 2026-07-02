// TARGET: TaskWidgetExtension (Widget Extension)
// Minimum deployment target: iOS 17 (required for Button(intent:) in widgets)

import SwiftUI
import WidgetKit
import AppIntents

/// Lock Screen widget UI — `.accessoryRectangular` only.
///
/// Layout:
///   Top row  : [📁 Note title ──────────] [⟫]
///   Divider
///   Bottom row: [○ Top task]  OR  [+ Add task] when no pending tasks
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

    private var noteRow: some View {
        HStack(spacing: 0) {

            // Tap note title → open note in app
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

            // Cycle to next note (no app launch)
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

    // MARK: - Task row

    @ViewBuilder
    private var taskRow: some View {
        if let taskTitle = entry.topTaskTitle,
           let taskID = entry.topTaskIDString {
            // Pending task → tap to complete
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
            // No pending tasks → tap to open app and add a task
            Link(destination: entry.noteAddTaskLaunchURL) {
                HStack(spacing: 4) {
                    Image(systemName: entry.noteTitle == "No Notes" ? "plus.circle" : "plus.circle.fill")
                        .font(.caption)
                    Text(entry.noteTitle == "No Notes"
                         ? "Open app to add notes"
                         : "+ Add task")
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
        noteIDString: "00000000-0000-0000-0000-000000000001",
        topTaskTitle: nil,
        topTaskIDString: nil
    )
}
