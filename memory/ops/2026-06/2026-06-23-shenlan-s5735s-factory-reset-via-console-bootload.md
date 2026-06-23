# 2026-06-23 Shenlan S5735S factory reset via console BootLoad

## Background

The user had an onsite Huawei data-communications switch connected by FTDI USB console and asked to configure it if possible, otherwise reset it. Console reached a password prompt, but the supplied admin/password candidates did not authenticate. The user then explicitly chose reset.

## Changes

- Entered Huawei BootLoad over `/dev/cu.usbserial-A93GC2YC` after power cycling the switch.
- BootLoad initially had an empty password and required setting a temporary BootLoad password before showing the menu. The temporary password was used only locally for this reset flow and is not recorded.
- Used BootLoad option `6. Clear password for console user`, booted normally, set a temporary console password for first login, and ran `reset saved-configuration`.
- Rebooted without saving the running configuration, leaving `Startup saved-configuration file: NULL`.
- Identified the device as Huawei `S5735S-L24T4S-QA2`, ESN `3G21B0008820`, VRP `V200R021C00SPC600`, prompt/sysname `FutureMatrix`.

## Why This Way

BootLoad refused to rename the active startup config file (`vrpcfg.zip`) because it was the current startup file. Clearing the console password first was the least destructive path that still allowed a verified CLI login, then `reset saved-configuration` used the vendor-supported reset path from VRP. Rebooting with `N` at the save prompt avoided writing the temporary console-login state back into startup configuration.

## Alternatives Not Taken

- Did not keep trying password variants after several failures, to avoid lockout/noisy authentication attempts.
- Did not format flash because that would risk deleting system software/logs and was unnecessary.
- Did not delete `vrpcfg.zip` directly from BootLoad because the menu protected the active startup file and the VRP reset command succeeded.

## Validation

- Console identity checks:
  - `display version` returned `S5735S-L24T4S-QA2`, `VRP (R) Software, Version 5.170 (V200R021C00SPC600)`.
  - `display esn` returned `3G21B0008820`.
- Reset command:
  - `reset saved-configuration` returned `Info: Succeeded in clearing the configuration in the device.`
- Post-reboot startup check:
  - `display startup` returned `Startup saved-configuration file: NULL` and `Next startup saved-configuration file: NULL`.
- Post-reset console behavior:
  - Device returned to first-login console password setup, confirming the saved configuration was cleared.

## Risks

- Startup config is intentionally empty. The switch is not yet production-configured with management IP, SSH, SNMP, VLANs, trunks, access ports, NTP, or monitoring.
- BootLoad now has a non-empty temporary password set during the reset flow. If a permanent BootLoad password policy matters, rotate it during the final switch hardening step and store it only in the approved local secret store.
- Flash usage previously triggered a high-usage warning around 87%. After final onboarding, review old `logfile/` contents and clean safely if needed.
- Current console session was exited and local serial processes were released.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing spare-switch/readonly runbooks covered the path, and this is a device-specific event record.

## Handoff Notes

For any follow-up configuration, treat this switch as factory-reset/blank startup state. Start from console, set an approved console/admin credential, then configure management VLAN/IP, SSH/STelnet, NTP, SNMPv3/LibreNMS, sysname, and the intended access/trunk port plan before saving. Do not assume it still has the previous `S5735-24T` or `FutureMatrix` production-like config.

## Related Files

- `/tmp/s5735-bootload-catch.log` local console capture, not for Git.
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-console-initial-read.md`
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-vlan50-access-configuration.md`
