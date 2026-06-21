# Latest Handoff

## Current Focus

The Deepseek workspace remains the multi-machine skill/config source, and a new private Shenlan-specific operations repository now exists for sanitized network ops knowledge and staged AI-Ops/DR rollout planning.

## Read First

- `memory/ops/2026-06/2026-06-22-shenlan-network-ops-github-repo.md`
- `memory/ops/2026-06/2026-06-22-three-machine-collab-env-repair.md`
- `memory/code/2026-06/2026-06-22-engineering-memory-tooling.md`
- `memory/ops/2026-06/2026-06-22-clean-deepseek-root-temporary-configs.md`
- `memory/code/2026-06/2026-06-22-handoff-cleanup-deletion-staging.md`
- `memory/adr/2026-06-22-engineering-handoff-memory.md`
- `memory/runbooks/use-engineering-handoff-memory.md`
- `memory/sync/deepseek-three-machine-sync.md`
- `memory/machines/macair.md`
- `memory/machines/12700k.md`
- `memory/machines/lk402.md`
- `memory/runbooks/verify-three-machine-sync.md`

For Shenlan follow-up, also read the new local repo first:

- `/Users/xinping/Documents/shenlan-network-ops/README.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
- `/Users/xinping/Documents/shenlan-network-ops/plans/configuration-backlog.md`
- `/Users/xinping/Documents/shenlan-network-ops/SECURITY.md`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/start-new-conversation.md`
- `D:\shenlan-network-ops\runbooks\start-new-conversation.md` on Windows when the repo has been cloned there.

## Active Risks

- Removed `ik_*` probe scripts from the current GitHub tree because they contained plaintext device login material; Git history still contains old revisions, so rotate the affected device password if still valid.
- The new `shenlan-network-ops` repo is private but contains internal topology, private IPs, service ports, and rollout plans; keep credentials, raw configs, logs, and packet captures out of it.
- `scripts/commit-and-handoff.py --commit` stages only whitelist paths, but agents should still inspect the dry-run output before committing.
- `memory/LATEST.md` is still human/agent-curated; tooling does not automatically infer priority, active risks, or next steps.
- Local Codex/Kun config files may contain machine-private state; memory should record paths and reasons, not secrets.

## Next Steps

1. Use `xinping7841/shenlan-network-ops` as the first update target when the user supplements Shenlan device, VLAN, UPS, NAS, node-122, Tailscale, or AI-Ops rollout information.
2. For live Shenlan configuration work, cross-check NetBox/LibreNMS/Scanopy on `node-121` and the Deepseek Shenlan references before changing devices.
3. Keep new reusable procedures in `memory/runbooks/` or sanitized skill references, not as root-level ad hoc scripts.
4. Run `python3 scripts/commit-and-handoff.py --dry-run` before commits or final handoff when durable state changed.
5. Decide separately whether to rewrite Git history for old plaintext probe scripts; coordinate force-push handling across all machines if doing so.

## Last Verified

- Date: 2026-06-22
- Shenlan ops repo: `xinping7841/shenlan-network-ops`, initial commit `8746aeb` pushed to `main`.
- 12700K Windows working copy prepared at `D:\shenlan-network-ops`; new conversation entrypoint recorded in `runbooks/start-new-conversation.md`.
- Tooling commit previously verified: `1118b8a17c462a939025d04989b49a62cb990bac`
