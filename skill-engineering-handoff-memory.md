# Engineering Handoff Memory Skill

Use this when a task touches code behavior, module design, architecture decisions, SSH/MCP/sync/deployment configuration, machine state, runbooks, or agent handoff.

Required workflow:

1. Start by reading `memory/LATEST.md` if it exists.
2. Read the relevant durable memory:
   - `memory/machines/`, `memory/sync/`, `memory/ops/`, `memory/runbooks/` for machine, SSH, MCP, sync, deploy, scheduler, or local config work.
   - `memory/modules/`, `memory/code/`, `memory/adr/` for code, module, API, behavior, or architecture work.
3. After meaningful changes, write or update the matching memory record and rewrite `memory/LATEST.md` as a concise handoff index.
4. Run `python3 scripts/memory-audit.py` before finishing.
5. If no memory update is needed after a code/config task, explain why in the final response.

Recommended tooling:

- `python3 scripts/memory-new.py <ops|code|adr|module|runbook> "Title"` creates records from templates.
- `python3 scripts/memory-new.py code "Example Change" --dry-run` previews the path and template.
- `python3 scripts/commit-and-handoff.py --dry-run` runs the audit gate, checks whether non-memory edits have memory updates, lists whitelisted paths, and suggests a memory-derived commit message.
- `python3 scripts/commit-and-handoff.py --commit` commits whitelisted files; `--push` also pushes.

For the full repeatable procedure, read `memory/runbooks/use-engineering-handoff-memory.md`.

Memory rules:

- Use memory for why, tradeoffs, validation, risks, and next handoff steps.
- Use code comments only for local surprising logic.
- Do not store secrets, tokens, private keys, cookies, passwords, or raw auth files.
- Keep `LATEST.md` short; link to detailed records instead of appending history.
