# Shenlan Office Access Switch Status Snapshot - 2026-06-18 13:35

Updated: 2026-06-18 13:40 Asia/Shanghai

## Purpose

After fixing the VLAN16/17/18 OpenWrt return routes, the user asked to check the office access switch traffic status and endpoint access state.

## Devices

- Office access switch: `S5735S-Office-Access`, management `192.168.99.2`
- Office access uplink: S5735S `GE0/0/25` -> H3C core `XGE1/0/28`
- Active VLANs on this access switch: VLAN16, VLAN17, VLAN18, plus management/uplink VLANs

## Traffic / Interface Summary

The access switch was not congested and no current interface error pattern was observed.

S5735S `display interface brief` at device time around `12:10` showed:

- `GE0/0/25` uplink up/up, input about `0.67%`, output about `0.23%`, `0` input/output errors.
- Active access ports all reported `0` input/output errors in the brief output.
- Highest visible current access-port output was `GE0/0/2` at about `0.43%`, still far below congestion.

H3C `XGE1/0/28` at H3C time `13:35` showed:

- Up/up, 1G full duplex over optical module.
- Current traffic about `269 KB/s` input and `789 KB/s` output on the H3C side, around `0-1%` utilization.
- `0` input errors, `0` CRC, `0` output errors.
- Last physical flap was from the earlier setup period on 2026-06-16, not during this incident.

## Port / VLAN Access State

VLAN16:

- Online access ports: `GE0/0/1`, `GE0/0/2`
- Idle/down configured ports: `GE0/0/3`, `GE0/0/5`, `GE0/0/6`
- `GE0/0/4` is administratively down
- Tagged uplink: `GE0/0/25`

VLAN17:

- Online access ports: `GE0/0/9`, `GE0/0/10`, `GE0/0/12`
- Idle/down configured ports: `GE0/0/11`, `GE0/0/13`, `GE0/0/14`, `GE0/0/15`, `GE0/0/16`
- Tagged uplink: `GE0/0/25`

VLAN18:

- Online access ports: `GE0/0/18`, `GE0/0/19`, `GE0/0/24`
- Idle/down configured ports: `GE0/0/17`, `GE0/0/20`, `GE0/0/21`, `GE0/0/22`, `GE0/0/23`
- Tagged uplink: `GE0/0/25`

## Endpoint / MAC / ARP State

S5735S dynamic MAC view:

- VLAN16: 7 MAC entries total, including the H3C gateway MAC on the uplink; about 6 endpoint/downstream MACs.
- VLAN17: 6 MAC entries total, including the H3C gateway MAC on the uplink; about 5 endpoint/downstream MACs.
- VLAN18: 10 MAC entries total, including the H3C gateway MAC on the uplink; about 9 endpoint/downstream MACs.

H3C ARP active endpoints behind `XGE1/0/28`:

- VLAN16: `192.168.16.2`, `.3`, `.4`, `.7`, `.9`, `.10`
- VLAN17: `192.168.17.2`, `.3`, `.9`, `.11`, `.14`, `.15`
- VLAN18: `192.168.18.14`, `.18`, `.19`, `.20`, `.22`, `.25`, `.26`, `.27`, `.28`, `.29`, `.30`, `.31`

H3C DHCP leases:

- VLAN16: 8 active leases in the DHCP table.
- VLAN17: 10 active leases in the DHCP table.
- VLAN18: 22 active leases in the DHCP table.

The DHCP lease count being higher than current ARP/MAC visibility is expected when devices are offline, idle, sleeping, or have recently moved.

## Notable Observation

The test laptop MAC `a82b-dd5d-de2b` appeared in both VLAN17 and VLAN16 state during the troubleshooting window:

- VLAN17: `GE0/0/12`, IP `192.168.17.15`
- VLAN16: IP `192.168.16.10` observed by H3C during the later snapshot

This may be stale ARP/MAC state after onsite plug/unplug testing or the same laptop/adapter being moved between VLAN16 and VLAN17 ports. If it persists, check whether the laptop has bridging, Internet sharing, a virtual switch, or another dual-access path.

## Connectivity Verification

After the OpenWrt route fix, H3C sourced pings from VLAN gateways to public IP `223.5.5.5` passed:

- Source `192.168.16.1`: 3/3 received, 0% loss.
- Source `192.168.17.1`: 3/3 received, 0% loss.
- Source `192.168.18.1`: 3/3 received, 0% loss.

## Interpretation

At this snapshot, the office access switch itself looked healthy:

- Uplink was up, clean, and lightly utilized.
- Active access ports had no visible error counters.
- VLAN16/17/18 endpoint learning was present.
- VLAN16/17/18 egress through OpenWrt had recovered after the route fix.

If a specific endpoint still reports no network, continue with that endpoint's IP/MAC: confirm switch port, DHCP lease, ARP, gateway reachability, DNS, and local client settings.
