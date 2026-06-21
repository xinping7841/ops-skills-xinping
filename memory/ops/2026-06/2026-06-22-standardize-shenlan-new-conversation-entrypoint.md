# 2026-06-22 Standardize Shenlan New Conversation Entrypoint

## Background

The user defined a fixed way to start future Shenlan operations conversations across 12700K, lk402, macair, and node-121. The goal is to stop each new agent from rediscovering where Deepseek rules live, where the dedicated Shenlan operations repository lives, which files to read first, and what must remain out of Git.

## Changes

- Cloned the dedicated sanitized operations repository to the Windows working copy path `D:\shenlan-network-ops` on 12700K.
- Added `runbooks/start-new-conversation.md` in `shenlan-network-ops` with the standard first-machine setup, reusable new-conversation prompt, update checklist, and secret boundary.
- Linked that runbook from `shenlan-network-ops/README.md` and `runbooks/update-ops-knowledge.md`.
- Updated Deepseek `codex-skills/shenlan-ops/SKILL.md` so future agents read the dedicated repo entry files when present and understand that `shenlan-network-ops` is the primary sanitized update target for new inventory/planning/runbook facts.
- Updated `memory/LATEST.md` to point at the new conversation entrypoint and record the Windows working copy path.

## Why This Way

Deepseek remains the multi-machine coordination and skill source, while `shenlan-network-ops` is the narrower sanitized operations knowledge base. Keeping the reusable prompt inside the Shenlan repo makes it discoverable to future agents even when chat history is absent; linking it from the Deepseek skill keeps existing Codex/Kun startup behavior aligned.

## Alternatives Not Taken

- Did not paste the full entry prompt into `AGENTS.md`; that file should remain a compact global routing document and avoid context bloat.
- Did not store the prompt only in chat; future machines and agents need a Git-backed entrypoint.
- Did not put secrets or live configuration outputs into either repository; the runbook records process and paths only.

## Validation

- Commands run:
  - `git pull --rebase` in `D:\Deepseek` -> already up to date.
  - `git clone git@github.com:xinping7841/shenlan-network-ops.git D:\shenlan-network-ops` -> cloned successfully.
  - Read `README.md`, `docs/current-state.md`, `plans/configuration-backlog.md`, `SECURITY.md`, and existing runbooks in `D:\shenlan-network-ops` before editing.
- Result: the standard entrypoint is available in both the dedicated operations repo and the Deepseek `shenlan-ops` skill path.

## Risks

- `shenlan-network-ops` is private but still contains internal topology and private IP context; keep it private and continue scanning staged changes for credentials.
- Other machines still need their local `shenlan-network-ops` clone prepared if not already present.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: `D:\shenlan-network-ops\runbooks\start-new-conversation.md`

## Handoff Notes

For future Shenlan update tasks, pull both repositories, then read:

1. Deepseek `AGENTS.md` and `memory/LATEST.md`.
2. Deepseek `codex-skills/shenlan-ops/SKILL.md`.
3. `shenlan-network-ops/README.md`.
4. `shenlan-network-ops/docs/current-state.md`.
5. `shenlan-network-ops/plans/configuration-backlog.md`.
6. `shenlan-network-ops/SECURITY.md`.
7. `shenlan-network-ops/runbooks/start-new-conversation.md` when setting up a fresh thread.

## Related Files

- `D:\shenlan-network-ops\runbooks\start-new-conversation.md`
- `D:\shenlan-network-ops\README.md`
- `D:\shenlan-network-ops\runbooks\update-ops-knowledge.md`
- `D:\Deepseek\codex-skills\shenlan-ops\SKILL.md`
- `D:\Deepseek\memory\LATEST.md`
