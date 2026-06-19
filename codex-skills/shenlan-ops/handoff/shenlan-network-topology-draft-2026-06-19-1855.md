# Shenlan Network Topology Draft Handoff — 2026-06-19 18:55

已基于 `node-121` 上 Scanopy、LibreNMS、NetBox 生成第一版深澜网络拓扑草图：

- 主文档：`codex-skills/shenlan-ops/references/shenlan-network-topology.md`
- 数据来源：LibreNMS SNMPv3 设备/端口/links 表、NetBox VLAN/IPAM/设备清单、Scanopy 服务运行状态
- 本次没有修改任何 live 网络配置，也没有提交密码、SNMP 凭据或原始导出数据。

核心结论：现有三个程序已经足够构建初始拓扑；LibreNMS 提供监控与链路证据，NetBox 承载资产/IPAM 底账，Scanopy 用于补足自动发现资产。当前可表达 OpenWrt 出口、H3C 核心、S5735S 接入、ER5200G3 AC、node-121 运维服务主干关系。端口级施工图仍需复核 H3C ↔ S5735S 多端口邻居/聚合关系，以及下游 PoE/AP/终端链路。

已补环境：本机安装了 `mcp-diagram-generator` npm 包，并把 `[mcp_servers.mcp-diagram-generator]` 写入 `~/.codex/config.toml`。需要重启 Codex 后才会暴露 `mcp__mcp-diagram-generator__*` 工具；当前文档先使用 Mermaid 版本保证仓库可同步、可审阅。
