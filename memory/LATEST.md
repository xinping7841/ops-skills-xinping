# Latest Handoff

## Current Focus

The Deepseek workspace remains the multi-machine skill/config source, and the private Shenlan operations repository is now being used as the sanitized source for live network asset facts and staged AI-Ops/DR rollout planning.

## Read First

- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-console-initial-read.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-vlan50-access-configuration.md`
- `memory/ops/2026-06/2026-06-23-shenlan-spare-switch-lab-knowledge.md`
- `memory/ops/2026-06/2026-06-23-shenlan-switch-asset-catalog-and-cli-diagnostics.md`
- `memory/ops/2026-06/2026-06-23-shenlan-openwrt-hardware-inventory.md`
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
- OpenWrt logical hardware/interface facts are now recorded, but the physical port label/order still needs onsite visual confirmation before updating handover-grade cable diagrams or NetBox cable records.
- Switch model pages and readonly CLI runbook now exist, but most listed switches still need onsite confirmation of physical location, management IP/VLAN, uplink/downlink ports, CLI support, PoE budget, and NetBox/LibreNMS onboarding.
- Many listed switches may be idle/spare, but exact per-device status is still not recorded; do not factory reset, upgrade, or reconfigure any unit until it is confirmed as non-production and approved for isolated lab work.
- Onsite S5735S `S5735S-VLAN50-Access` / ESN `3G21B0008306` is now configured as a VLAN50 access switch with management IP `192.168.99.10` on VLAN99 and SSH enabled. Clock is still stale and needs NTP/time follow-up.
- `scripts/commit-and-handoff.py --commit` stages only whitelist paths, but agents should still inspect the dry-run output before committing.
- `memory/LATEST.md` is still human/agent-curated; tooling does not automatically infer priority, active risks, or next steps.
- Local Codex/Kun config files may contain machine-private state; memory should record paths and reasons, not secrets.

## Next Steps

1. Use `xinping7841/shenlan-network-ops` as the first update target when the user supplements Shenlan device, VLAN, UPS, NAS, node-122, Tailscale, or AI-Ops rollout information.
2. For live Shenlan configuration work, cross-check NetBox/LibreNMS/Scanopy on `node-121` and the Deepseek Shenlan references before changing devices.
3. If continuing the onsite S5735S work, verify NTP/time, SNMPv3/LibreNMS onboarding, and final per-port descriptions/shutdown state for VLAN50 access ports.
4. For Shenlan switch knowledge prep, read `D:\shenlan-network-ops\docs\switch-knowledge-index.md`, then choose the spare-device lab runbook for confirmed idle devices or the readonly CLI runbook for online/unknown devices.
5. For Shenlan switch troubleshooting, read `D:\shenlan-network-ops\runbooks\switch-cli-readonly-diagnostics.md` before using CLI, and keep live sessions readonly unless a pre-change safety check and backup are complete.
6. Keep new reusable procedures in `memory/runbooks/` or sanitized skill references, not as root-level ad hoc scripts.
7. Run `python3 scripts/commit-and-handoff.py --dry-run` before commits or final handoff when durable state changed.
8. Decide separately whether to rewrite Git history for old plaintext probe scripts; coordinate force-push handling across all machines if doing so.

## Last Verified

- Date: 2026-06-23
- Shenlan ops repo: `xinping7841/shenlan-network-ops`, initial commit `8746aeb` pushed to `main`.
- 12700K Windows working copy prepared at `D:\shenlan-network-ops`; new conversation entrypoint recorded in `runbooks/start-new-conversation.md`.
- OpenWrt main router hardware snapshot captured read-only: 倍控 H30S / Intel N150 / 16GB RAM / Samsung SSD 980 500GB / OpenWrt 25.12.4; logical interface roles recorded in `D:\shenlan-network-ops\inventory\devices\core-devices.md`.
- Shenlan switch asset catalog and readonly CLI runbook added to `D:\shenlan-network-ops` and pushed as commit `00122bf`.
- Shenlan spare switch lab runbook and switch knowledge index added to `D:\shenlan-network-ops` and pushed as commit `d90ddc5`.
- Onsite S5735S configured locally on macair: `S5735S-VLAN50-Access`, ESN `3G21B0008306`, management `192.168.99.10/24` on VLAN99, `GE0/0/1` trunk VLAN50/99 to H3C `GE1/0/11`, `GE0/0/2-28` access VLAN50, SSH port 22 reachable from `node-121`. H3C `GE1/0/11` was changed from access VLAN50 to trunk VLAN50/99 and saved.
- Tooling commit previously verified: `1118b8a17c462a939025d04989b49a62cb990bac`
