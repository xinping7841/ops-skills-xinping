#!/usr/bin/env python3
"""Run handoff checks and optionally create a memory-driven commit."""

from __future__ import annotations

import argparse
import fnmatch
import re
import subprocess
import sys
from pathlib import Path


WHITELIST_FILES = {
    "AGENTS.md",
    ".gitattributes",
    ".gitignore",
    "auto-sync.sh",
    "sync.ps1",
    "sync-hidden.vbs",
    "setup-mac.sh",
    "setup-win.ps1",
    "setup-codex-macos.sh",
}
WHITELIST_PATTERNS = ["skill-*.md", "codex-config-*.toml", "setup-*.sh", "setup-*.ps1"]
WHITELIST_DIRS = ["codex-skills/", "memory/", "scripts/", "machine-profiles/", "mcp-templates/"]
GENERATED_PARTS = {"__pycache__"}
GENERATED_SUFFIXES = {".pyc", ".pyo"}


def run(cmd: list[str], cwd: Path, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, check=check)


def git_root() -> Path:
    return Path(run(["git", "rev-parse", "--show-toplevel"], Path.cwd()).stdout.strip())


def porcelain(root: Path) -> list[str]:
    return run(["git", "status", "--porcelain"], root).stdout.splitlines()


def staged_paths(root: Path) -> list[str]:
    output = run(["git", "diff", "--cached", "--name-only"], root).stdout.splitlines()
    return [line for line in output if line.strip()]


def git_path(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def is_generated(path: str) -> bool:
    parts = Path(path).parts
    if any(part in GENERATED_PARTS for part in parts):
        return True
    return Path(path).suffix in GENERATED_SUFFIXES


def expand_changed_path(root: Path, path: str) -> list[str]:
    if " -> " in path:
        path = path.rsplit(" -> ", 1)[1]
    full = root / path
    if full.is_dir():
        return [
            git_path(candidate, root)
            for candidate in sorted(full.rglob("*"))
            if candidate.is_file() and not is_generated(git_path(candidate, root))
        ]
    if is_generated(path):
        return []
    return [path]


def changed_paths(root: Path) -> list[str]:
    paths: list[str] = []
    for line in porcelain(root):
        if len(line) >= 4:
            paths.extend(expand_changed_path(root, line[3:]))
    return paths


def is_whitelisted(path: str) -> bool:
    if is_generated(path):
        return False
    if path in WHITELIST_FILES:
        return True
    if any(path.startswith(prefix) for prefix in WHITELIST_DIRS):
        return True
    name = Path(path).name
    return any(fnmatch.fnmatch(name, pattern) for pattern in WHITELIST_PATTERNS)


def first_heading(path: Path) -> str | None:
    if not path.exists():
        return None
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return None


def section_lines(text: str, heading: str, limit: int = 4) -> list[str]:
    marker = f"## {heading}"
    if marker not in text:
        return []
    body = text.split(marker, 1)[1]
    body = re.split(r"\n## ", body, maxsplit=1)[0]
    lines = []
    for raw in body.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("-"):
            lines.append(line)
        elif line and len(lines) < 1:
            lines.append(f"- {line}")
        if len(lines) >= limit:
            break
    return lines


def newest_memory_record(root: Path, paths: list[str]) -> Path | None:
    candidates = []
    primary_candidates = []
    for path in paths:
        if path.startswith(("memory/ops/", "memory/code/", "memory/adr/")) and path.endswith(".md"):
            full = root / path
            if full.exists() and "/templates/" not in path:
                candidates.append(full)
                if path.startswith(("memory/ops/", "memory/code/")):
                    primary_candidates.append(full)
    if primary_candidates:
        return max(primary_candidates, key=lambda p: p.stat().st_mtime)
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def clean_title(title: str) -> str:
    title = re.sub(r"^\d{4}-\d{2}-\d{2}\s+", "", title)
    title = re.sub(r"^ADR-\d{8}\s+", "", title)
    return title.strip()


def suggested_message(root: Path, paths: list[str]) -> str:
    record = newest_memory_record(root, paths)
    if not record:
        return "Update Deepseek engineering handoff memory"
    title = clean_title(first_heading(record) or "Update engineering handoff memory")
    text = record.read_text(encoding="utf-8")
    bullets = section_lines(text, "Changes", limit=4)
    validation = section_lines(text, "Validation", limit=2)
    message = title
    details = bullets + validation
    if details:
        message += "\n\n" + "\n".join(details)
    return message


def stage_whitelist(root: Path, paths: list[str]) -> list[str]:
    staged = []
    for path in sorted(set(paths)):
        if is_whitelisted(path):
            run(["git", "add", "--", path], root)
            staged.append(path)
    return staged


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit handoff memory and optionally commit whitelisted changes.")
    parser.add_argument("--commit", action="store_true", help="Stage whitelisted files and create a commit.")
    parser.add_argument("--push", action="store_true", help="Push after committing. Implies --commit.")
    parser.add_argument("--message", help="Commit message override.")
    parser.add_argument("--allow-no-memory", action="store_true", help="Allow non-memory changes without memory updates.")
    parser.add_argument("--dry-run", action="store_true", help="Show checks and suggested commit message only.")
    args = parser.parse_args()

    root = git_root()
    paths = changed_paths(root)
    has_non_memory = any(not p.startswith("memory/") for p in paths)
    has_memory = any(p.startswith("memory/") for p in paths)

    audit_cmd = ["python3", "scripts/memory-audit.py"]
    if has_non_memory and not args.allow_no_memory:
        audit_cmd.append("--require-memory-change")
    audit = subprocess.run(audit_cmd, cwd=root, text=True)
    if audit.returncode != 0:
        return audit.returncode

    if has_non_memory and not has_memory and not args.allow_no_memory:
        print("Non-memory changes require a memory update or --allow-no-memory.", file=sys.stderr)
        return 1

    message = args.message or suggested_message(root, paths)
    print("Changed paths:")
    if paths:
        for path in paths:
            marker = "whitelist" if is_whitelisted(path) else "skip"
            print(f"  - [{marker}] {path}")
    else:
        print("  none")
    print("\nSuggested commit message:\n")
    print(message)

    if args.dry_run or (not args.commit and not args.push):
        return 0

    pre_staged = staged_paths(root)
    if pre_staged:
        print("Refusing to commit because files are already staged:", file=sys.stderr)
        for path in pre_staged:
            print(f"  - {path}", file=sys.stderr)
        print("Unstage them or commit manually after reviewing the index.", file=sys.stderr)
        return 1

    staged = stage_whitelist(root, paths)
    if not staged:
        print("No whitelisted changes to commit.")
        return 0
    commit = subprocess.run(["git", "commit", "-m", message], cwd=root, text=True)
    if commit.returncode != 0:
        return commit.returncode
    if args.push:
        push = subprocess.run(["git", "push"], cwd=root, text=True)
        if push.returncode != 0:
            return push.returncode
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
