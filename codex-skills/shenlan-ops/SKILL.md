---
name: shenlan-ops
description: "Shenlan on-site network operations knowledge base. Use when the user asks about Shenlan ops/network, OpenWrt, H3C core switch, ER5200G3, AC/AP, NAS, VLAN, DNS, routing, configuration backups, WPS sync, monitoring, central-control integration, traffic collection, SQM/QoS, bandwidth optimization, or troubleshooting."
---

# Shenlan Ops

Use this skill as the machine-readable knowledge base for Shenlan network operations.

## Load References

For any resumed Shenlan operations conversation, read these first:

1. `handoff/LATEST-HANDOFF.md`
2. `references/network-inventory.sanitized.json`
3. The task-specific files listed below only when needed.

Task-specific references:

- Current DNS/VLAN/routing baseline after the 2026-06-17 LinkedIn DNS fix: `handoff/shenlan-dns-vlan-standard-2026-06-17.md` and `references/dns-vlan-standard.md`.
- 2026-06-17 H3C DHCP DNS/Web address-pool cleanup: `handoff/h3c-dhcp-dns-web-fix-2026-06-17-1600.md`.
- 2026-06-17 VLAN cleanup: `handoff/h3c-vlan-cleanup-2026-06-17-1530.md` and `handoff/vlan-current-map-2026-06-16.md`.
- Traffic/DNS observation and QoS findings: `handoff/shenlan-traffic-dns-observation-2026-06-17-1730.md` and `references/traffic-collection.md`.
- Scheduled backups, report generation, WPS/NAS sync, monitoring plans, and migration to the 192.168.50.121 service host: `references/backup-monitoring.md`.

Local full-fidelity operational data may exist on 12700K at `D:\IDE\AI\network-ops`. Treat that directory as sensitive local state, not as the shared source of truth for other machines.

## Operating Rules

- Treat credentials, SNMP communities, API keys, NAS credentials, and raw backup paths as sensitive. Do not print passwords unless the user explicitly asks and the task requires them.
- Do not assume raw backups or local state exist on every machine. Prefer the synchronized `handoff/` and `references/` files for cross-machine reasoning.
- Before changing live network configuration, verify the current state when possible and prefer reversible changes with backups.
- Keep OpenWrt as the main egress/NAT/DNS/QoS/policy-routing device, H3C core switch as the internal L3 gateway/DHCP device, and ER5200G3 as the AC/MiniAP controller with ordinary DHCP disabled.
- If the user says to add or update Shenlan information, update the relevant synchronized file under `handoff/` or `references/`, then commit and push the ops skills repository so other machines receive it.
- Full local scripts and raw backups should remain in `D:\IDE\AI\network-ops` or a future locked-down private repository. Do not copy raw `config.json`, `inventory/`, `backups/`, `logs/`, `reports/`, or generated `state/` into this synchronized skill package.
- The backup and monitoring service should run on `192.168.50.121`, not on the current PC, unless the user explicitly changes this decision.
- Do not modify Chinese-named H3C DHCP pools through raw UTF-8 SSH/console input. Use H3C Web/API, manual Web UI edits, or GBK/CP936 encoded command files because console encoding previously created garbled pool names.
