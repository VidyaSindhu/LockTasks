// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

/// Full-screen editor for a single TaskItem — title, details, and completion toggle.
struct TaskDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskItem

    // Local editable copies so we only commit on Save.
    @State private var editedTitle: String
    @State private var editedDetails: String

    init(task: TaskItem) {
        self.task = task
        _editedTitle   = State(initialValue: task.title)
        _editedDetails = State(initialValue: task.details)
    }

    private var noteColor: Color {
        Color(hex: task.note?.colorHex ?? "#FFD700")
    }

    private var hasChanges: Bool {
        editedTitle != task.title || editedDetails != task.details
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Title
                Section("Task") {
                    TextField("Task title", text: $editedTitle, axis: .vertical)
                        .lineLimit(1...4)
                }

                // MARK: Details / notes
                Section {
                    ZStack(alignment: .topLeading) {
                        if editedDetails.isEmpty {
                            Text("Add bullet points, links, context…")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $editedDetails)
                            .frame(minHeight: 140)
                    }
                } header: {
                    Text("Details")
                } footer: {
                    Text("Supports plain text, bullet points (•), or any freeform notes.")
                }

                // MARK: Status
                Section("Status") {
                    Toggle(isOn: Binding(
                        get: { task.isCompleted },
                        set: { newValue in
                            withAnimation {
                                task.isCompleted = newValue
                                task.completedAt = newValue ? .now : nil
                            }
                            try? modelContext.save()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    )) {
                        Label(task.isCompleted ? "Completed" : "Pending",
                              systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    }
                    .tint(.green)

                    if task.isCompleted, let completedAt = task.completedAt {
                        Label(
                            "Done \(completedAt.formatted(.relative(presentation: .named)))",
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(noteColor.opacity(0.15), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.semibold)
                        .disabled(!hasChanges ||
                                  editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func saveChanges() {
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        task.title   = trimmedTitle
        task.details = editedDetails
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

#Preview {
    let task = TaskItem(title: "Write the quarterly report",
                        details: "• Q3 numbers\n• Growth metrics\n• Risk summary")
    return TaskDetailView(task: task)
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
