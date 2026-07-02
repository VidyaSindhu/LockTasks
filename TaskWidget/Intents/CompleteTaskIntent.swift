// TARGET: TaskWidget (Widget Extension)
// Requires: AppIntents + WidgetKit frameworks in the Widget target.

import AppIntents
import SwiftData
import WidgetKit

/// Interactive widget button — marks a specific TaskItem as completed.
struct CompleteTaskIntent: AppIntent {

    static var title: LocalizedStringResource = "Complete Task"
    static var description = IntentDescription("Marks a task as completed from the Lock Screen widget.")
    static var isDiscoverable: Bool = false  // Internal use; not surfaced in Shortcuts

    /// UUID string of the TaskItem to complete.
    @Parameter(title: "Task ID")
    var taskID: String

    // Required empty init so AppIntents framework can synthesise the intent.
    init() {}

    init(taskID: String) {
        self.taskID = taskID
    }

    // MARK: - Perform

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: taskID) else {
            return .result()
        }

        let container = try WidgetDatabaseHelper.makeContainer()
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate<TaskItem> { $0.id == uuid }
        )

        guard let task = try context.fetch(descriptor).first else {
            return .result()
        }

        task.isCompleted = true
        task.completedAt = .now
        try context.save()

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
