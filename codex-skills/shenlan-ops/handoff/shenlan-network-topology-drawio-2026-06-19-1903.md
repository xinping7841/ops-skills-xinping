# Shenlan Network Topology Draw.io Handoff — 2026-06-19 19:03

已在 Codex 重启后通过 `mcp-diagram-generator` 生成深澜网络拓扑 draw.io 可编辑图：

- 图文件：`codex-skills/shenlan-ops/diagrams/shenlan-network-topology.drawio`
- 来源文档：`codex-skills/shenlan-ops/references/shenlan-network-topology.md`
- 图中包括：WAN1/WAN2、OpenWrt 主出口、H3C 核心、S5735S 接入、ER5200G3 AC、node-121 运维服务、Scanopy/LibreNMS/NetBox、NetBox VLAN/IPAM、以及待确认 LLDP 邻居。

本次没有修改任何 live 网络配置，没有提交密码、SNMP 凭据、Token、原始导出数据或设备配置备份。后续如果要把图升级为施工级拓扑，需要继续复核 H3C/S5735S 多端口邻居、聚合关系、PoE/AP/房间面板端口，并把确认结果回写 NetBox。
