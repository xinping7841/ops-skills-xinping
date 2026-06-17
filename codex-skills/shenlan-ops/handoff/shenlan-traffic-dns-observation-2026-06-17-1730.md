# Shenlan DNS And Traffic Observation

Updated: 2026-06-17 17:35 Asia/Shanghai

## Scope

This note continues from `LATEST-HANDOFF.md` after the 2026-06-17 H3C DHCP DNS fix. No live network configuration was changed during this observation, except running the existing local `Invoke-NetworkOps.ps1` reporting/backup script.

## Files Read First

- `D:\IDE\AI\AGENTS.md` was requested but is not present on this machine; the user-provided AGENTS content in the conversation was followed.
- `C:\Users\gaoxi\.codex\skills\shenlan-ops\SKILL.md`
- `D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md`
- `C:\Users\gaoxi\.codex\skills\shenlan-ops\references\traffic-collection.md`
- `C:\Users\gaoxi\.codex\skills\shenlan-ops\references\dns-vlan-standard.md`

## DNS Stability Check

OpenWrt was checked read-only at `192.168.99.3`.

Observed:

```text
nslookup www.linkedin.com 127.0.0.1 -> 104.18.41.41 / 172.64.146.215
nslookup www.linkedin.com 192.168.77.1 -> 104.18.41.41 / 172.64.146.215
OpenWrt dnsmasq noresolv=1, server=192.168.77.1
DNS TCP/UDP 53 redirect rules are active and counters are increasing
```

Conclusion: the post-fix DNS baseline is still good from OpenWrt's perspective. H3C DHCP DNS had already been fixed and saved in the earlier handoff. A direct H3C read was not completed in this turn because the local `config.json` does not include the H3C login password, and no password guessing was attempted.

## Traffic Collection Status

OpenWrt usage collection is active:

```text
Cron: */5 * * * * /root/shenlan-usage/bin/collect-usage.sh >/dev/null 2>&1
Latest snapshot: /root/shenlan-usage/snapshots/2026-06-17/20260617-172500
```

Pulled local analysis inputs:

```text
D:\IDE\AI\network-ops\state\openwrt-usage-20260617\nlbw-latest.json
D:\IDE\AI\network-ops\state\openwrt-usage-20260617\interface-counters-2026-06-16.csv
D:\IDE\AI\network-ops\state\openwrt-usage-20260617\interface-counters-2026-06-17.csv
```

## Key Traffic Findings

Top upload sources by nlbwmon:

| IP | VLAN | Download | Upload | Note |
|---|---:|---:|---:|---|
| `192.168.10.16` | VLAN10 | 10.27 GB | 177.62 GB | Dominant upload source |
| `192.168.10.60` | VLAN10 | 3.59 GB | 39.45 GB | Heavy uploader |
| `192.168.10.177` | VLAN10 | 1.93 GB | 8.35 GB | Heavy uploader |
| `192.168.10.22` | VLAN10 | 4.58 GB | 6.99 GB | Many connections |
| `192.168.19.10` | VLAN19 | 3.26 GB | 6.49 GB | Reception VLAN upload |
| `192.168.60.223` | VLAN60 | 1.54 GB | 4.29 GB | Wi-Fi upload source |

Traffic by VLAN:

| VLAN | Download | Upload | Observation |
|---|---:|---:|---|
| VLAN10 | 72.75 GB | 253.84 GB | Primary upload pressure |
| VLAN60 | 123.93 GB | 18.33 GB | Primary download volume, upload moderate |
| VLAN19 | 11.54 GB | 7.90 GB | Secondary traffic |
| VLAN50 | 3.41 GB | 0.35 GB | Light |

Interface counters:

```text
2026-06-16 eth1: 139.27 GB rx / 79.29 GB tx, peak about 115.6 Mbps rx and 43.0 Mbps tx
2026-06-16 eth2: 0.21 GB rx / 0 GB tx, effectively idle
2026-06-17 partial eth1: 144.19 GB rx / 34.23 GB tx, peak about 128.0 Mbps rx and 43.9 Mbps tx
2026-06-17 partial eth2: 0.01 GB rx / 0 GB tx, effectively idle
```

## SQM/QoS Observation

Observed `tc -s qdisc` shows CAKE queues on WAN1/WAN2, but `/etc/init.d/sqm status` prints:

```text
active with no instances
```

WAN1 CAKE stats are significant:

```text
eth1 upload CAKE bandwidth: 46Mbit
eth1 upload CAKE drops: 8,235,369
eth1 upload CAKE overlimits: 152,627,552
ifb4eth1 download CAKE bandwidth: 950Mbit
ifb4eth1 download drops: 521
```

Interpretation: WAN1 upload is the real congestion point, and CAKE is actively shedding/controlling traffic. Download is not currently saturated. WAN2 is up but almost unused.

## Suggested Next Actions

1. Identify owners or business role for the top upload IPs, especially `192.168.10.16` and `192.168.10.60`.
2. Keep CAKE at roughly `950M/46M` for now; do not raise upload until latency under load is tested.
3. Consider adding host or VLAN policy only after confirming whether the heavy upload is legitimate work traffic, backup/sync traffic, or abnormal traffic.
4. Design VLAN-based WAN policy routing before implementing. Candidate direction: keep office/Wi-Fi default on WAN1 initially, use WAN2 for selected high-bandwidth or test VLANs/hosts, and preserve WAN1 for SDWAN-dependent traffic.
5. Fix backup/report synchronization to QNAP. Latest run synced WPS and fnOS, but QNAP failed with an SMB credential error.
6. Improve local automation to include OpenWrt usage summaries in `latest-status.json` and daily reports.

## Reporting Run

The existing local reporting script was run once:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File D:\IDE\AI\network-ops\Invoke-NetworkOps.ps1
```

Generated/updated:

```text
D:\IDE\AI\network-ops\state\latest-status.json
D:\IDE\AI\network-ops\backups\openwrt\openwrt-config-20260617-172825.tar.gz
D:\IDE\AI\network-ops\backups\openwrt\openwrt-state-20260617-172825.txt
D:\IDE\AI\network-ops\reports\shenlan-network-status.xlsx
D:\IDE\AI\network-ops\dashboard\index.html
D:\IDE\AI\network-ops\logs\network-ops-20260617-172825.log
```

Sync result:

```text
WPS sync: ok
fnOS sync: ok
QNAP sync: failed, username or password incorrect
```
