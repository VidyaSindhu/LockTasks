// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

@main
struct LockTasksApp: App {

    /// Drives deep-linking from widget → note detail (optionally with add-task focus).
    @State private var deepLinkRequest: DeepLinkRequest? = nil

    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkRequest: $deepLinkRequest)
                .onOpenURL { url in
                    deepLinkRequest = AppConstants.parseDeepLink(url)
                }
        }
        .modelContainer(DatabaseManager.shared.container)
    }
}
