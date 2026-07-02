// TARGET: LockTasks (Main App) + TaskWidget (Widget Extension)
// Add this file to BOTH targets in Xcode.

import SwiftData
import Foundation

@Model
final class StickyNote {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var colorHex: String
    var createdAt: Date

    /// Cascade-delete all child TaskItems when this note is deleted.
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.note)
    var tasks: [TaskItem] = []

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String = "#FFD700",
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    /// Pending tasks sorted by manual priority first, then creation date.
    var pendingTasks: [TaskItem] {
        tasks
            .filter { !$0.isCompleted }
            .sorted {
                if $0.sortOrder == $1.sortOrder {
                    return $0.createdAt < $1.createdAt
                }
                return $0.sortOrder < $1.sortOrder
            }
    }
}
