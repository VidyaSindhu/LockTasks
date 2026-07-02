// TARGET: LockTasks (Main App)

import SwiftUI
import SwiftData
import WidgetKit

/// Half-sheet for changing a note's colour after creation.
struct NoteColorPickerSheet: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var note: StickyNote
    @Binding var isPresented: Bool

    private let columns = [GridItem(.adaptive(minimum: 52), spacing: 14)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Live card preview
                StickyNoteCard(note: note)
                    .frame(width: 200)
                    .padding(.top, 8)

                // Colour swatches
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Color.stickyPalette, id: \.0) { hex, name in
                        colorSwatch(hex: hex, name: name)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Note Colour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        WidgetCenter.shared.reloadAllTimelines()
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private func colorSwatch(hex: String, name: String) -> some View {
        let isSelected = note.colorHex == hex
        return Circle()
            .fill(Color(hex: hex))
            .frame(width: 48, height: 48)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                }
            }
            .overlay {
                Circle()
                    .stroke(isSelected ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 2.5)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(duration: 0.2), value: isSelected)
            .onTapGesture { note.colorHex = hex }
            .accessibilityLabel(name)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NoteColorPickerSheet(
        note: StickyNote(title: "Work", colorHex: "#4ECDC4"),
        isPresented: .constant(true)
    )
    .modelContainer(for: [StickyNote.self, TaskItem.self], inMemory: true)
}
