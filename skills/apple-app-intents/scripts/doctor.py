#!/usr/bin/env python3
"""Read-only environment and Swift integration inventory; never a Siri compliance test."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

SKIP = {".git", ".build", "DerivedData", "node_modules", "Pods", ".swiftpm"}
FEATURES = {
    "schema_macros": r"@App(?:Intent|Entity|Enum)\s*\(\s*schema\s*:",
    "intents": r"\b(?:AppIntent|OpenIntent)\b",
    "entities": r"\bAppEntity\b",
    "queries": r"\b(?:EntityQuery|EntityStringQuery|EntityPropertyQuery|IntentValueQuery)\b",
    "shortcuts": r"\bAppShortcutsProvider\b",
    "indexing": r"\b(?:IndexedEntity|indexAppEntities|IndexedEntityQuery)\b",
    "context": r"\b(?:appEntityIdentifier|appEntityUIElements|appEntity|userActivity)\b",
    "system_tests": r"\bAppIntentsTesting\b",
}


def command(argv):
    if not shutil.which(argv[0]):
        return {"status": "unavailable"}
    try:
        result = subprocess.run(argv, capture_output=True, text=True, timeout=15, check=False)
        return {"status": "ok" if result.returncode == 0 else "unavailable",
                "detail": (result.stdout + result.stderr).strip()[:2000]}
    except (OSError, subprocess.TimeoutExpired) as error:
        return {"status": "unavailable", "detail": str(error)}


def inventory(root: Path):
    counts = dict.fromkeys(FEATURES, 0)
    files = 0
    unreadable = 0
    for directory, names, filenames in os.walk(root, followlinks=False):
        names[:] = sorted(n for n in names if n not in SKIP and not (Path(directory) / n).is_symlink())
        for name in sorted(filenames):
            path = Path(directory) / name
            if path.suffix != ".swift" or path.is_symlink():
                continue
            try:
                if path.stat().st_size > 2_000_000:
                    unreadable += 1
                    continue
                content = path.read_text(encoding="utf-8")
            except (OSError, UnicodeError):
                unreadable += 1
                continue
            files += 1
            for feature, pattern in FEATURES.items():
                counts[feature] += bool(re.search(pattern, content))
    return {"swift_files": files, "skipped_or_unreadable_files": unreadable,
            "files_with_text_matches": counts}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", type=Path)
    args = parser.parse_args()
    if not args.project.is_dir():
        parser.error("project must be an existing directory")
    report = {"meaning": "Text inventory only; comments and strings may match. No build, credentials, network, or Siri test is performed.",
              "xcode": command(["xcodebuild", "-version"]),
              "swift": command(["swift", "--version"]),
              "source": inventory(args.project)}
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
