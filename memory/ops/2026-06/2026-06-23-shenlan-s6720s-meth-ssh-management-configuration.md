# 2026-06-23 Shenlan S6720S MEth SSH management configuration

## Background

The user asked to configure the onsite Huawei `S6720S-S24S28X-A` Ethernet management port with IP `192.168.99.11` and enable SSH management after the initial console inspection. H3C `GE1/0/20` had already been prepared as a temporary access VLAN99 management port for this switch.

## Changes

- On S6720S `FutureMatrix` / ESN `3G21B0060790`:
  - Changed `MEth0/0/1` from default `192.168.1.253/24` to `192.168.99.11/24`.
  - Enabled STelnet/SSH and bound SSH server source to `MEth0/0/1`.
  - Created/updated local user `admin` with privilege level 15 and service type `ssh terminal`.
  - Added default route `0.0.0.0/0` via H3C gateway `192.168.99.1` so routed management hosts such as `node-121` can reach SSH.
  - Disabled original-password alert under the administrator local AAA password policy so SSH login no longer forces an immediate password change.
  - Saved the configuration to `flash:/vrpcfg.zip`.
- Follow-up: rotated the local `admin` SSH password back to the user-specified formal password value and saved again. The password is not recorded here.
- Passwords were provided by the user during the session and are not recorded in Git, memory, or local captures.

## Why This Way

The switch is still otherwise un-deployed, so using the dedicated `MEth0/0/1` port on VLAN99 gives a narrow management path without touching service-port VLAN design. The default route is required because `node-121` is in VLAN50 and the switch must route replies back through H3C.

## Alternatives Not Taken

- Did not configure a production VLANIF or service-port trunk/access role; that should be done only after a separate deployment plan.
- Did not enable SFTP/SCP/SNMPv3/NTP yet; this task was limited to management IP and SSH.
- Did not keep the initial SSH password prompt workflow because it would disconnect if the password change was refused and would block unattended SSH login.

## Validation

- Console checks:
  - `display ip interface brief` showed `MEth0/0/1 192.168.99.11/24 up/up`.
  - `display ssh server status` showed SSH version 2.0, STELNET IPv4/IPv6 enabled, and SSH server source interface `MEth0/0/1`.
  - `display ip routing-table` showed default route via `192.168.99.1` on `MEth0/0/1`.
  - Switch ping to `192.168.99.1` and `192.168.50.121` succeeded with 0% loss.
- External checks:
  - macair pinged `192.168.99.11` and connected to TCP/22 successfully.
  - `node-121` pinged `192.168.99.11` and connected to TCP/22 successfully.
  - Real SSH login as `admin@192.168.99.11` succeeded with the user-provided SSH password, did not require an initial password change, and could run `display ip interface brief` and `display ssh server status`.
  - Follow-up SSH login with the final formal password succeeded, `display ip interface brief` showed `MEth0/0/1 192.168.99.11/24 up/up`, and `save` reported success.

## Risks

- `H3C GE1/0/20` is currently a temporary access VLAN99 management setup. If the S6720S will later carry production VLANs, replace this with a documented trunk/access plan.
- S6720S still has default sysname `FutureMatrix`, no NTP/time standardization beyond current clock, no SNMPv3/LibreNMS onboarding, and no service-port VLAN plan.
- Local admin password authentication is enabled for setup convenience. Long-term operations should decide the final account policy and whether to restrict SSH with ACLs.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch CLI runbook remains applicable.

## Handoff Notes

Use `ssh admin@192.168.99.11` from macair or `node-121` for follow-up management. Before production deployment, decide sysname, NTP, SNMPv3/LibreNMS, SSH ACL/source restrictions, final account policy, service VLANs, uplink ports, and whether `H3C GE1/0/20` remains access VLAN99 or becomes a trunk.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-meth-ssh-config-20260623-140540.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-meth-default-route-20260623-140726.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-ssh-password-update-fixed-20260623-141803.log`
- `/Users/xinping/Documents/shenlan-network-ops/local-captures/s6720s-ssh-password-uppercase-20260623-142348.log`
