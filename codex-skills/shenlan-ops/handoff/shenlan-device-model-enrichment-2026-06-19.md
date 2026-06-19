# Shenlan Device Model Enrichment

Updated: 2026-06-19 20:45 Asia/Shanghai

## Purpose

Continue the Shenlan topology handoff by extracting device hardware/model information from node-121 services and read-only SNMP/SSH-accessible data. No credentials, SNMP secrets, tokens, raw backups, or `.env` files were copied into the repository.

## Connectivity Checked

- `ssh xinping@100.122.235.56 'hostname'` returned `node-121`.
- LibreNMS `http://100.122.235.56:60800/` returned HTTP 302 to `/login`.
- NetBox `http://100.122.235.56:60801/` returned HTTP 302 to `/login/?next=/`.
- Scanopy `http://100.122.235.56:60072/api/health` returned `Scanopy Server 0.16.2`.

## Confirmed Models

| Device | Model / hardware | Evidence |
|---|---|---|
| H3C core switch `192.168.99.1` | `H3C S5130V2-28S-LI` | LibreNMS SNMP `devices.hardware` and `sysDescr` |
| Huawei office access `192.168.99.2` | `Huawei S5735S-L24T4S-QA2` | LibreNMS SNMP `devices.hardware` and `sysDescr` |
| ER5200G3 AC `192.168.99.4` | `H3C ERG3 / ER5200G3`, software `ERG3-MINIWAREV2-R0174P03` | LibreNMS SNMP `sysDescr`; NetBox device name/type already marks ER5200G3 AC |
| node-121 service host `192.168.50.121` | `AZW SER` / AMD Beelink service platform | Local DMI returned manufacturer `AZW`, product `SER`; Scanopy description says `服务平台AMD零刻` |

## Partially Identified Assets

| Device | What is known | Missing |
|---|---|---|
| 飞牛 NAS `192.168.50.254` | User confirmed this is an assembled NAS; record the system/asset name as `飞牛OS`. Scanopy found MAC `4c:ed:fb:45:c6:e1` and services including NFS/FTP/SSH/HTTPS/Samba/Home Assistant | Physical access port |
| 威联通 NAS | User-confirmed QNAP/威联通 `TS-h973AX-8G` on H3C `Te1/0/27`, VLAN30, 10G optical access; MAC `245e-be7d-49fd` | None |
| 小米中枢网关 | User-confirmed model `ZSWG01CM` on H3C `GE1/0/7`, VLAN30, currently 100M | MAC, IP |
| 海康威视 NVR | User-confirmed model `DS-7932N-R4(C)`, IP `192.168.40.168` in monitoring VLAN | Access port |
| VLAN50 downstream switches | LibreNMS LLDP/links mention `TL-SG2024MP`, `YLS220P-5G1F`, `TL-ST2008`, and `FutureMatrix`; Scanopy found many VLAN50 hosts | Physical locations, complete model labels, uplink ports |

## Still Needs Field Supplement

- OpenWrt main router is now user-confirmed as 倍控 `H30S`; still need exact OpenWrt version and physical WAN/LAN port mapping.
- SDWAN is now user-confirmed as `OSDWAN`; still need management address and port mapping.
- Telecom optical modem is now user-confirmed as `B866-S2`; still need management address.
- AP/MiniAP model is now user-confirmed from ER5200G3 screenshot as 7 x `A61-1500`, AP version `SWBA1A1V100R005`, IPs `172.17.1.2` through `172.17.1.8`; still need physical location and uplink port per AP.
- Remaining endpoint details: 飞牛OS NAS physical access port, 小米中枢网关 MAC/IP, 海康威视 NVR access port.

## User-Supplied Model Update

2026-06-19 follow-up from user:

- 电信光猫：`B866-S2`
- SDWAN：`OSDWAN`
- OpenWrt 硬件：倍控 `H30S`
- AP：ER5200G3 MiniAP/AP 列表截图显示 7 台 `A61-1500`，AP 版本 `SWBA1A1V100R005`，IP `172.17.1.2`、`172.17.1.3`、`172.17.1.4`、`172.17.1.5`、`172.17.1.6`、`172.17.1.7`、`172.17.1.8`。
- 威联通 / QNAP NAS：`TS-h973AX-8G`
- 飞牛 NAS：组装 NAS，系统/资产名按 `飞牛OS` 记录
- 小米中枢网关：`ZSWG01CM`
- 海康威视 NVR：`DS-7932N-R4(C)`

## Repository Updates

Updated `codex-skills/shenlan-ops/references/shenlan-network-topology.md` with a model/status table and a concise field-supplement checklist.
