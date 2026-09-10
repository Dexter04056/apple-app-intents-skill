# Research: App Intents, App Schemas, and Siri AI

**Evidence baseline:** September 10, 2026

**Scope:** Apple App Intents and App Schemas for Siri, Shortcuts, Spotlight, and related system experiences. Source identifiers in brackets resolve to the complete [source inventory](SOURCES.md).

This report treats current Apple documentation and WWDC transcripts as the authority for framework contracts. Apple announcements establish product direction and rollout status, but they do not prove that a particular third-party app, schema, language, or device works at runtime. Matthew Cassinelli's work supplies useful practitioner judgment about capability design and usability; it is not SDK authority. Exact symbols, generated templates, and availability must be checked again against the Xcode SDK used for an implementation.

## The durable model is capability exposure

App Intents is the typed interface between an app's existing behavior and Apple system experiences. An `AppIntent` describes an action and its parameters and result. An `AppEntity` describes meaningful app content with an identity, properties, display representation, and retrieval path. Queries resolve entities or search for them. App Shortcuts promote selected intents as ready-made entry points. This foundation existed before Siri AI and also serves Shortcuts, Spotlight, widgets, controls, and hardware affordances [A10].

WWDC26 adds a more specific Siri integration layer. App Schemas give system-defined meanings to compatible intents, entities, and enumerations. The macros map an app type to a known schema, while the app continues to own storage, authorization, navigation, and side effects. Apple presents Siri as the language interpreter and system orchestrator; developers provide accurate structured capabilities and content [A4, A5]. A custom intent can remain valuable in Shortcuts or another surface even when it has no schema that Siri AI understands.

The practical implication is to start with the app, not a list of imagined utterances. Inventory each real user action, the service operation that performs it, its inputs, entity identities, result, authorization, execution mode, and eligible system surface. Then select a schema only when the semantics match. This approach keeps UI labels and conversational phrasing from becoming a second implementation of the product.

## Schema coverage has explicit boundaries

Apple's catalog divides the current domains into three groups [D1]:

| Catalog category | Domains at the baseline | Meaning |
|---|---|---|
| Primary Siri and Apple Intelligence | Audio, Calendar, Camera, Clock, Mail, Maps, Messages, Notes, Phone, Photos, Reminders, System and in-app search | Their schema pages describe Siri or Apple Intelligence participation. Each schema still has its own supported experiences and availability. |
| Single-purpose | Assistant, Visual intelligence | These connect to a particular system surface outside the general Siri domain catalog. |
| Shortcuts-specific | Books, Browser, Files, Journaling, Presentation, Reader, Spreadsheet, Whiteboard, Word processor | Conformance supports Shortcuts; the catalog expressly says it does not make those types discoverable by Apple Intelligence and Siri. |

This is a dated catalog, not a claim that every app category has Siri AI coverage. The WWDC26 Apple Intelligence Group Lab advised developers to adopt only schemas that genuinely fit, mix domains when appropriate, and use custom App Intents, Spotlight, App Shortcuts, or view annotations for the remaining capabilities [A12]. Relabeling a time record as an alarm or a generic contact as a message participant creates a misleading contract and unreliable system behavior.

Some domains also impose completeness rules. At this baseline, adopting any schema in **Mail, Clock, or Messages requires the app to implement every schema in that domain's required group**. Xcode validates this during the consuming target's build [D2, D3]. Notes does not carry the same all-or-nothing statement: its current page lists `createNote` and `updateNote`. Developers must inspect the actual domain page and generated template rather than extrapolating a universal CRUD set. Additional optional properties can improve the Shortcuts action without necessarily becoming inputs Apple Intelligence understands [D2].

