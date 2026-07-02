// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

/// Shows all pending tasks for a note and lets the user add / complete / delete them.
struct NoteDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var note: StickyNote

    /// When true (e.g. opened via widget `+` deep link), focuses the add-task field on appear.
    var autoFocusAddTask: Bool = false
    var onDidFocusAddTask: (() -> Void)? = nil

    @State private var newTaskTitle = ""
    @State private var editedNoteTitle = ""
    @State private var isRenameNotePresented = false
    @State private var isColorPickerPresented = false
    @FocusState private var isInputFocused: Bool

    private var noteColor: Color { Color(hex: note.colorHex) }

    var body: some View {
        List {
            pendingSection

            if note.tasks.contains(where: \.isCompleted) {
                completedSection
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(note.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(noteColor.opacity(0.15), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                colorPickerButton
                pinButton
                renameNoteButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            addTaskBar
        }
        .sheet(isPresented: $isColorPickerPresented) {
            NoteColorPickerSheet(note: note, isPresented: $isColorPickerPresented)
        }
        .alert("Rename Note", isPresented: $isRenameNotePresented) {
            TextField("Note name", text: $editedNoteTitle)
            Button("Cancel", role: .cancel) {}
            Button("Save") { saveRenamedNote() }
                .disabled(editedNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Update the note title shown in the app and widget.")
        }
        .onAppear {
            guard autoFocusAddTask else { return }
            // Brief delay lets navigation settle before raising the keyboard.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                isInputFocused = true
            }
            onDidFocusAddTask?()
        }
    }

    // MARK: - Sections

    private var pendingSection: some View {
        Section {
            if note.pendingTasks.isEmpty {
                Label("No pending tasks", systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(note.pendingTasks) { task in
                    TaskRow(task: task)
                }
                .onDelete { offsets in
                    deletePendingTasks(at: offsets)
                }
                .onMove(perform: reorderPendingTasks)
            }
        } header: {
            Text("Pending")
        } footer: {
            if !note.pendingTasks.isEmpty {
                Text("Use Edit to reorder. The first task appears on the lock-screen widget.")
            }
        }
    }

    private var completedSection: some View {
        Section {
            ForEach(note.tasks.filter(\.isCompleted).sorted {
                ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
            }) { task in
                TaskRow(task: task)
            }
        } header: {
            Text("Completed")
        }
    }

    // MARK: - Input Bar

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("Add a task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .onSubmit { addTask() }

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(noteColor)
            }
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    // MARK: - Pin button

    private var pinButton: some View {
        Button {
            pinNote()
        } label: {
            Image(systemName: "pin.fill")
        }
        .help("Pin to Lock Screen widget")
    }

    private var renameNoteButton: some View {
        Button {
            beginRenameNote()
        } label: {
            Image(systemName: "pencil")
        }
        .help("Rename note")
    }

    private var colorPickerButton: some View {
        Button {
            isColorPickerPresented = true
        } label: {
            Image(systemName: "paintpalette.fill")
                .foregroundStyle(noteColor)
        }
        .help("Change note colour")
    }

    // MARK: - Actions

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let nextSortOrder = (note.pendingTasks.map(\.sortOrder).max() ?? -1) + 1
        let task = TaskItem(title: trimmed, sortOrder: nextSortOrder)
        task.note = note
        note.tasks.append(task)
        modelContext.insert(task)
        try? modelContext.save()

        newTaskTitle = ""
        isInputFocused = false
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func pinNote() {
        WidgetStateManager.shared.currentActiveNoteID = note.id.uuidString
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func beginRenameNote() {
        editedNoteTitle = note.title
        isRenameNotePresented = true
    }

    private func saveRenamedNote() {
        let trimmed = editedNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        note.title = trimmed
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deletePendingTasks(at offsets: IndexSet) {
        let pending = note.pendingTasks
        for index in offsets {
            modelContext.delete(pending[index])
        }
        normalizePendingSortOrder()
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func reorderPendingTasks(from source: IndexSet, to destination: Int) {
        var reordered = note.pendingTasks
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, task) in reordered.enumerated() {
            task.sortOrder = index
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func normalizePendingSortOrder() {
        for (index, task) in note.pendingTasks.enumerated() {
            task.sortOrder = index
        }
    }
}

#Preview {
    let note = StickyNote(title: "Work", colorHex: "#4ECDC4")
    let t1 = TaskItem(title: "Write the quarterly report")
    let t2 = TaskItem(title: "Review pull requests")
    note.tasks = [t1, t2]
    return NavigationStack {
        NoteDetailView(note: note)
    }
    .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
