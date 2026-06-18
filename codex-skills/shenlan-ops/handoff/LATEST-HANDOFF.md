# Shenlan Network Ops Latest Handoff

Updated: 2026-06-18 09:50 Asia/Shanghai

Latest change: 2026-06-18 09:50 Asia/Shanghai. Morning disconnect diagnosis found that OpenWrt itself had intermittent public HTTP failures, so the issue was not isolated to the Mac/VLAN16 client. OpenWrt was changed so WAN2/direct optical modem is the global default route, WAN1/SDWAN is retained for marked policy traffic, and dnsmasq upstream DNS was changed to Beijing Telecom `219.141.136.10` with AAAA filtering. A starter foreign-domain nft mark set was created, but its cron refresh is currently disabled because the installed dnsmasq has `no-ipset no-nftset` and the helper resolver may add DNS pressure. See `D:\IDE\AI\network-ops\handoff\shenlan-wan2-default-dns-adjustment-2026-06-18-0950.md`.

Latest probe expansion: 2026-06-18 08:20 Asia/Shanghai. Added HTTP/HTTPS and DNS health probes to OpenWrt 1-minute collector so future public ICMP loss can be distinguished from real web/DNS reachability failure. New files: `/root/shenlan-usage/health/http-health-YYYY-MM-DD.csv` and `/root/shenlan-usage/health/dns-health-YYYY-MM-DD.csv`. See `D:\IDE\AI\network-ops\handoff\shenlan-http-dns-health-probes-2026-06-18-0820.md`.

Stage summary: 2026-06-18. The recent upload limiting, flash-disconnect diagnosis, `nlbwmon` stop, overnight findings, and HTTP/DNS probe expansion are summarized in `D:\IDE\AI\network-ops\handoff\shenlan-flap-traffic-stage-summary-2026-06-18.md`.

Latest live event: 2026-06-17 19:00 Asia/Shanghai. User reported another short disconnect around 18:48. The 1-minute OpenWrt health probe captured a matching 18:45 event: H3C core, WAN1 gateway, and WAN2 gateway were reachable, while both public targets had 100% loss for that minute. OpenWrt simultaneously logged a large `nlbwmon` MAC lookup storm. `nlbwmon` was temporarily stopped at about 18:52 and stayed inactive; public probes from 18:53 onward were healthy. See `D:\IDE\AI\network-ops\handoff\shenlan-flap-event-nlbwmon-stop-2026-06-17-1900.md`.

Latest continuation: 2026-06-17 17:35 Asia/Shanghai. See `D:\IDE\AI\network-ops\handoff\shenlan-traffic-dns-observation-2026-06-17-1730.md`.
Latest change: 2026-06-17 17:58 Asia/Shanghai. Temporary host upload limits were applied on OpenWrt for `192.168.10.16` and `192.168.10.60`; see `D:\IDE\AI\network-ops\handoff\openwrt-host-upload-rate-limit-2026-06-17-1758.md`.
Latest troubleshooting: 2026-06-17 18:20 Asia/Shanghai. User reported frequent short disconnects. No router reboot, WAN1 link flap, or internal management packet loss was found during the check window. OpenWrt `nlbwmon` was flooding logs with netlink/conntrack buffer errors, so its buffer/refresh settings and kernel receive buffer limit were tuned; see `D:\IDE\AI\network-ops\handoff\shenlan-flap-diagnosis-nlbwmon-tuning-2026-06-17-1820.md`.
Latest observation setup: 2026-06-17 18:35 Asia/Shanghai. Added a 1-minute OpenWrt health probe to observe for one day. Main purpose: analyze short disconnects and the overall traffic situation, identify concrete problem sources, and decide handling/optimization direction; see `D:\IDE\AI\network-ops\handoff\shenlan-24h-health-observation-setup-2026-06-17-1835.md`.

Use this file when a new Codex/Kun conversation needs to continue Shenlan network operations without the full chat history.

## How To Resume

Read these first:

```text
D:\IDE\AI\AGENTS.md
C:\Users\gaoxi\.codex\skills\shenlan-ops\SKILL.md
D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md
```

Then load referenced files only as needed.

