# 深澜备份、报表与监控

更新时间：2026-06-15

## 当前原则

- 定时备份时间：每天凌晨 03:00。
- 服务不要长期跑在当前 PC；目标运行主机是 `192.168.50.121`。
- 当前 PC 上已有可用脚本，可作为迁移到 `192.168.50.121` 的源目录。
- 报表要同步到 WPS，方便用户异地查看。

## 已有自动化目录

本机工作目录：

```text
D:\IDE\AI\network-ops
```

主要文件：

```text
D:\IDE\AI\network-ops\config.json
D:\IDE\AI\network-ops\Invoke-NetworkOps.ps1
D:\IDE\AI\network-ops\Build-NetworkStatusWorkbook.mjs
D:\IDE\AI\network-ops\Install-ScheduledTask.ps1
D:\IDE\AI\network-ops\backups
D:\IDE\AI\network-ops\dashboard
D:\IDE\AI\network-ops\logs
D:\IDE\AI\network-ops\reports
D:\IDE\AI\network-ops\state
```

## Feishu integration plan

- Target runtime host: 192.168.50.121 is Linux; current PC has SSH key-based login to it.
- Feishu Base role: operational CMDB/status center for inventory, current status, alerts, change log, backup log, VLAN/IP/port mapping, and daily traffic summary.
- Do not store high-frequency raw traffic snapshots in Feishu Base. Keep raw 5-minute data on 192.168.50.121 and NAS; sync only current status and daily/hourly summaries to Feishu.
- Alert chat: reuse the existing central-control operations group first. Create a separate network-alert group only if alert volume becomes noisy.
- Permission principle: credentials, IP details, and config-backup paths are visible only to group owner/admins. Ordinary members should see status and alert summaries only.
- Feishu Docs/Wiki role: human-readable architecture, emergency runbooks, and change summaries. Do not write plaintext passwords into Feishu docs.

