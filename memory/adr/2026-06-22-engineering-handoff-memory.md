# ADR-20260622 Engineering Handoff Memory

## Status

Accepted

## Context

The Deepseek workspace is maintained by multiple agents across multiple machines. Before this decision, machine configuration drift and code-context loss were handled by scattered skill files, Git history, sync logs, and ad hoc chat history. This made future agents prone to repeating investigations, missing why code or config was written a certain way, or accidentally using stale machine paths.

## Decision

Adopt `engineering-handoff-memory` as the durable handoff model for this repository. The system uses `memory/LATEST.md` as a short handoff index and separate durable records for ops, code, ADRs, modules, machines, sync, and runbooks. Meaningful code or environment changes should update the matching memory record and run `scripts/memory-audit.py` before handoff.

## Consequences

- Benefits:
  - Future agents have a stable entry point before changing code or machine state.
  - Code reasons, ops reasons, validation, risks, and next steps are preserved outside ephemeral chat.
  - Machine-specific drift can be documented without committing secrets.
- Costs:
  - Meaningful changes now require a small amount of memory maintenance.
  - Poorly maintained memory can become stale, so audit and `LATEST.md` discipline are required.
- Operational implications:
  - `memory/**` is now part of the auto-sync whitelist.
  - `AGENTS.md` requires reading and updating memory for relevant tasks.

## Alternatives Considered

- Only add code comments: skipped because comments cannot capture task-level tradeoffs, validation, machine state, or handoff risks.
- Only use Git commit messages: skipped because many machine-derived changes are not committed and commit messages are hard to query by module or machine.
- Only keep ops memory: skipped because code-level design intent and module behavior were also being forgotten.
- Use a heavy documentation portal immediately: skipped for first version because the current need is reliable Markdown memory plus audit, not site publishing.

## Validation / Review

- Created `codex-skills/engineering-handoff-memory/` and `skill-engineering-handoff-memory.md`.
- Created `memory/` structure, templates, first machine profiles, sync runbook, and first ops record.
- Added `scripts/memory-audit.py` and verified it passes on the initial memory set.
- Updated `AGENTS.md`, `auto-sync.sh`, and `sync.ps1` so the workflow and `memory/**` sync behavior are explicit.

## Links

- `memory/LATEST.md`
- `codex-skills/engineering-handoff-memory/SKILL.md`
- `skill-engineering-handoff-memory.md`
- `scripts/memory-audit.py`
- `memory/ops/2026-06/2026-06-22-three-machine-collab-env-repair.md`

