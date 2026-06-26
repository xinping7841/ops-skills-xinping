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
- Follow-up S6720S downstream access change:
  - Console-connected S5735S `S5735S-Access-8820` / ESN `3G21B0008820` was confirmed as factory-like after reset, then configured as a downstream access switch for the S6720S.
  - Physical link: S5735S `GigabitEthernet0/0/28` to S6720S `XGigabitEthernet0/0/28`, verified by LLDP on both sides.
  - S6720S `XGE0/0/28` was initially configured as trunk VLAN `10,99`, saved to `flash:/vrpcfg.zip`; it was later expanded to the small machine room test VLAN set below.
  - S5735S `GE0/0/28` was initially configured as trunk VLAN `10,99` with VLAN1 removed and `GE0/0/1-24` baseline access VLAN10; selected test ports were later reassigned as listed below.
  - S5735S management was configured as `Vlanif99 192.168.99.13/24` with default route via `192.168.99.1`.
  - S5735S SSH was enabled on `Vlanif99`; local `admin` password was set to the user-confirmed onsite password, and the VRP administrator first-login password policy was disabled because it prevented SSH login unless the password changed to a different value.
  - S5735S SNMP was configured as v2c only, using the existing node-121 secret and ACL `2001` restricted to `192.168.50.121`.
  - Added S5735S to LibreNMS as device ID `14`, display name `S5735S-Access-8820`; discovery and polling completed.
- Follow-up small machine room VLAN test expansion:
  - Expanded the H3C `Ten-GigabitEthernet1/0/25`, S6720S `XGigabitEthernet0/0/25`, S6720S `XGigabitEthernet0/0/28`, and S5735S-Access-8820 `GigabitEthernet0/0/28` trunks to allow VLANs `10,16-19,40,50,80,99`.
  - On both S6720S and S5735S-Access-8820, temporarily assigned test access ports: port 4 -> VLAN40, port 5 -> VLAN50, port 8 -> VLAN80, and ports 16/17/18/19 -> VLAN16/17/18/19.
  - Follow-up correction after laptop testing: S6720S has both `GigabitEthernet0/0/x` and `XGigabitEthernet0/0/x` numbered port families. The first pass configured the `XGE0/0/4/5/8/16-19` ports; the laptop was connected to ordinary `GE0/0/16`, so the ordinary `GE0/0/4/5/8/16-19` ports were configured to the same temporary VLAN map and saved.
  - Saved all three device configurations. These access assignments are explicitly temporary for testing and should be replaced by the final onsite port plan during installation.

## Why This Way

The link is switch-to-switch, so both sides should be trunk rather than leaving H3C as access VLAN10 and S6720S as default access VLAN1. VLAN10 carries the requested existing office VLAN path, and VLAN99 now carries management over the production uplink. The dedicated `MEth0/0/1` port is no longer required for normal LAN management, but remains available as an out-of-band port if a separate address is assigned later.

## Alternatives Not Taken

- Did not leave H3C `Te1/0/25` as access VLAN10 because the user specifically identified it as the uplink to the S6720S.
- Did not permit all VLANs on the new trunk. The trunk was later expanded only to the requested small machine room VLAN set `10,16-19,40,50,80,99`.
- Did not configure unrelated S6720S downstream ports, VLANIFs, SNMPv3, NTP, or additional LibreNMS onboarding; those still need a separate deployment plan.
- Did not use SNMPv3 for this device because the user explicitly requested v2c for simplicity after reviewing the existing LibreNMS/SNMP state. The v2c community is sourced from the existing local secret file and not recorded.
- Did not force SSH to a different password during VRP first-login change because the user explicitly confirmed the existing onsite password should remain in use. The administrator password policy was disabled for this S5735S to avoid forced SSH password rotation.

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
- S5735S-Access-8820 validation:
  - `display version` showed `S5735S-L24T4S-QA2` running `V200R021C00SPC600`; `display esn` showed `3G21B0008820`.
  - `display startup` showed next startup saved-configuration file `flash:/vrpcfg.zip`.
  - `display vlan 10` showed `GE0/0/1-24` untagged and `GE0/0/28` tagged/up.
  - `display vlan 99` showed `GE0/0/28` tagged/up.
  - `display ip interface brief` showed `Vlanif99 192.168.99.13/24 up/up`.
  - SSH to `192.168.99.13` succeeded after disabling the administrator first-login password policy.
  - node-121 SNMPv2c `snmpget` returned sysName `S5735S-Access-8820` and the VRP system description.
  - LibreNMS `lnms device:discover 14` and `lnms device:poll 14` completed successfully.
