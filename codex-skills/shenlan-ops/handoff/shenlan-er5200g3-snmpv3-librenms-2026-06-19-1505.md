# Shenlan ER5200G3 SNMPv3 LibreNMS Handoff — 2026-06-19 15:05

## Summary

ER5200G3 `192.168.99.4` is now reachable by SNMPv3 from `node-121` and has been added to LibreNMS.

## Completed

- ER5200G3 Web UI SNMP user `shenlan_ro` was created by the user.
- ER5200G3 SNMPv3 probe from `node-121` succeeded:
  - Username: `shenlan_ro`
  - Auth protocol: `MD5`
  - Privacy protocol: `DES` / `Des56`
  - Password was provided by the user during the live session and must be treated as sensitive.
- ER5200G3 SNMPv2c remains non-responsive from `node-121`.
- LibreNMS ping-only placeholder for `192.168.99.4` was replaced by an SNMPv3 device.
- LibreNMS discovery/poll succeeded as `ER5200G3-AC`, OS `comware`, type `network`, with 11 ports.

## Current LibreNMS Device State

- `192.168.50.121` / `node-121-service-host`: SNMPv3, OS `linux`, type `server`, 26 ports.
- `192.168.99.1` / `H3C-Core-Switch`: SNMPv3, OS `comware`, type `network`, 48 ports.
- `192.168.99.2` / `S5735S-Office-Access`: SNMPv3, OS `vrp`, type `network`, 33 ports.
- `192.168.99.4` / `ER5200G3-AC`: SNMPv3, OS `comware`, type `network`, 11 ports.
- `192.168.99.3` / `OpenWrt-Main-Router`: still ping-only placeholder.

## Notes

- ER5200G3 appears limited in this UI to `MD5 + Des56`; it is SNMPv3, but weaker than the `SHA + AES` used for H3C/S5735S.
- Do not print or commit the ER SNMP password.
- No VLAN/DNS/routing/firewall/SQM/PBR/MWAN/DHCP/AP changes were made for this step.
