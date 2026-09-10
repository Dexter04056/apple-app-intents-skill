import AppIntentsTesting
import Foundation
import XCTest

/// Run against a disposable FieldNotes installation with matching signing teams.
/// This intentionally imports no application module.
final class NoteIntentTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testCreateRenameAndResolveThroughSystem() async throws {
        let definitions = IntentDefinitions(bundleIdentifier: "org.example.FieldNotes")
        let uniqueName = "FieldNotesIntegration-\(UUID().uuidString)"
        let created = try await definitions.intents["CreateNoteIntent"].makeIntent(
            name: uniqueName,
            content: "Created through the system intent runtime",
            attachments: [String](),
            isPinned: false
        ).run()
        let renamed = uniqueName + "-renamed"
        let updated = try await definitions.intents["UpdateNoteIntent"].makeIntent(
            target: created.value,
            name: renamed,
            isPinned: true
        ).run()
        let resultName: AttributedString = try updated.value.name
        XCTAssertEqual(String(resultName.characters), renamed)
        let matches = try await definitions.entities["NoteEntity"].entities(matching: renamed)
        XCTAssertEqual(matches.count, 1)
        let matchedName: AttributedString = try matches[0].name
        XCTAssertEqual(String(matchedName.characters), renamed)
    }
}
