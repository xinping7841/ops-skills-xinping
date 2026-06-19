# Shenlan node-121 SNMPv3 / LibreNMS upgrade — 2026-06-19 13:45

## Summary

Configured safe SNMPv3 monitoring for the `node-121` service host and upgraded LibreNMS from ping-only monitoring to real SNMP polling for `192.168.50.121`.

No OpenWrt, H3C core switch, Huawei/S5735S access switch, ER5200G3, VLAN, routing, DNS, firewall, SQM, PBR, MWAN, DHCP, or AP configuration was changed.

## What changed on node-121

Installed Ubuntu packages:

- `snmpd`
- `snmp`

Configured `snmpd`:

- Config file: `/etc/snmp/snmpd.conf`
- Backup created before overwrite: `/etc/snmp/snmpd.conf.bak-shenlan-<timestamp>`
- Agent bind addresses:
  - `127.0.0.1:161`
  - `192.168.50.121:161`
  - `100.122.235.56:161`
- SNMPv3 read-only user: stored locally only, not recorded in Git
- SNMPv3 auth/privacy mode: `authPriv`
- Location: `Shenlan Space node-121 service host`
- Contact: `Shenlan Ops`

Sensitive SNMPv3 credentials are stored only on `node-121`:

- `/opt/shenlan-ops/secrets/snmpv3-node121.env`

Do not copy this file into the synchronized ops-skills repository.

## LibreNMS update

LibreNMS path:

- `/opt/librenms/docker-src/examples/compose`

Actions:

1. Removed the old `192.168.50.121` ping-only LibreNMS device entry.
2. Re-added `192.168.50.121` using SNMPv3 authPriv.
3. Ran `device:discover 192.168.50.121`.
4. Ran `device:poll 192.168.50.121`.

Validated LibreNMS data for `node-121`:

- Device ID: `6`
- Hostname: `192.168.50.121`
- sysName: `node-121`
- OS: `linux`
- Type: `server`
- Status: `1`
- Ports discovered: `26`
- Processors discovered: `16`
- Storage entries discovered: `2`

LibreNMS discovery/polling reported CPU, memory, swap, disk, IPv4/IPv6, ports, and Linux host resource metrics.

## SNMP status for network devices

Tested from the LibreNMS container using SNMPv2c communities `public` and `shenlan` against:

- `192.168.99.1` — H3C core switch
- `192.168.99.2` — Huawei/S5735S office access switch
- `192.168.99.3` — OpenWrt main router
- `192.168.99.4` — ER5200G3 AC

All tests failed, so no existing plaintext community was usable.

SSH status during this run:

- `node-121` to `192.168.99.3` OpenWrt: SSH host key was refreshed, but login failed due to missing usable auth from `node-121`.
- `node-121` to `192.168.99.1` H3C: password auth required; no non-interactive credential available.
- `node-121` to `192.168.99.2` S5735S: SSH host key verification still requires operator handling/credential confirmation.
- macair direct SSH to `192.168.99.1/2/3` reset during this run, likely due current management path/firewall/session behavior.

## Current monitoring state

LibreNMS now has:

- Ping-only monitoring for:
  - `192.168.99.1`
  - `192.168.99.2`
  - `192.168.99.3`
  - `192.168.99.4`
- SNMPv3 monitoring for:
  - `192.168.50.121` / `node-121`

## Remaining work

To get full topology/interface health for the network itself, still need read-only SNMP credentials or a safe maintenance window to enable them on:

1. H3C core switch `192.168.99.1`
2. Huawei/S5735S access switch `192.168.99.2`
3. OpenWrt main router `192.168.99.3`
4. ER5200G3 AC `192.168.99.4`, if supported

Recommended next step:

- Provide/confirm read-only SNMP credentials for each network device, or provide confirmed SSH/Web credentials and approved commands for enabling read-only SNMP.
- For H3C/Huawei, prefer read-only SNMPv3 where supported; SNMPv2c can be used only if restricted to the management VLAN/source host `192.168.50.121`.
- After network-device SNMP is enabled, re-add/convert LibreNMS entries from ping-only to SNMP polling and run discovery/polling.