## Current Objective

The Shenlan site network is online. OpenWrt x86 N150 replaced ER5200G3 as the main router. H3C core remains the internal L3 gateway and DHCP server. ER5200G3 remains router-mode but is only used as AC/MiniAP controller with ordinary DHCP disabled.

Near-term work:

1. Observe the 2026-06-18 09:50 WAN/DNS change: WAN2 is now the global default route, WAN1 remains available for marked policy traffic, and dnsmasq uses Beijing Telecom `219.141.136.10` with AAAA filtering. Watch whether domestic browsing stabilizes and whether foreign services route/resolve as intended.
2. Continue observing whether reported short disconnects stop while OpenWrt `nlbwmon` is temporarily inactive. The 18:45 event strongly implicated `nlbwmon` telemetry pressure: WAN gateways stayed reachable, both public probes failed for one minute, and an `nlbwmon` MAC lookup storm occurred at the same time. If reports continue while `nlbwmon` remains inactive, inspect the exact probe minute and collect longer probes from an affected client/VLAN to gateway, OpenWrt, WAN1 gateway, public IP, and DNS.
3. After one day of observation, analyze both flash-disconnect evidence and overall traffic/optimization direction: loss/latency by layer, interface error deltas, nlbwmon health, rate-limit hits, heavy clients/VLANs, WAN utilization, and SQM drops/overlimits.
4. Continue observing DHCP/DNS stability after the H3C DNS fix.
5. Observe the OpenWrt host upload limits. `192.168.10.16` and `192.168.10.60` are each limited to about `8Mbit/s` WAN upload using nftables `limit rate over 1000 kbytes/second drop`; counters remained `0` during the 18:20 flash-disconnect diagnosis.
6. Fix backup/report sync to QNAP. Latest reporting run synced WPS and fnOS, but QNAP failed with an SMB username/password error.
7. Deploy scheduled backups, monitoring, reports, and optional WPS/Feishu sync on `192.168.50.121`.
8. Later, optionally rebuild H3C DHCP pools with English names during a maintenance window.

## Device Roles

| Device | Address | Role |
|---|---:|---|
| OpenWrt main router | `192.168.99.3` | Egress/NAT/DNS/QoS/policy routing |
| OpenWrt local rescue LAN | `192.168.7.1` | Local management/rescue |
| H3C core switch | `192.168.99.1` | L3 gateway/VLAN/DHCP |
| ER5200G3 | `192.168.99.4` | AC/MiniAP controller, ordinary DHCP disabled |
| ER5200G3 rescue | `192.168.9.254` | VLAN1/LAN4 rescue management |
| Central control/NTP/SNMP trap | `192.168.50.120` | NTP, SNMP trap, central control |
| Ops service target | `192.168.50.121` | Future backup/monitoring/report service host |
| QNAP NAS | `192.168.30.145` | Primary backup target |
| fnOS NAS | `192.168.50.254:5666` | Secondary backup target |

Credentials exist in local skill/reference files and prior environment. Treat them as sensitive; do not print passwords unless explicitly required.

## Current DNS Standard

Client DHCP DNS must be:

```text
192.168.99.3
```

OpenWrt upstream DNS currently standardized to:

```text
192.168.77.1
```

Reason: `www.linkedin.com` resolved incorrectly through some DNS paths. Testing with client DNS `192.168.99.3` resolved correctly. OpenWrt DNS interception for TCP/UDP 53 from LAN side is active.

Latest observation at 2026-06-17 17:26: OpenWrt `nslookup www.linkedin.com 127.0.0.1` and `nslookup www.linkedin.com 192.168.77.1` both returned `104.18.41.41` / `172.64.146.215`. DNS redirect rule counters were increasing.

## H3C DHCP DNS Fix Completed

Status: completed and verified.

Actions completed:

- All active H3C DHCP pools now hand out DNS `192.168.99.3`.
- Old DNS removed from H3C DHCP config:
  - `223.5.5.5`
  - `119.29.29.29`
- Bad duplicate/empty mojibake DHCP pool removed.
- Empty unused DHCP pools `80` and `110` removed.
- H3C `save force` completed.
- H3C Web DHCP pool page recovered and now displays pools.

