import AppIntents
import CoreSpotlight
import Foundation

@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.account)
struct LocalAccount {
    static let defaultQuery = LocalAccountQuery()
    let id: String
    var name: String
    var displayRepresentation: DisplayRepresentation { .init(title: "\(name)") }
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    static var local: Self { Self(id: "local", name: "On this device") }
}

@available(iOS 27.0, macOS 27.0, *)
struct LocalAccountQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [LocalAccount] {
        identifiers.contains("local") ? [.local] : []
    }
}

@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.folder)
struct InboxEntity {
    static let defaultQuery = InboxQuery()
    let id: String
    var name: String
    var parentFolder: InboxEntity? { nil }
    var account: LocalAccount? { .local }
    var displayRepresentation: DisplayRepresentation { .init(title: "\(name)") }
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    static var inbox: Self { Self(id: "inbox", name: "Inbox") }
}

@available(iOS 27.0, macOS 27.0, *)
struct InboxQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [InboxEntity] {
        identifiers.contains("inbox") ? [.inbox] : []
    }
    func entities(matching string: String) async throws -> [InboxEntity] {
        "Inbox".localizedStandardContains(string) ? [.inbox] : []
    }
    func suggestedEntities() async throws -> [InboxEntity] { [.inbox] }
}

@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.note)
struct NoteEntity: IndexedEntity {
    static let defaultQuery = NoteQuery()
    let id: UUID
    var name: AttributedString
    var content: AttributedString?
    var attachments: [IntentFile]
    var isPinned: Bool
    var creationDate: Date?
    var modificationDate: Date?
    var folder: InboxEntity?

    init(_ note: Note) {
        id = note.id
        name = AttributedString(note.name)
        content = AttributedString(note.content)
        attachments = []
        isPinned = note.isPinned
        creationDate = note.created
        modificationDate = note.modified
        folder = .inbox
    }

    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(String(name.characters))", subtitle: "\(creationDate?.formatted() ?? "Inbox")")
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        attributes.title = String(name.characters)
        attributes.textContent = content.map { String($0.characters) }
        attributes.contentCreationDate = creationDate
        attributes.contentModificationDate = modificationDate
        return attributes
    }
}

@available(iOS 27.0, macOS 27.0, *)
struct NoteQuery: EntityStringQuery, IndexedEntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [NoteEntity] {
        try await NotesService.shared.store.resolve(identifiers).map(NoteEntity.init)
    }
    func entities(matching string: String) async throws -> [NoteEntity] {
        try await NotesService.shared.store.search(string).map(NoteEntity.init)
    }
    func suggestedEntities() async throws -> [NoteEntity] {
        try await NotesService.shared.store.all().suffix(10).reversed().map(NoteEntity.init)
    }
    func reindexEntities(for identifiers: [UUID], indexDescription: CSSearchableIndexDescription) async throws {
        try await NotesService.shared.rebuildIndex()
    }
    func reindexAllEntities(indexDescription: CSSearchableIndexDescription) async throws {
        try await NotesService.shared.rebuildIndex()
    }
}
