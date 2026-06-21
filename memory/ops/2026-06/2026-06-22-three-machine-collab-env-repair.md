# 2026-06-22 Three-Machine Collaboration Environment Repair

## Background

The Deepseek collaboration environment had drifted across `macair`, `12700K`, and `lk402`. `12700K` had two Deepseek clones, its scheduled sync task pointed at the old `C:\Users\gaoxi\Documents\Deepseek` clone, GitHub SSH failed, and MCP filesystem roots still referenced the stale clone. `lk402` was mostly healthy but used an HTTPS remote and later exposed a UTF-8 BOM issue in `~/.ssh/config`. `macair` had Windows MCP path residue in local Codex config.

## Changes

- Restored `12700K` GitHub SSH by replacing `~\.ssh\id_ed25519_nodes` with the standard macair nodes key and backing up the previous key.
- Changed `12700K` `Deepseek-Sync` scheduled task to execute `D:\Deepseek\sync-hidden.vbs` with working directory `D:\Deepseek`.
- Set `12700K` repo remote to `git@github.com:xinping7841/ops-skills-xinping.git` and pulled `D:\Deepseek` to `8b602a17192a8a15b9c5a7c7f992af9b8c264d7b`.
- Ran `D:\Deepseek\sync.ps1` on `12700K` to refresh derived Codex/Kun skills.
- Removed stale `C:\Users\gaoxi\Documents\Deepseek` references from `12700K` Codex/Kun MCP configs; filesystem MCP now uses `D:\Deepseek` plus the intended local roots.
- Updated SSH host blocks on `12700K` and `lk402` so `12700k`, `lk402`, and `macair` aliases use `id_ed25519_nodes`.
- Rewrote Windows SSH configs without UTF-8 BOM so OpenSSH accepts the first `Host` line.
- Changed `lk402` repo remote from HTTPS to SSH and upgraded `@upstash/context7-mcp` to `3.2.1`.
- Cleaned macair Codex MCP config block to use macOS direct-node paths for filesystem, GitHub, Playwright, and Context7.

## Why This Way

`D:\Deepseek` is the documented Windows source workspace. Keeping scheduled sync, MCP filesystem roots, and manual work on the same path prevents split-brain state. SSH remotes and passwordless node keys make scheduled Git sync and machine-to-machine handoff non-interactive. Keeping local Codex/Kun directories derived from the Git repo preserves GitHub as the source of truth.

## Alternatives Not Taken

- Keeping `C:\Users\gaoxi\Documents\Deepseek` as the active 12700K repo was skipped because AGENTS.md and the Windows setup model standardize on `D:\Deepseek`.
- Using HTTPS remotes was skipped for scheduled sync because SSH keys are already the cluster standard and avoid credential prompts.
- Deleting the old 12700K clone and untracked helper BAT files was skipped because they may still be useful local artifacts and were not required to restore the collaboration chain.

## Validation

- `git rev-parse HEAD` on `macair`, `12700K`, and `lk402` returned `8b602a17192a8a15b9c5a7c7f992af9b8c264d7b`.
- `ssh -T git@github.com` succeeded on `12700K` and `lk402` with GitHub's expected no-shell message.
- `macair -> 12700K`, `macair -> lk402`, `12700K -> lk402`, `12700K -> macair`, `lk402 -> 12700K`, and `lk402 -> macair` SSH checks succeeded.
- `Get-ScheduledTaskInfo -TaskName Deepseek-Sync` on `12700K` and `lk402` showed `LastTaskResult = 0`.
- `12700K` and `lk402` both had `codex-skills/web-app-dev/SKILL.md` and `codex-skills/code-review-eval/SKILL.md` after sync.
- Config searches found no remaining `Documents\Deepseek` references in `12700K` or `lk402` Codex/Kun MCP configs.

## Risks

- `12700K` still has `C:\Users\gaoxi\Documents\Deepseek`; manual work inside it can reintroduce confusion.
- `12700K` still has untracked `D:\Deepseek\auto-sync.bat`.
- `lk402` still has untracked `D:\Deepseek\install-admin-bridge-once.bat` and `D:\Deepseek\run-repair-lk402-tailscale-admin.bat`.
- macair local Codex config still contains some Codex app runtime cache paths from previous Windows state outside the MCP block. They were not changed because Codex app may manage those entries itself.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [x] Updated `memory/machines/macair.md`.
- [x] Updated `memory/machines/12700k.md`.
- [x] Updated `memory/machines/lk402.md`.
- [x] Updated `memory/sync/deepseek-three-machine-sync.md`.
- [x] Updated `memory/runbooks/verify-three-machine-sync.md`.

## Handoff Notes

Future agents should treat `D:\Deepseek` as the only active Windows Deepseek workspace. If anything references `C:\Users\gaoxi\Documents\Deepseek`, consider it drift unless the user explicitly says otherwise. Use `memory/runbooks/verify-three-machine-sync.md` before and after environment repair work.

## Related Files

- `AGENTS.md`
- `skill-ssh-tailscale.md`
- `skill-mcp-servers.md`
- `sync.ps1`
- `auto-sync.sh`
- `memory/machines/12700k.md`
- `memory/machines/lk402.md`
- `memory/machines/macair.md`
- `memory/sync/deepseek-three-machine-sync.md`

