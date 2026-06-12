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
| node-121 | 100.122.235.56 | xinping | id_ed25519 | `ssh node-121` |
| node-123 | 100.119.214.90 | sl123 | id_ed25519_nodes | `ssh node-123-ts` |
| 12700k | 100.94.150.23 | gaoxi | **id_ed25519_nodes** | `ssh -i ~/.ssh/id_ed25519_nodes gaoxi@100.94.150.23` |

## 离线/待补充

| 机器 | Tailscale IP | 状态 |
|------|-------------|------|
| lk402-1 | 100.89.199.122 | 离线（5h前） |
| node-122 | 100.84.214.75 | 离线（1d前） |
| node-124 | 100.78.193.102 | 离线（9d前） |

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

*最后更新：2026-06-12 | Kun 整理*
