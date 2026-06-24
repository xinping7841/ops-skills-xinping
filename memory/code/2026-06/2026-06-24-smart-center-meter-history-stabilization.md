# 2026-06-24 Smart Center Meter History Stabilization

## Background

The user reported that node-120's meter page showed historical operating data jumping between different values, which is unacceptable for operations reference. The requested business rule is: node-121 collects all raw cumulative meter counts, while node-120 decides which configured meters are displayed, hidden, repeated, or included through add/subtract calculated meters. The 2026-06-19, 2026-06-20, and 2026-06-21 report must follow the node-121 meter-service configuration and include the visible `二号厅` row.

## Changes

- SmartCenter branch `codex/12700k-meter-history-spike-filter-20260622` already contained and pushed commits `d92e003` and `82665a7` for target alias resolution and visible target history lookup.
- node-121 production does not run the repository package layout directly. Its systemd unit runs `/opt/smart_power_services/meter_service/.venv/bin/python -m meter_service.app` from `/opt/smart_power_services/meter_service`, where `service.py` is a flat onsite file with extra APIs such as `get_latest_snapshot_rows()`.
- Deployed a minimal patch onto the current onsite flat `/opt/smart_power_services/meter_service/service.py`, preserving onsite-only functions:
  - Added source-key variants so `legacy_meter_3`, `meter:legacy_meter_3`, `cabinet_meter_1`, and `cabinet:1` resolve consistently.
  - Made single-meter/area history targets resolve against visible rows while `total` resolves against summary rows.
  - Restored support for `meter_statistics.summary_mode=visible_only` in `_filter_summary_rows`, so node-121 total history includes visible `二号厅` even though that row has `include_in_totals=false`.
- node-121 backup from the successful deploy: `/opt/smart_power_services/meter_service/backups/codex_meter_target_fix_20260624_093252/service.py.before`.

## Why This Way

The first whole-file deployment attempt failed because the repository `meter_service/service.py` lacked onsite-only symbols expected by the node-121 flat deployment. The safer fix was to patch only the small target-resolution and summary-filtering behavior in the file that production was already running.

## Alternatives Not Taken

- Replacing node-121 with the repository `meter_service/service.py`: skipped because it caused `ImportError: cannot import name 'get_latest_snapshot_rows' from 'meter_service.service'`.
- Changing node-120 display configuration to force `include_in_totals=true` for `二号厅`: skipped because the user's rule is that node-120 display should follow the configured visible/reporting set, not a manual one-off guess.

## Validation

- node-121 deploy verification showed `meter-service.service` active after restart and `/api/meters` target aliases returning the expected rows.
- node-121 `/api/meters?target=total&period=day&days=8` after the patch returned 2026-06-19/20/21 total trend approximately `174.5, 164.0, 167.05`, no longer missing `二号厅`.
- node-120 configured report verification returned `remote_payload_shape=node120_config`, `meter_count=14`, `remote_history_errors=[]`, and summary trend `174.5, 164.0, 167.05`.
- node-120 stability probe read `total`, `meter:legacy_meter_3`, `meter:legacy_meter_11`, and `meter:legacy_meter_5` five consecutive times; all 2026-06-19/20/21 values were identical and `stability={"ok": true}`.
- Local SmartCenter checks passed: `python -m unittest tests.test_meter_storage_history tests.test_power_remote_meter_cache` and `python -m compileall meter_service services api\power.py`.

## Risks

- node-121 still has a production flat deployment that differs from the repository package layout. Future agents must not overwrite `/opt/smart_power_services/meter_service/service.py` with the repository file wholesale.
- node-120 API values are sanitized/history-cache values and differ slightly from independent raw SQLite first/last counter estimates. For formal audit tables, use the raw-count estimate from node-121 SQLite and state that it is the raw-count-derived value.
- An older diagnostic script's final curl pipeline failed after printing the raw-count audit; the important config and raw-row output had already been emitted.

## Module Notes Impact

- [x] Does not affect long-lived module documentation.

## Handoff Notes

Start from `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter` for local code and from node-121 `/opt/smart_power_services/meter_service/service.py` for onsite service behavior. Use `scripts/ssh_exec.sh --host node-120|node-121 --script scripts/remote/<script>.sh` for complex remote checks. Do not call physical control endpoints such as `/api/set`, `/api/onekey_start`, or `/api/onekey_stop` during meter diagnostics.

Final raw-count-derived visible report for 2026-06-19/20/21:

| Meter | 2026-06-19 | 2026-06-20 | 2026-06-21 | Total |
| --- | ---: | ---: | ---: | ---: |
| 二号厅LED | 0.00 | 0.00 | 0.00 | 0.00 |
| 影棚配电柜 | 3.12 | 3.10 | 3.44 | 9.66 |
| 影棚LED配电柜 | 0.00 | 0.00 | 0.00 | 0.00 |
| 门口LED | 0.01 | 0.00 | 0.01 | 0.02 |
| 二号厅 | 4.85 | 4.91 | 6.00 | 15.76 |
| 中控室 | 80.74 | 48.12 | 47.74 | 176.60 |
| 办公室&工作坊 | 24.31 | 53.01 | 55.11 | 132.43 |
| 2楼小机房 | 7.18 | 7.11 | 7.11 | 21.40 |
| 咖啡厅 | 11.66 | 10.66 | 14.79 | 37.11 |
| 一号厅 | 11.50 | 5.10 | 5.09 | 21.69 |
| 运营中心 | 6.46 | 6.39 | 6.68 | 19.53 |
| 餐车电表 | 25.01 | 25.70 | 21.23 | 71.94 |
| 公牛充电桩电表 | 0.04 | 0.05 | 0.04 | 0.13 |
| 220V电表 | 0.00 | 0.00 | 0.00 | 0.00 |
| 汇总 | 174.88 | 164.15 | 167.24 | 506.27 |

## Related Files

- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\meter_service\service.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\services\meter_remote.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\api\power.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\tests\test_meter_storage_history.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\tests\test_power_remote_meter_cache.py`
- `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter\scripts\remote\verify_meter_history_stability_120_20260624.sh`
