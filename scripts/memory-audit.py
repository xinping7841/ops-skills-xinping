#!/usr/bin/env python3
"""Audit engineering handoff memory files.

This is intentionally conservative: it catches broken structure and obvious
secret leaks without requiring every tiny change to produce a memory record.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


REQUIRED_DIRS = [
    "memory/ops",
    "memory/code",
    "memory/adr",
    "memory/modules",
    "memory/machines",
    "memory/sync",
    "memory/runbooks",
    "memory/templates",
]

REQUIRED_RECORD_HEADINGS = [
    "## Background",
    "## Changes",
    "## Why This Way",
    "## Alternatives Not Taken",
    "## Validation",
    "## Risks",
    "## Handoff Notes",
    "## Related Files",
]

LATEST_REQUIRED_HEADINGS = [
    "## Current Focus",
    "## Read First",
    "## Active Risks",
    "## Next Steps",
    "## Last Verified",
]

SECRET_PATTERNS = [
    re.compile(r"-----BEGIN (?:OPENSSH|RSA|DSA|EC|PRIVATE) KEY-----"),
    re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"\bctx7sk-[A-Za-z0-9-]{20,}\b"),
    re.compile(r"(?i)\b(api[_-]?key|access[_-]?token|secret|password|cookie)\s*[:=]\s*['\"]?[^\s'\"]{8,}"),
]


def run_git_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        check=True,
        text=True,
        capture_output=True,
    )
    return Path(result.stdout.strip())


def rel(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def iter_memory_markdown(root: Path):
    memory = root / "memory"
    if not memory.exists():
        return
    for path in memory.rglob("*.md"):
        yield path


def find_markdown_links(text: str):
    # Ignore URLs and anchors; check repo-relative memory links.
    for match in re.finditer(r"\[[^\]]+\]\(([^)]+)\)|`(memory/[^`]+\.md)`", text):
        target = match.group(1) or match.group(2)
        if not target or "://" in target or target.startswith("#"):
            continue
        target = target.split("#", 1)[0].strip()
        if target.startswith("memory/"):
            yield target


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit engineering handoff memory.")
    parser.add_argument("--max-latest-bytes", type=int, default=12000)
    parser.add_argument(
        "--require-memory-change",
        action="store_true",
        help="Fail when non-memory files changed but no memory/ files changed.",
    )
    args = parser.parse_args()

    root = run_git_root()
    errors: list[str] = []
    warnings: list[str] = []

    for directory in REQUIRED_DIRS:
        if not (root / directory).is_dir():
            errors.append(f"missing directory: {directory}")

    latest = root / "memory" / "LATEST.md"
    if not latest.is_file():
        errors.append("missing memory/LATEST.md")
    else:
        text = read_text(latest)
        if len(text.encode("utf-8")) > args.max_latest_bytes:
            errors.append(f"memory/LATEST.md exceeds {args.max_latest_bytes} bytes")
        for heading in LATEST_REQUIRED_HEADINGS:
            if heading not in text:
                errors.append(f"memory/LATEST.md missing heading: {heading}")

    for path in iter_memory_markdown(root) or []:
        text = read_text(path)
        relative = rel(path, root)

        for pattern in SECRET_PATTERNS:
            if pattern.search(text):
                errors.append(f"possible secret in {relative}: {pattern.pattern}")

        for target in find_markdown_links(text):
            if not (root / target).exists():
                errors.append(f"broken memory link in {relative}: {target}")

        if relative.startswith("memory/ops/") or relative.startswith("memory/code/"):
            if "/templates/" not in relative:
                missing = [h for h in REQUIRED_RECORD_HEADINGS if h not in text]
                if missing:
                    errors.append(f"{relative} missing headings: {', '.join(missing)}")
        if relative.startswith("memory/code/") and "/templates/" not in relative:
            if "## Module Notes Impact" not in text:
                errors.append(f"{relative} missing heading: ## Module Notes Impact")
        if relative.startswith("memory/ops/") and "/templates/" not in relative:
            if "## Machine / Sync Impact" not in text:
                errors.append(f"{relative} missing heading: ## Machine / Sync Impact")

    # Soft signal for meaningful git changes without memory updates.
    status = subprocess.run(
        ["git", "status", "--porcelain"],
        text=True,
        capture_output=True,
        cwd=root,
        check=False,
    ).stdout.splitlines()
    changed = [line[3:] for line in status if len(line) > 3]
    non_memory = [p for p in changed if not p.startswith("memory/")]
    memory_changes = [p for p in changed if p.startswith("memory/")]
    if non_memory and not memory_changes:
        message = "working tree has non-memory changes but no memory/ changes"
        if args.require_memory_change:
            errors.append(message)
        else:
            warnings.append(message)

    if warnings:
        print("Warnings:")
        for warning in warnings:
            print(f"  - {warning}")
        print("")

    if errors:
        print("Memory audit failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print("Memory audit passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
