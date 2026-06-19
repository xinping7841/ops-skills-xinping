# node-121 服务目录

更新时间：2026-06-19 18:35 Asia/Shanghai

主机：`node-121`

地址：

- LAN：`192.168.50.121`
- Tailscale：`100.122.235.56`

用途：深蓝现场网络的长期运维服务主机。备份、监控、拓扑、IPAM、WAN1 域名管理、SNMP 相关服务优先部署在这里，不要长期跑在临时操作电脑上。

## 对外入口

| 服务 | 用途 | LAN URL | Tailscale URL | 部署/数据目录 | 管理方式 |
|---|---|---|---|---|---|
| Scanopy | 网络发现、拓扑视图、资产/服务初步沉淀 | `http://192.168.50.121:60072/` | `http://100.122.235.56:60072/` | `/opt/scanopy` | Docker Compose |
| LibreNMS | 长期监控、SNMP/ICMP 轮询、告警基础、syslog/trap 接收 | `http://192.168.50.121:60800/` | `http://100.122.235.56:60800/` | `/opt/librenms/docker-src/examples/compose` | Docker Compose |
| NetBox | IPAM、VLAN、设备与机柜/连接关系的专业事实源 | `http://192.168.50.121:60801/` | `http://100.122.235.56:60801/` | `/opt/netbox/netbox-docker` | Docker Compose |
| WAN1 Domain Manager | OpenWrt WAN1 域名/出口相关管理小服务 | `http://192.168.50.121:8765/` | 不建议直接暴露使用 | `/opt/shenlan-network-ops/tools/wan1-domain-manager` | `shenlan-wan1-domain-manager.service` |

认证信息、数据库密码、SNMP 密码、Basic Auth 密码只保存在 `node-121` 本地 secret/env 文件中，不写入本仓库。

Web 管理账号当前已统一：Scanopy、LibreNMS、NetBox 使用同一套管理员密码；用户名分别按产品约定保留。密码只记录在下列 `node-121` 本地文件中：

- Scanopy：`/opt/scanopy/.shenlan-credentials`
- LibreNMS：`/opt/librenms/docker-src/examples/compose/.shenlan-credentials`
- NetBox：`/opt/netbox/netbox-docker/.shenlan-credentials`

## 本机 SNMP / Trap / Syslog

| 服务 | 端口 | 绑定 | 用途 | 管理方式 |
|---|---:|---|---|---|
| `snmpd.service` | UDP `161` | `127.0.0.1`, `192.168.50.121`, `100.122.235.56` | `node-121` 自身 SNMPv3 被 LibreNMS 监控 | systemd |
| LibreNMS snmptrapd | TCP/UDP `162` | `0.0.0.0`, `::` | 接收 SNMP Trap | Docker Compose |
| LibreNMS syslog-ng | TCP/UDP `514` | `0.0.0.0`, `::` | 接收网络设备 syslog | Docker Compose |
| Smart Center SNMP Agent | 由 `/etc/smart-snmp-agent.env` 指定 | 由 env 指定 | smart-center 自定义 SNMP Agent/API | `smart-snmp.service` |

`snmpd.service` 当前使用 SNMPv3，本地 secret 文件位置：`/opt/shenlan-ops/secrets/snmpv3-node121.env`。不要打印或提交该文件内容。

交换机/路由器共用的 SNMPv3 监控凭据保存在：`/opt/shenlan-ops/secrets/snmpv3-switches.env`。不要打印或提交该文件内容。

## Docker 服务

当前在 `node-121` 上运行的主要容器组：

### Scanopy

- `scanopy-server-1`
- `scanopy-postgres-1`
- `scanopy-daemon`

目录：`/opt/scanopy`

管理员用户名：`admin@shenlan.local`。密码见本机 secret 文件 `/opt/scanopy/.shenlan-credentials`，不要打印或提交。

常用命令：

```bash
cd /opt/scanopy
docker compose ps
docker compose logs --tail=100
```

### LibreNMS

- `librenms`
- `librenms_db`
- `librenms_redis`
- `librenms_dispatcher`
- `librenms_syslogng`
- `librenms_snmptrapd`
- `librenms_msmtpd`

目录：`/opt/librenms/docker-src/examples/compose`

管理员用户名：`admin`。密码见本机 secret 文件 `/opt/librenms/docker-src/examples/compose/.shenlan-credentials`，不要打印或提交。

常用命令：

