# Shenlan Scanopy Onboarding and VLAN Discovery

Time: 2026-06-18 23:10 Asia/Shanghai

## Summary

Completed Scanopy first-run onboarding on `node-121` / `192.168.50.121` / `100.122.235.56` and started discovery for the Shenlan LAN topology.

Admin account was created for the local Scanopy instance. The password was provided interactively by the user and is intentionally not recorded here.

## Current Access

- LAN URL: `http://192.168.50.121:60072/`
- Tailscale URL: `http://100.122.235.56:60072/`
- Scanopy containers remained healthy:
  - `scanopy-server-1`
  - `scanopy-daemon`
  - `scanopy-postgres-1`

## Initial Scan Result

The first onboarding discovery completed successfully using the daemon auto-interface mode.

Observed after first completion:

- `48` hosts
- `76` services
- `9` subnets
- Primary auto-discovered subnet: `192.168.50.0/24`
- Docker bridge subnets were also discovered from the host daemon and Docker socket integration.

This confirmed Scanopy can discover the service host and VLAN50-side hosts, but daemon auto-interface mode does not enumerate routed H3C VLANs by itself.

## Standardized Shenlan Subnets Added to Scanopy

Added the following manual subnets to Scanopy under network `Shenlan LAN`:

| Name | CIDR | Type |
|---|---:|---|
| VLAN10 Office Wired | `192.168.10.0/24` | Lan |
| VLAN16 Marketing | `192.168.16.0/24` | Lan |
| VLAN17 Training | `192.168.17.0/24` | Lan |
| VLAN18 AI Innovation | `192.168.18.0/24` | Lan |
| VLAN19 Reception | `192.168.19.0/24` | Lan |
| VLAN20 WiFi AP Management | `192.168.20.0/24` | Management |
| VLAN30 NAS Storage | `192.168.30.0/24` | Storage |
| VLAN40 Surveillance | `192.168.40.0/24` | Lan |
| VLAN50 Showroom Extension | `192.168.51.0/24` | Lan |
| VLAN60 WiFi Clients | `192.168.60.0/23` | WiFi |
| VLAN70 Workshop | `192.168.70.0/24` | Lan |
| VLAN80 Hall 2 | `192.168.80.0/24` | Lan |
| VLAN90 XR Studio | `192.168.90.0/24` | Lan |
| VLAN99 Core Management | `192.168.99.0/24` | Management |
| VLAN120 Temporary DHCP | `192.168.120.0/24` | Lan |
| VLAN201 Optical Modem | `172.16.201.0/24` | Management |

Updated the scheduled Discovery `36294d4a-e0fc-4694-8020-b74a4b1d33d1` so its `Unified.subnet_ids` contains the 17 intended Shenlan subnets, including the original `192.168.50.0/24`.

## Discovery Runs

Two manual Run attempts were started after adding routed VLAN subnets. Scanopy marks manual runs as full scans (`Full 65k ports override`), which made the 17-subnet run estimate more than one hour.

Actions taken:

- Cancelled manual full scan session `6033c587-3db6-4495-81b4-acb598f41b51` at about `35%`.
- Cancelled manual full scan session `b2954b0b-560a-44a4-b7f8-07d4c03b2c90`.
- Restored the scheduled Discovery cron schedule to weekly: `0 0 0 * * 0`.
- Rebuilt topology `f246d197-0e71-4eea-9fe7-ca6afe9af27f`.

Current Scanopy counts after the partial routed-VLAN discovery and rebuild:

- `50` hosts
- `78` services
- `25` subnets

New routed VLAN host discovered before cancellation:

| Host | Subnet |
|---|---|
| `192.168.30.2` | VLAN30 NAS Storage |

## Visual Output

Local screenshots were saved on macair for user review only and were not committed:

- `/Users/wanghongyu/Documents/Deepseek/output/scanopy-topology-after-shenlan-subnets.png`
- `/Users/wanghongyu/Documents/Deepseek/output/shenlan-topology-current-sharp.png`

## Caveats and Next Steps

Scanopy is now useful for fast initial topology visualization, but exact L2 switch-port ownership still needs proper SNMP inventory from H3C/S5735S/ER5200G3. The current configured SNMP credential in Scanopy is the onboarding test community and may not be sufficient for production H3C/Huawei port and LLDP/CDP data.

Recommended next action:

1. Add the real H3C/S5735S SNMP credential to Scanopy without recording it in the shared repo.
2. Prefer targeted subnet or host scans instead of manual full scans across all 17 subnets.
3. If Scanopy cannot run routed-VLAN light scans on demand without full-scan override, use scheduled light discovery or import H3C ARP/MAC/SNMP data through the API.

No OpenWrt, H3C, ER5200G3, VLAN, DNS, routing, firewall, SQM, OpenClash, PBR, or MWAN configuration was changed during this Scanopy onboarding/discovery work.