Schema conformance is structural. It does not create business behavior, persisted data, indexing, authorization, or navigation. A generated stub that returns success merely satisfies source shape; it is not a working implementation. A schema intent must map resolved parameters into the same application service as the UI, await the actual commit, and return a truthful typed result. Entity queries must rehydrate current authorized records, omit stale identifiers, and preserve ambiguity instead of silently choosing the first match. The detailed implementation consequences live in the skill's [architecture](../skills/apple-app-intents/references/architecture.md), [entity and search](../skills/apple-app-intents/references/entities-and-search.md), and [schema selection](../skills/apple-app-intents/references/platform-and-schemas.md) guides.

## Content must be findable and transferable

An entity declaration describes content, but a declaration alone does not place instances in Spotlight. Apple's CometCal walkthrough makes the lifecycle explicit: conform appropriate persistent content to `IndexedEntity`, submit created and updated entities to a named `CSSearchableIndex`, and remove deleted entities [A5, D6]. The application must also reconcile logout, access revocation, partial failures, and reindex requests. Frequently changing or server-scale content may call for structured lookup with `IntentValueQuery` instead of indexing the complete catalog [A6].

Onscreen context has the same identity requirement. A primary activity can associate one entity through user activity; lists and other multi-item interfaces use view annotations. The identifier attached to a view must be the identifier the entity query can resolve. An annotation macro or modifier proves neither that the record exists nor that Siri selected the intended item [A4, A5].

Cross-app transfer requires a representation the receiving capability understands. File or data representations remain appropriate for established formats. `IntentValueRepresentation` supports certain system-understood structured values, while `IntentValueQuery` can resolve an incoming value to an existing app record [A4, A8, D6]. Conformance is not a universal interchange promise: both sides, the value type, the schema, and the runtime surface must be compatible. Imports must not turn a lookup into an unintended duplicate record.

## Compilation, extraction, system tests, and Siri are different evidence

The framework generates an App Intents representation from Swift source at build time. Apple says this processing happens individually for each target. Shared framework or Swift-package declarations use `AppIntentsPackage`, and each consuming app or extension must include the relevant package dependency so the runtime can index and validate those types [A10, D5]. Therefore, a successful package build establishes that the module compiles; it does **not** establish that the installed app bundle exports those intents.

Evidence should be reported as separate gates:

| Gate | What positive evidence establishes | What remains unproven |
|---|---|---|
| Application service tests | Mutations, validation, persistence, authorization, and failure behavior work when called as application code. | App Intents metadata and system execution. |
| Swift package or framework build | Shared declarations compile for that module and SDK. | Inclusion in any consuming app's extracted metadata. |
| Real app-target build and metadata extraction | The selected app target contains discoverable definitions and passes macro, target-membership, and required-schema diagnostics. | Installed runtime selection and conversational behavior. |
| AppIntentsTesting | An XCUITest runner addresses the installed app by bundle identifier and exercises intents, entities, queries, chaining, Spotlight, or annotations across a process boundary. | Complete Siri language understanding, rollout eligibility, and every UI or voice surface. |
| Manual Shortcuts, Spotlight, and Siri workflows | The exact installed build behaves on the tested device, OS build, language, region, account, and settings. | Other untested configurations and future rollout changes. |

AppIntentsTesting is not a unit test that imports the app and calls `perform()`. Apple places it in an XCUITest bundle; the runner and app use the same signing team, execute in separate processes, and locate extracted definitions through `IntentDefinitions` and the app's bundle identifier [A7, D4]. Tests can drive entity queries, chain a returned entity into another intent, inspect Spotlight results, and retrieve reported view annotations. Test-only setup intents should be undiscoverable and excluded from release builds. Apple still ends the workflow with manual Siri and Shortcuts testing [A7].

This distinction matters for portable coding agents. An agent working without full Xcode can review source and produce a plan. A package-only CI job can prove compilation. Neither result should be labeled Siri-ready. The [testing guide](../skills/apple-app-intents/references/testing-and-release.md) defines the evidence and reporting language for each gate.

## OS 27 additions improve specific constraints

