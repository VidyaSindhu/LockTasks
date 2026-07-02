// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \StickyNote.createdAt, order: .reverse)
    private var notes: [StickyNote]

    @Binding var deepLinkNoteID: String?
    var refreshToken: Int

    @State private var navigationPath = NavigationPath()
    @State private var showingAddNote = false
    @State private var noteToRename: StickyNote?
    @State private var editedNoteTitle = ""
    @State private var showingRenameAlert = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if notes.isEmpty {
                    emptyState
                } else {
                    noteGrid
                }
            }
            .id(refreshToken)
            .navigationTitle("LockTasks")
            .navigationDestination(for: StickyNote.self) { note in
                NoteDetailView(note: note)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteSheet(isPresented: $showingAddNote)
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
        // Respond to deep-link note IDs arriving from the widget.
        .onChange(of: deepLinkNoteID) { _, newID in
            guard let idString = newID,
                  let uuid = UUID(uuidString: idString),
                  let note = notes.first(where: { $0.id == uuid }) else { return }

            // Reset path then push so we always land at the right note.
            navigationPath = NavigationPath()
            navigationPath.append(note)
            deepLinkNoteID = nil
        }
    }

    // MARK: - Subviews

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

    private func deleteNote(_ note: StickyNote) {
        modelContext.delete(note)
        try? modelContext.save()
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
    HomeView(deepLinkNoteID: .constant(nil), refreshToken: 0)
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
