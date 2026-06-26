# 2026-06-26 Shenlan S6720S H3C Te25 trunk uplink configuration

## Background

The user connected the Huawei S6720S to the H3C core with optical port 25 on both devices and asked to change the H3C core 25th optical port from VLAN10 access into the uplink for the S6720S. Pre-checks confirmed H3C `Ten-GigabitEthernet1/0/25` was an access port in VLAN10 and LLDP already saw the S6720S peer `XGigabitEthernet0/0/25`.

## Changes

- On Huawei S6720S `FutureMatrix` / ESN `3G21B0060790` / `192.168.99.11`:
  - Created VLANs `10` and `99`.
  - Configured `XGigabitEthernet0/0/25` as trunk.
  - Description set to `TO-H3C-Core-Te1/0/25`.
  - Allowed VLANs `10,99`.
  - Saved configuration to `flash:/vrpcfg.zip`.
- On H3C core `192.168.99.1`:
  - Changed `Ten-GigabitEthernet1/0/25` from access VLAN10 to trunk.
  - Description set to `TO-S6720S-XGE0/0/25-UPLINK`.
  - Permitted VLANs `10,99`; default VLAN1 was removed from the trunk in a follow-up change.
  - Saved configuration with `save force`.
- Follow-up management changes on S6720S:
  - Moved management IP `192.168.99.11/24` from dedicated `MEth0/0/1` to `Vlanif99`.
  - Changed SSH server source interface from `MEth0/0/1` to `Vlanif99`.
  - Kept static default route via `192.168.99.1` on `Vlanif99`.
  - Enabled SNMPv2c read-only using the existing node-121 `snmpv2-switches.env` community and ACL `2001` limited to source `192.168.50.121`.
  - Bound SNMP protocol source interface to `Vlanif99`.
  - Added the device to LibreNMS as ID `13` with display name `S6720S-FutureMatrix`, then ran discovery and poll successfully.
- Updated sanitized private Shenlan ops docs:
  - `inventory/devices/switches/huawei-s6720s-s24s28x-a.md`
  - `inventory/devices/switches/h3c-s5130v2-28s-li.md`
  - `inventory/devices/switches/switch-catalog.md`
  - `docs/current-state.md`

## Why This Way

The link is switch-to-switch, so both sides should be trunk rather than leaving H3C as access VLAN10 and S6720S as default access VLAN1. VLAN10 carries the requested existing office VLAN path, and VLAN99 now carries management over the production uplink. The dedicated `MEth0/0/1` port is no longer required for normal LAN management, but remains available as an out-of-band port if a separate address is assigned later.

## Alternatives Not Taken

- Did not leave H3C `Te1/0/25` as access VLAN10 because the user specifically identified it as the uplink to the S6720S.
- Did not permit all VLANs on the new trunk. Only VLAN10 and VLAN99 were intentionally added for the current request and management expansion.
- Did not configure S6720S downstream access ports, VLANIFs, SNMPv3, NTP, or LibreNMS onboarding; those still need a separate deployment plan.
- Did not use SNMPv3 for this device because the user explicitly requested v2c for simplicity after reviewing the existing LibreNMS/SNMP state. The v2c community is sourced from the existing local secret file and not recorded.

## Validation

- H3C pre-check:
  - `display current-configuration interface Ten-GigabitEthernet 1/0/25` showed `port access vlan 10`.
  - `display interface Ten-GigabitEthernet 1/0/25` showed UP/UP, 10G optical, PVID 10, access VLAN10.
  - `display lldp neighbor-information interface Ten-GigabitEthernet 1/0/25` showed peer `XGigabitEthernet0/0/25`, chassis MAC `3cc7-861b-cf60`.
- S6720S pre-check:
  - `display current-configuration interface XGigabitEthernet 0/0/25` had no custom config.
  - `display interface XGigabitEthernet 0/0/25` showed UP/UP, access negotiated, PVID 1, 10G LR SFP.
- Post-change H3C:
  - `display current-configuration interface Ten-GigabitEthernet 1/0/25` showed description `TO-S6720S-XGE0/0/25-UPLINK`, `port link-type trunk`, `undo port trunk permit vlan 1`, and `port trunk permit vlan 10 99`.
  - `display interface Ten-GigabitEthernet 1/0/25 brief` showed `UP`, `10G(a)`, type `T`, PVID `1`.
  - `display vlan 10` showed `Te1/0/25` tagged.
  - `display vlan 99` showed `Te1/0/25` tagged.
  - LLDP still showed S6720S `XGigabitEthernet0/0/25`.
- Post-change S6720S:
  - `display current-configuration interface XGigabitEthernet 0/0/25` showed trunk and `port trunk allow-pass vlan 10 99`.
  - `display interface XGigabitEthernet 0/0/25` showed UP/UP, link-type trunk configured, speed 10000, no errors.
  - `display vlan 10` and `display vlan 99` showed `XGE0/0/25` tagged/up.
  - `display lldp neighbor brief` showed `XGE0/0/25` neighbor H3C `Ten-GigabitEthernet1/0/25`.
- Management/SNMP validation:
  - `display ip interface brief` showed `Vlanif99 192.168.99.11/24 up/up` and `MEth0/0/1 unassigned down/down`.
  - `display ssh server status` showed SSH server source interface `Vlanif99`.
  - `display ip routing-table 0.0.0.0` showed default route via `192.168.99.1` on `Vlanif99`.
  - From macair and node-121, ping and TCP/22 to `192.168.99.11` succeeded after the migration.
  - From node-121, SNMPv2c `snmpget` returned `sysName` `FutureMatrix` and S6720 VRP system description.
  - LibreNMS `lnms device:discover 13` and `lnms device:poll 13` completed successfully.

## Risks

- S6720S now uses SNMPv2c rather than SNMPv3 by user request. Access is limited by device ACL to node-121 `192.168.50.121`, but v2c is still less secure than SNMPv3.
- S6720S is now uplinked and monitored but still lacks final production design for sysname, NTP, downstream access/trunk ports, and NetBox cabling.
- H3C `Te1/0/25` had historical minor input errors before the change (`2 input errors`, `1 CRC`, `1 runt`) and a recent link flap around cabling time. Watch counters while testing.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; this was a device-specific port change.

## Handoff Notes

Treat S6720S `XGE0/0/25` <-> H3C `Te1/0/25` as the active 10G trunk uplink for VLAN10 and VLAN99. Manage the switch at `192.168.99.11` through `Vlanif99`, not `MEth0/0/1`. LibreNMS device ID is `13`; SNMPv2c read access is intentionally limited to node-121. Before adding downstream S6720S ports, decide access/trunk roles and update NetBox cabling.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/huawei-s6720s-s24s28x-a.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/h3c-s5130v2-28s-li.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/switch-catalog.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
