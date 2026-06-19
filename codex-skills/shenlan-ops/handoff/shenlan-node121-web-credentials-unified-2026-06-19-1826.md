# node-121 Web 服务账号统一记录

时间：2026-06-19 18:26 Asia/Shanghai

范围：`node-121` 上的 Scanopy、LibreNMS、NetBox Web 管理账号。

## 结果

- Scanopy：`http://100.122.235.56:60072/`，管理员用户名 `admin@shenlan.local`。
- LibreNMS：`http://100.122.235.56:60800/`，管理员用户名 `admin`。
- NetBox：`http://100.122.235.56:60801/`，管理员用户名 `admin`。
- 三个服务已统一使用同一套管理员密码；明文密码不写入本仓库。
- 本次没有修改 OpenWrt、H3C、S5735S、ER5200G3、VLAN、DNS、路由、防火墙、SQM/PBR/MWAN、AP 配置。

## 本地 secret 文件

仅在 `node-121` 本地保存凭据，其他终端需要读取时应通过 SSH 登录 `node-121` 后查看，不要复制到同步仓库：

- Scanopy：`/opt/scanopy/.shenlan-credentials`
- LibreNMS：`/opt/librenms/docker-src/examples/compose/.shenlan-credentials`
- NetBox：`/opt/netbox/netbox-docker/.shenlan-credentials`

三个 secret 文件权限均为 `600`。LibreNMS 与 NetBox 文件属主为部署用户，Scanopy 文件属主为 `root`。

## 验证

- HTTP 可达性：Scanopy 本机访问返回 `200`；LibreNMS 与 NetBox 未登录访问返回登录重定向 `302`。
- 后台密码校验：NetBox Django `check_password` 通过；Scanopy Argon2id 哈希用统一密码验证通过；LibreNMS 用户哈希用统一密码验证通过。
- 统一性校验：三个本地 secret 文件中的管理员密码值一致。

## 备注

- LibreNMS 中文界面配置仍保留：Web 主容器 `APP_LOCALE=zh-CN`，管理员用户偏好 `locale=zh-CN`。
- Scanopy 与 NetBox 当前未确认有完整内置中文界面；建议继续使用中文命名、中文描述和本仓库交接文档补充上下文。
