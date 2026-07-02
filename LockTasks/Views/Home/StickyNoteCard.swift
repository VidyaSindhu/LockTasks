// TARGET: LockTasks (Main App)

import SwiftUI

/// A Google-Keep-style card representing a single StickyNote.
struct StickyNoteCard: View {

    let note: StickyNote

    private var pendingCount: Int {
        note.tasks.filter { !$0.isCompleted }.count
    }

    private var totalCount: Int { note.tasks.count }

    private var noteColor: Color { Color(hex: note.colorHex) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Colour accent bar at the top
            noteColor
                .frame(height: 6)

            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 4)

                if !note.tasks.isEmpty {
                    // Compact task preview (up to 2 lines)
                    ForEach(note.pendingTasks.prefix(2)) { task in
                        HStack(spacing: 6) {
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle(noteColor)
                            Text(task.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Divider()

                HStack {
                    Label("\(pendingCount)", systemImage: "circle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(note.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
        }
        .frame(minHeight: 140)
        .background(noteColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(noteColor.opacity(0.5), lineWidth: 1)
        }
        .shadow(color: noteColor.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let note = StickyNote(title: "Work", colorHex: "#4ECDC4")
    note.tasks = [
        TaskItem(title: "Write the quarterly report"),
        TaskItem(title: "Review PRs"),
    ]
    return StickyNoteCard(note: note)
        .padding()
        .frame(width: 200)
}
