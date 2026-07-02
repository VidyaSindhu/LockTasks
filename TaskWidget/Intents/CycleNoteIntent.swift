// TARGET: TaskWidget (Widget Extension)
// Requires: AppIntents + WidgetKit frameworks in the Widget target.

import AppIntents
import SwiftData
import WidgetKit

/// Interactive widget button — advances the active note to the next one in the list.
struct CycleNoteIntent: AppIntent {

    static var title: LocalizedStringResource = "Cycle to Next Note"
    static var description = IntentDescription("Shows the next sticky note on the Lock Screen widget.")
    static var isDiscoverable: Bool = false

    // Required empty init.
    init() {}

    // MARK: - Perform

    @MainActor
    func perform() async throws -> some IntentResult {
        let container = try WidgetDatabaseHelper.makeContainer()
        let context = ModelContext(container)

        // Fetch all notes sorted by creation date so cycling is deterministic.
        let descriptor = FetchDescriptor<StickyNote>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let notes = try context.fetch(descriptor)
        guard !notes.isEmpty else { return .result() }

        let stateManager = WidgetStateManager.shared

        let nextNote: StickyNote
        if let idString = stateManager.currentActiveNoteID,
           let currentID = UUID(uuidString: idString),
           let currentIndex = notes.firstIndex(where: { $0.id == currentID }) {
            // Advance circularly.
            let nextIndex = (currentIndex + 1) % notes.count
            nextNote = notes[nextIndex]
        } else {
            // Nothing pinned yet — pin the first note.
            nextNote = notes[0]
        }

        stateManager.currentActiveNoteID = nextNote.id.uuidString
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