Latest H3C backup:

```text
D:\IDE\AI\network-ops\backups\h3c-after-dhcp-dns-web-fix-20260617-160613.txt
```

Detailed fix record:

```text
D:\IDE\AI\network-ops\handoff\h3c-dhcp-dns-web-fix-2026-06-17-1600.md
```

## Active H3C DHCP Pools

| Pool | Network | Gateway | DNS |
|---|---|---|---|
| `有线办公` | `192.168.10.0/24` | `192.168.10.1` | `192.168.99.3` |
| `接待厅` | `192.168.19.0/24` | `192.168.19.1` | `192.168.99.3` |
| `无线管理` | `192.168.20.0/24` | `192.168.20.1` | `192.168.99.3` |
| `NAS存储` | `192.168.30.0/24` | `192.168.30.1` | `192.168.99.3` |
| `监控网络` | `192.168.40.0/24` | `192.168.40.1` | `192.168.99.3` |
| `无线业务` | `192.168.60.0/23` | `192.168.60.1` | `192.168.99.3` |
| `工作坊` | `192.168.70.0/24` | `192.168.70.1` | `192.168.99.3` |
| `2号厅` | `192.168.80.0/24` | `192.168.80.1` | `192.168.99.3` |
| `XR影棚` | `192.168.90.0/24` | `192.168.90.1` | `192.168.99.3` |
| `120` | `192.168.120.0/24` | `192.168.120.1` | `192.168.99.3` |
| `vlan16` | `192.168.16.0/24` | `192.168.16.1` | `192.168.99.3` |
| `vlan17` | `192.168.17.0/24` | `192.168.17.1` | `192.168.99.3` |
| `vlan18` | `192.168.18.0/24` | `192.168.18.1` | `192.168.99.3` |

Important H3C encoding warning:

- H3C CLI stores/displays Chinese object names in GBK/CP936.
- Do not send normal UTF-8 Chinese commands through raw SSH/plink to modify Chinese-named objects.
- If Chinese object modification is unavoidable, use a GBK/CP936 encoded command file.
- Better long-term option: rebuild DHCP pools as English names during a maintenance window.

Suggested future English DHCP pool names:

| Current | Suggested |
|---|---|
| `有线办公` | `vlan10-office` |
| `接待厅` | `vlan19-reception` |
| `无线管理` | `vlan20-wifi-mgmt` |
| `NAS存储` | `vlan30-nas` |
| `监控网络` | `vlan40-surveillance` |
| `无线业务` | `vlan60-wifi-client` |
| `工作坊` | `vlan70-workshop` |
| `2号厅` | `vlan80-hall2` |
| `XR影棚` | `vlan90-xr-studio` |
| `120` | `vlan120-temp` |

## H3C VLAN Baseline

VLAN cleanup already completed:

- VLAN11/12/13 deleted.
- Vlan-interface11/12/13 deleted.
- DHCP pools `vlan11/vlan12/vlan13` deleted.
- VLAN16 description `Marketing`.
- VLAN17 description `Training`.
- VLAN18 description `AI-Innovation`.
- VLAN201 description `Optical-Modem`.

Key VLANs:

| VLAN | Purpose | Gateway |
|---:|---|---|
| 10 | Wired office | `192.168.10.1/24` |
| 16 | Marketing | `192.168.16.1/24` |
| 17 | Training | `192.168.17.1/24` |
| 18 | AI-Innovation | `192.168.18.1/24` |
| 19 | Reception | `192.168.19.1/24` |
| 20 | Wi-Fi/AP management | `192.168.20.1/24` |
| 30 | NAS storage | `192.168.30.1/24` |
| 40 | Surveillance | `192.168.40.1/24` |
| 50 | Showroom/server/central control | `192.168.50.1/23` |
| 60 | Wi-Fi clients | `192.168.60.1/23` |
| 70 | Workshop | `192.168.70.1/24` |
| 80 | Hall 2 | `192.168.80.1/24` |
| 90 | XR studio | `192.168.90.1/24` |
| 99 | Core/router/AC management | `192.168.99.1/24` |
| 120 | Temporary/free DHCP | `192.168.120.1/24` |
| 201 | Optical modem | `172.16.201.254/24` |

