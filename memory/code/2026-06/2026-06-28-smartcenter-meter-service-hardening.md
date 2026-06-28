# 2026-06-28 SmartCenter Meter Service Hardening

## Background

The user asked to inspect and fix the node-121 meter data detection service, then perform a review before considering the task complete. The service was running and returning data, but the review found production-impacting reliability and security risks around unauthenticated config/control endpoints, background loop failures being swallowed, duplicate background threads, SQLite write locking, and health checks reporting `ok=1` even when the live meter fleet was degraded.

## Changes

- SmartCenter worktree: `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter`, branch `codex/12700k-meter-history-spike-filter-20260622`.
- Repository code changes:
  - `meter_service/app.py` now protects config sync and cabinet control/config endpoints with `X-Meter-Service-Token`; `/api/health` now exposes `status` and only returns `ok=1` when runtime status is `ok`.
  - `services/meter_remote.py` and `services/cabinet_gateway.py` can source the shared token from config or environment and send it on remote config/control calls.
  - `meter_service/service.py` records poll/export successes and failures, logs loop exceptions, exposes runtime counters in health, and makes `start_background_threads()` idempotent.
  - `meter_service/storage.py` uses SQLite `busy_timeout`, WAL mode, and retry wrapping for write paths.
  - `tests/test_meter_service_hardening.py` covers token enforcement, outbound token headers, background-thread idempotence, health status classification, and SQLite WAL/retry behavior.
  - `scripts/ssh_exec.ps1` now writes uploaded bash wrappers with LF newlines so Linux remote execution does not fail from CRLF wrappers.
- Production node-121 changes:
  - Patched onsite flat deployment under `/opt/smart_power_services/meter_service` without wholesale replacement, preserving onsite-only behavior.
  - Created `/etc/smart_power_services/meter_service.env` with mode `0600` and systemd drop-in `/etc/systemd/system/meter-service.service.d/30-api-token.conf`. Do not print or store the token value.
  - Successful backup directory: `/opt/smart_power_services/meter_service/backups/codex_meter_hardening_20260628_134439`.
- Production node-120 changes:
  - Patched `/srv/smart-center/current/services/meter_remote.py` and `services/cabinet_gateway.py` so node-120 can call the protected node-121 write/control proxy endpoints with the shared token.
  - Updated `/etc/smart-center.env` with the required token environment variables. Do not print or store the token value.
  - Successful backup directory: `/srv/smart-center-data/backups/codex_meter_client_token_20260628_135241`.

## Why This Way

node-121 production is still an onsite flat deployment whose import surface differs from the repository package. The safe path was a minimal remote patch preserving the existing deployed files and only adding the hardening behavior. The repository received equivalent maintainable changes and focused tests so future package deployments do not regress the same issues.

The control/config endpoints now fail closed when no token is configured. Read-only status and meter endpoints remain available for internal dashboards and diagnostics, while mutating paths require the shared secret header.

## Alternatives Not Taken

- Replacing node-121 production files wholesale with repository files: skipped because prior SmartCenter meter work showed the onsite flat deployment has extra APIs and differs from the package layout.
- Locking down every read-only endpoint with the token: skipped for this pass to avoid breaking existing internal read-only consumers; the highest-risk config and control surfaces were protected first.
- Verifying cabinet control through real `/api/cabinet/set` or `/api/cabinet/onekey` calls: intentionally skipped to avoid physical control side effects.

## Validation

- Deepseek repo start rule: ran `git pull --rebase` in `D:\Deepseek`; result was already up to date.
- Local SmartCenter checks passed:
  - `python -m unittest tests.test_meter_service_hardening tests.test_meter_storage_history tests.test_power_remote_meter_cache`: 25 tests passed.
  - `python -m compileall meter_service services api\power.py`: passed.
  - `bash -n scripts/remote/deploy_node120_meter_client_token_20260628.sh`: passed.
  - `git diff --check`: passed; only normal Windows line-ending warnings were reported.
- node-121 production verification passed:
  - `meter-service.service` active after restart.
  - token env file and systemd drop-in present.
  - symbol checks found token auth, runtime health/logging/idempotence, SQLite WAL/retry support.
  - Safe probes: `/api/health` returned HTTP 200 with `ok:0`, `status:"degraded"`, `runtime_status:"degraded"`, and `meter_count:14`; `/api/meters` returned HTTP 200 with 14 meters; `/api/config` returned HTTP 401 without token and HTTP 200 with token.
- node-120 production verification passed:
  - `smart-center.service` active after restart.
  - imported helper verification showed meter/cabinet tokens available and outbound headers present.
  - Safe read-only probe on `http://127.0.0.1:6899/api/meters?target=total&period=day&days=2` returned HTTP 200, `ok:1`, `data_source:"remote_meter_service"`, and `meter_count:14`.
- No real physical control endpoints were called during validation.

## Risks

- node-121 still listens on `0.0.0.0:6901`; mutating config/control endpoints are token-protected, but read-only meter/health endpoints remain reachable on the internal network.
- node-121 `/api/health` is currently degraded because live meter rows include offline/degraded/failure state. This is now visible rather than hidden by `ok=1`.
- node-121 production remains a flat onsite deployment. Future agents must not overwrite `/opt/smart_power_services/meter_service/app.py`, `service.py`, or `storage.py` wholesale with repository files.
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\config.json` had unrelated local modifications and was intentionally left untouched.

## Module Notes Impact

- [x] Does not affect long-lived module documentation.

## Handoff Notes

For follow-up, start in `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter` and check `git status` first. Preserve the node-121 onsite flat deployment distinction and use remote scripts under `scripts/remote/` for repeatable production checks. Keep token values out of logs, memory, commits, and final replies. Treat `/api/set`, `/api/onekey_start`, `/api/onekey_stop`, `/api/cabinet/set`, and `/api/cabinet/onekey` as physical-control endpoints and avoid them unless the user explicitly authorizes a control test.

## Related Files

- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\meter_service\app.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\meter_service\service.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\meter_service\storage.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\services\meter_remote.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\services\cabinet_gateway.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\tests\test_meter_service_hardening.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\scripts\remote\deploy_meter_service_hardening_121_20260628.sh`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\scripts\remote\verify_meter_service_hardening_121_20260628.sh`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\scripts\remote\deploy_node120_meter_client_token_20260628.sh`
