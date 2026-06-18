# Huawei Office Access Switch

## Identity

- Device name: `S5735S-Office-Access`
- Role: office multi-department access switch
- Location: office area
- Upstream: H3C core switch port 28
- Local uplink port: `GigabitEthernet0/0/25`
- Management IP: `192.168.99.2/24`
- Management VLAN: `VLAN 99`
- Default gateway: `192.168.99.1`

## Hardware

- Vendor/OS banner: FutureMatrix / Huawei VRP-compatible S5735 platform
- Model: `S5735S-L24T4S-QA2`
- Software: `VRP (R) Software, Version 5.170 (V200R021C00SPC600)`
- Main board ESN / barcode: `3G21B0008299`
- Uplink optic module on `GigabitEthernet0/0/25`:
  - Board type: `MXPD-243S`
  - Barcode: `HA20392162948`
  - Description: `1300Mbps-1310nm-LC-10000(9um)`

## Management Access

- SSH/STelnet: enabled
- SSH version: `2.0`
- SSH login user: `admin`
- Authentication: password, stored out-of-band only
- Verified from macair on 2026-06-18:
  - `ping 192.168.99.2` succeeded
  - TCP `192.168.99.2:22` succeeded
  - SSH login as `admin` succeeded
  - `display ssh server status` showed `STELNET IPv4 server : Enable`

## VLAN And Port Summary

- VLANs present: `1, 10, 11, 12, 13, 16, 17, 18, 99`
- Business VLANs with access ports:
  - `VLAN 10`: `GE0/0/7-8`
  - `VLAN 16`: `GE0/0/1-6`
  - `VLAN 17`: `GE0/0/9-16`
  - `VLAN 18`: `GE0/0/17-24`
- Management VLAN:
  - `VLAN 99`: tagged on `GE0/0/25`
- Uplink:
  - `GE0/0/25`
  - Description on device: `TO-H3C-Core-Uplink`
  - Trunk allow-pass: `10, 16, 17, 18, 99`
  - Link status during capture: `up/up`

## Change Log

- 2026-06-18: Renamed device from `S5735S-Backup` to `S5735S-Office-Access` and saved configuration.
- 2026-06-18: Confirmed SSH management access over `192.168.99.2`.

## Source Captures

Local capture logs are intentionally kept under ignored `.sync-reports/` and are not committed because they contain raw device output:

- `.sync-reports/huawei-console-read-20260618-084236.txt`
- `.sync-reports/huawei-ssh-fix-verify-save-20260618-084822.txt`
- `.sync-reports/huawei-office-access-rename-collect-20260618-085222.txt`
- `.sync-reports/huawei-office-access-clean-inventory-20260618-085907.txt`
