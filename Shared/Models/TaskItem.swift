// TARGET: LockTasks (Main App) + TaskWidget (Widget Extension)
// Add this file to BOTH targets in Xcode.

import SwiftData
import Foundation

@Model
final class TaskItem {

    @Attribute(.unique)
    var id: UUID

    var title: String
    /// Free-form notes / bullet points for this task. Defaults to empty string
    /// so lightweight migration fills existing rows automatically.
    var details: String = ""
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    /// Lower value means higher priority in the pending list and widget.
    /// Keeping a model-level default allows lightweight migration for older stores.
    var sortOrder: Int = 0

    /// Back-reference to the owning StickyNote. Inverse is declared on StickyNote.tasks.
    var note: StickyNote?

    init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = .now,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}
