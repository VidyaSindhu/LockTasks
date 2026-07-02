// TARGET: LockTasks (Main App)

import SwiftData
import Foundation

/// Singleton that owns the SwiftData ModelContainer stored in the shared
/// App Group so both the app and the widget extension read/write the same DB.
@MainActor
final class DatabaseManager {

    static let shared = DatabaseManager()

    let container: ModelContainer

    private init() {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupID
        ) else {
            fatalError("App Group '\(AppConstants.appGroupID)' is not configured in entitlements.")
        }

        let storeURL = groupURL.appendingPathComponent(AppConstants.storeFilename)
        let config = ModelConfiguration(url: storeURL)

        do {
            container = try ModelContainer(
                for: StickyNote.self, TaskItem.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
