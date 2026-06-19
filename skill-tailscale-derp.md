# Tailscale 自建 DERP 中继 Skill

用于配置、排查和交接自建 Tailscale DERP 中继。当前目标是：当 12700K、lk402、macair、node-121 等节点无法 P2P 直连时，优先通过北京阿里云 ECS 中继，避免落到海外 DERP 区域导致 SSH/HTTPS 延迟过高或不可用。

## 当前结论

- 自建 DERP 部署在北京阿里云 ECS：`39.106.125.197` / Tailscale `100.97.0.61`。
- 域名使用：`nvidia.gaoxinping.top`。
- DERP TLS 端口使用 `8443/TCP`，不占用 nginx 正在使用的 `443/TCP`。
- STUN 端口使用 `3478/UDP`。
- ECS 上 `derper.service` 已运行，监听 `*:8443` 和 `*:3478`。
- Tailscale 管理台已把下方 `derpMap` 合并到 tailnet policy，并已在 12700K 与 ECS 上验证 `ali-bj` 生效。
- 当前没有设置 `OmitDefaultRegions`，官方 DERP 仍保留为兜底。

## 服务器信息

| 项目 | 值 |
|---|---|
| 云服务器 | 阿里云北京 ECS |
| 公网 IP | `39.106.125.197` |
| Tailscale IP | `100.97.0.61` |
| SSH | `ssh -i ~/.ssh/id_ed25519_nodes -o IdentitiesOnly=yes root@39.106.125.197` |
| DERP 域名 | `nvidia.gaoxinping.top` |
| DERP TLS | `8443/TCP` |
| STUN | `3478/UDP` |
| systemd unit | `/etc/systemd/system/derper.service` |
| 证书目录 | `/etc/letsencrypt/live/nvidia.gaoxinping.top` |

Windows 12700K 上的 SSH 命令：

```powershell
ssh -i $env:USERPROFILE\.ssh\id_ed25519_nodes -o IdentitiesOnly=yes root@39.106.125.197
```

## 安全组

阿里云安全组：`sg-2zeffnv2z05jy3aefc72`，地域：`cn-beijing`。

需要保留以下入站规则：

| 协议 | 端口 | 来源 | 说明 |
|---|---:|---|---|
| TCP | `8443/8443` | `0.0.0.0/0` | Tailscale DERP TLS relay |
| UDP | `3478/3478` | `0.0.0.0/0` | Tailscale DERP STUN |
| TCP | `80/80` | `0.0.0.0/0` | nginx / certbot HTTP-01 |
| TCP | `443/443` | `0.0.0.0/0` | nginx HTTPS |

## DERP 安装记录

Go / derper 安装：

```bash
dnf install -y golang
GOBIN=/usr/local/bin GOTOOLCHAIN=auto GOPROXY=https://goproxy.cn,direct \
  go install tailscale.com/cmd/derper@v1.98.4
```

`derper@v1.98.4` 需要较新的 Go toolchain，安装时用 `GOTOOLCHAIN=auto` 自动拉取匹配版本。

## systemd 单元

`/etc/systemd/system/derper.service` 的关键命令：

```ini
[Unit]
Description=Tailscale DERP relay for gaoxinping tailnet
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/derper \
  --hostname=nvidia.gaoxinping.top \
  --a=:8443 \
  --http-port=-1 \
  --certmode=manual \
  --certdir=/etc/letsencrypt/live/nvidia.gaoxinping.top \
  --stun \
  --stun-port=3478 \
  --verify-clients \
  --home=blank
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

常用命令：

```bash
systemctl daemon-reload
systemctl enable --now derper
systemctl status derper --no-pager -l
journalctl -u derper -n 80 --no-pager
ss -lntup | grep -E ':8443|:3478'
```

`--verify-clients` 会拒绝非本 tailnet 客户端，普通 `curl` 到 `8443` 失败不一定代表 DERP 不可用，应以 Tailscale 客户端验证为准。

## 证书和续期

DERP 使用已有 Let's Encrypt 证书：

- `/etc/letsencrypt/live/nvidia.gaoxinping.top/fullchain.pem`
- `/etc/letsencrypt/live/nvidia.gaoxinping.top/privkey.pem`

`certmode=manual` 需要按主机名命名的证书文件，因此已创建软链接：

```bash
ln -sfn /etc/letsencrypt/live/nvidia.gaoxinping.top/fullchain.pem \
  /etc/letsencrypt/live/nvidia.gaoxinping.top/nvidia.gaoxinping.top.crt
ln -sfn /etc/letsencrypt/live/nvidia.gaoxinping.top/privkey.pem \
  /etc/letsencrypt/live/nvidia.gaoxinping.top/nvidia.gaoxinping.top.key
