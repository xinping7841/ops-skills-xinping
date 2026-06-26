# Latest Handoff

## Current Focus

Codex context injection for the Deepseek workspace was slimmed on 12700K after a high token-consumption analysis. The project `AGENTS.md` is now a short read-on-demand entry, local Codex default plugins/MCP/skills were reduced, and sync scripts no longer auto-register orphan local skills into every Codex thread.

SmartCenter meter history stabilization was completed on node-121 and verified through node-120. node-121 remains the raw cumulative meter collector, while node-120 displays the configured visible/reporting meters and now returns stable 2026-06-19/20/21 history values without the previous missing `二号厅` total drift.

node-123 SSH was re-verified after the user power-cycled the machine. LAN `192.168.50.123` and Tailscale `100.119.214.90` both accept SSH as `sl123`; user-side SSH key permissions and authorized key line endings were repaired, local aliases now include `node-123-lan` and `node-123-ts`, and system SSH policy now disables password login/root login through `/etc/ssh/sshd_config.d/99-codex-hardening.conf`. RDP is restored through `xrdp` on TCP/3389; GNOME Remote Desktop is disabled to avoid port conflicts.

## Read First

- `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md`
- `memory/ops/2026-06/2026-06-25-node-123-ssh-hardening-after-power-cycle.md`
- `memory/machines/123.md`
- `memory/ops/2026-06/2026-06-24-slim-codex-context-injection.md`
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
- node-123 SSH password login is now disabled, so future SSH access requires an authorized key or console access. Do not remove authorized keys casually.
- node-123 RDP should be served by `xrdp.service` on TCP/3389. Keep `gnome-remote-desktop.service` disabled unless it is deliberately moved to another port and given credentials.
- Codex context was intentionally slimmed on 12700K. Do not bulk-register every local `~/.codex/skills/*` directory or re-enable all heavy plugins/MCP blocks unless the user accepts higher recurring input-token cost. Restore from `C:\Users\gaoxi\.codex\config.toml.before-context-slim-20260624-095241.bak` only if broad capabilities are more important than context cost.
- Existing Shenlan network risks still apply: many switches remain partially documented or factory-like, and live device changes need a deliberate pre-change plan and sanitized records.
- S6720S `XGE0/0/25` is now the active 10G trunk uplink to H3C `Te1/0/25` for VLAN10/16-19/40/50/80/99; VLAN1 has been removed from the H3C trunk. S6720S management has moved from `MEth0/0/1` to `Vlanif99 192.168.99.11/24`, SSH source is `Vlanif99`, and LibreNMS monitors it as device ID `13` using SNMPv2c restricted to node-121.
- S5735S-Access-8820 (`S5735S-L24T4S-QA2`, ESN `3G21B0008820`) is now downstream of S6720S: `GE0/0/28` <-> S6720S `XGE0/0/28`, trunk VLAN10/16-19/40/50/80/99; temporary test access ports on both Huawei switches are 4 -> VLAN40, 5 -> VLAN50, 8 -> VLAN80, and 16/17/18/19 -> VLAN16/17/18/19; management is `Vlanif99 192.168.99.13/24`; SSH and SNMPv2c are verified; LibreNMS device ID is `14`.

## Next Steps

