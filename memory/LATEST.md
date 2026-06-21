# Latest Handoff

## Current Focus

The Deepseek workspace is being cleaned so the GitHub repo and local `Deepseek` working copies keep only durable collaboration assets, not root-level one-off troubleshooting scripts or machine drift.

## Read First

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

## Active Risks

- Removed `ik_*` probe scripts from the current GitHub tree because they contained plaintext device login material; Git history still contains old revisions, so rotate the affected device password if still valid.
- `scripts/commit-and-handoff.py --commit` stages only whitelist paths, but agents should still inspect the dry-run output before committing.
- `memory/LATEST.md` is still human/agent-curated; tooling does not automatically infer priority, active risks, or next steps.
- Local Codex/Kun config files may contain machine-private state; memory should record paths and reasons, not secrets.

## Next Steps

1. Keep new reusable procedures in `memory/runbooks/` or sanitized skill references, not as root-level ad hoc scripts.
2. Run `python3 scripts/commit-and-handoff.py --dry-run` before commits or final handoff when durable state changed.
3. Decide separately whether to rewrite Git history for old plaintext probe scripts; coordinate force-push handling across all machines if doing so.

## Last Verified

- Date: 2026-06-22
- Tooling commit verified: `1118b8a17c462a939025d04989b49a62cb990bac`
- Cleanup verification before commit: `macair`, `12700K`, and `lk402` local drift checked; obsolete local cleanup wrappers/logs removed where safe.
