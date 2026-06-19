# Shenlan Network Ops Tree Handoff — 2026-06-19

已按“运维交接排查”视角生成树状拓扑图：

- 树状 SVG：`codex-skills/shenlan-ops/diagrams/shenlan-network-ops-tree.svg`
- 可编辑 draw.io 原图仍保留：`codex-skills/shenlan-ops/diagrams/shenlan-network-topology.drawio`
- 来源文档：`codex-skills/shenlan-ops/references/shenlan-network-topology.md`

树状图按故障排查顺序组织：上游 Internet/WAN → OpenWrt 主出口 → H3C 核心三层 → S5735S 接入、ER5200G3 AC、node-121 运维服务、待确认下游设备。图中橙色/虚线表示后续要复核的 LLDP 多端口邻居、聚合、AP/PoE/房间面板链路。

本次没有修改任何 live 网络配置，没有提交密码、SNMP 凭据、Token、原始导出数据或设备配置备份。
