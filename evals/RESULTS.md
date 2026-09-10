# Recorded evaluation: 2026-09-10

One independent agent evaluated case 2 from the [prompt set](README.md), using skill commit `1bf896d03b2e068dc409bc3777093c3daabfd3e8` (the skill content was unchanged from the initial publication). The evaluator was Codex `gpt-5.6-sol` at maximum reasoning effort, in a disposable workspace, with the installed Markdown skill, public Apple documentation, and Swift 6.4/macOS 27 Command Line Tools. No full Xcode or iPhoneOS SDK was available. This is a small behavioral smoke evaluation, not an agent benchmark or certification.

## Observed output

The agent produced an iOS 18 game integration plan and a custom dice-intent Swift vertical slice. It correctly identified the lack of a gaming schema, selected custom App Intents and curated App Shortcuts, preserved the requested iOS 18 target, and declined to promise arbitrary natural-language gameplay control. The plan covered shared services, stable player identifiers, authorization, persistent XP changes, parameter validation, and useful returned values.

The dice example passed parsing and typechecking in Swift 5 and Swift 6 language modes using the available **macOS 27** SDK. These results do not establish Xcode 16/iOS 18 compilation or App Intents metadata extraction. The agent explicitly left app-target, system-runtime, and device checks unverified.

| Rubric dimension | Observation |
|---|---|
| Semantic/API routing | Correct domain boundary and legacy strategy; exact old-SDK compatibility remains unverified |
| Data integrity | XP safeguards were specified in the plan; the generated vertical slice was dice, so no XP persistence execution was claimed |
| Useful implementation | Typed dice parameters, service injection, bounds checks, chainable total, dialog, and app-name phrases |
| Truthful evidence | Clearly separated newer-SDK typechecking from old-SDK app builds and Siri device behavior |

No automatic-failure behavior from the rubric was observed. A numeric aggregate would hide unexecuted platform checks, so this record reports the dimensions separately.

## Improvement made

The evaluation found that older-SDK guidance required too much inference. The platform reference now includes explicit Xcode 16, 26, and 27 routing and a warning that changing Swift language mode does not validate an older SDK. A compiled legacy sample remains future work.

Cases 1 and 3–5 have not been run as independent agent evaluations. The authored FieldNotes example, code review, service tests, and CI builds are separate evidence recorded in [validation](../docs/VALIDATION.md); they are not substituted for those cases.
