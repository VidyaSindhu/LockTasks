// TARGET: LockTasks (Main App) + TaskWidgetExtension (Widget Extension)

import Foundation

/// Parsed deep-link target from a `locktasks://` URL.
struct DeepLinkRequest: Equatable {
    var noteID: String?
    var focusAddTask: Bool = false
}

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

    /// Opens the app to the note and focuses the add-task field.
    static func noteAddTaskURL(id: String) -> URL? {
        URL(string: "\(deepLinkScheme)://note/\(id)/add")
    }

    /// Parses any supported `locktasks://` URL into a navigation request.
    static func parseDeepLink(_ url: URL) -> DeepLinkRequest {
        guard url.scheme == deepLinkScheme else {
            return DeepLinkRequest(noteID: nil, focusAddTask: false)
        }

        switch url.host {
        case "note":
            let pathParts = url.pathComponents.filter { $0 != "/" }
            let noteID = pathParts.first.flatMap { $0.isEmpty ? nil : $0 }
            let focusAddTask = pathParts.dropFirst().contains("add")
            return DeepLinkRequest(noteID: noteID, focusAddTask: focusAddTask)
        default:
            return DeepLinkRequest(noteID: nil, focusAddTask: false)
        }
    }

    /// Legacy helper — extracts note ID only (no add-task flag).
    static func noteID(from url: URL) -> String? {
        parseDeepLink(url).noteID
    }
}
