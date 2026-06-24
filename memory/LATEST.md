# Latest Handoff

## Current Focus

SmartCenter meter history stabilization was completed on node-121 and verified through node-120. node-121 remains the raw cumulative meter collector, while node-120 displays the configured visible/reporting meters and now returns stable 2026-06-19/20/21 history values without the previous missing `二号厅` total drift.

## Read First

- `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s6720s-console-initial-status.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-factory-reset-via-console-bootload.md`
- `memory/ops/2026-06/2026-06-23-shenlan-second-s5735s-factory-reset-via-console-bootload.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s6720s-meth-ssh-management-configuration.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s6730-meth-ssh-management-configuration.md`
- `memory/ops/2026-06/2026-06-23-shenlan-h3c-ge20-vlan99-switch-management.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-vlan50-access-configuration.md`
- `memory/ops/2026-06/2026-06-23-shenlan-switch-asset-catalog-and-cli-diagnostics.md`
- `memory/ops/2026-06/2026-06-22-three-machine-collab-env-repair.md`
- `memory/code/2026-06/2026-06-22-engineering-memory-tooling.md`
- `memory/adr/2026-06-22-engineering-handoff-memory.md`
- `memory/runbooks/use-engineering-handoff-memory.md`
- `memory/sync/deepseek-three-machine-sync.md`
- `memory/machines/macair.md`
- `memory/machines/12700k.md`
- `memory/machines/lk402.md`

For Shenlan network follow-up, also read the `shenlan-network-ops` repo start files before changing devices:

- `/Users/xinping/Documents/shenlan-network-ops/README.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
- `/Users/xinping/Documents/shenlan-network-ops/plans/configuration-backlog.md`
- `/Users/xinping/Documents/shenlan-network-ops/SECURITY.md`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/start-new-conversation.md`
- `D:\shenlan-network-ops\runbooks\start-new-conversation.md` on Windows when available.

## Active Risks

- node-121 SmartCenter meter service is a flat onsite deployment at `/opt/smart_power_services/meter_service/service.py`, not the repository package layout. Do not replace it wholesale with repo `meter_service/service.py`; preserve onsite-only APIs such as `get_latest_snapshot_rows()`.
- SmartCenter meter diagnostics must stay read-only unless the user explicitly authorizes controls. Avoid `/api/set`, `/api/onekey_start`, `/api/onekey_stop`, and similar physical-control endpoints.
- node-120 history API values are sanitized/cache-shaped display values and can differ slightly from independent node-121 SQLite first/last raw-counter estimates. Use the raw-count-derived table from the 2026-06-24 memory record for formal reporting.
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\config.json` had unrelated local modifications during the meter task; do not revert them casually.
- Deepseek repo currently has untracked local artifacts such as `Kun-0.2.16-win-x64.exe`, `tmp-node123/`, and `tmp/`; inspect before any broad commit and keep private/generated artifacts out of Git.
- Existing Shenlan network risks still apply: many switches remain partially documented or factory-like, and live device changes need a deliberate pre-change plan and sanitized records.

## Next Steps

1. If continuing SmartCenter meter work, start in `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter`, check `git status`, and use `scripts/ssh_exec.sh --host node-120|node-121 --script scripts/remote/<script>.sh` for complex remote commands.
2. For a user-facing meter report, present the raw-count-derived visible table from `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md`, with final row named `汇总` and including `二号厅`.
3. If making more SmartCenter production changes, create or reuse remote scripts under `scripts/remote/`, run local tests, and re-verify node-120 history stability after deployment.
4. Before committing Deepseek memory or scripts, run `python3 scripts/commit-and-handoff.py --dry-run` and stage only whitelist-safe files.
5. For Shenlan switch follow-up, read the listed Shenlan records and the local `shenlan-network-ops` runbook first, then keep live CLI sessions read-only until a pre-change plan is approved.

## Last Verified

- Date: 2026-06-24
- SmartCenter branch: `codex/12700k-meter-history-spike-filter-20260622`
- node-121: `meter-service.service` active after patching onsite flat `service.py`; `target=legacy_meter_3`, `target=meter:legacy_meter_3`, `target=cabinet_meter_1`, `target=cabinet:1`, and `target=total` verified through `/api/meters`.
- node-120: configured report returned `remote_payload_shape=node120_config`, `meter_count=14`, no remote history errors, and total trend `174.5, 164.0, 167.05`; five repeated reads of total, `二号厅`, `咖啡厅`, and `中控室` were stable.
- Raw node-121 SQLite estimate for visible configured meters: `汇总` 2026-06-19 `174.88`, 2026-06-20 `164.15`, 2026-06-21 `167.24`, total `506.27`.
- Local checks: `python -m unittest tests.test_meter_storage_history tests.test_power_remote_meter_cache` passed; `python -m compileall meter_service services api\power.py` passed.
