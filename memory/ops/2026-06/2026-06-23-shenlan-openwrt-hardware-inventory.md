# 2026-06-23 Shenlan OpenWrt hardware inventory

## Background

The Shenlan operations backlog still listed the OpenWrt main router version and physical port mapping as unknown. The user asked for detailed OpenWrt router hardware information, so the live router was queried read-only and the sanitized facts were written into the dedicated Shenlan operations repository.

## Changes

- Queried OpenWrt main router `192.168.99.3` over existing key-based SSH as `root` using read-only system commands.
- Recorded sanitized hardware and interface facts in `D:\shenlan-network-ops\inventory\devices\core-devices.md`.
- Updated `D:\shenlan-network-ops\docs\current-state.md` to mark the OpenWrt hardware snapshot as complete.
- Updated `D:\shenlan-network-ops\docs\open-questions.md` so the remaining OpenWrt question is physical port labeling/line order, not OS version or logical interface role.
- No OpenWrt, H3C, S5735S, ER5200G3, VLAN, DNS, route, firewall, SQM, PBR, MWAN, DHCP, SNMP, LibreNMS, NetBox, or Scanopy configuration was changed.

## Why This Way

The dedicated `shenlan-network-ops` repository is the sanitized fact source for Shenlan assets. It should hold durable hardware facts and unresolved physical-site questions, while raw credentials, serial-focused asset data, raw configs, logs, and command dumps stay out of Git.

## Alternatives Not Taken

- Did not install extra packages such as `pciutils`, `usbutils`, `nvme-cli`, or `smartmontools` on the router; the requested inventory could be completed with existing read-only files and tools.
- Did not change live network configuration or restart services because the task was inventory only.
- Did not write device serial numbers into the shared repository; they are not necessary for this sanitized handoff and can be handled separately in an asset system if needed.

## Validation

- Commands run:
  - `ssh root@192.168.99.3 "cat /etc/openwrt_release; ubus call system board; uname -a; uptime"`
  - `ssh root@192.168.99.3 "cat /proc/cpuinfo; head -40 /proc/meminfo; free -h"`
  - `ssh root@192.168.99.3 "df -h; mount | grep -E ' / |/boot|/tmp'"`
  - `ssh root@192.168.99.3 "uci show network ...; ip route; ip rule"`
  - `ssh root@192.168.99.3 "sensors"`
  - `ssh root@192.168.99.3 "cat /sys/class/dmi/id/...; cat /sys/class/nvme/...; ethtool ..."`
- Result:
  - OpenWrt `25.12.4`, kernel `6.12.87`, target `x86/64`.
  - CPU Intel N150, 4 cores, 16GB RAM, no swap.
  - System disk Samsung SSD 980 500GB NVMe, root ext4 about 460GB.
  - Four Intel `igc` Ethernet interfaces: `eth0` rescue LAN link down, `eth1` WAN1/SDWAN at 2.5G, `eth2` WAN2/optical-modem path at 1G, `eth3.99` over `eth3` to H3C VLAN99 at 1G.
  - Temperature snapshot: CPU package about 43C, NVMe about 49C.

## Risks

- Physical port left-to-right order and cable labeling still require onsite visual confirmation before producing a handover-grade port diagram.
- Current link speeds reflect present peer devices/cables and may change if upstream equipment or cabling changes.
- `D:\shenlan-network-ops` has an unrelated untracked `inventory/devices/switches/` directory that was not touched or staged.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

For follow-up Shenlan hardware/topology work, read `D:\shenlan-network-ops\inventory\devices\core-devices.md` first. Treat OpenWrt logical interface roles as now confirmed from live UCI state, but still ask onsite staff to verify physical port labels and cable order before changing diagrams or NetBox cable records.

## Related Files

- `D:\shenlan-network-ops\inventory\devices\core-devices.md`
- `D:\shenlan-network-ops\docs\current-state.md`
- `D:\shenlan-network-ops\docs\open-questions.md`