- Small machine room VLAN test expansion validation:
  - S6720S `display current-configuration interface XGigabitEthernet 0/0/25` and `XGigabitEthernet 0/0/28` showed `port trunk allow-pass vlan 10 16 to 19 40 50 80 99`.
  - S5735S-Access-8820 `display current-configuration interface GigabitEthernet 0/0/28` showed `undo port trunk allow-pass vlan 1` and `port trunk allow-pass vlan 10 16 to 19 40 50 80 99`.
  - H3C `display current-configuration interface Ten-GigabitEthernet 1/0/25` showed `undo port trunk permit vlan 1` and `port trunk permit vlan 10 16 to 19 40 50 80 99`.
  - S6720S test access ports verified: `XGE0/0/4` and `GE0/0/4` VLAN40, `XGE0/0/5` and `GE0/0/5` VLAN50, `XGE0/0/8` and `GE0/0/8` VLAN80, `XGE0/0/16-19` and `GE0/0/16-19` VLAN16/17/18/19. At verification time `GE0/0/16` showed untagged VLAN16 but physical down, so the client needed cable/link renewal.
  - S5735S-Access-8820 test access ports verified: `GE0/0/4` VLAN40, `GE0/0/5` VLAN50, `GE0/0/8` VLAN80, `GE0/0/16-19` VLAN16/17/18/19.
  - S6720S LLDP still showed H3C on `XGE0/0/25` and S5735S-Access-8820 on `XGE0/0/28`; S5735S-Access-8820 LLDP still showed S6720S on `GE0/0/28`.
  - `Vlanif99` management remained up/up on S6720S `192.168.99.11/24` and S5735S-Access-8820 `192.168.99.13/24`; macair ping to both addresses returned 0% packet loss.

## Risks

- S6720S now uses SNMPv2c rather than SNMPv3 by user request. Access is limited by device ACL to node-121 `192.168.50.121`, but v2c is still less secure than SNMPv3.
- S6720S is now uplinked and monitored but still lacks final production design for sysname, NTP, downstream access/trunk ports, and NetBox cabling.
- S5735S-Access-8820 uses SNMPv2c and has administrator password policy disabled by user preference for the existing onsite password. Access is limited by SNMP ACL, but this is less strict than SNMPv3 plus forced password rotation.
- S6720S and S5735S-Access-8820 now have temporary test access ports for VLAN40/50/80/16/17/18/19. On S6720S, both ordinary `GE0/0/x` and `XGE0/0/x` numbered test ports were configured because onsite testing used the ordinary GE ports. These are not a final production port map; formal installation should deliberately reassign ports and update NetBox/LibreNMS records.
- H3C `Te1/0/25` had historical minor input errors before the change (`2 input errors`, `1 CRC`, `1 runt`) and a recent link flap around cabling time. Watch counters while testing.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; this was a device-specific port change.

## Handoff Notes

Treat S6720S `XGE0/0/25` <-> H3C `Te1/0/25` as the active 10G trunk uplink for VLAN10/16-19/40/50/80/99. Treat S6720S `XGE0/0/28` <-> S5735S-Access-8820 `GE0/0/28` as the active downstream trunk for the same VLAN set. Manage S6720S at `192.168.99.11` and S5735S-Access-8820 at `192.168.99.13`, both through `Vlanif99`. LibreNMS device IDs are `13` for S6720S and `14` for S5735S-Access-8820`; SNMPv2c read access is intentionally limited to node-121. Current test access ports on S5735S are 4 -> VLAN40, 5 -> VLAN50, 8 -> VLAN80, and 16/17/18/19 -> VLAN16/17/18/19; on S6720S the same map exists on both ordinary `GE0/0/x` and `XGE0/0/x` families. Before formal installation, decide final access/trunk roles and update NetBox cabling.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/huawei-s6720s-s24s28x-a.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/huawei-s5735s-access-8820.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/h3c-s5130v2-28s-li.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/switch-catalog.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
