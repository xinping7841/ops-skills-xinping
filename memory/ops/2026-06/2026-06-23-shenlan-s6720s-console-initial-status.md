# 2026-06-23 Shenlan S6720S console initial status

## Background

The user connected a console cable to an onsite Huawei `S6720S-S24S28X-A` and asked for a status check. The switch was at first-login initialization and required a console password before any read-only inspection could run.

## Changes

- Initialized the console login password with the user-specified formal password. The password is not recorded in Git, memory, or local captures.
- Saved the current configuration so the console password survives reboot. `display startup` now shows next startup saved configuration `flash:/vrpcfg.zip`.
- Collected read-only console output for version, ESN, clock, device status, fans, temperature, CPU, memory, startup, interfaces, VLANs, port VLAN mode, IP interfaces, LLDP, MAC table, STP, logbuffer, trapbuffer, current configuration, and targeted optical-module checks.
- Raw captures are kept only under ignored local path `/Users/xinping/Documents/shenlan-network-ops/local-captures/`.

## Why This Way

The switch could not be inspected until first-login initialization completed. Saving only the minimal current configuration avoids losing the formal console password after a reboot while leaving the switch otherwise in its factory-like default state.

## Alternatives Not Taken

- Did not configure production VLANs, management VLAN, SSH users, SNMP, NTP, or uplinks because the user asked for status inspection, not deployment.
- Did not commit raw CLI captures or password material because raw configs can contain sensitive local state.
- Did not continue `display elabel` after the device warned it may take a long time; the prompt was cancelled.

## Validation

- Commands run: `display version`, `display esn`, `display clock`, `display device`, `display power`, `display fan`, `display temperature all`, `display cpu-usage`, `display memory-usage`, `display startup`, `display interface brief`, `display interface description`, `display vlan`, `display port vlan`, `display ip interface brief`, `display lldp neighbor brief`, `display mac-address`, `display stp brief`, `display logbuffer`, `display trapbuffer`, `display current-configuration`, `display interface GigabitEthernet0/0/1`, `display interface GigabitEthernet0/0/5`, and transceiver verbose checks for `GE0/0/1` and `GE0/0/5`.
- Result: model `S6720S-S24S28X-A`, VRP `V200R020C30`, ESN `3G21B0060790`, sysname `FutureMatrix`, uptime about 27 minutes at inspection, clock `2026-06-23 05:57 UTC`, slot status normal/master, fan 1-3 normal at 35%, temperature normal at 33 C, CPU about 3%, memory about 12%.
- Current switching state is factory-like: only VLAN 1 exists, all service ports are down, all service ports show auto/PVID 1/trunk VLAN list `1-4094`, no learned MAC entries, no STP active port rows, and `Vlanif1` has no IP.
- Only management Ethernet is up: `MEth0/0/1` has default IP `192.168.1.253/24` and LLDP neighbor `H3C` on `GE1/0/20`.
- Alarm found: `GE0/0/5` has an invalid optical-module/speed mismatch. Targeted check showed `GE0/0/5` is a 1G interface reporting a `10GBASE_SR_SFP` / `SFP-10G-T` module, RX `-40.00 dBm`, and link down. `GE0/0/1` has a `1000_BASE_T_SFP` copper module and is also link down.

## Risks

- Do not connect this switch into production trunks yet. It is still a broad default VLAN1 L2 switch with no intended Shenlan VLAN design applied.
- `MEth0/0/1` default IP `192.168.1.253/24` is reachable only via the connected management path and should be redesigned before long-term use.
- `GE0/0/5` module should be removed or replaced with a module appropriate for that interface before use.
- Startup saved-configuration current file remains `NULL` until reboot, while next startup file is `flash:/vrpcfg.zip`; this is normal immediately after first save but should be rechecked after any reboot.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch read-only diagnostics runbook was followed.

## Handoff Notes

Before deploying this S6720S, decide whether it is a spare/lab switch, aggregation switch, or production access/uplink device. Prepare a separate pre-change plan for sysname, clock/NTP, management VLAN/IP, SSH user policy, SNMPv3, VLAN/trunk/access role, and replacement/removal of the invalid `GE0/0/5` module.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-full-read-20260623-1345.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-optical-read-20260623-1400.log`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/switch-cli-readonly-diagnostics.md`
