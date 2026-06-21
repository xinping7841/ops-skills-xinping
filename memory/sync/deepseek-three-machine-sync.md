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
- `.gitattributes`, `.gitignore`
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

Do not keep one-off live-network probes or local credential-bearing scripts in the repo root. Convert reusable procedures into sanitized `memory/runbooks/` entries or skill references.

## Derived State

- `~/.codex/AGENTS.md` is a short index that points agents to this repo's `AGENTS.md`.
- `~/.codex/skills` is populated from `skill-*.md` and `codex-skills/**`.
- `~/.agents/skills` is linked or copied for GUI visibility.
- Sync runtime logs live under `.sync-reports/sync.log`, not root `sync.log`.
- Codex/Kun MCP configs are local machine state; memory records should document intent and paths, not secrets.

## Conflict Policy

If `git pull --rebase` reports conflicts, stop and ask for human resolution. Do not auto-resolve sync conflicts.

## Last Verified

- Date: 2026-06-22
- Repo HEAD before cleanup commit: `45870e63bac99de2ccdc46a6634f1ffae7f8cfd3`
- `macair`, `12700K`, and `lk402` were checked for root-level local drift; obsolete ignored/untracked cleanup artifacts were removed where safe.
