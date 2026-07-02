// TARGET: LockTasks (Main App) + TaskWidgetExtension (Widget Extension)

import Foundation

/// Thread-safe wrapper around the shared UserDefaults suite used to pass
/// lightweight state (e.g. the active note ID) between the app and widget.
final class WidgetStateManager {

    static let shared = WidgetStateManager()

    private let defaults: UserDefaults

    private init() {
        guard let suite = UserDefaults(suiteName: AppConstants.appGroupID) else {
            fatalError("Shared UserDefaults suite '\(AppConstants.appGroupID)' is unavailable.")
        }
        self.defaults = suite
    }

    /// The UUID string of the note currently pinned to the widget.
    /// Setting `nil` causes the widget to fall back to the first available note.
    var currentActiveNoteID: String? {
        get { defaults.string(forKey: AppConstants.activeNoteIDKey) }
        set { defaults.set(newValue, forKey: AppConstants.activeNoteIDKey) }
    }
}
