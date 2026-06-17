---
name: ops-terminal-sync
description: Synchronize and maintain the Deepseek ops skills workspace across multiple terminals and machines. Use when the user asks to deploy, verify, repair, or document multi-machine terminal skill sync, Deepseek/ops-skills-xinping setup, Codex/Kun AGENTS.md sharing, scheduled Git sync, Windows Deepseek-Sync task, macOS launchd sync, or GitHub-distributed skill packages.
---

# Ops Terminal Sync

Use this skill to keep the shared ops skills repository working across Codex, Kun, Windows, macOS, and Linux terminals.

## Repository

- GitHub: `git@github.com:xinping7841/ops-skills-xinping.git`
- Preferred macOS/Linux path: `~/Documents/Deepseek`
- Preferred Windows path: `D:\Deepseek`; accept `~/Documents/Deepseek` when that is where the repo is already cloned.
- Main shared instruction file: `AGENTS.md`
- Kun skill files: `skill-*.md`
- Codex skill package path in repo: `codex-skills/ops-terminal-sync`

## Workflow

1. Locate the repo. Check the preferred path first, then common alternates under the user's Documents folder.
2. Run `git status --short` and `git remote -v`. Confirm the remote is `xinping7841/ops-skills-xinping` before making sync changes.
3. Inspect deployment scripts before running them:
   - Windows: `setup-win.ps1`, `sync.ps1`
   - macOS/Linux: `setup-mac.sh`, `auto-sync.sh`
4. Deploy for the current OS:
   - Windows: `powershell -ExecutionPolicy Bypass -File setup-win.ps1`
   - macOS/Linux: `bash setup-mac.sh`
5. Verify the scheduler:
   - Windows task name: `Deepseek-Sync`, every 5 minutes.
   - macOS launchd label: `com.ops-skills.sync`, every 300 seconds.
6. Verify local Codex install:
   - `~/.codex/AGENTS.md` matches the repo `AGENTS.md`.
   - `~/.codex/skills/ops-terminal-sync/SKILL.md` exists after setup or sync.
   - `~/.agents/skills/<skill>` is linked or copied for UI visibility.
   - `~/.codex/config.toml` has `[skills.<skill>] path = ...` entries for visible skills.
7. Commit and push script or skill changes so other machines receive them.

## Source-of-truth model

- GitHub repo `xinping7841/ops-skills-xinping` is the only long-term source for shared instructions, MCP templates, and shared skills.
- Local Codex/Kun directories are derived state:
  - `~/.codex/skills`
  - `~/.agents/skills`
  - `~/.codex/config.toml` skill registrations
  - Kun GUI extraDirs / MCP runtime config
- Add new shared Codex skills under `codex-skills/<skill-name>/`.
- Add Kun/common markdown skills as `skill-<topic>.md`.
- Local-only skills that are not in the repo are "orphan skills"; audit and report them, but do not auto-import or auto-commit them.

## Guardrails

- Do not overwrite unrelated user files outside the repo, `~/.codex/AGENTS.md`, `~/.codex/skills/ops-terminal-sync`, SSH config marker block `### ops-skills ###`, and the documented scheduler entry.
- Before deleting or replacing a skill directory, resolve and verify the destination remains inside `~/.codex/skills`.
- If `git pull --rebase` reports conflicts, stop and report the conflicted files instead of guessing a resolution.
- Keep machine-specific paths out of `sync.ps1` and `auto-sync.sh` unless they are fallback search paths.
- Use UTF-8 when reading or writing Chinese markdown files and PowerShell scripts.
- Sync scripts must use a local `.sync.lock` and skip when another sync is already running.
- Sync scripts must not use broad `git add -A`. Stage only the documented whitelist:
  - `AGENTS.md`
  - `skill-*.md`
  - `codex-skills/**`
  - `setup-*.sh`, `setup-*.ps1`
  - `auto-sync.sh`, `sync.ps1`, `sync-hidden.vbs`
  - `codex-config-*.toml`
  - `scripts/**`
  - `machine-profiles/**`
  - `mcp-templates/**`
- Never auto-commit machine-private files, tokens, `.env*`, logs, backups, router exports, or `*-settings.json`.

## Validation Commands

Windows:

```powershell
Get-ScheduledTask -TaskName 'Deepseek-Sync'
Get-ScheduledTaskInfo -TaskName 'Deepseek-Sync'
powershell -ExecutionPolicy Bypass -File .\sync.ps1
Test-Path "$env:USERPROFILE\.codex\skills\ops-terminal-sync\SKILL.md"
git status --short
```

macOS/Linux:

```bash
launchctl list | grep com.ops-skills.sync || true
bash ./auto-sync.sh "$PWD"
test -f "$HOME/.codex/skills/ops-terminal-sync/SKILL.md"
scripts/audit-skills.sh
git status --short
```
