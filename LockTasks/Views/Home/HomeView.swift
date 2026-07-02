// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    /// Notes sorted by manual sortOrder, then createdAt as tiebreaker.
    @Query(sort: [SortDescriptor(\StickyNote.sortOrder),
                  SortDescriptor(\StickyNote.createdAt)])
    private var notes: [StickyNote]

    @Binding var deepLinkRequest: DeepLinkRequest?
    var refreshToken: Int

    @State private var navigationPath = NavigationPath()
    @State private var focusAddTaskForNoteID: UUID?
    @State private var showingAddNote = false
    @State private var isReordering = false
    @State private var noteToRename: StickyNote?
    @State private var editedNoteTitle = ""
    @State private var showingRenameAlert = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if notes.isEmpty {
                    emptyState
                } else if isReordering {
                    reorderList
                } else {
                    noteGrid
                }
            }
            .id(refreshToken)
            .navigationTitle("LockTasks")
            .navigationDestination(for: StickyNote.self) { note in
                NoteDetailView(
                    note: note,
                    autoFocusAddTask: focusAddTaskForNoteID == note.id,
                    onDidFocusAddTask: {
                        if focusAddTaskForNoteID == note.id {
                            focusAddTaskForNoteID = nil
                        }
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !notes.isEmpty {
                        Button {
                            withAnimation { isReordering.toggle() }
                        } label: {
                            Label(
                                isReordering ? "Done" : "Reorder",
                                systemImage: isReordering ? "checkmark.circle.fill" : "arrow.up.arrow.down"
                            )
                        }
                        .tint(isReordering ? .green : .primary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .disabled(isReordering)
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteSheet(
                    isPresented: $showingAddNote,
                    nextSortOrder: (notes.map(\.sortOrder).max() ?? -1) + 1
                )
            }
            .alert("Rename Note", isPresented: $showingRenameAlert) {
                TextField("Note name", text: $editedNoteTitle)
                Button("Cancel", role: .cancel) {}
                Button("Save") { saveRenamedNote() }
                    .disabled(editedNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text("Update the note title.")
            }
        }
        .onChange(of: deepLinkRequest) { _, request in
            guard let request,
                  let idString = request.noteID,
                  let uuid = UUID(uuidString: idString),
                  let note = notes.first(where: { $0.id == uuid }) else { return }

            if request.focusAddTask {
                focusAddTaskForNoteID = uuid
            }

            navigationPath = NavigationPath()
            navigationPath.append(note)
            deepLinkRequest = nil
        }
    }

    // MARK: - Grid (normal browsing)

    private var noteGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(notes) { note in
                    NavigationLink(value: note) {
                        StickyNoteCard(note: note)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            beginRename(note)
                        } label: {
                            Label("Rename Note", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - List (reorder mode)

    private var reorderList: some View {
        List {
            ForEach(notes) { note in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: note.colorHex))
                        .frame(width: 14, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(note.title)
                            .font(.headline)

                        let pending = note.tasks.filter { !$0.isCompleted }.count
                        Text("\(pending) pending task\(pending == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .onMove(perform: reorderNotes)
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(.active))
        .overlay(alignment: .bottom) {
            Text("Drag to reorder. Tap ✓ when done.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Notes Yet", systemImage: "note.text")
        } description: {
            Text("Tap **+** to create your first sticky note.")
        } actions: {
            Button("New Note") { showingAddNote = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func reorderNotes(from source: IndexSet, to destination: Int) {
        var reordered = notes
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, note) in reordered.enumerated() {
            note.sortOrder = index
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteNote(_ note: StickyNote) {
        modelContext.delete(note)
        normalizeNoteSortOrder()
        try? modelContext.save()
    }

    private func normalizeNoteSortOrder() {
        for (index, note) in notes.enumerated() {
            note.sortOrder = index
        }
    }

    private func beginRename(_ note: StickyNote) {
        noteToRename = note
        editedNoteTitle = note.title
        showingRenameAlert = true
    }

    private func saveRenamedNote() {
        guard let noteToRename else { return }
        let trimmed = editedNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        noteToRename.title = trimmed
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    HomeView(deepLinkRequest: .constant(nil), refreshToken: 0)
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
