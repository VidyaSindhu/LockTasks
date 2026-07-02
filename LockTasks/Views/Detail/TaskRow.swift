// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

/// A single list row for a TaskItem.
/// - Tapping the circle toggles completion.
/// - Tapping the title/body area opens TaskDetailView.
/// - Left-swipe shows a Rename action.
struct TaskRow: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var task: TaskItem
    @State private var showingDetail = false
    @State private var editedTaskTitle = ""
    @State private var isRenameTaskPresented = false

    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle
            Button(action: toggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            // Tapping the text opens the detail editor
            Button {
                showingDetail = true
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)

                    if !task.details.isEmpty {
                        Text(task.details)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    if task.isCompleted, let completedAt = task.completedAt {
                        Text("Done \(completedAt.formatted(.relative(presentation: .named)))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                beginRenameTask()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .alert("Rename Task", isPresented: $isRenameTaskPresented) {
            TextField("Task name", text: $editedTaskTitle)
            Button("Cancel", role: .cancel) {}
            Button("Save") { saveRenamedTask() }
                .disabled(editedTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - Actions

    private func toggleCompletion() {
        withAnimation {
            task.isCompleted.toggle()
            task.completedAt = task.isCompleted ? .now : nil
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func beginRenameTask() {
        editedTaskTitle = task.title
        isRenameTaskPresented = true
    }

    private func saveRenamedTask() {
        let trimmed = editedTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        task.title = trimmed
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