H3C default route:

```text
0.0.0.0/0 -> 192.168.99.3
```

## OpenWrt Baseline

| Interface | Role |
|---|---|
| `eth0 / br-lan` | Local management LAN, `192.168.7.1/24` |
| `eth1` | WAN1, SDWAN uplink |
| `eth2` | WAN2, direct optical modem |
| `eth3.99` | H3C core VLAN99, `192.168.99.3/24` |

OpenWrt static routes to internal VLANs use next hop:

```text
192.168.99.1
```

Internal routes include:

```text
172.16.201.0/24
192.168.10.0/24
192.168.16.0/24
192.168.17.0/24
192.168.18.0/24
192.168.19.0/24
192.168.20.0/24
192.168.30.0/24
192.168.40.0/24
192.168.50.0/23
192.168.60.0/23
192.168.70.0/24
192.168.80.0/24
192.168.90.0/24
192.168.110.0/24
192.168.120.0/24
```

OpenWrt IPv6 was disabled earlier. DNS interception is active. SQM/QoS optimization is pending after traffic data collection.

## ER5200G3 / AC Baseline

ER5200G3 cannot be changed to pure AC mode per vendor. It remains in router mode but is used only as AC/MiniAP controller. Ordinary DHCP is disabled.

Formal management:

```text
http://192.168.99.4/router_index.html
```

Rescue management:

```text
http://192.168.9.254
```

Core switch port to ER5200G3:

```text
H3C GE1/0/12
trunk permit VLAN 20 60 99
PVID 99
```

Wi-Fi service bridges to VLAN60. H3C core provides VLAN60 gateway/DHCP.

SSIDs:

| Band | SSID | VLAN |
|---|---|---:|
| 2.4G | `shenlan2.4g` | 60 |
| 5G | `shenlan_5G` | 60 |

Passwords are recorded in local sensitive references/history; do not print unless needed.

## H3C Access Notes

SSH works to:

```text
admin@192.168.99.1
```

Use PuTTY plink on this Windows host:

```powershell
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' admin@192.168.99.1 "display version"
```

Reliable read pattern:

