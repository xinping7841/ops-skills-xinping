# Use Engineering Handoff Memory

## Purpose

Create, validate, and hand off durable engineering memory for Deepseek code and ops work.

## When To Use

- Before and after tasks touching code behavior, module design, architecture decisions, SSH, MCP, sync, scheduler tasks, deployment configuration, or machine paths.
- When a future agent needs to understand why a code or environment decision was made.

## Prerequisites

- Work from the Deepseek repo root.
- Read `memory/LATEST.md` first.
- Read task-relevant memory under `memory/ops`, `memory/code`, `memory/adr`, `memory/modules`, `memory/machines`, `memory/sync`, or `memory/runbooks`.

## Steps

Create a new ops record:

```bash
python3 scripts/memory-new.py ops "Repair 12700K GitHub SSH"
```

Create a new code record:

```bash
python3 scripts/memory-new.py code "Stabilize device polling state"
```

Create a new ADR:

```bash
python3 scripts/memory-new.py adr "Use SQLite for local session index"
```

Create a module note:

```bash
python3 scripts/memory-new.py module "Device Control"
```

Preview a record path and template without writing:

```bash
python3 scripts/memory-new.py code "Example Change" --dry-run
```

Audit memory before handoff:

```bash
python3 scripts/memory-audit.py
```

Run the handoff gate and preview a commit message:

```bash
python3 scripts/commit-and-handoff.py --dry-run
```

Commit whitelisted changes using a memory-derived message:

```bash
python3 scripts/commit-and-handoff.py --commit
```

Commit and push:

```bash
python3 scripts/commit-and-handoff.py --push
```

## Expected Result

- `memory/LATEST.md` stays short and points to the important records.
- Detailed records live in `memory/ops`, `memory/code`, `memory/adr`, `memory/modules`, `memory/machines`, `memory/sync`, or `memory/runbooks`.
- `scripts/memory-audit.py` passes before handoff.
- Commit messages can be derived from memory records instead of vague summaries.

## Failure / Rollback

- If `memory-audit.py` reports broken links or missing headings, fix the record before handoff.
- If a task truly does not need memory, run `scripts/commit-and-handoff.py --allow-no-memory --dry-run` and explain why in the final response.
- If `commit-and-handoff.py --commit` stages unexpected files, stop before committing and inspect `git status --short`.

## Related Memory

- `memory/adr/2026-06-22-engineering-handoff-memory.md`
- `codex-skills/engineering-handoff-memory/SKILL.md`

