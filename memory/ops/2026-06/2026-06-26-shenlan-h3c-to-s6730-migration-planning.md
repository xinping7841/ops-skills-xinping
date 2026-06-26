# 2026-06-26 Shenlan H3C to S6730 migration planning

## Background

The user wants to replace the current H3C S5130V2 core with Huawei S6730 plus Huawei S5735 access switches. H3C currently acts as the production L3 core, DHCP server, VLAN gateway, and default-route handoff to OpenWrt, so a direct physical swap would risk duplicate gateways, DHCP conflicts, and lost legacy PBR/WOL behavior.

## Changes

- Exported H3C current configuration and migration state by read-only SSH. Raw files are intentionally under the `shenlan-network-ops` ignored local directories because they contain SNMP community, password hashes, and other sensitive material:
  - `/Users/xinping/Documents/shenlan-network-ops/backups/h3c/h3c-current-config-20260626-130616.txt`
  - `/Users/xinping/Documents/shenlan-network-ops/captures/h3c/h3c-migration-state-20260626-130616.txt`
- Added sanitized migration plan `/Users/xinping/Documents/shenlan-network-ops/plans/h3c-to-s6730-core-migration.md`.
- Added sanitized S6730 preconfiguration template `/Users/xinping/Documents/shenlan-network-ops/plans/s6730-core-preconfig-template.md`.
- Confirmed S6730 `192.168.99.12` is reachable by ping and TCP/22, but SSH resets during key exchange from macair. Use console or repair SSH before relying on remote SSH for cutover.

## Why This Way

The plan splits safe preconfiguration from cutover-only commands. VLAN definitions, English DHCP pool names, LLDP/STP/NTP/SNMP baselines, and inactive templates can be prepared in advance. Existing H3C gateway IPs such as `192.168.99.1` and business VLAN `.1` addresses must not be enabled on S6730 until H3C gateway ownership is removed, otherwise duplicate IP/DHCP conflicts are likely.

## Alternatives Not Taken

- Did not paste or commit raw H3C configuration because it contains secrets and hashes.
- Did not blindly translate H3C PBR to Huawei syntax because the policies point to `172.16.201.1` and `192.168.110.2`; their current business purpose must be confirmed before migration.
- Did not preserve garbled H3C Chinese DHCP pool names. The S6730 template uses English pool names to avoid encoding damage.
- Did not execute S6730 preconfiguration yet because the user asked to study the migration plan first and S6730 SSH is not currently reliable from macair.

## Validation

- Commands run:
  - `git pull --rebase` in both Deepseek and `shenlan-network-ops`.
  - H3C read-only `display current-configuration`, `display interface brief`, `display vlan`, `display ip interface brief`, `display ip routing-table`, `display dhcp server ip-pool`, `display dhcp server ip-in-use`, `display lldp neighbor-information list`, `display arp`, and `display mac-address`.
  - S6730 reachability probe: `ping`, `nc -vz`, and `ssh -vvv` to `192.168.99.12`.
- Result:
  - H3C raw export succeeded: 626-line config and 1020-line state capture.
  - H3C roles identified: VLANIF gateways for VLAN10/16/17/18/19/20/30/40/50/60/70/80/90/99/110/120/201; DHCP pools for VLAN10/16/17/18/19/20/30/60/80/90/120; default route to OpenWrt `192.168.99.3`; PBR and WOL/directed broadcast ACLs present.
  - S6730 management IP `192.168.99.12` responds to ICMP and TCP/22, but SSH key exchange resets from macair.

## Risks

- Raw ignored backup files exist only on this Mac and are not synchronized.
- S6730 console access is available per user report, but SSH must be repaired or avoided for cutover.
- Huawei syntax for directed broadcast/WOL and PBR must be tested before preserving those behaviors.
- First cutover should leave H3C powered and console-reachable for rollback.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not a runbook yet; added migration plan and preconfiguration template in `shenlan-network-ops/plans/`.

## Handoff Notes

Before touching S6730 production config, read the sanitized migration plan and template, then use the local raw H3C export only if you are on this Mac and need exact source config. Do not enable S6730 VLANIF gateway addresses or DHCP service before H3C is disconnected or disabled for those VLANs. Confirm S6730 console access and decide physical port mapping first.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/plans/h3c-to-s6730-core-migration.md`
- `/Users/xinping/Documents/shenlan-network-ops/plans/s6730-core-preconfig-template.md`
- `/Users/xinping/Documents/shenlan-network-ops/backups/h3c/h3c-current-config-20260626-130616.txt` (ignored, sensitive)
- `/Users/xinping/Documents/shenlan-network-ops/captures/h3c/h3c-migration-state-20260626-130616.txt` (ignored, sensitive)
