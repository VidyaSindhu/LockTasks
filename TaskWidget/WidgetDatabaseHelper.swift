// TARGET: TaskWidgetExtension (Widget Extension)

import SwiftData
import Foundation

/// Utility that creates a read/write ModelContainer pointing at the shared
/// App Group store. Used by both App Intents and the Timeline Provider.
enum WidgetDatabaseHelper {

    enum DBError: LocalizedError {
        case appGroupUnavailable
        var errorDescription: String? {
            "App Group '\(AppConstants.appGroupID)' could not be accessed."
        }
    }

    /// Creates a new ModelContainer each call (lightweight — SwiftData caches the schema).
    static func makeContainer() throws -> ModelContainer {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupID
        ) else {
            throw DBError.appGroupUnavailable
        }

        let storeURL = groupURL.appendingPathComponent(AppConstants.storeFilename)
        let config = ModelConfiguration(url: storeURL)
        return try ModelContainer(
            for: StickyNote.self, TaskItem.self,
            configurations: config
        )
    }
}
