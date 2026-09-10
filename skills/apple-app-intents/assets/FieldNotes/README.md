# FieldNotes

An original small SwiftUI example for the Apple App Intents skill. The app targets **iOS 27 with Xcode 27**. The Foundation-only persistence package has an older deployment baseline so its service tests can run independently.

## Implemented scope

| Capability | Implementation |
|---|---|
| Create a note | `.notes.createNote`, persistent plain text/name/pin state, returned `NoteEntity` |
| Rename or pin a note | `.notes.updateNote`, resolves current stored record by stable ID |
| Open a chosen note | Custom `OpenIntent` and app-name App Shortcut; observable navigation path |
| Find notes | ID lookup, text query, recent suggestions, named Spotlight index |
| Onscreen context | Persistent entity identifiers on rows and detail view |
| Delete | Confirmed in-app deletion and search-index reconciliation |
| Repair search | Explicit repair UI and rebuild at launch |

This is a **plain text, single-account, single-Inbox demo**. Richly attributed text, nonempty attachments, and foreign folders are rejected before mutation. The create/update schemas include those fields because the contract requires them; unsupported inputs do not become successful no-ops. The Notes update schema does not contain a content parameter, and this example does not invent one. Delete and open are not represented as nonexistent Notes-domain CRUD schemas.

The file store is owned by one app process. It is not a multiprocess database or cloud-sync implementation. Do not add an extension reading the same file without replacing it with coordinated storage. The sample uses a small local dataset; serialized full index rebuilds after mutations are intentionally simple and unsuitable for a large catalog. Failed indexing leaves saved data intact and a repair state; launch also rebuilds the index.

## Run service tests

From this directory, with a compatible Swift toolchain:

```sh
swift test
```

If Desktop/iCloud extended attributes interfere with signing generated test products, keep build products outside that tree:

```sh
swift test --scratch-path /tmp/fieldnotes-tests
```

These tests exercise durable create/update, identity through reopening, duplicate-name lookup, deletion, validation, and failed writes. They do not build the SwiftUI app or extract App Intents metadata.

## Build the iOS app

Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you want to generate the provided project (for example `brew install xcodegen`). Then:

```sh
xcodegen generate
xcodebuild -project FieldNotes.xcodeproj -scheme FieldNotes \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/FieldNotesDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

Alternatively, create an iOS 27 SwiftUI app target in Xcode and include all Swift files in `Sources/FieldNotesCore` and `App`; use `FieldNotesApp` as the only app entrypoint. The Xcode project intentionally compiles these into the app target so metadata extraction sees the intents directly.

For a device build, choose your own bundle identifier and signing team in Xcode, then run on an eligible device. Unsigned simulator builds do not establish device signing or Siri availability.

## Verify system behavior

Create two differently dated notes with the same name. In Shortcuts, select the intended note with Open Note and confirm the detail screen and ID remain correct after relaunch. Try creating and renaming with Siri on an eligible OS 27 device, inspect the returned content, and ask about the note visible onscreen. Delete a note in the app and confirm that search no longer returns it.

These are acceptance requests to test, not a claim that a device run has already passed. Refer to the repository's validation report for recorded evidence. The `FieldNotesSystemTests` XCUITest target includes an AppIntentsTesting create→rename→query scenario. It imports no app code and uses the system runtime. Set the same signing team for both app and test runner, select an eligible destination, and run the scheme's tests. If you change the app bundle ID, also change the test's `IntentDefinitions` bundle ID.

Use a disposable test installation: the system test creates a uniquely named synthetic note and intentionally does not expose a data-reset intent. Uninstall the test app to clear its fixture data. The system test is provided for device execution; its presence is not evidence that it ran.

## Extending the example

Add real folder/attachment storage before accepting those inputs. Add localized resources, a production database, bounded incremental index deletion/reindexing, account access controls, and actual sync as your product requires them. Donate real UI interactions when adopted, keeping that path distinct from system-invoked actions. Add content-transfer representations only for supported workflows. The example does not claim to implement those extensions.

Original example code is MIT licensed under the skill's bundled license. Apple framework APIs and tooling retain Apple's terms.