```bash
cd /opt/librenms/docker-src/examples/compose
docker compose -f compose.yml ps
docker compose -f compose.yml logs --tail=100 librenms
```

LibreNMS 当前关键设备均为 SNMPv3：

| 地址 | 显示名 | OS | 类型 | SNMP | 端口数 |
|---|---|---|---|---|---:|
| `192.168.50.121` | `node-121-service-host` | `linux` | `server` | `v3` | 26 |
| `192.168.99.1` | `H3C-Core-Switch` | `comware` | `network` | `v3` | 48 |
| `192.168.99.2` | `S5735S-Office-Access` | `vrp` | `network` | `v3` | 33 |
| `192.168.99.3` | `OpenWrt-Main-Router` | `linux` | `server` | `v3` | 9 |
| `192.168.99.4` | `ER5200G3-AC` | `comware` | `network` | `v3` | 11 |

界面语言：Web 主容器通过 `compose.override.yml` 设置 `APP_LOCALE=zh-CN`，管理员用户 `admin` 的 `users_prefs.locale` 也设置为 `zh-CN`。如果登录后仍显示英文，刷新浏览器或在用户偏好里选择简体中文。

### NetBox

- `netbox-docker-netbox-1`
- `netbox-docker-postgres-1`
- `netbox-docker-redis-1`
- `netbox-docker-redis-cache-1`

目录：`/opt/netbox/netbox-docker`

管理员用户名：`admin`。密码见本机 secret 文件 `/opt/netbox/netbox-docker/.shenlan-credentials`，不要打印或提交。

NetBox 已在 `env/netbox.env` 设置 `CSRF_TRUSTED_ORIGINS`，允许从以下入口提交登录表单，避免通过 Tailscale/LAN 端口访问时出现 Django CSRF 403：

- `http://100.122.235.56:60801`
- `http://192.168.50.121:60801`

常用命令：

```bash
cd /opt/netbox/netbox-docker
docker compose ps
docker compose logs --tail=100 netbox
```

## systemd 服务

| Unit | 描述 | 状态 | 单元文件 | 备注 |
|---|---|---|---|---|
| `docker.service` | Docker 容器运行时 | active/running | `/usr/lib/systemd/system/docker.service` | 承载 Scanopy/LibreNMS/NetBox |
| `shenlan-wan1-domain-manager.service` | WAN1 Domain Manager | active/running | `/etc/systemd/system/shenlan-wan1-domain-manager.service` | 使用 `/etc/shenlan-wan1-domain-manager.env`，含认证信息，勿打印 |
| `snmpd.service` | node-121 本机 SNMPv3 Agent | active/running | `/usr/lib/systemd/system/snmpd.service` | LibreNMS 监控本机 |
| `smart-snmp.service` | Smart Center SNMP Agent Service | active/running | `/etc/systemd/system/smart-snmp.service` | 使用 `/etc/smart-snmp-agent.env` |

常用命令：

```bash
systemctl status shenlan-wan1-domain-manager.service
systemctl status snmpd.service
systemctl status smart-snmp.service
journalctl -u shenlan-wan1-domain-manager.service --no-pager -n 80
journalctl -u snmpd.service --no-pager -n 80
journalctl -u smart-snmp.service --no-pager -n 80
```

## 相关交接记录

- `codex-skills/shenlan-ops/handoff/shenlan-wan1-domain-manager-121-deployment-2026-06-18-2015.md`
- `codex-skills/shenlan-ops/handoff/shenlan-scanopy-onboarding-and-vlan-discovery-2026-06-18-2310.md`
- `codex-skills/shenlan-ops/handoff/shenlan-node121-librenms-netbox-deployment-2026-06-19-0145.md`
- `codex-skills/shenlan-ops/handoff/shenlan-node121-snmpv3-librenms-upgrade-2026-06-19-1345.md`
- `codex-skills/shenlan-ops/handoff/shenlan-snmpv3-switches-er5200g3-2026-06-19-1445.md`
- `codex-skills/shenlan-ops/handoff/shenlan-er5200g3-snmpv3-librenms-2026-06-19-1505.md`
- `codex-skills/shenlan-ops/handoff/shenlan-openwrt-snmpv3-librenms-2026-06-19-1735.md`
- `codex-skills/shenlan-ops/handoff/shenlan-node121-web-credentials-unified-2026-06-19-1826.md`
- `codex-skills/shenlan-ops/handoff/shenlan-netbox-csrf-trusted-origins-2026-06-19-1835.md`