```

续期 deploy hook：`/etc/letsencrypt/renewal-hooks/deploy/reload-derper.sh`。作用是刷新软链接并重启 `derper.service`。

```bash
#!/usr/bin/env bash
set -euo pipefail
DOMAIN=nvidia.gaoxinping.top
LIVE=/etc/letsencrypt/live/$DOMAIN
ln -sfn "$LIVE/fullchain.pem" "$LIVE/$DOMAIN.crt"
ln -sfn "$LIVE/privkey.pem" "$LIVE/$DOMAIN.key"
systemctl restart derper.service
```

## Tailscale Policy DERP Map

进入 Tailscale 管理台 policy 文件：

```text
https://login.tailscale.com/admin/acls/file
```

把以下片段合并到 policy 顶层。若已有 `derpMap`，只把 `Regions.900` 合并进去；不要覆盖已有 ACL、SSH、tags 或 grants。

```json
"derpMap": {
  "Regions": {
    "900": {
      "RegionID": 900,
      "RegionCode": "ali-bj",
      "RegionName": "Aliyun Beijing",
      "Latitude": 39.9042,
      "Longitude": 116.4074,
      "Nodes": [
        {
          "Name": "900a",
          "RegionID": 900,
          "HostName": "nvidia.gaoxinping.top",
          "IPv4": "39.106.125.197",
          "IPv6": "none",
          "DERPPort": 8443,
          "STUNPort": 3478
        }
      ]
    }
  }
}
```

说明：

- `RegionID=900` 是自定义区域，避开官方区域 ID。
- `DERPPort=8443` 让 DERP 不占用 nginx 的 `443`。
- `STUNPort=3478` 明确使用阿里云安全组已放行的 UDP 端口。
- 先不要设置 `OmitDefaultRegions`，等多机确认 `ali-bj` 稳定后再考虑是否限制官方 DERP。

## 验证步骤

在 12700K / Windows：

```powershell
tailscale netcheck
tailscale debug derp-map | Select-String -Pattern 'ali-bj|900|nvidia|39.106.125.197|DERPPort|STUNPort'
tailscale ping -c 5 100.122.235.56
```

在 ECS：

```bash
tailscale netcheck
tailscale debug derp-map | grep -E 'ali-bj|900|nvidia|39.106.125.197|DERPPort|STUNPort'
journalctl -u derper -f
```

期望结果：

- `tailscale netcheck` 出现 `ali-bj`，延迟明显低于 `nue`、`tok` 等海外 DERP。
- 如果 peer 能直连，`tailscale ping` 显示 `via <公网IP:端口>` 是正常的。
- 如果直连失败，`tailscale ping` 应优先显示 `via DERP(ali-bj)`，而不是 `DERP(nue)` 或 `DERP(tok)`。
- `journalctl -u derper -f` 在客户端使用中继时能看到连接日志。

## 当前验证快照

2026-06-19 20:09 Asia/Shanghai：

- Tailscale 管理台已保存 `derpMap.Regions.900`。
- 12700K：`tailscale debug derp-map` 已显示 `900 / ali-bj / nvidia.gaoxinping.top / DERPPort 8443 / STUNPort 3478`。
- 12700K：`tailscale netcheck` 显示 `Nearest DERP: Aliyun Beijing`，`ali-bj` 延迟约 `16.6ms`；`tok` 约 `61.1ms`，`nue` 约 `125.2ms`。
- 12700K 到 node-121：`tailscale ping 100.122.235.56` 曾先走 `DERP(nue)` 约 `680ms`，随后切到直连 `124.127.149.110:9561` 约 `60ms`。直连可用时不会强制走 DERP，这是正常行为。
- ECS：`derper.service` 为 `active`。
- ECS：`ss -lntup` 显示 `derper` 监听 `*:8443/TCP` 与 `*:3478/UDP`。
- ECS：`tailscale netcheck` 显示 `Nearest DERP: Aliyun Beijing`，`ali-bj` 延迟约 `5.5ms`。
- ECS：`tailscale debug derp-map` 已显示 `900 / ali-bj / nvidia.gaoxinping.top / DERPPort 8443 / STUNPort 3478`。
- ECS 到 node-121：`tailscale ping 100.122.235.56` 直连约 `8ms`。

## 回滚

如果自建 DERP 策略导致客户端异常：

1. 在 Tailscale 管理台删除 policy 中的 `derpMap.Regions.900`，保存。
2. 客户端执行 `tailscale netcheck` 确认恢复官方 DERP。
3. ECS 上可临时停止服务：

```bash
systemctl disable --now derper.service
```

4. nginx 的 `80/443` 和 `nvidia.gaoxinping.top` 静态站不依赖 `derper.service`，停止 DERP 不应影响 HTTPS 网站。

## 注意事项

- 本文不记录 Tailscale 登录凭据、阿里云账号凭据、证书私钥内容。
- 本地 Windows 可能因代理/DNS 返回 `198.18.0.0/15` 测试地址，测试域名连通性时优先用 ECS 或 Tailscale 自带命令。
- 直接 `curl https://nvidia.gaoxinping.top:8443/` 可能被 `--verify-clients` 拒绝，不作为唯一判据。
- 修改本文后提交并推送 `xinping7841/ops-skills-xinping`，确保 macair、12700K、lk402 自动同步。
- node-121 当前在 `tailscale status` 中为 `active; direct 124.127.149.110:9561`。若需要在 node-121 本机验证 `derp-map`，优先使用明确用户 `xinping@100.122.235.56` 或修复本机 SSH config ACL 后再用别名。

---

*最后更新：2026-06-19 20:15 | Codex 整理*
