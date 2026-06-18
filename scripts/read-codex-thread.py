#!/usr/bin/env python3
"""Read a local Codex Desktop thread JSONL and render a compact Markdown transcript."""
from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Any, Iterable

THREAD_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.I)


def normalize_thread_id(value: str) -> str:
    match = THREAD_RE.search(value)
    if not match:
        raise SystemExit(f"No Codex thread id found in: {value}")
    return match.group(0).lower()


def iter_state_dbs(codex_home: Path) -> Iterable[Path]:
    for path in (codex_home / "state_5.sqlite", codex_home / "sqlite" / "state_5.sqlite"):
        if path.exists():
            yield path


def path_from_sqlite(codex_home: Path, thread_id: str) -> Path | None:
    for db_path in iter_state_dbs(codex_home):
        try:
            conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
            try:
                row = conn.execute(
                    "SELECT rollout_path FROM threads WHERE lower(id)=lower(?)",
                    (thread_id,),
                ).fetchone()
            finally:
                conn.close()
        except sqlite3.Error:
            continue
        if row and row[0]:
            path = Path(row[0]).expanduser()
            if path.exists():
                return path
    return None


def path_from_session_index(codex_home: Path, thread_id: str) -> Path | None:
    index = codex_home / "session_index.jsonl"
    if not index.exists():
        return None
    try:
        for line in index.read_text(errors="replace").splitlines():
            if thread_id not in line.lower():
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            for key in ("rollout_path", "path", "file", "session_path"):
                value = obj.get(key)
                if isinstance(value, str):
                    path = Path(value).expanduser()
                    if path.exists():
                        return path
    except OSError:
        return None
    return None


def path_from_scan(codex_home: Path, thread_id: str) -> Path | None:
    sessions = codex_home / "sessions"
    if not sessions.exists():
        return None
    matches = sorted(sessions.rglob(f"*{thread_id}*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    return matches[0] if matches else None


def find_thread_path(codex_home: Path, thread_id: str) -> Path:
    for finder in (path_from_sqlite, path_from_session_index, path_from_scan):
        path = finder(codex_home, thread_id)
        if path:
            return path
    raise SystemExit(f"Thread {thread_id} not found under {codex_home}")


def text_from_content(content: Any) -> str:
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""
    parts: list[str] = []
    for item in content:
        if isinstance(item, str):
            parts.append(item)
        elif isinstance(item, dict):
            for key in ("text", "message", "input", "output"):
                value = item.get(key)
                if isinstance(value, str) and value:
                    parts.append(value)
                    break
    return "\n".join(parts).strip()


def compact_text(value: str, limit: int | None) -> str:
    value = value.strip()
    if limit and len(value) > limit:
        return value[: limit - 20].rstrip() + "\n…[truncated]"
    return value


def render_item(obj: dict[str, Any], include_tools: bool, max_chars: int | None) -> str | None:
    timestamp = obj.get("timestamp", "")
    payload = obj.get("payload") or {}
    top_type = obj.get("type")

    if top_type == "session_meta":
        return (
            f"## Session\n"
            f"- id: `{payload.get('id', '')}`\n"
            f"- cwd: `{payload.get('cwd', '')}`\n"
            f"- model: `{payload.get('model_provider', '')}`\n"
            f"- started: `{payload.get('timestamp', timestamp)}`"
        )

    if top_type == "compacted":
        message = compact_text(str(payload.get("message", "")), max_chars)
        return f"## Compacted Context\n\n{message}" if message else None

    if top_type != "response_item":
        return None

    item_type = payload.get("type")
    role = payload.get("role")
    if item_type == "message" and role in {"user", "assistant", "system", "developer"}:
        text = compact_text(text_from_content(payload.get("content")), max_chars)
        if not text:
            return None
        title = role.capitalize()
        return f"## {title} · {timestamp}\n\n{text}"

    if include_tools and item_type in {"function_call", "function_call_output", "local_shell_call", "mcp_tool_call"}:
        name = payload.get("name") or item_type
        if item_type == "function_call_output":
            text = payload.get("output", "")
            title = f"Tool Output `{payload.get('call_id', '')}`"
        else:
            text = payload.get("arguments") or payload.get("input") or payload.get("action") or ""
            title = f"Tool Call `{name}`"
        if not isinstance(text, str):
            text = json.dumps(text, ensure_ascii=False, indent=2)
        text = compact_text(text, max_chars)
        return f"## {title} · {timestamp}\n\n```\n{text}\n```"

    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("thread", help="Codex thread id or codex://threads/<id> URI")
    parser.add_argument("--codex-home", default=os.environ.get("CODEX_HOME", "~/.codex"))
    parser.add_argument("--include-tools", action="store_true", help="Include tool calls and outputs")
    parser.add_argument("--max-chars", type=int, default=12000, help="Max chars per transcript block; 0 disables truncation")
    parser.add_argument("--jsonl-path", action="store_true", help="Only print the source JSONL path")
    args = parser.parse_args()

    thread_id = normalize_thread_id(args.thread)
    codex_home = Path(args.codex_home).expanduser()
    path = find_thread_path(codex_home, thread_id)
    if args.jsonl_path:
        print(path)
        return 0

    max_chars = args.max_chars or None
    rendered: list[str] = [f"# Codex Thread `{thread_id}`", f"Source: `{path}`"]
    seen_session = False
    with path.open(errors="replace") as handle:
        for line in handle:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            block = render_item(obj, args.include_tools, max_chars)
            if not block:
                continue
            if block.startswith("## Session"):
                if seen_session:
                    continue
                seen_session = True
            rendered.append(block)
    print("\n\n".join(rendered))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
