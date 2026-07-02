// TARGET: TaskWidget (Widget Extension)

import WidgetKit
import SwiftData
import SwiftUI

struct TaskWidgetProvider: TimelineProvider {

    typealias Entry = TaskWidgetEntry

    // MARK: - TimelineProvider

    func placeholder(in context: Context) -> TaskWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskWidgetEntry) -> Void) {
        // In preview / snapshot mode return placeholder immediately to avoid DB access.
        if context.isPreview {
            completion(.placeholder)
            return
        }
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskWidgetEntry>) -> Void) {
        let entry = buildEntry()
        // .never means WidgetKit will only refresh when we call reloadAllTimelines()
        // (i.e. after every Intent completion). Avoids unnecessary wake-ups.
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    // MARK: - Entry builder

    private func buildEntry() -> TaskWidgetEntry {
        do {
            let container = try WidgetDatabaseHelper.makeContainer()
            let context = ModelContext(container)

            // 1. Resolve the active note.
            var activeNote: StickyNote? = nil
            let stateManager = WidgetStateManager.shared

            if let idString = stateManager.currentActiveNoteID,
               let pinnedID = UUID(uuidString: idString) {
                let descriptor = FetchDescriptor<StickyNote>(
                    predicate: #Predicate<StickyNote> { $0.id == pinnedID }
                )
                activeNote = try context.fetch(descriptor).first
            }

            // 2. Fall back to the first note if none is pinned (or pinned note was deleted).
            if activeNote == nil {
                let descriptor = FetchDescriptor<StickyNote>(
                    sortBy: [SortDescriptor(\.createdAt, order: .forward)]
                )
                activeNote = try context.fetch(descriptor).first
            }

            guard let note = activeNote else {
                return .empty  // No notes at all
            }

            // 3. Grab the highest-priority pending task (top-1).
            let topTask = note.pendingTasks.first

            return TaskWidgetEntry(
                date: .now,
                noteTitle: note.title,
                noteColor: Color(hex: note.colorHex),
                noteIDString: note.id.uuidString,
                topTaskTitle: topTask?.title,
                topTaskIDString: topTask?.id.uuidString
            )

        } catch {
            return .empty
        }
    }
}