WWDC26 session 345 introduces focused capabilities rather than a new minimum checklist [A8]. `EntityCollection` can carry identifiers when an operation need not eagerly hydrate every full entity. `SyncableEntity` describes identity that is already stable across devices; it does not implement synchronization. `RelevantEntities` adds contextual suggestions alongside two existing channels: Spotlight for searchable or retrievable content, and interaction donations for completed behavior the system can learn from. These mechanisms have different lifecycle and privacy implications.

The same session covers richer native parameters, union values, long-running work, cancellation, and explicit execution targets. `LongRunningIntent` extends eligible work beyond the ordinary budget described in the session and requires progress reporting. `CancellableIntent` supplies cancellation handling, but an app must still clean up or reconcile partial remote work. Execution targets control whether an app, App Intents extension, or WidgetKit extension runs shared intent code; `supportedModes` separately describes foreground and background behavior. The exact platform availability and current spelling for each symbol belong in [advanced-2026.md](../skills/apple-app-intents/references/advanced-2026.md), not in assumptions derived from a talk.

## Announcements do not equal runtime availability

The WWDC26 keynote and special presentation establish Apple's direction: Siri AI uses personal context, onscreen awareness, system orchestration, Spotlight, and app capabilities supplied through App Intents [A1, A9]. They are useful context, not verification of a third-party integration.

At the September 10 baseline, Apple's June 8 release stated that new Siri AI features were in developer testing for iOS 27, iPadOS 27, macOS 27, and visionOS 27, with watchOS testing planned for a later beta. The consumer release was described as a beta later in 2026, initially for supported devices set to English. Apple also listed regional restrictions, including no initial iPhone or iPad Siri AI availability in the EU and no Siri AI availability in China at that time [A2]. Apple's developer guide separately warns that features can change and vary by region, language, and law [A3].

These conditions are independent of SDK compilation. A type can compile while the intended Siri surface is unavailable for the device, account, language, region, or current seed. The Group Lab did not confirm CarPlay view-annotation support and said the new Siri beta was not available on HomePod, while existing App Shortcuts remained a different HomePod path [A12]. Release claims must therefore record the precise environment and observed request rather than infer universal behavior from a keynote or a schema macro.

## Practitioner guidance from Matthew Cassinelli

Cassinelli's App Intents Digest and talks reinforce a useful action-centered mental model: begin with the app's important actions and nouns, make identifiers and outputs composable, and test from the surfaces people actually use [C1, C7]. His recommended session order starts with Apple's current mental model and design guidance before older implementation history; he specifically notes that the 2024 design session supersedes portions of the 2021 advice [C5].

His app reviews add practical usability judgments. Deep integrations expose meaningful product operations instead of token support. Preconfigured App Shortcuts can make common variants immediately discoverable while the underlying configurable action remains reusable. Clear names, populated entity choices, and coherent parameters are preferable to dozens of nearly identical button-shaped actions [C6]. These are design recommendations, not Apple requirements.

Cassinelli's WWDC26 posts are valuable indexes and readable annotations of Apple demonstrations, especially for entity relevance, structured transfer, bulk resolution, stable identity, and long-running execution [C2-C4]. Technical claims in those posts were checked against the Apple sessions and symbol pages before inclusion here. His commercial capability-mapping material was not copied, adapted as a proprietary framework, or treated as an endorsement. The skill uses a generic capability table derived from the engineering need to connect real services to public intent contracts.

## Remaining uncertainty

The catalog and OS 27 symbols are likely to evolve after this dated baseline. Generated Xcode templates remain the best check for exact required fields, optionality, result types, and diagnostics. Device testing remains necessary for natural-language selection, clarification, confirmation, voice-only responses, and multi-turn behavior.

No current technical transcript was available for Cassinelli's September 9, 2026 TWiT appearance, so this report draws no implementation claims from it [C8]. His announced NSSpain talk, “Preparing Your App for Siri AI: App Intents Deep Dive,” was scheduled after this baseline and had not yet been delivered [C8]. No public Cassinelli-authored WWDC26 App Schemas sample repository or dedicated AppIntentsTesting technical guide was located. Those gaps should not be filled by inference.
