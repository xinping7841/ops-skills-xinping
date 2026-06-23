# 2026-06-23 Shenlan S5735S console initial read

## Background

The user connected a console cable to an onsite Huawei S5735S switch and asked Codex to read its information. The device appeared to be uninitialized at first console login, so a console login password was set with user-provided credentials to allow readonly discovery.

## Changes

- Initialized the S5735S console login password from the first-login prompt. The password is not recorded in Git or memory.
- Collected readonly console output for version, ESN, clock, device status, interface brief, VLAN, port VLAN, IP interface, LLDP neighbor, MAC table, STP, and current configuration.
- Redacted local capture logs are under `/Users/xinping/Documents/shenlan-network-ops/local-captures/`, which is ignored by Git.

## Why This Way

Console was the only available management path in the immediate onsite context. The workflow stayed in Huawei VRP user view and used `display` commands only after the first-login password was set.

## Alternatives Not Taken

- Did not configure VLAN40 or a management IP because the user asked to read information first.
- Did not save or commit the raw configuration output because it may contain sensitive local state.
- Did not store the console password in memory, Git, or chat summaries.

## Validation

- Commands run: `display version`, `display esn`, `display clock`, `display device`, `display interface brief`, `display vlan`, `display port vlan`, `display ip interface brief`, `display lldp neighbor brief`, `display mac-address`, `display stp brief`, `display current-configuration`.
- Result: device is `S5735S-L24T4S-QA2`, VRP `V200R021C00SPC600`, ESN `3G21B0008306`, sysname `FutureMatrix`, uptime about 1 week 1 day, clock still `2024-01-15` UTC. Only VLAN 1 exists; `Vlanif1` has no IP. All ports are auto/PVID 1/trunk VLAN list 1-4094. LLDP shows `GE0/0/23` neighbor `H3C` on `GE1/0/11`; STP marks `GE0/0/23` as root forwarding. Several access ports are up, with one input error seen on `GE0/0/21`.

## Risks

- The switch is not yet safely configured for the intended VLAN40-only monitoring access role. In its current state, it is a broad default VLAN1 L2 switch.
- Because all ports are in auto mode with PVID 1 and broad trunk VLAN list display, avoid connecting it into production trunks until VLAN40 access/trunk intent is explicitly configured and verified.
- The device clock is stale, so logs cannot be trusted for real timestamps until NTP/time is configured.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch readonly runbook was followed.

## Handoff Notes

Before configuring this S5735S, decide the target physical role and exact uplink/downlink ports. For VLAN40-only monitoring access, prepare a pre-change checklist and configure only the intended uplink/access ports, then verify from H3C and the switch console. Do not commit raw captures or password material.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s5735s-full-read-20260623-094136.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s5735s-port-read-20260623-094236.log`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/switch-cli-readonly-diagnostics.md`
