# AGENTS.md — 三机协作总纲

> 本文件供 Codex、Kun 等所有终端智能体在工作区启动时读取。
> 通过 Git 在不同机器间同步，确保所有智能体掌握相同上下文。

---

## 一、工作区拓扑

| 机器 | 角色 | 路径 | 同步方式 |
|------|------|------|----------|
| **macair** | 移动办公 | `~/Documents/Deepseek` | auto-sync.sh (5min) |
| **12700K** | 主力工作 | `D:\Deepseek` | 计划任务 (5min) |
| **lk402** | 家庭工作 | `D:\Deepseek` | Deepseek-Sync 计划任务 (5min) |

> 三机均通过 `github.com:xinping7841/ops-skills-xinping` 同步。

---

## 二、协作规则（所有智能体必须遵守）

### 开工前
```bash
git pull --rebase   # 拿最新
```

### 改完代码/文档后
```bash
git add -A
git commit -m "描述改动"
git push
```

### 冲突处理
- 出现冲突时**不要自动解决**，暂停并等人裁决
- 大改动开分支，不阻塞其他机器

### 文件命名
- 技能文档：`skill-<主题>.md`（Kun 专用）
- 通用指令：`AGENTS.md`（Codex/Kun 都读）
- 脚本：`.sh`（macOS）、`.ps1`（Windows）

---

## 三、SSH 集群速查

| 机器 | Tailscale IP | 用户 | 密钥 | 连接命令 |
|------|-------------|------|------|----------|
| macair | 100.79.241.32 | wanghongyu | id_ed25519_nodes | — |
| 12700k | 100.94.150.23 | gaoxi | id_ed25519_nodes | `ssh -i ~/.ssh/id_ed25519_nodes gaoxi@100.94.150.23` |
| lk402 | 100.89.199.122 | gaoxi | id_ed25519_nodes | `ssh lk402-1` |

> 无密码 key：`id_ed25519_nodes`（macbook-air-nodes / lk402-nodes）
> 有密码 key：`id_ed25519`（wanghongyu@bogon，需要 Keychain）

---

## 四、Windows SSH 部署（管理员机器）

```powershell
# 管理员 PowerShell 执行
$key_nodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbeeVegOMLoXaAwJtmBddRBOVumbo/vGAIIZgDjJ9/A macbook-air-nodes"
$file = "C:\ProgramData\ssh\administrators_authorized_keys"
Add-Content $file $key_nodes
icacls $file /inheritance:r /grant "SYSTEM:(R)" /grant "BUILTIN\Administrators:(R)"
Restart-Service sshd
```

---

## 五、MCP 服务器清单

所有 Kun GUI 应配置以下 MCP 服务器：

1. **github** — GitHub 操作（PR/Issue/文件）
2. **gui_schedule** — 定时任务管理
3. **playwright** — 浏览器自动化
4. **context7** — 开发文档查询

详见 `skill-mcp-servers.md`。

---

## 六、当前技能文件

| 文件 | 用途 |
|------|------|
| `skill-ssh-tailscale.md` | SSH 免密 + Tailscale 拓扑（含12700k/lk402配置细节） |
| `skill-mcp-servers.md` | MCP 服务器配置指南 |
| `AGENTS.md` | 本文件，通用协作指令 |

---

## 七、GitHub 仓库

| 仓库 | 用途 | 主要工作机 |
|------|------|-----------|
| `xinping7841/ops-skills-xinping` | 技能/配置/脚本共享 | macair, 12700K, lk402 |
| `xinping7841/smart-center` | 多媒体展厅智能中控系统 | node-120 为主 |

### smart-center

```bash
git clone git@github.com:xinping7841/smart-center.git
```
- 主分支：`main`，另有多个 `codex/*` 开发分支
- node-120 本地 bare repo：`/srv/git/smart-center.git`（origin → GitHub）

---

## 八、新机器快速部署

```bash
# 1. clone
git clone git@github.com:xinping7841/ops-skills-xinping.git ~/Documents/Deepseek

# 2. 一键部署
cd ~/Documents/Deepseek
bash setup-mac.sh      # macOS
# 或
powershell -ExecutionPolicy Bypass -File setup-win.ps1   # Windows

# 3. 手动：Kun GUI → MCP 参考 skill-mcp-servers.md 配置
```

部署脚本自动处理：Codex AGENTS.md、SSH config、定时同步。

---

*本文件由 macair Kun 维护，最后更新 2026-06-13*

## 工作区技能文件

以下技能文件位于 `~/Documents/Deepseek/`，处理相关任务时请主动读取：

| 文件 | 何时读取 |
|------|----------|
| `skill-ssh-tailscale.md` | SSH 连接、Tailscale 组网、新机器上线 |
| `skill-mcp-servers.md` | MCP 服务器配置、Kun GUI 工具对齐 |

如需修改这些文件，改完后提交：
```bash
cd ~/Documents/Deepseek
git add -A && git commit -m "描述" && git push
```
