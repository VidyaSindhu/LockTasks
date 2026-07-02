// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData

/// Modal sheet for creating a new StickyNote.
struct AddNoteSheet: View {

    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    /// Passed in by HomeView so new notes append at the end of the sorted list.
    var nextSortOrder: Int = 0

    @State private var title = ""
    @State private var selectedHex = Color.stickyPalette[0].0
    @FocusState private var isTitleFocused: Bool

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Note Title") {
                    TextField("e.g. Work, Personal, Shopping…", text: $title)
                        .focused($isTitleFocused)
                }

                Section("Colour") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Color.stickyPalette, id: \.0) { hex, name in
                            colorSwatch(hex: hex, name: name)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Live preview
                Section("Preview") {
                    HStack {
                        Spacer()
                        StickyNoteCard(
                            note: StickyNote(
                                title: title.isEmpty ? "Note Title" : title,
                                colorHex: selectedHex
                            )
                        )
                        .frame(width: 180)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear { isTitleFocused = true }
        }
    }

    // MARK: - Subviews

    private func colorSwatch(hex: String, name: String) -> some View {
        let isSelected = selectedHex == hex
        return Circle()
            .fill(Color(hex: hex))
            .frame(width: 38, height: 38)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                }
            }
            .overlay {
                Circle()
                    .stroke(isSelected ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 2)
            }
            .onTapGesture { selectedHex = hex }
            .accessibilityLabel(name)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Actions

    private func save() {
        let note = StickyNote(
            title: title.trimmingCharacters(in: .whitespaces),
            colorHex: selectedHex,
            sortOrder: nextSortOrder
        )
        modelContext.insert(note)
        try? modelContext.save()
        isPresented = false
    }
}

#Preview {
    AddNoteSheet(isPresented: .constant(true))
        .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
