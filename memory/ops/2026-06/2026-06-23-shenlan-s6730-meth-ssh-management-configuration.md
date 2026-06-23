# 2026-06-23 Shenlan S6730 MEth SSH management configuration

## Background

The user connected console and Ethernet management cabling to a new Huawei `S6730-S24X6Q` and asked for the same management setup as the previously configured S6720S, using management IP `192.168.99.12` and the user-specified formal password.

## Changes

- Initialized console access with the user-specified formal password. The password is not recorded in Git, memory, or local captures.
- Configured S6730 `S6730-MGMT-99-12` / ESN `102170397708`:
  - `MEth0/0/1` set to `192.168.99.12/24`.
  - Static default route `0.0.0.0/0` via H3C gateway `192.168.99.1`.
  - STelnet/SSH enabled and SSH server source set to `MEth0/0/1`.
  - Local `admin` user configured with privilege level 15 and service type `ssh terminal`.
  - Administrator password policy `undo password alert original` applied to avoid first SSH login password-change interruption.
  - RSA SSH host key verified/generated and SSH user stanza added: `ssh user admin authentication-type password`, `ssh user admin service-type stelnet`.
  - `user-interface vty 0 4` and `user-interface vty 16 20` configured with AAA authentication, SSH-only inbound protocol, and privilege level 15.
  - Configuration saved to `flash:/vrpcfg.zip`.
- Updated synchronized `shenlan-network-ops` asset facts for this S6730.

## Why This Way

The goal was management-plane readiness only, not production forwarding. Keeping access on `MEth0/0/1` over the temporary VLAN99 H3C setup port gives a narrow management path while leaving production VLAN, trunk, and uplink design untouched.

## Alternatives Not Taken

- Did not configure production VLANs, trunks, SNMPv3, NTP, NetBox, or LibreNMS onboarding yet.
- Did not use service ports for management because the management Ethernet path is already cabled and matches the previous S6720S staging model.
- Did not store passwords in memory, Git, or raw committed files.

## Validation

- Console checks:
  - `display version`: Huawei `S6730-S24X6Q`, VRP `V200R020C10SPC500`, uptime about 21 minutes during validation.
  - `display esn`: ESN `102170397708`.
  - `display ip interface brief`: `MEth0/0/1 192.168.99.12/24 up/up`.
  - `display ssh server status`: SSH 2.0, STELNET IPv4/IPv6 enabled, SSH server source `MEth0/0/1`.
  - `display ip routing-table`: default route via `192.168.99.1` on `MEth0/0/1`.
  - `display startup`: next startup saved configuration `flash:/vrpcfg.zip`.
- External checks:
  - macair pinged `192.168.99.12` and connected to TCP/22 successfully.
  - `node-121` pinged `192.168.99.12` and connected to TCP/22 successfully.
  - Real SSH login as `admin@192.168.99.12` succeeded with the user-specified formal password, did not require a password-change prompt, and ran `display ip interface brief`, `display ssh server status`, and `display startup`.

## Risks

- H3C `GE1/0/20` is still a temporary access VLAN99 staging port. If the S6730 becomes production aggregation/core, replace this with a documented trunk/uplink plan.
- The S6730 is management-ready but not production-ready: no service VLANs, uplinks/downlinks, NTP/time standardization, SNMPv3, LibreNMS, NetBox, or backup automation yet.
- Early console automation produced repeated harmless `Y` command errors in the local capture while waiting for prompts. The final configuration and SSH validation succeeded after manual VTY/SSH fixes.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch CLI runbook remains applicable.

## Handoff Notes

Use `ssh admin@192.168.99.12` from macair or `node-121` for follow-up. Before production deployment, define sysname convention, NTP, SSH ACL/source restrictions, SNMPv3/LibreNMS, NetBox record, config backup, service VLANs, uplinks/downlinks, and final optics/cabling.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6730-meth-ssh-config-*.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6730-post-config-check-20260623-144512.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6730-ssh-key-fix-20260623-144744.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6730-vty-ssh-fix-20260623-144916.log`
