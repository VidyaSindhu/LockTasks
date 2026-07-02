// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

/// Root tab container. Accepts deep-link requests from the widget and
/// refreshes SwiftData @Query views every time the app comes to foreground.
struct ContentView: View {

    @Binding var deepLinkRequest: DeepLinkRequest?
    @Environment(\.scenePhase) private var scenePhase

    @State private var refreshToken = 0

    var body: some View {
        TabView {
            HomeView(deepLinkRequest: $deepLinkRequest, refreshToken: refreshToken)
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            HistoryView()
                .id(refreshToken)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshToken += 1
            }
        }
    }
}

#Preview {
    ContentView(deepLinkRequest: .constant(nil))
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
