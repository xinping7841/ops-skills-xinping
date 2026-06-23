# 2026-06-23 Shenlan H3C GE1/0/20 VLAN99 switch management setup

## Background

The user wanted to debug a newly connected access switch whose management network should be on VLAN99. H3C core `GE1/0/20` was previously one of the VLAN120 free-DHCP ports, so a switch attached there could not directly use the management subnet.

## Changes

- On H3C core `192.168.99.1`, changed only `GigabitEthernet1/0/20`:
  - Description set to `VLAN99-Switch-Management-Setup`.
  - Access VLAN changed from `120` to `99`.
  - Running configuration saved with `save force`.
- Updated the private Shenlan ops repo:
  - `inventory/devices/switches/h3c-s5130v2-28s-li.md`
  - `inventory/vlans/shenlan-vlans.md`
  - `docs/current-state.md`

## Why This Way

VLAN99 is the management subnet for the core, OpenWrt, ER5200G3, and managed switches. Making `GE1/0/20` an access VLAN99 port gives a newly attached switch a simple untagged management path during setup without touching trunk uplinks or other business VLANs.

## Alternatives Not Taken

- Did not change `GE1/0/21-24`; they remain VLAN120 free-DHCP ports.
- Did not configure `GE1/0/20` as a trunk yet because the immediate goal is simple management access for setup. A trunk should be planned separately once downstream VLAN needs are known.
- Did not modify H3C DHCP pools, VLANIFs, routing, OpenWrt, S5735S, ER5200G3, or WAN/DNS settings.

## Validation

- Pre-change `display current-configuration interface GigabitEthernet1/0/20` showed:
  - Description `VLAN120-Free-DHCP`.
  - `port access vlan 120`.
- Pre-change `display vlan 120` showed `GE1/0/20-24` untagged.
- Post-change `display current-configuration interface GigabitEthernet1/0/20` showed:
  - Description `VLAN99-Switch-Management-Setup`.
  - `port access vlan 99`.
- Post-change `display interface GigabitEthernet1/0/20` showed:
  - `Current state: UP`, `Line protocol state: UP`.
  - `PVID: 99`.
  - `Port link-type: Access`.
  - `Untagged VLANs: 99`.
- Post-change `display vlan 99` showed `GE1/0/20` as an untagged member.
- Post-change `display vlan 120` no longer included `GE1/0/20`; VLAN120 untagged members are now `GE1/0/21-24`.
- Post-change MAC table showed MAC `3cc7-861b-cf60` learned on VLAN99 via `GE1/0/20`.
- 12700K local evidence files:
  - `D:\IDE\AI\network-ops\state\h3c-ge20-vlan99-precheck-20260623-135526.txt`
  - `D:\IDE\AI\network-ops\state\h3c-ge20-to-vlan99-change-20260623-135545.txt`
  - `D:\IDE\AI\network-ops\state\h3c-ge20-vlan99-postcheck-20260623-135607.txt`

## Risks

- `GE1/0/20` was up before and after the change. Any device that expected VLAN120 DHCP on this port is now on VLAN99 instead.
- The interface currently negotiates at 100 Mbps full duplex and has historical errors: 8 input errors including 4 CRC and 3 frame errors, plus 4 lost-carrier output errors. Watch the cable and connected switch port during debugging.
- This is a convenience management setup port. Before using it for production downstream traffic, decide whether it should stay access VLAN99 or become a trunk with a documented allowed VLAN list.

## Rollback

To return `GE1/0/20` to the previous free-DHCP behavior:

```text
system-view
interface GigabitEthernet1/0/20
 description VLAN120-Free-DHCP
 port link-type access
 port access vlan 120
quit
quit
save force
```

Then verify `display vlan 120`, `display current-configuration interface GigabitEthernet1/0/20`, and `display interface GigabitEthernet1/0/20`.

## Machine / Sync Impact

- [x] Does not affect long-lived machine SSH/Tailscale/sync configuration.
- [x] Private Shenlan ops repo docs updated.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:

## Handoff Notes

Use H3C `GE1/0/20` as an untagged VLAN99 switch-management setup port for the newly connected switch. If the downstream switch must carry business VLANs later, replace this temporary access setup with an explicit trunk plan and update NetBox/LibreNMS after verification.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/switches/h3c-s5130v2-28s-li.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/vlans/shenlan-vlans.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
