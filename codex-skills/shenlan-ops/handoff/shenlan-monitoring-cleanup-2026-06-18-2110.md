# Shenlan Monitoring Cleanup

Updated: 2026-06-18 21:10 Asia/Shanghai

## Scope

User asked to optimize monitoring after post-WAN1-20M analysis found stale `nlbwmon` processes and duplicate `crond` processes causing duplicate one-minute health rows.

This task only changed monitoring/runtime helper state. It did not change live routing, DNS, firewall, SQM, H3C configuration, OpenClash, PBR, or MWAN.

Local evidence directory:

```text
D:\IDE\AI\network-ops\state\monitoring-cleanup-20260618-205636
```

## Actions

1. Took a pre-cleanup process/service snapshot on OpenWrt.
2. Stopped stale `nlbwmon` runtime and killed remaining `nlbwmon` processes.
3. Restarted cron through init script.
4. Found one duplicate bare `crond` process that was not the managed `/usr/sbin/crond -f -c /etc/crontabs -l 9` instance, then killed only that duplicate.
5. Added a lightweight lock to `/root/shenlan-usage/bin/collect-health.sh` using `mkdir /root/shenlan-usage/run/collect-health.lock` so overlapping health probes skip instead of writing duplicate rows.
6. Installed missing OpenWrt helper packages:
   - `openssh-sftp-server`, so PuTTY `pscp`/SFTP file transfer works.
   - `coreutils-base64`, so future base64-based script deployment works.
7. Verified `pscp` file upload now succeeds.

## Verification

Final process state:

```text
crond_count=1
nlbwmon_count=0
crond pid=19907 cmd=/usr/sbin/crond -f -c /etc/crontabs -l 9
```

Final package state:

```text
openssh-sftp-server installed
coreutils-base64 installed
/bin/base64 available
/usr/libexec/sftp-server -> ../lib/sftp-server
```

Health collector verification:

- `collect-health.sh` syntax check passed.
- Manual run returned `manual_rc=0`.
- Lock directory was removed after completion.
- Natural cron samples at `21:06`, `21:07`, `21:08`, and `21:09` wrote one set per minute:
  - 5 health probe rows per minute.
  - 4 interface rows per minute.
  - HTTP/DNS rows no longer duplicated in recent tail.

Recent health probes were clean for WAN gateways and public targets. H3C management ping still showed latency spikes but 0 loss, consistent with prior observation.

## Current Status

Monitoring runtime is now clean enough for overnight trend analysis:

- `nlbwmon` remains inactive with no residual process.
- Only one managed cron process is running.
- Health collection has an overlap lock.
- File transfer helpers are installed for safer future script deployment.

## Notes

The historical CSV files still contain duplicate rows from before cleanup. When analyzing the full day, deduplicate by `timestamp + label` or start clean trend interpretation from about `2026-06-18 21:06` onward.
