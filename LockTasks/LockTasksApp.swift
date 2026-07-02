// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

@main
struct LockTasksApp: App {

    /// Drives deep-linking from widget → specific note detail.
    @State private var deepLinkNoteID: String? = nil

    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkNoteID: $deepLinkNoteID)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .modelContainer(DatabaseManager.shared.container)
    }

    // MARK: - Helpers

    private func handleURL(_ url: URL) {
        if let noteID = AppConstants.noteID(from: url) {
            deepLinkNoteID = noteID
        }
        // locktasks://home — opens the app without specific navigation.
    }
}
