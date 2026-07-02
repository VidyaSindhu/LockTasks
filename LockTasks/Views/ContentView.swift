// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

/// Root tab container. Accepts a deep-link note ID from the widget and
/// refreshes SwiftData @Query views every time the app comes to foreground
/// so widget-driven task completions are always visible immediately.
struct ContentView: View {

    @Binding var deepLinkNoteID: String?
    @Environment(\.scenePhase) private var scenePhase

    /// Incrementing this forces views using `.id(refreshToken)` to rebuild,
    /// which re-executes their @Query and picks up changes written by the widget.
    @State private var refreshToken = 0

    var body: some View {
        TabView {
            HomeView(deepLinkNoteID: $deepLinkNoteID, refreshToken: refreshToken)
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            HistoryView()
                .id(refreshToken)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        // When the app becomes active (including when opened from the widget),
        // bump the refresh token so @Query views re-execute against the shared store.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshToken += 1
            }
        }
    }
}

#Preview {
    ContentView(deepLinkNoteID: .constant(nil))
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