一键执行命令：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\IDE\AI\network-ops\Invoke-NetworkOps.ps1
```

注意：当前 PC 上曾创建过计划任务 `ShenlanNetworkOps`，后因用户确认服务应运行在 `192.168.50.121`，已删除。

## 工具路径

```text
PuTTY plink: C:\Program Files\PuTTY\plink.exe
PuTTY pscp:  C:\Program Files\PuTTY\pscp.exe
Node.js:     C:\Users\gaoxi\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe
```

## 同步目标

| 目标 | 路径 | 用途 |
|---|---|---|
| QNAP 主备份 | `\\192.168.30.145\public\Shenlan-Network-Backup` | 主备份存储 |
| fnOS 二级备份 | `\\192.168.50.254\数据备份\Shenlan-Network-Backup` | 双保险备份 |
| WPS 同步 | `C:\Users\gaoxi\WPSDrive\267090523\WPS云盘\深澜网络运维` | 异地查看报表 |
| 本地工作副本 | `D:\IDE\AI\network-ops` | 当前脚本和临时状态 |

## 已验证的一次性运行

最近成功运行记录：

```text
时间：2026-06-15 16:47:23
QNAP/WPS/fnOS 中 shenlan-network-status.xlsx 更新：2026-06-15 16:47:29 左右
OpenWrt 备份：openwrt-config-20260615-164122.tar.gz；后续运行可能生成 164723 版本
```

已验证能力：

- 通过 SSH/pscp 从 `192.168.99.3` 拉取 OpenWrt 配置备份。
- 通过 SSH 从 `192.168.99.4` 采集 ER5200G3 状态。
- H3C 核心交换机目前只采集 ping/简要状态；详细 SNMP/console 采集待补充。
- 生成 Excel、HTML、JSON 状态文件。
- 同步到 QNAP、fnOS、WPS 目录。

## 报表文件

Excel 文件名保持英文，避免路径和同步编码问题：

```text
shenlan-network-status.xlsx
shenlan-network-status.html
latest-status.json
```

Excel 已改为中文内容：

```text
工作表：实时状态、配置变更记录、备份记录、输出文件
表头：设备、地址、角色、状态、变更、备注
常用值：在线、有变更、无变更
```

历史台账文件：

```text
D:\IDE\AI\深澜网络架构与配置台账-2026-06-15.md
D:\IDE\AI\outputs\network-inventory-20260615\深澜网络架构与配置台账-2026-06-15.xlsx
```

## config.json 摘要

当前本机配置：

```json
{
  "paths": {
    "root": "D:\\IDE\\AI\\network-ops",
    "wpsSync": "C:\\Users\\gaoxi\\WPSDrive\\267090523\\WPS云盘\\深澜网络运维",
    "nasSync": "\\\\192.168.30.145\\public\\Shenlan-Network-Backup",
    "fnosSync": "\\\\192.168.50.254\\数据备份\\Shenlan-Network-Backup",
    "inventoryDir": "D:\\IDE\\AI\\outputs\\network-inventory-20260615"
  },
  "devices": {
    "openwrt": { "host": "192.168.99.3", "user": "root" },
    "er5200g3": { "host": "192.168.99.4", "user": "admin" },
    "core": { "host": "192.168.99.1", "snmpCommunityRef": "h3c-snmp-community" }
  }
}
```

完整密码和 host key 见 `references/network-inventory.md`。

## 迁移到 192.168.50.121 的待办

`192.168.50.121` 已知状态：

```text
ping: 通
开放端口：22, 80, 443, 3389, 3000
关闭/超时：445, 5985
```

迁移前还需要确认：

```text
1. 192.168.50.121 的系统类型：Windows / Linux / 其他。
2. SSH 或 RDP 登录账号密码/密钥。
3. 121 服务器是否能访问 QNAP SMB、fnOS SMB、WPS 同步目录或替代同步方式。
4. 是否允许在 121 上安装 Node.js、PuTTY/OpenSSH、计划任务/cron。
```

建议迁移步骤：

```text
1. 将 D:\IDE\AI\network-ops 复制到 192.168.50.121。
2. 在 121 上修正 config.json 中的 root、WPS、NAS 路径。
3. 在 121 上验证 OpenWrt/ER/H3C 的网络可达性。
4. 在 121 上手动运行 Invoke-NetworkOps.ps1 一次。
5. 确认 QNAP、fnOS、WPS 同步结果。
6. 在 121 上配置每日 03:00 的计划任务或 cron。
7. 保留当前 PC 目录作为维护副本，但不启用定时任务。
```

## 监控建设建议

OpenWrt 建议监控：

```text
CPU、内存、温度、磁盘/NVMe、接口流量、WAN1/WAN2 状态、连接数、NAT/防火墙、mwan3 状态、SQM/QoS 状态、日志告警
```

H3C 核心建议监控：

```text
端口 up/down、端口速率、VLAN 网关状态、CPU/内存、SNMP、告警日志、trunk 口状态、默认路由、DHCP 地址池
```

ER5200G3 / AP 建议监控：

```text
AP 在线数、AP 地址 172.17.1.x、SSID 客户端数、无线信道、无线功率、AP 离线告警、无线业务 VLAN60 可用性
```

展示方式可选：

```text
1. 独立 HTML 页面：当前脚本已生成 shenlan-network-status.html，适合快速落地。
2. Excel/WPS 表格：适合异地查看和人工台账。
3. 中控对接：建议提供 JSON/HTTP API，读取 latest-status.json 或服务化接口。
4. 标准监控：后续可接 Prometheus/Grafana、Zabbix、LibreNMS，优先用 SNMP 和 OpenWrt exporter。
```

## 带宽与分流需求记录

宽带参数：

```text
下行：1000M
上行：50M
```

建议 QoS/SQM：

```text
优先控制上行，防止上传占满导致全网延迟升高。
上行建议初始限制：45M 左右。
下行建议初始限制：900M 左右，或先只控上行。
算法建议：cake / piece_of_cake。
```

双 WAN 事实：

```text
WAN1 eth1: SDWAN 设备后面的一路宽带
WAN2 eth2: 光猫直连，同一条宽带的直连路径
```

分流建议：

```text
国内普通流量优先 WAN2 光猫直连。
需要 SDWAN 的业务走 WAN1。
WAN1/WAN2 可做互备。
具体策略等 mwan3、WAN 状态和目标域名/IP 清单确认后再下发。
```

