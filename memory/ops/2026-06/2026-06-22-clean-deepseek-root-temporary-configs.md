# 2026-06-22 Clean Deepseek Root Temporary Configs

## Background

The Deepseek repo had accumulated root-level one-off troubleshooting scripts from earlier Shenlan network and SSH repair sessions. They were not referenced by the current setup/sync/skill workflow, duplicated knowledge already captured in `codex-skills/shenlan-ops/` and `memory/`, and made the workspace harder for future agents to scan. Several temporary iKuai probe scripts also contained a plaintext device login value, which must not remain in the current GitHub tree.

## Changes

- Removed unreferenced root-level temporary network scripts from the Git-tracked repo current tree: `check_h3c*`, `h3c_*`, `ik_*`, `serial_probe*`, `check_speed.sh`, `speed_test.sh`, `persist_nat.sh`, `fix_121_persist.sh`, and `setup_121_routes.sh`.
- Removed obsolete root-level setup/context snippets: `setup_ssh_12700k.bat`, `smart-center-context.md`, and `codex-self-config.md`.
- Kept durable shared assets: `AGENTS.md`, `skill-*.md`, `codex-skills/**`, `memory/**`, `scripts/**`, `machine-profiles/**`, setup/sync scripts, and the macOS MCP template.
- Cleaned local ignored artifacts on macair: `sync.log` and `.sync-reports/`.
- Removed 12700K local drift: `D:\Deepseek\auto-sync.bat` and stale clone `C:\Users\gaoxi\Documents\Deepseek`.
- Removed lk402 local drift: `D:\Deepseek\install-admin-bridge-once.bat` and `D:\Deepseek\run-repair-lk402-tailscale-admin.bat`.
- Added `.gitignore` guardrails and `AGENTS.md` guidance so one-off root-level probes are not reintroduced.
- Updated `scripts/commit-and-handoff.py` to allow staging deletions of already-tracked files during cleanup while still skipping new non-whitelisted files.

## Why This Way

The repo should stay focused on reusable collaboration assets rather than root-level forensic leftovers. Current Shenlan network context already lives in the `shenlan-ops` skill handoff/reference files, and repeatable Deepseek collaboration procedures live under `memory/` and `scripts/`. Removing temporary scripts reduces context noise, avoids accidental execution of stale live-network commands, and removes plaintext credential material from the current GitHub tree.

## Alternatives Not Taken

- Moving the old scripts into `scripts/` was skipped because they were one-off probes or live repair snippets with hard-coded interface names, ports, IPs, and unsafe credential handling.
- Keeping a local archive in the repo was skipped because Git history already preserves old revisions and the useful operating knowledge is summarized in `shenlan-ops` and `memory/`.
- Rewriting Git history to purge old plaintext content was skipped in this pass because it would require coordinated force-push handling across all three machines. Rotate the affected device password if it is still in use; history purge can be a separate planned operation.

## Validation

- Ran reference searches for each deleted root-level file name; no current workflow references were found outside the files themselves.
- Ran sensitive-pattern search and confirmed the removed `ik_*` files were the root-level plaintext credential offenders.
- Verified GitHub remote only exposes `main` with `git ls-remote --heads --tags origin`.
- Verified lk402 `D:\Deepseek` is clean after deleting the two untracked BAT wrappers.
- Verified 12700K `D:\Deepseek` is clean after deleting `auto-sync.bat` and the stale `Documents\Deepseek` clone.
- Ran `python3 scripts/memory-audit.py` before this record was finalized.

## Risks

- The current GitHub tree no longer contains the removed plaintext probe scripts, but Git history still does. Rotate the affected iKuai/OpenWrt admin password if it is still valid.
- Do not reintroduce ad hoc live-network scripts into the repo root. Put repeatable procedures in `memory/runbooks/` or sanitized skill references.
- Local orphan skills remain on some machines by design; sync scripts audit them but do not import or delete them.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [x] Updated `memory/machines/12700k.md`.
- [x] Updated `memory/machines/lk402.md`.
- [x] Updated `memory/machines/macair.md`.
- [x] Updated `memory/sync/deepseek-three-machine-sync.md`.
- [ ] Updated relevant runbook:

## Handoff Notes

Future agents should treat the repo root as a high-signal entry point only. If a task needs Shenlan network context, load `codex-skills/shenlan-ops/SKILL.md` and task-specific handoff/reference files. If a task needs repeatable Deepseek collaboration operations, use `memory/runbooks/` and `scripts/`. Do not recreate plaintext credential probes in the shared repo.

## Related Files

- `codex-skills/shenlan-ops/`
- `.gitignore`
- `AGENTS.md`
- `memory/sync/deepseek-three-machine-sync.md`
- `memory/machines/12700k.md`
- `memory/machines/lk402.md`
- `memory/machines/macair.md`
- `scripts/commit-and-handoff.py`
- `memory/code/2026-06/2026-06-22-handoff-cleanup-deletion-staging.md`
