#!/usr/bin/env python3
"""Create a new engineering handoff memory file from a template."""

from __future__ import annotations

import argparse
import datetime as dt
import re
import subprocess
import sys
from pathlib import Path


TEMPLATES = {
    "ops": "memory/templates/ops-change.md",
    "code": "memory/templates/code-change.md",
    "adr": "memory/templates/adr.md",
    "module": "memory/templates/module-note.md",
    "runbook": "memory/templates/runbook.md",
}


def git_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        text=True,
        capture_output=True,
        check=True,
    )
    return Path(result.stdout.strip())


def slugify(text: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return slug or "untitled"


def replace_first_heading(template: str, heading: str) -> str:
    lines = template.splitlines()
    for index, line in enumerate(lines):
        if line.startswith("# "):
            lines[index] = heading
            return "\n".join(lines).rstrip() + "\n"
    return heading + "\n\n" + template.rstrip() + "\n"


def destination(root: Path, kind: str, title: str, date: dt.date, slug: str) -> Path:
    if kind in {"ops", "code"}:
        return root / "memory" / kind / date.strftime("%Y-%m") / f"{date.isoformat()}-{slug}.md"
    if kind == "adr":
        return root / "memory" / "adr" / f"{date.isoformat()}-{slug}.md"
    if kind == "module":
        return root / "memory" / "modules" / f"{slug}.md"
    if kind == "runbook":
        return root / "memory" / "runbooks" / f"{slug}.md"
    raise ValueError(f"unsupported kind: {kind}")


def render(root: Path, kind: str, title: str, date: dt.date) -> str:
    template_path = root / TEMPLATES[kind]
    if not template_path.exists():
        raise FileNotFoundError(f"missing template: {template_path}")
    template = template_path.read_text(encoding="utf-8")
    if kind in {"ops", "code"}:
        return replace_first_heading(template, f"# {date.isoformat()} {title}")
    if kind == "adr":
        return replace_first_heading(template, f"# ADR-{date.strftime('%Y%m%d')} {title}")
    return replace_first_heading(template, f"# {title}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a memory file from a template.")
    parser.add_argument("kind", choices=sorted(TEMPLATES))
    parser.add_argument("title", help="Human-readable title for the memory record.")
    parser.add_argument("--date", default=dt.date.today().isoformat(), help="Record date, YYYY-MM-DD.")
    parser.add_argument("--slug", help="Override filename slug.")
    parser.add_argument("--root", type=Path, help="Repository root. Defaults to git root.")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing file.")
    parser.add_argument("--dry-run", action="store_true", help="Print destination and preview without writing.")
    args = parser.parse_args()

    root = args.root.resolve() if args.root else git_root()
    try:
        date = dt.date.fromisoformat(args.date)
    except ValueError:
        print("--date must be YYYY-MM-DD", file=sys.stderr)
        return 2

    slug = args.slug or slugify(args.title)
    dest = destination(root, args.kind, args.title, date, slug)
    content = render(root, args.kind, args.title, date)

    if args.dry_run:
        print(dest)
        print("---")
        print(content, end="")
        return 0

    if dest.exists() and not args.force:
        print(f"refusing to overwrite existing file: {dest}", file=sys.stderr)
        return 1
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(content, encoding="utf-8")
    print(dest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

