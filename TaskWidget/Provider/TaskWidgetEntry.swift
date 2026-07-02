// TARGET: TaskWidget (Widget Extension)

import WidgetKit
import SwiftUI

/// The data snapshot the widget renders at a given point in time.
struct TaskWidgetEntry: TimelineEntry {

    let date: Date

    // Note info
    let noteTitle: String
    let noteColor: Color
    /// UUID string used to deep-link directly into this note when the user taps the widget.
    let noteIDString: String?

    // Top pending task (nil when all tasks are done or there are no tasks at all)
    let topTaskTitle: String?
    let topTaskIDString: String?

    /// Convenience: the deep-link URL for the active note, or the home URL if no ID.
    var noteLaunchURL: URL {
        if let id = noteIDString {
            return AppConstants.noteURL(id: id) ?? AppConstants.appLaunchURL ?? URL(string: "locktasks://home")!
        }
        return AppConstants.appLaunchURL ?? URL(string: "locktasks://home")!
    }

    // MARK: - Static convenience entries

    /// Placeholder shown while the real data loads.
    static let placeholder = TaskWidgetEntry(
        date: .now,
        noteTitle: "Work",
        noteColor: .stickyTeal,
        noteIDString: nil,
        topTaskTitle: "Write the quarterly report",
        topTaskIDString: nil
    )

    /// Shown when there are no notes in the database yet.
    static let empty = TaskWidgetEntry(
        date: .now,
        noteTitle: "No Notes",
        noteColor: .gray,
        noteIDString: nil,
        topTaskTitle: nil,
        topTaskIDString: nil
    )
}
