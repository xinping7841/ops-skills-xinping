# Shenlan Post-WAN1-20M Network Analysis

Updated: 2026-06-18 20:45 Asia/Shanghai

## Scope

User asked to check router and core-switch state after the 2026-06-18 16:53 WAN1 20M/20M SQM change, record logs, and analyze the network condition.

Raw local evidence directory:

```text
D:\IDE\AI\network-ops\state\post-wan1-20m-audit-20260618-202753
```

Important raw files in that directory:

```text
openwrt-audit-output.txt
openwrt-monitoring-cron-log-output.txt
openwrt-services-processes-output.txt
h3c-readonly-audit-output.txt
health-probes-2026-06-18.csv
http-health-2026-06-18.csv
dns-health-2026-06-18.csv
interface-health-2026-06-18.csv
interface-counters-2026-06-18.csv
health-duplicate-analysis.txt
```

This report is sanitized and does not include passwords, SNMP community strings, or raw configuration backups.

## Current Conclusion

No evidence was found that the WAN1 20M/20M SQM limit caused a core-switch, OpenWrt interface, WAN1 gateway, or WAN2 gateway outage.

From 16:53 to about 20:35:

- WAN1 gateway `192.168.77.1`: 0 ICMP loss in health probes.
- WAN2 gateway `192.168.201.1`: 0 ICMP loss in health probes.
- H3C core `192.168.99.1`: 0 ICMP loss, but repeated management-plane latency spikes were observed.
- OpenWrt `eth1`, `eth2`, `eth3`, and `eth3.99`: all remained `up`; no link-down sample; no RX/TX error delta; no CRC error delta.
- H3C key interfaces checked by SSH were up/up with 0 input errors, 0 output errors, and 0 CRC errors.

There were several short public-side probe anomalies after the WAN1 limit:

| Time | Finding | Interpretation |
|---|---|---|
| 16:59 | Public ICMP to Aliyun/DNSPod showed 100% loss in duplicated samples; WAN gateways stayed clean | Public-side or probe transient, not local link loss |
| 18:08 | DNSPod ICMP partial loss 33% | Minor public ICMP transient |
| 19:00 | Aliyun/DNSPod ICMP 100% loss, both HTTP tests failed with timeout, local dnsmasq query for `www.aliyun.com` timed out; WAN gateways stayed clean | The strongest post-change Internet reachability event; likely WAN2/upstream/public-path or dnsmasq transient, not physical link down |
| 20:01 | Aliyun ICMP loss only | Public ICMP transient |

The 19:00 event is the only post-change minute where ICMP, HTTP, and DNS symptoms lined up. Because WAN1/WAN2 gateways stayed reachable and interfaces stayed up, this does not look like a H3C/OpenWrt physical link flap.

## WAN1 SQM And Traffic

WAN1 20M/20M SQM is active:

```text
sqm.eth1.download='20000'
sqm.eth1.upload='20000'
eth1 cake bandwidth 20Mbit
ifb4eth1 cake bandwidth 20Mbit
```

At the OpenWrt audit time, CAKE queues had drops/overlimits but no standing backlog:

```text
eth1 egress CAKE: dropped 7408, overlimits 9578211, backlog 0
ifb4eth1 ingress CAKE: dropped 34631, overlimits 6217892, backlog 0
```

This means WAN1 shaping is actively doing work, but it was not stuck with queued backlog at the time of inspection.

Interface counter deltas from about 16:55 to 20:35:

| Interface | RX | TX | Average RX | Average TX | Notes |
|---|---:|---:|---:|---:|---|
| `eth1` WAN1 | 4.075 GB | 4.443 GB | 2.529 Mbps | 2.757 Mbps | WAN1 not continuously saturated |
| `eth2` WAN2 | 24.95 GB | 8.707 GB | 15.484 Mbps | 5.404 Mbps | WAN2 remains primary exit |
| `eth3.99` H3C transit | 12.804 GB | 28.83 GB | 7.947 Mbps | 17.892 Mbps | Internal transit normal for current usage |

WAN2 had the largest observed 5-minute receive peak around 18:55-19:00, about 65 Mbps, which overlaps the 19:00 public health event. WAN2 upload did not approach its 46M SQM ceiling in the sampled windows.

## OpenWrt Health And Logs

Expected services:

```text
dnsmasq: running
sqm: active
cron: running
log: running
openclash: inactive
pbr: inactive/no active policies
mwan3: inactive
```

Notable anomalies:

1. `nlbwmon` service reports disabled/inactive, but two stale `nlbwmon` processes were visible in `ps`.
2. Two `crond` processes were visible, causing the one-minute health collector to run twice per minute.
3. The health CSVs therefore contain duplicate rows for most timestamp/label pairs after 16:53. Analysis above accounts for this and treats duplicate same-minute rows as one observed minute.
4. `logd` had one segfault at 18:34:11:

```text
logd[22808]: segfault ... in libubox.so.20260213
```

