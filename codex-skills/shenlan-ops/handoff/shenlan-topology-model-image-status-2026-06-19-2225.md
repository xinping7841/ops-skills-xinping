# Shenlan Topology / Device Model / Diagram Status

Updated: 2026-06-19 22:25 Asia/Shanghai

## Purpose

This handoff records the current state after continuing the Shenlan network topology cleanup, device model enrichment, SVG conflict merge, and final image-layout fix. It is intended for the next Codex/Kun session to resume without reading the full chat history.

No credentials, SNMP secrets, tokens, `.env` files, raw backups, or router/switch config exports were added to this repository.

## Current Repository State

- Repository: `xinping7841/ops-skills-xinping`
- Local path on macair: `/Users/wanghongyu/Documents/Deepseek`
- Branch: `main`
- Last completed topology image commit before this status record: `15287f2 优化深澜拓扑图图片布局`
- This status record should be committed and pushed after writing, so later sessions can treat `origin/main` as the source of truth

## What Was Completed

1. Pulled current shared repository state and continued from the earlier Shenlan topology/model-enrichment work.
2. Confirmed and recorded user-supplied device model supplements:
   - 电信光猫：`B866-S2`
   - SDWAN：`OSDWAN`
   - OpenWrt 主路由硬件：倍控 `H30S`
   - AP：7 × `H3C A61-1500`，AP 版本 `SWBA1A1V100R005`，IP `172.17.1.2` - `172.17.1.8`
   - 威联通/QNAP NAS：`TS-h973AX-8G`
   - 飞牛 NAS：组装 NAS，资产/系统名按 `飞牛OS` 记录
   - 小米中枢网关：`ZSWG01CM`
   - 海康威视 NVR：`DS-7932N-R4(C)`
3. Kept prior SNMP/service-derived model facts:
   - H3C 核心：`H3C S5130V2-28S-LI`
   - S5735S 汇聚：`Huawei S5735S-L24T4S-QA2`
   - ER5200G3 AC：`H3C ERG3 / ER5200G3`，软件 `ERG3-MINIWAREV2-R0174P03`
   - node-121：`AZW SER` / AMD 零刻服务平台
4. Resolved the earlier `add/add` conflict on `codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg` by keeping the merged topology content and then synchronizing it with the latest safe-layout SVG.
5. Generated a latest horizontal tree topology SVG matching the user's preferred style:
   - Not a vertical single-column VLAN box diagram.
   - H3C remains the horizontal tree branch point.
   - VLAN10/16/17/18 stay under the S5735S branch.
   - ER5200G3 is shown only as AC/MiniAP manager, not as router/core/gateway.
   - VLAN50 remains a grouped layer because downstream physical placement is still incomplete.
6. Fixed the image/text overflow issue by changing the final topology drawing to a square `2600 x 2600` canvas and shortening/wrapping labels so QuickLook/PNG preview no longer crops the right side.
7. Exported a PNG preview for easy viewing and sharing.

## Current Diagram Files

| File | Status | Notes |
|---|---|---|
| `codex-skills/shenlan-ops/diagrams/shenlan-network-latest-tree.svg` | Current primary SVG | Latest horizontal tree diagram, safe square canvas |
| `codex-skills/shenlan-ops/diagrams/shenlan-network-latest-tree.svg.png` | Current PNG preview | Rendered from latest SVG, `2400 x 2400` PNG |
| `codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg` | Synchronized SVG | Conflict resolved; now same safe-layout topology content |
| `codex-skills/shenlan-ops/diagrams/shenlan-network-topology.drawio` | Editable draw.io source | Earlier editable topology file; can be manually refined later |
| `codex-skills/shenlan-ops/diagrams/shenlan-network-ops-tree.svg` | Earlier ops tree | Kept for fault-isolation style handoff |

## Current Topology Summary

```text
电信光猫（B866-S2，路由模式）
        ├─ LAN1 —— SDWAN（OSDWAN） —— OpenWrt WAN1
        └─ LAN2 ─────────────────── OpenWrt WAN2

OpenWrt 主路由（192.168.99.3，倍控 H30S）
        └─ LAN —— H3C 核心三层交换机（192.168.99.1，H3C S5130V2-28S-LI）
                    ├─ S5735S 汇聚 —— Huawei S5735S-L24T4S-QA2（192.168.99.2）
                    │       ├─ VLAN10 办公
                    │       ├─ VLAN16 市场
                    │       ├─ VLAN17 教培
                    │       ├─ VLAN18 AI开发
                    │       └─ VLAN99 管理
                    ├─ ER5200G3 AC —— H3C ERG3 / ER5200G3（192.168.99.4）
                    │       └─ AP：7 × H3C A61-1500
                    ├─ VLAN30 —— 小米 ZSWG01CM / QNAP TS-h973AX-8G
                    ├─ VLAN40 —— 海康 NVR DS-7932N-R4(C)
                    ├─ VLAN50 —— node-121 / 飞牛OS NAS / 中控 / 下挂交换机集合
                    ├─ VLAN19 / VLAN70 / VLAN80 / VLAN90
                    ├─ VLAN99 管理网
                    ├─ VLAN120 临时口
                    └─ VLAN201 光猫 / 预留业务
```

## Still Needs Field Supplement

The main model list is now mostly complete. Remaining work is mostly physical placement and management addressing:

- 飞牛OS NAS：接入交换机和端口。
- 小米 `ZSWG01CM`：MAC、IP、最终接入口确认。
- 海康 NVR `DS-7932N-R4(C)`：物理接入口。
- AP：7 台 `A61-1500` 的现场安装位置、上联端口、与 `172.17.1.2` - `172.17.1.8` 的对应关系。
- 电信光猫 `B866-S2`：管理地址。
- `OSDWAN`：管理地址、端口映射。
- OpenWrt 倍控 `H30S`：OpenWrt 具体版本、物理 WAN/LAN 口映射。
- VLAN50 下挂交换机：逐台确认物理位置、完整品牌型号、上联端口。
- ER5200G3：若用于采购/维保，补充机身铭牌完整型号。
- node-121：若用于资产入库，补充零刻具体商品型号。

## Safe Resume Notes

- Start with `git pull --rebase` in `/Users/wanghongyu/Documents/Deepseek` or the corresponding Windows shared repo path.
- Read `codex-skills/shenlan-ops/handoff/LATEST-HANDOFF.md` first, then this file if continuing topology/model/diagram work.
- Do not commit node-121 secret files, SNMP credentials, raw backups, `.env`, logs, or config exports.
- If changing diagrams again, keep the user-preferred horizontal tree style and avoid dense single-column VLAN box layouts.
