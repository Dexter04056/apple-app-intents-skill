#!/usr/bin/env python3
"""Validate this repository's distributable skill and relative resource links."""
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills/apple-app-intents"
EXCLUDED = {".git", ".build", ".swiftpm", "__pycache__", "DerivedData", "dist"}


def validate(root=ROOT):
    errors = []
    skill = root / "skills/apple-app-intents"
    entry = skill / "SKILL.md"
    text = entry.read_text()
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.S)
    if not match:
        return ["Missing YAML frontmatter"]
    front = match.group(1)
    name = re.search(r"^name: ([a-z0-9]+(?:-[a-z0-9]+)*)$", front, re.M)
    description = re.search(r"^description: (.+)$", front, re.M)
    if not name or name.group(1) != skill.name or len(name.group(1)) > 64:
        errors.append("Skill name must match its directory and Agent Skills syntax")
    if not description or not 1 <= len(description.group(1)) <= 1024:
        errors.append("Description missing or too long")
    if len(text.splitlines()) >= 500:
        errors.append("Entrypoint must remain below 500 lines")
    if (root / "LICENSE").read_bytes() != (skill / "LICENSE").read_bytes():
        errors.append("The standalone skill must contain the repository license")
    checked = 0
    for path in root.rglob("*.md"):
        if set(path.relative_to(root).parts) & EXCLUDED:
            continue
        # Ignore illustrative links in fenced code examples.
        content = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
        for target in re.findall(r"\[[^\]]*\]\(([^\s)]+)\)", content):
            url = urlsplit(target.strip("<>"))
            if url.scheme or target.startswith("#"):
                continue
            linked = (path.parent / unquote(url.path)).resolve()
            checked += 1
            if not linked.is_relative_to(root.resolve()) or not linked.exists():
                errors.append(f"Broken relative link in {path.relative_to(root)}: {target}")
            if path.is_relative_to(skill) and not linked.is_relative_to(skill.resolve()):
                errors.append(f"Installed skill depends on repository-external file: {target}")
    if not errors:
        print(f"Validated skill structure, bundled license, and {checked} local links. No Swift or Siri validation implied.")
    return errors


if __name__ == "__main__":
    failures = validate()
    for failure in failures:
        print(failure, file=sys.stderr)
    raise SystemExit(bool(failures))
