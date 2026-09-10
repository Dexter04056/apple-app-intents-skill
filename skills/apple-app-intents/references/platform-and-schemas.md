# Platform and schema selection

Baseline checked 2026-09-10. Re-read the linked domain and symbol pages for the SDK in use. An API's introduction version and the rollout of the Siri experience that uses it are different facts.

## Capability layers

| Layer | What to implement | What it establishes |
|---|---|---|
| App Intents foundation | `AppIntent`, typed parameters/results, entity queries | Actions that system surfaces can use; availability varies by surface |
| App Shortcuts | `AppShortcutsProvider`, phrases containing application name | Curated entry points without users first composing a shortcut |
| Siri AI schemas | Matching `@AppIntent(schema:)`, `@AppEntity(schema:)`, `@AppEnum(schema:)` contracts | Structured capabilities the supported Siri domain can interpret |
| Content/context | Spotlight, view/entity annotations, transfer representations | Discoverable records, contextual references, cross-app values |
| Runtime delivery | Supported OS, hardware, language/region, Apple Intelligence enabled | Prerequisites for testing the intended Siri experience |

[Apple's framework introduction](https://developer.apple.com/videos/play/wwdc2025/244/) and [WWDC26 schema session](https://developer.apple.com/videos/play/wwdc2026/240/) explain these layers. Do not use a basic App Shortcut as evidence of schema-driven natural-language orchestration.

## Current domain map

Apple's [domain catalog](https://developer.apple.com/documentation/appintents/app-schema-domains) distinguishes:

| Current category | Domains |
|---|---|
| Primary Siri/Apple Intelligence | Audio, Calendar, Camera, Clock, Mail, Maps, Messages, Notes, Phone, Photos, Reminders, System and in-app search |
| Shortcuts-specific | Books, Browser, Files, Journaling, Presentation, Reader, Spreadsheet, Whiteboard, Word processor |
| Separate single-purpose surfaces | Assistant; Visual intelligence |

These categories are a dated lookup aid, not a promise about future releases. For each schema, inspect its **supported system experiences** section. A journaling app may honestly expose notes and photos if those are real features; it should not classify every journal operation as a note action.

Read completeness requirements for [Mail](https://developer.apple.com/documentation/appintents/app-schema-domain-mail), [Messages](https://developer.apple.com/documentation/appintents/app-schema-domain-messages), and [Clock](https://developer.apple.com/documentation/appintents/app-schema-domain-clock). These pages specify groups that must be adopted together. Build the app target and resolve the generated diagnostics; do not satisfy them with success-returning stubs.

## Availability and migration

- The framework began with iOS 16. Individual APIs were added later; inspect each symbol rather than assigning one minimum version to the whole integration.
- Older material uses `AssistantSchema`. The current SDK uses `AppSchema` and contains compatibility names. Use the terminology and spellings in the selected SDK.
- `supportedModes` is the modern execution-mode API (OS 26-era SDKs). Older targets may need `openAppWhenRun` or a compatible implementation. Do not remove working legacy support without a migration plan.
- Current `.notes.note`, `.notes.createNote`, and `.notes.updateNote` symbols require OS 27. Their fields differ from older Notes examples. See [note](https://developer.apple.com/documentation/appintents/appschema/notesentity/note), [createNote](https://developer.apple.com/documentation/appintents/appschema/notesintent/createnote), and [updateNote](https://developer.apple.com/documentation/appintents/appschema/notesintent/updatenote).
- Availability guards cannot make an unknown macro or missing SDK symbol compile. Separate newer source/targets when necessary and use an SDK that knows those APIs.

For existing integrations, preserve intent identity, entity IDs, parameter meaning, and enum raw values used by saved shortcuts. When contracts are incompatible, introduce a new schema intent alongside the existing intent. Apple's [migration guidance](https://developer.apple.com/documentation/appintents/making-actions-and-content-discoverable-by-apple-intelligence) describes temporary `isAssistantOnly` use to avoid duplicate actions. Verify its availability and plan retirement rather than deleting the old action immediately.

## Verification source order

Use current Apple symbol documentation and Xcode-generated schema templates for exact contracts, app-target compiler diagnostics for conformance, and device tests for actual Siri behavior. Sessions explain design; samples show integration. Third-party commentary can motivate UX decisions but does not override SDK types or supported surfaces. Record the source URL, SDK, minimum OS, and date beside decisions likely to drift.