After that, the log service was still running and logs continued, so this is a stability warning rather than observed router reboot/outage evidence.

No current OpenWrt log evidence of repeated WAN link flap, NIC carrier flap, OOM, or fresh `nlbwmon` netlink storm was found in the inspected log tail. SSH connection noise from `192.168.50.121` is from the WAN1 domain manager/service checks and is not itself a network outage indicator.

Interface health from 16:53 onward:

| Interface | State | RX errors | TX errors | CRC | Drop notes |
|---|---|---:|---:|---:|---|
| `eth1` | up | 0 delta | 0 delta | 0 delta | no drop delta in health file |
| `eth2` | up | 0 delta | 0 delta | 0 delta | RX dropped increased by about 39k, still no CRC/errors |
| `eth3` | up | 0 delta | 0 delta | 0 delta | clean |
| `eth3.99` | up | 0 delta | 0 delta | 0 delta | clean |

`eth2` RX dropped continues to be worth watching, but because CRC/error counters stay at zero and no link flap is present, it currently looks more like driver/queue/buffer accounting than a bad cable or optical modem Ethernet physical fault.

## H3C Core Switch Audit

H3C core was checked read-only through SSH.

Device health snapshot:

```text
Model: H3C S5130V2-28S-LI
Uptime: 6 days, 9 hours, 19 minutes
CPU: 43% last 5 seconds, 32% last 1 minute, 32% last 5 minutes
Memory: 494300 KB total, 354760 KB used, 139540 KB free, FreeRatio 31.9%
```

Key interfaces:

| Interface | Role | State | Recent traffic | Errors |
|---|---|---|---|---|
| `GE1/0/3` | PoE/AP path | up/up | low | 0 input errors, 0 output errors, 0 CRC |
| `GE1/0/12` | ER5200G3 AC | up/up | low | 0 input errors, 0 output errors, 0 CRC |
| `XGE1/0/28` | Office access uplink | up/up | low | 0 input errors, 0 output errors, 0 CRC |
| `Vlan-interface10/16/17/18/20/60/99` | active VLAN gateways | up/up | checked | no down state in current audit |

H3C sourced pings during the audit:

```text
H3C -> OpenWrt 192.168.99.3: 5/5 received, avg 2.781 ms
H3C -> WAN2 gateway 192.168.201.1: 5/5 received, avg 2.204 ms
H3C -> 223.5.5.5: 5/5 received, avg 7.496 ms
```

Relevant H3C log findings after the WAN1 change:

- 18:11:51: VLAN60 duplicate IP detected for `192.168.60.156` on `GE1/0/3`. This can affect the involved wireless client(s), but it does not explain whole-network outage.
- 16:02:42: `GE1/0/24` and `Vlan-interface120` came up after a down event at 15:55:51. This is before/around earlier testing and not evidence of the office/core uplink failing.
- No post-change link flaps were found for `GE1/0/3`, `GE1/0/12`, or `XGE1/0/28` in the inspected current state.

## Interpretation

The WAN1 20M limit appears safe so far. It is active, but WAN1 is not the main path and is not continuously saturated. The global default still goes through WAN2, and selected foreign/AI traffic still goes to WAN1 by nftset/fwmark.

The post-change health data points to three separate concerns:

1. Public Internet transient at 19:00: the best candidate for a real user-visible short outage in this window. Since WAN gateways stayed up, this is likely above the local physical layer, possibly WAN2/upstream/public routing or local dnsmasq being temporarily slow/unresponsive.
2. H3C management-plane latency spikes: H3C ping from OpenWrt sometimes had high latency but no loss. Because H3C forwarding ports and pings from H3C were clean, this may be control-plane scheduling rather than data-plane failure. Keep watching if users report LAN-side pauses.
3. Monitoring process hygiene: duplicate `crond` and stale `nlbwmon` processes make the observation less clean. This should be corrected before relying on another overnight dataset.

## Recommended Next Actions

1. Clean monitoring runtime only, without touching routing/DNS:
   - stop stale `nlbwmon` processes because the service is intended to stay inactive;
   - restart cron so only one `crond` remains;
   - verify health CSV appends one row per timestamp/label per minute.
2. Keep WAN1 20M/20M unchanged for now.
3. Keep WAN2 as global default.
4. Continue observing public health probes, especially if another user-visible short outage occurs. Correlate exact user time with `health-probes`, `http-health`, `dns-health`, and H3C logbuffer.
5. Track `eth2` RX dropped deltas, but do not change driver/offload/queue settings yet unless drops correlate with actual reachability failures.
6. Investigate the VLAN60 duplicate IP `192.168.60.156` if wireless users report isolated instability.
7. Deploy a real remote syslog receiver on `192.168.50.121` before re-enabling OpenWrt remote syslog.

## Current No-Change Status

This analysis did not change live routing, DNS, firewall, SQM, H3C configuration, or OpenClash/PBR/MWAN state.
