// TARGET: LockTasks (Main App) + TaskWidget (Widget Extension)
// Add this file to BOTH targets in Xcode.

import SwiftUI

extension Color {

    /// Initialise a Color from a CSS-style hex string.
    /// Supports 3-char (#RGB), 6-char (#RRGGBB) and 8-char (#AARRGGBB) formats.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64

        switch cleaned.count {
        case 3:
            // Expand #RGB → #RRGGBB
            r = ((value >> 8) & 0xF) * 17
            g = ((value >> 4) & 0xF) * 17
            b = (value & 0xF) * 17
            a = 255
        case 6:
            r = (value >> 16) & 0xFF
            g = (value >> 8)  & 0xFF
            b = value         & 0xFF
            a = 255
        case 8:
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8)  & 0xFF
            b = value         & 0xFF
        default:
            // Fallback: opaque white
            r = 255; g = 255; b = 255; a = 255
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preset sticky-note palette

extension Color {
    static let stickyYellow  = Color(hex: "#FFD700")
    static let stickyRed     = Color(hex: "#FF6B6B")
    static let stickyTeal    = Color(hex: "#4ECDC4")
    static let stickyGreen   = Color(hex: "#A8E6CF")
    static let stickyPurple  = Color(hex: "#C3B1E1")
    static let stickyOrange  = Color(hex: "#FFB347")
    static let stickyBlue    = Color(hex: "#74B9FF")
    static let stickyPink    = Color(hex: "#FD79A8")

    /// All built-in palette entries as (hex, display-name) tuples.
    static let stickyPalette: [(String, String)] = [
        ("#FFD700", "Yellow"),
        ("#FF6B6B", "Red"),
        ("#4ECDC4", "Teal"),
        ("#A8E6CF", "Green"),
        ("#C3B1E1", "Purple"),
        ("#FFB347", "Orange"),
        ("#74B9FF", "Blue"),
        ("#FD79A8", "Pink"),
    ]
}
