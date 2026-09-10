import AppIntents
import SwiftUI

@available(iOS 27.0, macOS 27.0, *)
@main
struct FieldNotesApp: App {
    var body: some Scene { WindowGroup { NotesView() } }
}

@available(iOS 27.0, macOS 27.0, *)
struct NotesView: View {
    @State private var route = NoteRoute.shared
    @State private var notes: [Note] = []
    @State private var name = ""
    @State private var content = ""
    @State private var error: String?
    @State private var repairNeeded = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $route.path) {
            List {
                Section("New plain text note") {
                    TextField("Name", text: $name)
                    TextField("Content", text: $content, axis: .vertical)
                    Button("Create Note") {
                        Task {
                            do {
                                _ = try await NotesService.shared.create(name: name, content: content, pinned: false)
                                name = ""; content = ""
                                await refresh()
                            } catch { self.error = error.localizedDescription }
                        }
                    }
                }
                Section("Inbox") {
                    ForEach(notes) { note in
                        NavigationLink(value: note.id) {
                            Label(note.name, systemImage: note.isPinned ? "pin.fill" : "note.text")
                        }
                        .appEntityIdentifier(EntityIdentifier(for: NoteEntity.self, identifier: note.id))
                    }
                }
                if repairNeeded {
                    Section("Search index needs repair") {
                        Text("Your notes are saved. Search results may be out of date.")
                        Button("Repair Search Index") { Task { await repair() } }
                    }
                }
            }
            .navigationTitle("FieldNotes")
            .navigationDestination(for: UUID.self) { id in NoteDetail(id: id) }
            .task { await refresh(); await repair() }
            .onChange(of: route.path) { _, _ in Task { await refresh() } }
            .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await refresh() } } }
            .alert("FieldNotes", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK") { error = nil }
            } message: { Text(error ?? "") }
        }
    }

    private func refresh() async {
        do { notes = try await NotesService.shared.store.all() }
        catch { self.error = error.localizedDescription }
        repairNeeded = await NotesService.shared.indexNeedsRepair
    }
    private func repair() async {
        do { try await NotesService.shared.rebuildIndex() }
        catch { self.error = error.localizedDescription }
        await refresh()
    }
}

@available(iOS 27.0, macOS 27.0, *)
struct NoteDetail: View {
    let id: UUID
    @State private var note: Note?
    @State private var error: String?
    @State private var confirmDelete = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Form {
            if let note {
                Text(note.name).font(.headline)
                Text(note.content)
                Button(note.isPinned ? "Unpin" : "Pin") {
                    Task {
                        do { self.note = try await NotesService.shared.update(id: id, name: nil, pinned: !note.isPinned) }
                        catch { self.error = error.localizedDescription }
                    }
                }
                Button("Delete Note", role: .destructive) { confirmDelete = true }
            } else { Text(error ?? "Loading note…") }
        }
        .appEntityIdentifier(EntityIdentifier(for: NoteEntity.self, identifier: id))
        .task(id: id) { await load() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await load() } } }
        .confirmationDialog("Delete this note?", isPresented: $confirmDelete) {
            Button("Delete Note", role: .destructive) {
                Task {
                    do { try await NotesService.shared.delete(id: id); dismiss() }
                    catch { self.error = error.localizedDescription }
                }
            }
        }
        .alert("FieldNotes", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("OK") { error = nil }
        } message: { Text(error ?? "") }
    }
    private func load() async {
        do {
            note = try await NotesService.shared.store.resolve([id]).first
            if note == nil { error = NoteError.missingNote.localizedDescription }
        } catch { self.error = error.localizedDescription }
    }
}
