# Shenlan Health Collector Timeout Hardening

Updated: 2026-06-18 22:35 Asia/Shanghai

## Scope

User asked to optimize monitoring service and clean duplicate health logs. Historical CSV dedupe was already completed at 21:57. This follow-up fixed a runtime hygiene issue observed after dedupe: stale `collect-health.sh` / `logread | grep` processes could remain around and hold the collector lock.

This task only changed the OpenWrt health collector runtime script. It did not change routing, DNS, firewall, SQM, H3C, OpenClash, PBR, MWAN, VLAN, or DHCP configuration.

## Finding

At about 22:24-22:25, OpenWrt still had one `crond` and zero `nlbwmon`, but there were stale health collector related processes:

```text
collect-health.sh parent/child processes
logread processes
grep -E nlbwmon|NIC Link is|netifd|... processes
/root/shenlan-usage/run/collect-health.lock present
```

CSV writes remained clean, but this could cause future minute jobs to skip or drift. The likely blocking section was the `logread | grep ...` pipeline in the collector log snapshot block.

## Change

Updated local source and deployed it to OpenWrt:

```text
D:\IDE\AI\network-ops\router-scripts\collect-health.sh
/root/shenlan-usage/bin/collect-health.sh
```

OpenWrt backup before replacement:

```text
/root/shenlan-usage/backups/collect-health-pre-timeout-20260618-222813.sh
```

Collector hardening added:

1. PID and start-time files inside `/root/shenlan-usage/run/collect-health.lock`.
2. Stale lock cleanup after 240 seconds.
3. A shell `run_with_timeout` helper.
4. 8-second hard timeout around `nslookup` probes.
5. 8-second hard timeout around `logread`, then filtering from a temporary file instead of a live `logread | grep` pipeline.
6. Lock cleanup now removes the whole lock directory on normal exit, INT, or TERM.

After deployment, stale collector/logread/grep processes and the stale lock directory were cleared.

## Verification

Deployment checks:

```text
ash -n /root/shenlan-usage/bin/collect-health.sh -> OK
manual /root/shenlan-usage/bin/collect-health.sh -> manual_rc=0
manual run completed in about 12 seconds
lock directory removed after completion
```

Natural cron verification:

```text
last-health-probe.txt -> 2026-06-18T22:30:00+08:00 and then 2026-06-18T22:31:00+08:00
/root/shenlan-usage/run contains no collect-health.lock after completion
collect-health-lock.log has no new lock conflict entries
no residual collect-health/logread/grep collector processes were present after the run
```

Recent health rows showed one clean set per minute at `22:29`, `22:30`, and `22:31`. Public ICMP, HTTP, and DNS checks in that window all succeeded.

Local post-check evidence directory:

```text
D:\IDE\AI\network-ops\state\health-post-timeout-20260618-2231
```

Post-check duplicate counts from pulled CSVs:

```text
health-probes-2026-06-18.csv rows=6755 duplicate_keys=0
http-health-2026-06-18.csv rows=1706 duplicate_keys=0
dns-health-2026-06-18.csv rows=3412 duplicate_keys=0
interface-health-2026-06-18.csv rows=5404 duplicate_keys=0
```

## Current Status

Monitoring is now cleaner for tomorrow's trend analysis:

- `crond` remains the single managed cron service.
- `nlbwmon` remains stopped/inactive.
- Health CSV duplicate keys remain 0 after dedupe and timeout hardening.
- The collector should skip only active runs younger than 240 seconds and self-recover from stale locks older than 240 seconds.

## Next Observation

Tomorrow, analyze post-cleanup overnight trends from `/root/shenlan-usage/health/` and `/root/shenlan-usage/latest/`:

- Public ICMP/HTTP/DNS failures.
- H3C management latency spikes.
- WAN1/WAN2 gateway loss.
- Interface errors/drops.
- `eth2` RX dropped growth.
- SQM counters and WAN1 shaping behavior.
