# Shenlan OpenWrt Traffic Collection

Updated: 2026-06-15

Purpose: collect at least one full day of real traffic data for later SQM/QoS tuning, dual-WAN policy routing, heavy upload/download detection, and monitoring integration.

## Router

OpenWrt main router: `192.168.99.3`

## Active Collection

```text
Root directory: /root/shenlan-usage
Script: /root/shenlan-usage/bin/collect-usage.sh
Raw snapshots: /root/shenlan-usage/snapshots/YYYY-MM-DD/YYYYMMDD-HHMMSS/
Latest snapshot pointer: /root/shenlan-usage/latest/last-snapshot-path.txt
Interface counters CSV: /root/shenlan-usage/interface-counters-YYYY-MM-DD.csv
nlbwmon persistent database: /root/shenlan-usage/nlbwmon-db
Cron: */5 * * * * /root/shenlan-usage/bin/collect-usage.sh >/dev/null 2>&1
```

## Data Collected

```text
WAN/WAN2 ifstatus
routing table
interface addresses
interface rx/tx bytes, packets, errors, drops
SQM tc qdisc statistics
nf_conntrack count/max
memory, disk, load average, uptime
log tail
nlbwmon JSON traffic details
```

## Important Notes

- `/var/lib/nlbwmon` is volatile because `/var` maps to tmpfs on OpenWrt. nlbwmon has been moved to `/root/shenlan-usage/nlbwmon-db`.
- Collection interval is 5 minutes.
- Raw snapshot cleanup keeps 14 days.
- This collection only observes. It does not change NAT, routing, VLAN, SQM, firewall, or dual-WAN policy.
- Root filesystem has about 459 GB available, enough for collection.

## Current QoS Baseline

```text
WAN1 eth1: SDWAN path, SQM enabled, CAKE, 950000 kbit down, 46000 kbit up
WAN2 eth2: direct optical modem path, SQM enabled, CAKE, 950000 kbit down, 46000 kbit up
```

## Tomorrow Analysis Focus

- Top upload IPs and VLANs, especially sustained upload usage.
- Top download IPs and VLANs.
- Wireless VLAN60 share of traffic.
- WAN1/WAN2 usage and whether policy routing should prefer WAN2 for ordinary traffic.
- SQM `tc -s qdisc` backlog, drops, marks, overlimits, and congestion windows.
- Whether SQM bandwidth should stay at `950M/46M` or be adjusted.
- Whether specific hosts/VLANs need additional throttling beyond CAKE fairness.

## Useful Commands

```sh
crontab -l
cat /root/shenlan-usage/latest/last-snapshot-path.txt
ls -lh /root/shenlan-usage/snapshots/$(date +%F) | tail
tail -n 30 /root/shenlan-usage/interface-counters-$(date +%F).csv
nlbw -c json > /root/shenlan-usage/latest/nlbw-manual.json
```
