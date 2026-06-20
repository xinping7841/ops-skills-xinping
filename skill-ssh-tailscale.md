# SSH 免密连接 Skill — Tailscale 集群

## 本机密钥

| 密钥文件 | 类型 | 密码 |
|----------|------|------|
| `~/.ssh/id_ed25519` | ED25519 | **有密码（Keychain）** |
| `~/.ssh/id_ed25519_nodes` | ED25519 | **无密码** |
| `~/.ssh/id_ed25519.pub` | 公钥 | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADSa1NydZ0L4fYpadK/mMeQoi/ccMGypVY+0u8FO1Ow wanghongyu@bogon` |
| `~/.ssh/id_ed25519_nodes.pub` | 公钥 | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbeeVegOMLoXaAwJtmBddRBOVumbo/vGAIIZgDjJ9/A macbook-air-nodes` |

## 在线机器

| 机器 | Tailscale IP | 用户 | 密钥 | 连接命令 |
|------|-------------|------|------|----------|
| hy-node-254 | 100.114.16.16 | enlightv-506 | id_ed25519 | `ssh hy-node-254` |
| node-120 | 100.80.138.78 | xinping | id_ed25519 | `ssh node-120` |
| node-121 | 100.122.235.56 | xinping | **id_ed25519_nodes** | `ssh node-121` |
| node-123 | 100.119.214.90 | sl123 | id_ed25519_nodes | `ssh node-123-ts` |
| 12700k | 100.94.150.23 | gaoxi | **id_ed25519_nodes** | `ssh -i ~/.ssh/id_ed25519_nodes gaoxi@100.94.150.23` |
| lk402-1 | 100.89.199.122 | gaoxi | **id_ed25519_nodes** | `ssh lk402-1` |

## 离线/待补充

| 机器 | Tailscale IP | 状态 |
|------|-------------|------|
| node-122 | 100.84.214.75 | 离线（1d前） |
| node-124 | 100.78.193.102 | 离线（9d前） |

## SSH config 标准片段

新机器运行 `setup-mac.sh` / `setup-win.ps1` 后应自动写入以下节点别名。若本机缺失，可手动追加到 `~/.ssh/config`：

```sshconfig
Host node-121
  HostName 100.122.235.56
  User xinping
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new

Host node-121-lan
  HostName 192.168.50.121
  User xinping
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new

Host 12700k
  HostName 100.94.150.23
  User gaoxi
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new

Host lk402-1
  HostName 100.89.199.122
  User gaoxi
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
```

`node-121` 优先走 Tailscale；在深蓝现场管理网内可用 `node-121-lan` 走 `192.168.50.121`。如果机器上有全局代理、TUN 或 Meta Tunnel 抢默认路由，访问 `192.168.50.121` 时可能从 `198.18.0.1` 发起连接并出现空响应；远程维护时优先检查 `tailscale status` / `tailscale ping node-121`。

Windows 上如果 `~/.ssh/config` 的 owner 是 `BUILTIN\Administrators` 且当前用户只有 Read 权限，普通终端会无法追加 Host 块。用管理员 PowerShell 运行 `setup-win.ps1` 修复，或临时用 `ssh -F <临时配置文件> node-121` 验证连接。

`node-121` 上的 Leadtek/NVIDIA RTX Report 服务监听 `18080`：

- Tailscale：`http://100.122.235.56:18080/`
- LAN：`http://192.168.50.121:18080/`
- 备案完成前不要用 `nvidia.gaoxinping.top` 做生产验收；公网 80/443 可能返回阿里云 ICP 合规 `403 Beaver`。

---

## 自建 DERP 兜底速查

北京阿里云 ECS `39.106.125.197` 已部署自建 Tailscale DERP/STUN，用于直连失败时优先走国内中继。域名 `nvidia.gaoxinping.top`，DERP TLS `8443/TCP`，STUN `3478/UDP`，systemd 服务 `derper.service`。

详细安装记录、Tailscale `derpMap`、验证命令和回滚步骤见 `skill-tailscale-derp.md`。处理 Tailscale 中继、`tailscale netcheck`、`DERP(nue)` / `DERP(tok)` 延迟问题时，先读取该文档。

