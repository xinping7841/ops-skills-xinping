# NetBox CSRF 可信来源修复

时间：2026-06-19 18:35 Asia/Shanghai

主机：`node-121`

服务：NetBox

入口：

- LAN：`http://192.168.50.121:60801/`
- Tailscale：`http://100.122.235.56:60801/`

## 背景

用户通过 `http://100.122.235.56:60801/login/` 打开 NetBox 登录页后遇到 Django `Forbidden (403)` / `CSRF verification failed`。

检查 NetBox 运行时 Django 设置确认：

- `ALLOWED_HOSTS = ['*']`
- `CSRF_TRUSTED_ORIGINS = []`

因此根因是 NetBox 未把当前 Tailscale/LAN 访问 URL 加入 CSRF 可信来源。

## 变更

在 `node-121:/opt/netbox/netbox-docker/env/netbox.env` 增加：

```text
CSRF_TRUSTED_ORIGINS=http://100.122.235.56:60801 http://192.168.50.121:60801
```

变更前已在同目录创建本地备份文件，备份仅留在 `node-121`，不进入仓库。

随后执行 NetBox 容器重建：

```bash
cd /opt/netbox/netbox-docker
docker compose up -d netbox
```

## 验证

验证结果：

- `netbox-docker-netbox-1` 健康状态为 `healthy`。
- 运行时 `CSRF_TRUSTED_ORIGINS` 已加载为：
  - `http://100.122.235.56:60801`
  - `http://192.168.50.121:60801`
- `GET /login/` 返回 `200 OK`。
- 带有效 CSRF token、`Origin: http://100.122.235.56:60801`、`Referer: http://100.122.235.56:60801/login/` 的登录表单提交返回登录页校验响应，不再被来源 CSRF 检查拒绝。

## 备注

如果浏览器仍显示旧的 403 页面，刷新页面即可；若仍异常，可清理该站点 Cookie 或使用无痕窗口重新打开 NetBox。

未修改 OpenWrt、H3C、S5735S、ER5200G3、VLAN、DNS、路由、防火墙、SQM、PBR、MWAN、DHCP 或 AP 配置。