```powershell
$cmd='D:\IDE\AI\network-ops\state\h3c-display.cmds'
Set-Content -Path $cmd -Value "screen-length disable`ndisplay current-configuration`nquit`n" -Encoding ascii
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' -m $cmd admin@192.168.99.1
```

GBK command-file pattern for Chinese object changes:

```powershell
$path='D:\IDE\AI\network-ops\state\h3c-gbk-change.cmds'
$enc=[Text.Encoding]::GetEncoding(936)
[IO.File]::WriteAllBytes($path, $enc.GetBytes(($lines -join "`r`n") + "`r`n"))
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' -m $path admin@192.168.99.1
```

## Backup And Monitoring Plan

User requirements:

1. Scheduled config backup to NAS at 03:00.
2. Config changes should update a table view; WPS remote view is desired.
3. Monitor OpenWrt and H3C core status, traffic, temperature, and services.
4. Later integrate with central control system or independent dashboard/tool.
5. Services should run on `192.168.50.121`, not the current PC.

NAS targets:

| NAS | Address | Role |
|---|---|---|
| QNAP | `192.168.30.145` | Primary backup target |
| fnOS | `192.168.50.254:5666` | Secondary backup target |

Feishu Base/WPS discussion:

- Feishu Base is suitable for device inventory, VLAN/IP records, backup logs, alerts, and operations history.
- Alert target might be the existing central-control ops group, or a new group.
- Account/IP/backup path visibility should be limited to group owner/admins.
- This was noted for later; not implemented yet.

## Traffic/QoS Plan

Current stability test: OpenWrt `nlbwmon` is stopped as of about 2026-06-17 18:52. Do not restart it during the overnight observation unless explicitly needed. The health script now records `nlbwmon_error_latest`; treat repeated old 18:45 log lines as historical unless the latest timestamp advances.

Current temporary limiter:

- OpenWrt file: `/etc/nftables.d/30-shenlan-rate-limit.nft`.
- Hosts: `192.168.10.16`, `192.168.10.60`.
- Match: forwarded traffic from those source IPs going out WAN interfaces `eth1` or `eth2`.
- Limit: each host about `1000 kbytes/second`, around `8Mbit/s`; excess packets dropped.
- Rollback: `rm -f /etc/nftables.d/30-shenlan-rate-limit.nft && fw4 reload`.
- During the 2026-06-17 18:20 flash-disconnect diagnosis, both limiter rules still had `0 packets / 0 bytes`, so the limiter had not triggered and was not implicated by observed counters.

Bandwidth: around 1000M down / 50M up.

User wants automatic throttling of large uploads/downloads, not crude static limits. WAN1 goes through SDWAN and speed test being lower was considered reasonable. WAN2 is direct optical modem.

Pending approach:

Latest observation:

- OpenWrt usage collection is active every 5 minutes under `/root/shenlan-usage`.
- Local analysis files were pulled to `D:\IDE\AI\network-ops\state\openwrt-usage-20260617`.
- VLAN10 is the main upload pressure: `192.168.10.16` uploaded about 177.62 GB in nlbwmon data; `192.168.10.60` uploaded about 39.45 GB.
- VLAN60 is the main download volume but upload is moderate.
- WAN1 carries almost all traffic. WAN2 is up but nearly idle.
- `tc -s qdisc` shows WAN1 upload CAKE at 46Mbit with millions of drops/overlimits, while WAN1 download at 950Mbit has minimal drops. Upload is the real congestion point.

Pending approach:

- Identify owner/business role of heavy upload IPs before applying host/VLAN restrictions.
- Keep CAKE near `950M/46M` until latency-under-load is tested.
- Consider host/VLAN throttling, qosify marking, or WAN2 offload only after user confirms policy goals.

## VLAN-Based WAN Policy Routing Plan

User asked whether VLANs can be steered to WAN1 or WAN2. Yes.

Possible future design:

- Default office/Wi-Fi through WAN1/SDWAN.
- Selected VLANs or test/high-bandwidth VLANs through WAN2/direct optical modem.
- Optionally combine with domain/IP-set routing for domestic/overseas split.

Do not implement until user confirms which VLANs should use which WAN.

## Important Files

```text
D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md
D:\IDE\AI\network-ops\handoff\shenlan-wan2-default-dns-adjustment-2026-06-18-0950.md
D:\IDE\AI\network-ops\handoff\shenlan-flap-traffic-stage-summary-2026-06-18.md
D:\IDE\AI\network-ops\handoff\shenlan-24h-health-observation-setup-2026-06-17-1835.md
D:\IDE\AI\network-ops\handoff\shenlan-flap-diagnosis-nlbwmon-tuning-2026-06-17-1820.md
D:\IDE\AI\network-ops\handoff\shenlan-traffic-dns-observation-2026-06-17-1730.md
D:\IDE\AI\network-ops\handoff\openwrt-host-upload-rate-limit-2026-06-17-1758.md
D:\IDE\AI\network-ops\handoff\h3c-dhcp-dns-web-fix-2026-06-17-1600.md
D:\IDE\AI\network-ops\handoff\h3c-vlan-cleanup-2026-06-17-1530.md
D:\IDE\AI\network-ops\handoff\shenlan-dns-vlan-standard-2026-06-17.md
D:\IDE\AI\network-ops\inventory\shenlan-network-standard.json
D:\IDE\AI\network-ops\backups\h3c-after-dhcp-dns-web-fix-20260617-160613.txt
D:\IDE\AI\network-ops\backups\openwrt\openwrt-config-20260617-172825.tar.gz
D:\IDE\AI\network-ops\backups\openwrt\openwrt-before-rate-limit-20260617-175328.tar.gz
D:\IDE\AI\network-ops\backups\openwrt\openwrt-dns-standard-20260617-150738.tar.gz
```

## One-Line User Prompt For New Conversation

```text
继续深澜网络运维，请先读取 D:\IDE\AI\AGENTS.md、shenlan-ops 技能和 D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md，然后按接力文件继续，不要从头猜。
```
