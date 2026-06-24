# AGENTS.md - Deepseek workspace entry

This repository is the shared source of truth for Codex/Kun skills, sync scripts, MCP templates, and handoff memory across macair, 12700K, and lk402.

Keep this file short. Do not paste full runbooks, machine inventories, or skill bodies here; every Codex thread reads this file, so oversized content becomes recurring input cost.

## Core Rules

- Start with `git pull --rebase` in this repo. If a rebase conflict appears, stop and ask for human resolution.
- Treat GitHub repo `xinping7841/ops-skills-xinping` as the only long-term source for shared skills and collaboration rules.
- Treat local `~/.codex/skills`, `~/.agents/skills`, and Kun GUI config as derived state.
- Add shared Codex skills under `codex-skills/<skill-name>/`.
- Add Kun/common skills as `skill-<topic>.md`.
- Do not commit machine-private files, tokens, `.env*`, logs, backups, router exports, `*-settings.json`, cookies, private keys, or plaintext passwords.
- Use UTF-8 when reading or writing Chinese markdown and PowerShell files.

## Handoff Memory

For tasks touching code behavior, module design, architecture, SSH, MCP, sync tasks, scheduled tasks, deployment config, machine paths, or durable agent handoff, use `engineering-handoff-memory`.

- Read `memory/LATEST.md` first.
- Then read only the task-relevant files under `memory/machines/`, `memory/sync/`, `memory/ops/`, `memory/runbooks/`, `memory/modules/`, `memory/code/`, or `memory/adr/`.
- Before finishing meaningful code/config/ops changes, update the relevant memory file, rewrite `memory/LATEST.md`, and run `python3 scripts/memory-audit.py`.
- If memory is not updated after such a task, explain why in the final reply.

## Read-On-Demand Files

- SSH or Tailscale: `skill-ssh-tailscale.md`, `skill-tailscale-derp.md`, plus relevant `memory/machines/` and `memory/ops/` records.
- Codex sandbox repair: `skill-codex-sandbox-repair.md`.
- MCP/Kun/Codex tool config: `skill-mcp-servers.md`.
- Multi-machine skill sync: `codex-skills/ops-terminal-sync/SKILL.md`, `skill-kun-skills-sync.md`.
- Web app work: `codex-skills/web-app-dev/SKILL.md`, `skill-web-app-dev-standards.md`.
- Code review/evaluation: `codex-skills/code-review-eval/SKILL.md`, `skill-code-review-eval.md`.
- Tables/spreadsheets: `codex-skills/table-data/SKILL.md`.
- Handoff process: `codex-skills/engineering-handoff-memory/SKILL.md`, `memory/runbooks/use-engineering-handoff-memory.md`.

## Git Hygiene

After changes, stage only whitelist-safe paths such as:

`AGENTS.md`, `.gitattributes`, `.gitignore`, `skill-*.md`, `codex-skills/**`, `memory/**`, `scripts/**`, `machine-profiles/**`, `mcp-templates/**`, `setup-*.sh`, `setup-*.ps1`, `auto-sync.sh`, `sync.ps1`, `sync-hidden.vbs`, and `codex-config-*.toml`.

Prefer `python3 scripts/commit-and-handoff.py --dry-run` before committing.
