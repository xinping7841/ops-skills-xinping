---
name: engineering-handoff-memory
description: Durable engineering memory for multi-agent handoff. Use when a task touches code behavior, module design, architecture decisions, SSH/MCP/sync/deployment configuration, machine state, runbooks, or when the user asks why something was changed, how to preserve context, or how to make future Codex/Kun agents read and update handoff notes.
---

# Engineering Handoff Memory

Use this skill to keep the Deepseek workspace from losing engineering context between machines, agents, and task cycles. It covers both code decisions and ops environment decisions.

## Start Workflow

1. Read `memory/LATEST.md` first when it exists.
2. Select additional memory by task type:
   - Machine, SSH, MCP, sync, scheduler, deploy, or local config: read `memory/machines/`, `memory/sync/`, relevant `memory/ops/`, and relevant `memory/runbooks/`.
   - Code behavior, bug fixes, module design, API contracts, or refactors: read relevant `memory/modules/`, `memory/code/`, and `memory/adr/`.
3. Keep `memory/LATEST.md` as an index and state summary only. Do not append a long diary there.

## End Workflow

Before finishing work that changed meaningful behavior or collaboration state:

1. Write one or more durable records:
   - Ops/environment changes -> `memory/ops/YYYY-MM/`.
   - Code behavior or business logic changes -> `memory/code/YYYY-MM/`.
   - Long-lived architecture decisions -> `memory/adr/`.
   - Long-lived module behavior changes -> update `memory/modules/`.
   - Machine state changes -> update `memory/machines/`.
   - Multi-machine path/sync policy changes -> update `memory/sync/`.
   - Repeatable procedures -> update `memory/runbooks/`.
2. Rewrite `memory/LATEST.md` with current focus, read-first links, active risks, and next steps.
3. Run `python3 scripts/memory-audit.py` from the repo root. Fix actionable failures before final response.
4. If no memory update is needed after a code/config task, state the reason in the final response.

## Tooling

Use the repo scripts when available instead of copying templates by hand:

- Create a record: `python3 scripts/memory-new.py <ops|code|adr|module|runbook> "Title"`.
- Preview a record: `python3 scripts/memory-new.py code "Example Change" --dry-run`.
- Audit only: `python3 scripts/memory-audit.py`.
- Handoff gate and commit preview: `python3 scripts/commit-and-handoff.py --dry-run`.
- Commit/push whitelisted changes: `python3 scripts/commit-and-handoff.py --commit` or `python3 scripts/commit-and-handoff.py --push`.

For the complete repeatable procedure, read `memory/runbooks/use-engineering-handoff-memory.md`.

## Record Rules

- Memory is for why, tradeoffs, validation, risks, and handoff notes. Do not duplicate every diff.
- Code comments are only for local surprising logic. Use memory for task-level and design-level reasons.
- Store Git-safe information only: paths, aliases, service names, variable names, commands, and sanitized summaries.
- Never store private keys, tokens, cookies, passwords, raw auth files, or secrets. Refer to secret locations by variable name or local config path only.
- Prefer short, link-rich records over huge narratives. Link to changed files and commands where possible.

## Templates

Use the templates in `memory/templates/`:

- `ops-change.md` for SSH, MCP, sync, scheduler, machine, deploy, and config changes.
- `code-change.md` for code behavior, bug fixes, module logic, API contracts, and refactors.
- `adr.md` for long-lived architecture decisions.
- `module-note.md` for durable module explanations.
- `runbook.md` for repeatable verification or repair procedures.
- `latest.md` for rewriting `memory/LATEST.md`.

## Audit

Run:

```bash
python3 scripts/memory-audit.py
```

The audit checks required directories, `LATEST.md` size, broken memory links, required headings, and obvious secret patterns.

## Commit Guidance

When committing, write memory before the commit. Use the memory record's Background, Changes, and Validation sections to build the commit message so Git history and handoff context stay aligned.

Prefer `python3 scripts/commit-and-handoff.py --dry-run` before manual commits. It enforces the memory-change gate for non-memory edits by default, lists which changed paths are inside the repo whitelist, and suggests a commit message from the newest changed ops/code/ADR record.
