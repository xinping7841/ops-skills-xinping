# Shenlan SNMPv3 Switches / ER5200G3 Handoff — 2026-06-19 14:45

## Summary

SNMP monitoring was advanced toward SNMPv3-only access from `node-121` / LibreNMS.

## Completed

- H3C core switch `192.168.99.1`:
  - SNMPv3 authPriv verified from `node-121`.
  - SNMPv2c community access no longer responds from `node-121`.
  - LibreNMS device re-added with SNMPv3.
  - LibreNMS discovery/poll succeeded as OS `comware`, type `network`, with 48 ports.
- S5735S access switch `192.168.99.2`:
  - SNMPv3 authPriv user/group/view/ACL configured and saved.
  - SNMPv2c access does not respond from `node-121`.
  - LibreNMS placeholder removed and device re-added with SNMPv3.
  - LibreNMS discovery/poll succeeded as OS `vrp`, type `network`, with 33 ports.
- ER5200G3 AC/router `192.168.99.4`:
  - User screenshots show SNMP enabled with SNMPv3 selected and SNMPv1/SNMPv2c disabled.
  - SNMPv2c probe from `node-121` does not respond.
  - SNMPv3 probe reaches the device but returns `Unknown user name`, meaning the configured SNMPv3 user does not match the LibreNMS/shared switch SNMPv3 credential set yet.

## LibreNMS Current Device State

- `192.168.50.121` / `node-121-service-host`: SNMPv3, OS `linux`, type `server`, 26 ports.
- `192.168.99.1` / `H3C-Core-Switch`: SNMPv3, OS `comware`, type `network`, 48 ports.
- `192.168.99.2` / `S5735S-Office-Access`: SNMPv3, OS `vrp`, type `network`, 33 ports.
- `192.168.99.3` / `OpenWrt-Main-Router`: still ping-only placeholder.
- `192.168.99.4` / `ER5200G3-AC`: still ping-only placeholder until SNMPv3 user is corrected.

## ER5200G3 Needed UI Changes

In ER5200G3 Web UI, keep SNMPv3-only, but change the SNMPv3 user used by Trap/basic settings from the built-in `admin` user to the same read-only SNMPv3 user used by LibreNMS. The desired user is stored only on `node-121` in `/opt/shenlan-ops/secrets/snmpv3-switches.env`; do not write credentials into this repository.

Recommended settings:

- SNMP versions: only `SNMPv3` enabled.
- Trusted host IPv4: `192.168.50.121`.
- Communities: remove or disable `public`, `private`, and any v2c-only community entries.
- SNMPv3 user: use the shared monitoring user, read-only, authPriv.
- Authentication protocol: prefer `SHA` if supported.
- Privacy/encryption protocol: prefer `AES`/`AES128` if supported.
- Trap destination: `192.168.50.121`, UDP `162`, SNMPv3 security name matching the monitoring user.

After applying ER5200G3 UI changes, verify from `node-121` with the SNMPv3 values in `/opt/shenlan-ops/secrets/snmpv3-switches.env`, then remove/re-add `192.168.99.4` in LibreNMS as SNMPv3.

## Notes

- Do not change VLAN/DNS/routing/firewall/SQM/PBR/MWAN/DHCP/AP behavior for this SNMP task.
- H3C still has an old v2c trap target line visible in config; direct removal syntax needs a matching H3C command form. It does not affect read access, and SNMPv2c polling is disabled/non-responsive from `node-121`.
- Secret files remain only on `node-121` under `/opt/shenlan-ops/secrets/`.