1. If continuing SmartCenter meter work, start in `D:\SmartCenter\smart-center-worktrees\meter-history-spike-filter`, check `git status`, and use `scripts/ssh_exec.sh --host node-120|node-121 --script scripts/remote/<script>.sh` for complex remote commands.
2. For a user-facing meter report, present the raw-count-derived visible table from `memory/code/2026-06/2026-06-24-smart-center-meter-history-stabilization.md`, with final row named `汇总` and including `二号厅`.
3. If making more SmartCenter production changes, create or reuse remote scripts under `scripts/remote/`, run local tests, and re-verify node-120 history stability after deployment.
4. Before committing Deepseek memory or scripts, run `python3 scripts/commit-and-handoff.py --dry-run` and stage only whitelist-safe files.
5. For node-123 follow-up, use `ssh node-123-lan` for LAN access or `ssh node-123-ts` for Tailscale access. Use RDP username `sl123` on port 3389. If continuing Hunyuan3D work, resume at the `custom_rasterizer` CUDA extension rebuild/import issue described in the 2026-06-25 node-123 SSH ops record.
6. For Shenlan switch follow-up, read the listed Shenlan records and the local `shenlan-network-ops` runbook first, then keep live CLI sessions read-only until a pre-change plan is approved.
7. For S6720S/S5735S follow-up, treat `XGE0/0/25` <-> H3C `Te1/0/25` as the core uplink and `XGE0/0/28` <-> S5735S-Access-8820 `GE0/0/28` as the downstream trunk, both carrying VLAN10/16-19/40/50/80/99. Manage S6720S through `192.168.99.11` and S5735S-Access-8820 through `192.168.99.13`; formalize the temporary test port roles, NTP, and NetBox cabling.
8. If a Codex task needs browser, document, spreadsheet, presentation, Figma, Notion, Lark, deploy, or security skills, re-enable only the specific plugin or skill in `C:\Users\gaoxi\.codex\config.toml` instead of restoring the full previous config.

## Last Verified

- Date: 2026-06-24
- Shenlan S6720S uplink and management: 2026-06-26 S6720S `XGE0/0/25` and H3C `Ten-GigabitEthernet1/0/25` verified UP/10G/trunk, LLDP from S6720S shows H3C neighbor, VLAN10/16-19/40/50/80/99 permitted on the trunk, and both device configurations saved. S6720S `Vlanif99 192.168.99.11/24` is up/up; macair and node-121 ping/SSH succeed; SNMPv2c from node-121 succeeds; LibreNMS discovery/poll succeeded for device ID `13`.
- Shenlan S5735S-Access-8820 downstream: 2026-06-26 S5735S `GE0/0/28` and S6720S `XGE0/0/28` verified by LLDP, VLAN10/16-19/40/50/80/99 trunked, temporary test access ports on both Huawei switches verified as 4/5/8/16/17/18/19 -> VLAN40/50/80/16/17/18/19, `Vlanif99 192.168.99.13/24` up/up, SSH login succeeds, SNMPv2c from node-121 succeeds, and LibreNMS discovery/poll succeeded for device ID `14`.
- node-123 SSH/RDP: 2026-06-25 LAN and Tailscale TCP/22 and TCP/3389 reachable; `ssh node-123-lan` returned `sl123-System-Product-Name`, user `sl123`; `ssh.service`, `ssh.socket`, `xrdp.service`, and `xrdp-sesman.service` enabled/active; `gnome-remote-desktop.service` disabled/inactive; `sshd -T` shows password auth and root login disabled.
- 12700K Codex context slimming: local TOML parsed successfully after edits; default registration count reduced from 62 plugin/skill/MCP blocks to 23 blocks before the handoff record, with 17 skill blocks and no default MCP server blocks.
- SmartCenter branch: `codex/12700k-meter-history-spike-filter-20260622`
- node-121: `meter-service.service` active after patching onsite flat `service.py`; `target=legacy_meter_3`, `target=meter:legacy_meter_3`, `target=cabinet_meter_1`, `target=cabinet:1`, and `target=total` verified through `/api/meters`.
- node-120: configured report returned `remote_payload_shape=node120_config`, `meter_count=14`, no remote history errors, and total trend `174.5, 164.0, 167.05`; five repeated reads of total, `二号厅`, `咖啡厅`, and `中控室` were stable.
- Raw node-121 SQLite estimate for visible configured meters: `汇总` 2026-06-19 `174.88`, 2026-06-20 `164.15`, 2026-06-21 `167.24`, total `506.27`.
- Local checks: `python -m unittest tests.test_meter_storage_history tests.test_power_remote_meter_cache` passed; `python -m compileall meter_service services api\power.py` passed.
