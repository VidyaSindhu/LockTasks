// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

/// Displays every completed TaskItem across all notes, sorted newest-first.
struct HistoryView: View {

    /// SwiftData fetches only completed items, ordered by completedAt descending.
    @Query(
        filter: #Predicate<TaskItem> { $0.isCompleted == true },
        sort: \TaskItem.completedAt,
        order: .reverse
    )
    private var completedTasks: [TaskItem]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if completedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("History")
        }
    }

    // MARK: - Subviews

    private var taskList: some View {
        List {
            ForEach(completedTasks) { task in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                            .strikethrough(color: .secondary)
                            .foregroundStyle(.primary)

                        HStack(spacing: 6) {
                            if let noteTitle = task.note?.title,
                               let noteColor = task.note.map({ Color(hex: $0.colorHex) }) {
                                Label(noteTitle, systemImage: "folder.fill")
                                    .font(.caption)
                                    .foregroundStyle(noteColor)
                            }

                            if let completedAt = task.completedAt {
                                Text(completedAt.formatted(.relative(presentation: .named)))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 2)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Completed Tasks", systemImage: "checkmark.circle")
        } description: {
            Text("Tasks you mark complete will appear here.")
        }
    }

    // MARK: - Actions

    private func deleteTask(_ task: TaskItem) {
        modelContext.delete(task)
        try? modelContext.save()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
