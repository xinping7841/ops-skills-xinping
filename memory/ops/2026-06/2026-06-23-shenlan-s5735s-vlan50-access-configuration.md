# 2026-06-23 Shenlan S5735S VLAN50 access configuration

## Background

The user asked to repurpose the onsite Huawei S5735S as a VLAN50 access switch, move the uplink to port 1, assign management IP `192.168.99.10`, and enable SSH. The first attempt left the switch reachable only by console because the upstream H3C port was still access VLAN50 and did not pass tagged VLAN99.

## Changes

- On S5735S `S5735S-VLAN50-Access`:
  - Created/kept VLAN `50` and `99`.
  - Configured `Vlanif99` as `192.168.99.10/24`.
  - Configured `GE0/0/1` as trunk, allowing VLAN `50` and `99`, with VLAN1 removed.
  - Configured `GE0/0/2-28` as access VLAN50 with edge-port enabled.
  - Enabled STelnet/SSH sourced from `Vlanif99`.
  - Created local SSH user `admin` and later unified SSH and console passwords to the user-specified final value; password is not recorded here.
  - Saved the S5735S configuration.
- On H3C core:
  - Confirmed S5735S LLDP neighbor on `GigabitEthernet1/0/11`.
  - Changed `GigabitEthernet1/0/11` from access VLAN50 to trunk, allowing VLAN `50` and `99`, with VLAN1 removed.
  - Saved H3C configuration with `save force`.

## Why This Way

The S5735S management interface lives on VLAN99 while its user/monitoring access ports are VLAN50. The uplink therefore must carry tagged VLAN50 and VLAN99. H3C `GE1/0/11` was previously access VLAN50, so VLAN99 management traffic could not reach the core gateway.

## Alternatives Not Taken

- Did not leave H3C `GE1/0/11` as access VLAN50 because S5735S management on VLAN99 would remain unreachable.
- Did not configure all S5735S ports as trunks; only `GE0/0/1` is uplink trunk, and `GE0/0/2-28` are VLAN50 access ports.
- Did not store the console/SSH password in Git, memory, or chat summaries.

## Validation

- S5735S checks:
  - `display ssh server status` showed STELNET IPv4/IPv6 enabled and SSH server source interface `Vlanif99`.
  - `display ip interface brief` showed `Vlanif99 192.168.99.10/24 up/up`.
  - `display current-configuration interface GigabitEthernet0/0/1` showed trunk allowing VLAN `50 99`.
  - `display vlan 50` showed `GE0/0/1` tagged and `GE0/0/2-28` untagged VLAN50.
- H3C checks:
  - `display current-configuration interface GigabitEthernet1/0/11` showed trunk allowing VLAN `50 99`.
  - `display vlan 99` showed `GigabitEthernet1/0/11` as tagged.
  - H3C ping to `192.168.99.10` succeeded: 5/5 received, 0% packet loss.
- Node-121 checks:
  - `ping -c 3 192.168.99.10` succeeded: 3/3 received.
  - `nc -vz -w 3 192.168.99.10 22` succeeded.
- Node-121 environment gap:
  - `node-121` did not have `expect`, so interactive SSH automation for S5735S could not run there during the onsite session.
  - The gap was documented in `shenlan-network-ops/inventory/services/node-121.md`; the earlier standalone environment-gap page was removed to keep the repo compact.
- Password verification:
  - SSH login to `admin@192.168.99.10` succeeded with the final user-specified password after clearing the Huawei initial-password change prompt.
  - Console logout/login also succeeded with the same final password.

## Risks

- S5735S clock is still stale (`2024-01-15` observed earlier); configure NTP/time later so logs are meaningful.
- SSH and console authentication currently use a local password for onsite setup. Consider replacing or supplementing this with a documented read-only/ops account policy before long-term use.
- Install `expect` on `node-121` or choose a longer-term toolchain such as Oxidized/Netmiko/NAPALM/Nornir before expecting node-121 to run interactive switch automation.
- H3C and S5735S raw console logs remain local only under ignored `local-captures/`; do not commit them without review and redaction.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch CLI runbook remains applicable.

## Handoff Notes

For follow-up, use `ssh admin@192.168.99.10` from a routed management host such as `node-121` or console access. Verify NTP/time, SNMPv3/LibreNMS onboarding, and whether all `GE0/0/2-28` should remain VLAN50 access or whether some ports need shutdown/description updates.

The private Shenlan device-management repository now includes the S5735S asset page and a compact node-121 environment gap note:

- `xinping7841/shenlan-network-ops` commit `21f7b15`: S5735S VLAN50 asset/config state.
- `xinping7841/shenlan-network-ops` commit `8360854` plus follow-up cleanup: node-121 interactive CLI tooling gap is kept in the existing service inventory instead of a standalone page.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/local-captures/`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/switch-cli-readonly-diagnostics.md`
