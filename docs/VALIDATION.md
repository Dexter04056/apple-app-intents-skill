# Validation scope

This page distinguishes reproducible checks from verification that requires Apple tooling and an eligible device. The following evidence was recorded on **2026-09-10**, with final sample source at commit [`7f99b15`](https://github.com/Sdefendre/apple-app-intents-skill/commit/7f99b15a9e07a9dd45e40e54af25282816cc76d3).

## Recorded results

| Gate | Result and limit |
|---|---|
| Skill structure and bundled license | Passed repository validator; the local Codex skill-creator validator also passed |
| Installer and environment helper | All 7 Python behavioral tests passed, including preservation and unsafe-path cases |
| Swift persistence service | All 4 Swift Testing tests passed in Xcode 27 CI; durable writes, reopening, identity, duplicates, deletion, validation, and write failures covered |
| iOS application and metadata | Xcode 27 beta 6, iOS 27 simulator SDK: `build-for-testing` passed and `ExtractAppIntentsMetadata` ran for the app |
| System-test target | Compiled successfully with AppIntentsTesting, including create/rename/query and active-UI assertion; **not executed** |
| Independent agent trial | One older-SDK/unmatched-domain case completed; [observations and limits](../evals/RESULTS.md) |
| Device and system experience | Siri, Shortcuts execution, Spotlight results, onscreen resolution, and cross-app behavior **not device-verified** |

The [source validation run](https://github.com/Sdefendre/apple-app-intents-skill/actions/runs/34439898647) includes both passing jobs and an uploaded build log. It is an unsigned simulator build, not a signed device installation. Check the [current workflow](https://github.com/Sdefendre/apple-app-intents-skill/actions/workflows/ci.yml) for subsequent commits.

A separate local compiled service harness exercised durable operations and rejected a deliberately broken ID resolver. A disposable-copy installer test also failed when file copying was replaced with an empty directory creation. These mutation checks confirmed that those behavioral checks detect the corresponding defects; they are not a comprehensive mutation score.

Read-only review and actual compiler diagnostics prompted fixes for macro-generated property initialization, Swift isolation of the search index, ordered index rebuilds, explicit clearing versus omitted update parameters, launching the system-test app, and visible UI refresh after intent mutations. The passing build includes those fixes. None of these source checks are substituted for device acceptance.

## Reproduce package checks

```sh
python3 scripts/validate.py
python3 -m unittest discover -s tests -v
```

The repository validator checks the portable entrypoint, bundled license, and relative file links. The installer tests exercise real copies into temporary directories, custom paths with spaces, preservation of existing customizations, and rejection of unsafe source/destination layouts. The environment helper is a text inventory only.

The Codex skill-creator validator can additionally check the entrypoint where that tool is installed. It is not a required consumer dependency and does not assess Swift API correctness.

## Swift and system checks

Run the commands in [FieldNotes](../skills/apple-app-intents/assets/FieldNotes/README.md). The persistence package is separate from the app target so a service-test pass is not mistaken for App Intents metadata extraction. CI explicitly builds the iOS app with Xcode 27 using GitHub's documented preview runner.

On the development host, command-line tools expose the macOS 27 Swift interfaces but lack the AppIntentsMacros and SwiftUIMacros plugins required for a complete app check. Direct `swiftc` typechecking on that host is therefore not app-build evidence. Full Xcode CI is required for those declarations.

## Device checks still required

No Siri-capable iPhone was used to validate this repository's example during authoring. Manual Siri, Spotlight, Shortcuts, onscreen resolution, and cross-app flows remain device acceptance work. The repository does not claim AppIntentsTesting execution, signing, App Store submission, or universal agent behavior from static validation.

See [the system test matrix](../skills/apple-app-intents/references/testing-and-release.md) and [agent evaluations](../evals/README.md). A future contributor can add device evidence with the exact app commit, OS build, device/language/region, request, expected result, and observation.
