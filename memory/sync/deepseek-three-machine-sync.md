# Deepseek Three-Machine Sync

## Source of Truth

GitHub repository: `git@github.com:xinping7841/ops-skills-xinping.git`

Local Codex/Kun directories are derived state and should not be treated as the long-term source.

## Workspace Paths

| Machine | Primary repo path | Notes |
|---|---|---|
| macair | `/Users/xinping/Documents/Deepseek` | launchd sync every 300 seconds |
| 12700K | `D:\Deepseek` | Windows scheduled task `Deepseek-Sync` |
| lk402 | `D:\Deepseek` | Windows scheduled task `Deepseek-Sync` |

Avoid using `C:\Users\gaoxi\Documents\Deepseek` on 12700K for normal Deepseek work.

## Auto-Sync Whitelist

The sync scripts may stage and commit only shared, non-secret project files such as:

- `AGENTS.md`
- `skill-*.md`
- `codex-skills/**`
- `memory/**`
- `setup-*.sh`, `setup-*.ps1`
- `auto-sync.sh`, `sync.ps1`, `sync-hidden.vbs`
- `codex-config-*.toml`
- `scripts/**`
- `machine-profiles/**`
- `mcp-templates/**`

Do not auto-commit machine-private files, tokens, `.env*`, logs, backups, router exports, or `*-settings.json`.

## Derived State

- `~/.codex/AGENTS.md` is a short index that points agents to this repo's `AGENTS.md`.
- `~/.codex/skills` is populated from `skill-*.md` and `codex-skills/**`.
- `~/.agents/skills` is linked or copied for GUI visibility.
- Codex/Kun MCP configs are local machine state; memory records should document intent and paths, not secrets.

## Conflict Policy

If `git pull --rebase` reports conflicts, stop and ask for human resolution. Do not auto-resolve sync conflicts.

## Last Verified

- Date: 2026-06-22
- Repo HEAD across all three machines: `8b602a17192a8a15b9c5a7c7f992af9b8c264d7b`