---

## 12700k Windows SSH 配置备忘

### 问题根因

Windows OpenSSH 对管理员用户使用特殊路径：
- **非管理员**：`%USERPROFILE%\.ssh\authorized_keys`
- **管理员**：`C:\ProgramData\ssh\administrators_authorized_keys`

### 已部署的文件

`C:\ProgramData\ssh\administrators_authorized_keys` 包含 4 个 key：
1. lk402-codex-to-12700k (RSA)
2. gaoxi@lk402 (ED25519)
3. wanghongyu@bogon — `id_ed25519`（有密码，**需要 Keychain**）
4. macbook-air-nodes — `id_ed25519_nodes`（**无密码，当前使用**）

### 快速部署脚本

新 Windows 管理员机器执行以下 PowerShell（管理员）：

```powershell
$b64_1 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFEU2ExTnlkWjBMNGZZcGFkSy9tTWVRb2kvY2NNR3lwVlkrMHU4Rk8xT3cgd2FuZ2hvbmd5dUBib2dvbgo="
$b64_2 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSURiZWVWZWdPTUxvWGFBd0p0bUJkZFJCT1Z1bWJvL3ZHQUlJWmdEako5L0EgbWFjYm9vay1haXItbm9kZXMK"

$key1 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64_1))
$key2 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64_2))

$file = "C:\ProgramData\ssh\administrators_authorized_keys"
Add-Content $file $key1
Add-Content $file $key2

icacls $file /inheritance:r /grant "SYSTEM:(F)" /grant "BUILTIN\Administrators:(F)"
Restart-Service sshd
```

### 常见坑

1. **OCR 复制会损坏 key** — 用 base64 或 bat 文件传输，不要截图
2. **管理员走 administrators_authorized_keys** — 不是 authorized_keys
3. **权限必须 SYSTEM + Administrators** — `icacls` 修复
4. **id_ed25519 有密码** — 非交互式终端需要 Keychain 或改用 id_ed25519_nodes

---

## 新机器上线检查清单

1. `tailscale status` 确认在线
2. `grep "^Host " ~/.ssh/config` 检查是否有配置
3. 没有的话补充 SSH config
4. 用 `ssh -o ConnectTimeout=5 -o PasswordAuthentication=no <host> 'hostname'` 测试
5. 更新本文档

---

## 三机工作台 Git 同步

| 机器 | Git 仓库 | 状态 |
|------|----------|------|
| macair | `~/Documents/Deepseek` → `github.com:xinping7841/ops-skills-xinping` | ✅ |
| 12700K | `D:\Deepseek` | ✅ |
| lk402-1 | `D:\Deepseek` → `github.com:xinping7841/ops-skills-xinping` | ✅ |

工作流：
```bash
# 开始工作前
git pull

# 写完脚本/skill 后
git add -A && git commit -m "描述" && git push
```

### 12700K 配置备忘

- 工作区路径：`D:\Deepseek`
- SSH 密钥：`~/.ssh/id_ed25519_nodes`（无密码，从 macair scp 传输）
- GitHub 认证：`~/.ssh/config` 已配 Host github.com → id_ed25519_nodes

---

## lk402-1 配置完成

- [x] OpenSSH 服务 → 已开启 + 自动启动
- [x] Git for Windows → 已装 (2.54.0)
- [x] Kun GUI → 已装 (0.2.9)
- [x] SSH 密钥 → 已生成 id_ed25519_nodes，GitHub 已授权
- [x] 仓库克隆 → `D:\Deepseek` (git@github.com:xinping7841/ops-skills-xinping.git)
- [x] 自动同步 → Windows 计划任务 `Deepseek-Sync`，每5分钟
- [x] SSH 入站 → `administrators_authorized_keys` 已含 macair 的 id_ed25519_nodes key
- [x] Kun skills → `claw.skills.extraDirs: ["D:\\Deepseek"]` 已配置，自动发现 skill-*.md

---

*最后更新：2026-06-13 | Kun 整理*
