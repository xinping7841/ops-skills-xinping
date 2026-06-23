# 2026-06-23 Shenlan second S5735S factory reset via console BootLoad

## Background

The user connected a second powered-off Huawei switch to the same FTDI USB console and confirmed it should be cleared. Passive boot capture showed the same Huawei S5735 platform and an existing console password prompt, so the device was not already blank.

## Changes

- Entered Huawei BootLoad over `/dev/cu.usbserial-A93GC2YC` after a power cycle.
- BootLoad initially had an empty password and required setting a temporary BootLoad password before showing the menu. The temporary password was used only locally for this reset flow and is not recorded.
- Used BootLoad option `6. Clear password for console user`, booted normally, set a temporary console password for first login, and ran `reset saved-configuration`.
- Rebooted without saving the running configuration, leaving `Startup saved-configuration file: NULL`.
- Identified the device as Huawei `S5735S-L24T4S-QA2`, ESN `3G21B0008087`, VRP `V200R021C00SPC600`, prompt/sysname `FutureMatrix`.

## Why This Way

The user explicitly approved clearing the switch. Clearing the console password through BootLoad allowed a vendor-supported VRP reset with `reset saved-configuration`, then rebooting without saving avoided persisting the temporary console login state.

## Alternatives Not Taken

- Did not attempt password guessing because reset was approved and repeated failed logins are unnecessary risk.
- Did not format flash or delete system files because only the startup configuration needed to be cleared.
- Did not configure management IP, SSH, SNMP, or VLANs in this turn; the requested action was to clear the switch.

## Validation

- Console identity checks:
  - `display version` returned `S5735S-L24T4S-QA2`, `VRP (R) Software, Version 5.170 (V200R021C00SPC600)`.
  - `display esn` returned `3G21B0008087`.
- Reset command:
  - `reset saved-configuration` returned `Info: Succeeded in clearing the configuration in the device.`
- Post-reboot startup check:
  - `display startup` returned `Startup saved-configuration file: NULL` and `Next startup saved-configuration file: NULL`.
- Post-reset console behavior:
  - Device returned to first-login console password setup, confirming the saved configuration was cleared.

## Risks

- Startup config is intentionally empty. The switch is not yet production-configured with management IP, SSH, SNMP, VLANs, trunks, access ports, NTP, or monitoring.
- BootLoad now has a non-empty temporary password set during reset because BootLoad required changing an empty password. Rotate BootLoad credentials during final hardening if this unit will be deployed.
- Flash usage again reported around 87% high usage during boot; after final onboarding, review old `logfile/` contents and clean safely if needed.
- Local serial processes were released after validation.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: not needed; existing switch lab/readonly guidance covered the work.

## Handoff Notes

For follow-up configuration, treat this switch as factory-reset/blank startup state. Start from console, set approved permanent credentials, then configure management VLAN/IP, SSH/STelnet, NTP, SNMPv3/LibreNMS, sysname, and the intended access/trunk port plan before saving. Do not assume any prior production config remains.

## Related Files

- `/tmp/s5735-second-reset.log` local console capture, not for Git.
- `memory/ops/2026-06/2026-06-23-shenlan-s5735s-factory-reset-via-console-bootload.md`
