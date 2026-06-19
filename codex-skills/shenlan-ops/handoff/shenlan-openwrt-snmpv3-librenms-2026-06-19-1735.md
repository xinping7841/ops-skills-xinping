# Shenlan OpenWrt SNMPv3 / LibreNMS 接入记录

时间：2026-06-19 17:35 Asia/Shanghai

## 结论

OpenWrt 主路由 `192.168.99.3` 已完成 SNMPv3-only 监控接入，并已替换 LibreNMS 中原 ping-only 占位设备。

当前 LibreNMS 关键设备状态：

| 地址 | 显示名 | OS | 类型 | SNMP | 端口数 |
|---|---|---|---|---|---:|
| `192.168.50.121` | `node-121-service-host` | `linux` | `server` | `v3` | 26 |
| `192.168.99.1` | `H3C-Core-Switch` | `comware` | `network` | `v3` | 48 |
| `192.168.99.2` | `S5735S-Office-Access` | `vrp` | `network` | `v3` | 33 |
| `192.168.99.3` | `OpenWrt-Main-Router` | `linux` | `server` | `v3` | 9 |
| `192.168.99.4` | `ER5200G3-AC` | `comware` | `network` | `v3` | 11 |

## OpenWrt SNMP 配置

OpenWrt `192.168.99.3` 已安装并启用：

- `snmpd-ssl`
- `snmp-utils-ssl`
- `libnetsnmp-ssl`
- `libopenssl3`

`/etc/config/snmpd` 已调整为 v3-only 风格，权限为 `600`，服务已 enable 并运行。

运行时 `/var/run/snmpd.conf` 已确认包含：

- `agentaddress UDP:192.168.99.3:161,UDP:127.0.0.1:161`
- `sysName OpenWrt-Main-Router`
- `createUser shenlan_ro SHA <redacted> AES <redacted>`
- `rouser shenlan_ro priv`

保留的配置备份：

- `/root/snmpd-config-before-snmpv3-20260619-172239.bak`
- `/root/snmpd-config-before-snmpv3-fix-20260619-172306.bak`

## 验证结果

从 `node-121` 使用 `/opt/shenlan-ops/secrets/snmpv3-switches.env` 中的 SNMPv3 凭据验证：

```text
.1.3.6.1.2.1.1.5.0 = STRING: "OpenWrt-Main-Router"
```

从 `node-121` 使用 SNMPv2c `public` 探测 `192.168.99.3` 无响应，符合 v3-only 目标。

## LibreNMS 操作

原 LibreNMS 记录为 ping-only/不完整设备：

```text
device_id=3 hostname=192.168.99.3 display=OpenWrt-Main-Router sysName=192.168.99.3 os=linux snmpver=<empty>
```

已执行：

1. 删除原 `192.168.99.3` 占位记录。
2. 使用 SNMPv3 authPriv 重新添加 `192.168.99.3`，显示名 `OpenWrt-Main-Router`。
3. 执行 `device:discover 192.168.99.3` 成功。
4. 执行 `device:poll 192.168.99.3` 成功。

发现/轮询结果：

- LibreNMS device id：`10`
- Hostname：`192.168.99.3`
- Display：`OpenWrt-Main-Router`
- sysName：`openwrt-main-router`
- OS：`linux`
- Type：`server`
- SNMP：`v3`
- Ports：`9`

## 注意事项

- 继续把 OpenWrt 作为 egress/NAT/DNS/QoS/policy-routing 设备。
- 不要把 H3C 内部三层网关/DHCP职责迁到 OpenWrt。
- 不要在共享仓库提交 SNMP 密码、`.env`、原始设备配置或导出备份。
- SNMPv3 凭据仍只保存在 `node-121` 的本地 secret 文件中。
