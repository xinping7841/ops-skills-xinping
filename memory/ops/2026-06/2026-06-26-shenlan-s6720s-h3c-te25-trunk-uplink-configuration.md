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
  - Permitted VLANs `10,99`; Comware retained default VLAN1 on the trunk.
  - Saved configuration with `save force`.
- Updated sanitized private Shenlan ops docs:
  - `inventory/devices/switches/huawei-s6720s-s24s28x-a.md`
  - `inventory/devices/switches/h3c-s5130v2-28s-li.md`
  - `inventory/devices/switches/switch-catalog.md`
  - `docs/current-state.md`

## Why This Way

The link is switch-to-switch, so both sides should be trunk rather than leaving H3C as access VLAN10 and S6720S as default access VLAN1. VLAN10 carries the requested existing office VLAN path, and VLAN99 is included for management/control-plane expansion on the uplink. S6720S management currently remains on `MEth0/0/1 192.168.99.11`, so this did not depend on the new trunk for SSH reachability.

## Alternatives Not Taken

- Did not leave H3C `Te1/0/25` as access VLAN10 because the user specifically identified it as the uplink to the S6720S.
- Did not permit all VLANs on the new trunk. Only VLAN10 and VLAN99 were intentionally added for the current request and management expansion.
- Did not configure S6720S downstream access ports, VLANIFs, SNMPv3, NTP, or LibreNMS onboarding; those still need a separate deployment plan.

## Validation

- H3C pre-check:
  - `display current-configuration interface Ten-GigabitEthernet 1/0/25` showed `port access vlan 10`.
  - `display interface Ten-GigabitEthernet 1/0/25` showed UP/UP, 10G optical, PVID 10, access VLAN10.
  - `display lldp neighbor-information interface Ten-GigabitEthernet 1/0/25` showed peer `XGigabitEthernet0/0/25`, chassis MAC `3cc7-861b-cf60`.
- S6720S pre-check:
  - `display current-configuration interface XGigabitEthernet 0/0/25` had no custom config.
  - `display interface XGigabitEthernet 0/0/25` showed UP/UP, access negotiated, PVID 1, 10G LR SFP.
- Post-change H3C:
  - `display current-configuration interface Ten-GigabitEthernet 1/0/25` showed description `TO-S6720S-XGE0/0/25-UPLINK`, `port link-type trunk`, and `port trunk permit vlan 1 10 99`.
  - `display interface Ten-GigabitEthernet 1/0/25 brief` showed `UP`, `10G(a)`, type `T`, PVID `1`.
  - `display vlan 10` showed `Te1/0/25` tagged.
  - `display vlan 99` showed `Te1/0/25` tagged.
  - LLDP still showed S6720S `XGigabitEthernet0/0/25`.
- Post-change S6720S:
  - `display current-configuration interface XGigabitEthernet 0/0/25` showed trunk and `port trunk allow-pass vlan 10 99`.
  - `display interface XGigabitEthernet 0/0/25` showed UP/UP, link-type trunk configured, speed 10000, no errors.
  - `display vlan 10` and `display vlan 99` showed `XGE0/0/25` tagged/up.
  - `display lldp neighbor brief` showed `XGE0/0/25` neighbor H3C `Ten-GigabitEthernet1/0/25`.

## Risks

- H3C Comware retained VLAN1 on the trunk (`port trunk permit vlan 1 10 99`) while S6720S only allows VLAN10/99. VLAN1 is therefore not intentionally usable end-to-end, but the H3C side still lists it as permitted/default.
- S6720S is now uplinked but still lacks final production design for sysname, NTP, SNMPv3/LibreNMS, SSH ACLs, downstream access/trunk ports, and NetBox cabling.
- H3C `Te1/0/25` had historical minor input errors before the change (`2 input errors`, `1 CRC`, `1 runt`) and a recent link flap around cabling time. Watch counters while testing.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; this was a device-specific port change.

## Handoff Notes

Treat S6720S `XGE0/0/25` <-> H3C `Te1/0/25` as the active 10G trunk uplink for VLAN10 and VLAN99. Before adding downstream S6720S ports, decide access/trunk roles and update NetBox/LibreNMS. If VLAN1 should be removed from H3C's trunk list, make that a separate checked change with post-validation.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/huawei-s6720s-s24s28x-a.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/h3c-s5130v2-28s-li.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/switch-catalog.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
