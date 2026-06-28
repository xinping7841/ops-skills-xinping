# Latest Handoff

## Current Focus

SmartCenter meter-service hardening was completed and reviewed on 2026-06-28. node-121 meter service now protects config/control endpoints with a shared token, reports degraded runtime health truthfully, logs poll/export loop failures, avoids duplicate background threads, and uses more reliable SQLite WAL/retry behavior; node-120 was updated to send the token for protected remote writes/control proxy calls.

Earlier SmartCenter meter history stabilization remains relevant: node-121 is the raw cumulative meter collector, while node-120 shapes the visible/reporting meter set and history display.

## Read First

- `memory/code/2026-06/2026-06-28-smartcenter-meter-service-hardening.md`
- `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md`
- `memory/ops/2026-06/2026-06-25-node-123-ssh-hardening-after-power-cycle.md`
- `memory/machines/123.md`
- `memory/ops/2026-06/2026-06-24-slim-codex-context-injection.md`
- `memory/ops/2026-06/2026-06-26-shenlan-h3c-to-s6730-migration-planning.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s6720s-console-initial-status.md`
- `memory/ops/2026-06/2026-06-26-shenlan-s6720s-h3c-te25-trunk-uplink-configuration.md`
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

For Shenlan network follow-up, also read the dedicated `shenlan-network-ops` start files before changing devices:

- `/Users/xinping/Documents/shenlan-network-ops/README.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
- `/Users/xinping/Documents/shenlan-network-ops/plans/configuration-backlog.md`
- `/Users/xinping/Documents/shenlan-network-ops/SECURITY.md`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/start-new-conversation.md`
- `D:\shenlan-network-ops\runbooks\start-new-conversation.md` on Windows when available.

## Active Risks

- node-121 SmartCenter meter service is a flat onsite deployment at `/opt/smart_power_services/meter_service`, not the repository package layout. Do not replace production `app.py`, `service.py`, or `storage.py` wholesale with repository files; preserve onsite-only APIs and behavior.
- node-121 `meter-service.service` has protected mutating config/control endpoints with `X-Meter-Service-Token`, but read-only `/api/meters` and `/api/health` remain reachable on the internal network. Keep token values out of logs, memory, commits, and final replies.
- SmartCenter meter diagnostics must stay read-only unless the user explicitly authorizes controls. Avoid `/api/set`, `/api/onekey_start`, `/api/onekey_stop`, `/api/cabinet/set`, `/api/cabinet/onekey`, and similar physical-control endpoints.
- node-121 `/api/health` currently reports degraded state because live meter rows include offline/degraded/failure data. This is expected after the hardening because health no longer reports `ok=1` for degraded runtime.
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\config.json` had unrelated local modifications during the meter task; do not revert or stage it casually.
- Deepseek repo has local untracked artifacts such as `Kun-0.2.16-win-x64.exe`, `tmp-node123/`, `tmp/`, `fix_121.py`, and `update_netbox.py`; inspect before any broad commit and keep private/generated artifacts out of Git.
- node-123 SSH password login is disabled, so future SSH access requires an authorized key or console access. RDP should be served by `xrdp.service` on TCP/3389; keep `gnome-remote-desktop.service` disabled unless deliberately reconfigured.
- Codex context was intentionally slimmed on 12700K. Do not bulk-register every local skill or re-enable heavy default plugins/MCP blocks unless the user accepts higher recurring input-token cost.
- Existing Shenlan network risks still apply: many switches remain partially documented or factory-like, and live device changes need a deliberate pre-change plan and sanitized records.
- S6720S `XGE0/0/25` is the active 10G trunk uplink to H3C `Te1/0/25` for VLAN10/16-19/40/50/80/99; S5735S-Access-8820 is downstream on `S6720S XGE0/0/28` to `S5735S GE0/0/28`; management is through VLAN99.

## Next Steps

1. If continuing SmartCenter meter work, start in `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter`, check `git status`, and use `scripts/ssh_exec.ps1` plus scripts under `scripts/remote/` for complex remote commands from Windows.
2. For node-121 meter-service follow-up, verify `meter-service.service`, `/etc/smart_power_services/meter_service.env`, and `/etc/systemd/system/meter-service.service.d/30-api-token.conf`; do not print token values.
3. For node-120 follow-up, verify `smart-center.service`, `/etc/smart-center.env`, and the read-only local API on port `6899` before assuming `5015` or `8001`.
4. For user-facing meter reports, present the raw-count-derived visible table from `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md` when formal totals are needed.
5. Before committing Deepseek memory or scripts, run `python3 scripts/commit-and-handoff.py --dry-run` and stage only whitelist-safe files.
6. For node-123 follow-up, use `ssh node-123-lan` or `ssh node-123-ts`; RDP username is `sl123` on port `3389`.
7. For Shenlan switch follow-up, read the listed Shenlan records and local `shenlan-network-ops` runbook first, then keep live CLI sessions read-only until a pre-change plan is approved.
8. For H3C -> S6730 migration, repair/use S6730 console or SSH, decide physical port mapping, then apply only safe preconfiguration. Gateway IP/DHCP activation belongs to a maintenance window with H3C ready for rollback.

## Last Verified

- Date: 2026-06-28
- SmartCenter branch: `codex/12700k-meter-history-spike-filter-20260622`
- node-121: `meter-service.service` active after hardening; token env file and systemd drop-in present; `/api/health` returns degraded rather than falsely ok; `/api/meters` returns 14 rows; `/api/config` returns 401 without token and 200 with token.
- node-120: `smart-center.service` active after client token patch; helper imports confirm meter/cabinet outbound token headers; read-only `http://127.0.0.1:6899/api/meters?target=total&period=day&days=2` returned HTTP 200, `ok:1`, `data_source:"remote_meter_service"`, `meter_count:14`.
- Local SmartCenter checks: `python -m unittest tests.test_meter_service_hardening tests.test_meter_storage_history tests.test_power_remote_meter_cache` passed; `python -m compileall meter_service services api\power.py` passed; `git diff --check` passed with only Windows line-ending warnings.
- No physical control endpoints were called during meter-service validation.
