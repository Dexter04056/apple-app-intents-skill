# Validation scope

This page distinguishes reproducible checks from verification that requires Apple tooling and an eligible device. Current command outcomes are recorded below before release; CI is visible in the repository's Actions tab.

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
