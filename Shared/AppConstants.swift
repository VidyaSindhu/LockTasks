// TARGET: LockTasks (Main App) + TaskWidgetExtension (Widget Extension)

import Foundation

enum AppConstants {
    static let appGroupID = "group.com.vsd-local.LockTasks"
    static let storeFilename = "LockTasks.store"
    static let activeNoteIDKey = "currentActiveNoteID"
    static let deepLinkScheme = "locktasks"

    /// Opens the app's home screen.
    static var appLaunchURL: URL? {
        URL(string: "\(deepLinkScheme)://home")
    }

    /// Opens the app directly to the note with the given UUID string.
    static func noteURL(id: String) -> URL? {
        URL(string: "\(deepLinkScheme)://note/\(id)")
    }

    /// Extracts a note UUID string from a deep-link URL, or nil if the URL
    /// is not a note deep link.
    static func noteID(from url: URL) -> String? {
        guard url.scheme == deepLinkScheme,
              url.host == "note" else { return nil }
        let id = url.pathComponents.dropFirst().first
        return id?.isEmpty == false ? id : nil
    }
}
