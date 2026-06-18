# Shenlan Health CSV Dedupe

Updated: 2026-06-18 21:57 Asia/Shanghai

## Scope

User asked to remove historical duplicate health rows and form clean logs after monitoring cleanup fixed duplicate `crond` and added a collector lock.

This task only cleaned historical OpenWrt health CSV files. It did not change routing, DNS, firewall, SQM, H3C configuration, OpenClash, PBR, or MWAN.

Local evidence directory:

```text
D:\IDE\AI\network-ops\state\health-dedupe-20260618-215417
```

OpenWrt original backup directory:

```text
/root/shenlan-usage/backups/health-csv-pre-dedupe-20260618-215504
```

## Dedupe Rules

Rows were deduplicated by file type while preserving the first occurrence of each key:

| File type | Unique key |
|---|---|
| `health-probes-*.csv` | `timestamp + label` |
| `http-health-*.csv` | `timestamp + label + url` |
| `dns-health-*.csv` | `timestamp + label + server + name` |
| `interface-health-*.csv` | `timestamp + iface` |

## Removed Rows

```text
health-probes-2026-06-17.csv: removed 0
health-probes-2026-06-18.csv: removed 1175
http-health-2026-06-18.csv: removed 470
dns-health-2026-06-18.csv: removed 940
interface-health-2026-06-17.csv: removed 0
interface-health-2026-06-18.csv: removed 940
```

After dedupe, all checked files reported `duplicate_data_rows=0`.

## Verification

A post-cleanup natural cron sample was observed at `2026-06-18T21:56:00+08:00`.

Final status:

```text
crond_count=1
nlbwmon_count=0
last_probe=2026-06-18T21:56:00+08:00
```

Post-cleanup duplicate counts:

```text
health-probes-2026-06-17.csv duplicate_data_rows=0
health-probes-2026-06-18.csv duplicate_data_rows=0
http-health-2026-06-18.csv duplicate_data_rows=0
dns-health-2026-06-18.csv duplicate_data_rows=0
interface-health-2026-06-17.csv duplicate_data_rows=0
interface-health-2026-06-18.csv duplicate_data_rows=0
```

Recent appended rows at `21:55` and `21:56` show one clean set per minute for health, HTTP, DNS, and interface files.

## Current Status

OpenWrt health logs are now clean for analysis. Historical raw duplicated CSVs remain recoverable from the backup directory above.
