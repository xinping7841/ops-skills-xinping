# AGENTS.md — 三机协作总纲

> 本文件供 Codex、Kun 等所有终端智能体在工作区启动时读取。
> 通过 Git 在不同机器间同步，确保所有智能体掌握相同上下文。

---

## 一、工作区拓扑

| 机器 | 角色 | 路径 | 同步方式 |
|------|------|------|----------|
| **macair / xinpingmacbook-air** | 移动办公 | `~/Documents/Deepseek` | auto-sync.sh (5min) |
| **12700K** | 主力工作 | `D:\Deepseek` | 计划任务 (5min) |
| **lk402** | 家庭工作 | `D:\Deepseek` | Deepseek-Sync 计划任务 (5min) |

> 三机均通过 `github.com:xinping7841/ops-skills-xinping` 同步。

---

## 二、协作规则（所有智能体必须遵守）

### GitHub 唯一事实源

- `~/Documents/Deepseek` / `D:\Deepseek` 的 GitHub 仓库是技能、协作规则、MCP 模板的唯一事实源
- `~/.codex/skills`、`~/.agents/skills`、Kun 本机配置都视为派生目录，不作为长期源头
- 新增 Codex 技能必须进入 `codex-skills/<skill-name>/`
- 新增 Kun/通用技能必须进入 `skill-<主题>.md`
- 本机已有但仓库没有的技能称为 orphan skill，只生成审计报告，不自动提交

### 开工前
```bash
git pull --rebase   # 拿最新
```

### 改完代码/文档后
```bash
git add <白名单文件>
git commit -m "描述改动"
git push
```

自动同步脚本只允许自动提交以下白名单：

- `AGENTS.md`
- `skill-*.md`
- `codex-skills/**`
- `memory/**`
- `setup-*.sh`、`setup-*.ps1`
- `auto-sync.sh`、`sync.ps1`、`sync-hidden.vbs`
- `codex-config-*.toml`
- `scripts/**`
- `machine-profiles/**`
- `mcp-templates/**`

禁止自动提交机器私有文件、token、`.env*`、日志、备份、路由器配置导出、`*-settings.json`。

### 冲突处理
- 出现冲突时**不要自动解决**，暂停并等人裁决
- 大改动开分支，不阻塞其他机器
- 同步脚本遇到 `git pull --rebase` 冲突必须停止

### 文件命名
- 技能文档：`skill-<主题>.md`（Kun 专用）
- 通用指令：`AGENTS.md`（Codex/Kun 都读）
- 脚本：`.sh`（macOS）、`.ps1`（Windows）

### Engineering Handoff Memory

涉及代码行为、模块设计、架构选择、SSH、MCP、同步任务、计划任务、部署配置或机器路径的任务，必须使用 `engineering-handoff-memory`。

- 开工前先读 `memory/LATEST.md`。
- 代码任务继续读相关 `memory/modules/`、`memory/code/`、`memory/adr/`。
- 环境/机器任务继续读相关 `memory/machines/`、`memory/sync/`、`memory/ops/`、`memory/runbooks/`。
- 收尾前更新对应 memory 文件，重写 `memory/LATEST.md`，并运行 `python3 scripts/memory-audit.py`。
- 如果未更新 memory，最终回复必须说明原因。

---

## 三、SSH 集群速查

| 机器 | Tailscale IP | 用户 | 密钥 | 连接命令 |
|------|-------------|------|------|----------|
| macair / xinpingmacbook-air | 100.112.77.115 | xinping | id_ed25519_nodes | `ssh macair` |
| node-121 | 100.122.235.56 | xinping | id_ed25519_nodes | `ssh node-121` |
| 12700k | 100.94.150.23 | gaoxi | id_ed25519_nodes | `ssh -i ~/.ssh/id_ed25519_nodes gaoxi@100.94.150.23` |
| lk402 | 100.89.199.122 | gaoxi | id_ed25519_nodes | `ssh lk402`（兼容 `ssh lk402-1`） |

> 无密码 key：`id_ed25519_nodes`（macbook-air-nodes / lk402-nodes）
> 有密码 key：`id_ed25519`（wanghongyu@bogon，需要 Keychain）

`node-121` 的 LAN 备用别名为 `node-121-lan`（`192.168.50.121`）。远程优先走 Tailscale；若 `tailscale status` 显示 `node-121` 离线，先恢复 Tailscale 再做服务变更。

---

## 四、Windows SSH 部署（管理员机器）

```powershell
# 管理员 PowerShell 执行
$key_nodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNo3GgCvj6YmcZDW5g8gI3XTvGZlhXSe2/Kw9FgKlHK macbook-air-nodes"
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
| `skill-tailscale-derp.md` | 北京阿里云自建 Tailscale DERP 中继配置、验证和回滚 |
| `skill-codex-sandbox-repair.md` | Codex Windows sandbox helper 故障修复记录和脚本入口 |
| `skill-mcp-servers.md` | MCP 服务器配置指南 |
| `skill-kun-skills-sync.md` | Kun / `.agents` skills 多机 Git 同步方案 |
| `skill-web-app-dev-standards.md` | Web 应用现场开发规范：代码结构、Agent 协作、UI 质量和验收清单 |
| `skill-code-review-eval.md` | 代码评估与审查规范：P0/P1/P2/P3 风险分级、结构体检、测试缺口和 UI 质量检查 |
| `skill-engineering-handoff-memory.md` | 工程接力记忆：代码/运维/机器/同步/架构决策的上下文防腐层 |
| `AGENTS.md` | 本文件，通用协作指令 |

Codex 专用技能包：

| 路径 | 用途 |
|------|------|
| `codex-skills/table-data/` | Excel、CSV、TSV、Google Sheets 表格数据整理、清洗、汇总、校验的入口技能 |
| `codex-skills/web-app-dev/` | 网页服务、React/Next/Vite、Tailwind/shadcn UI、代码规范和可维护性入口技能 |
| `codex-skills/code-review-eval/` | 代码审查、项目体检、风险评估、重构前评估、测试缺口和 UI 质量检查入口技能 |
| `codex-skills/engineering-handoff-memory/` | 工程接力记忆：任务开始读取上下文，任务结束写回 handoff memory 并审计 |

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

*本文件由 macair Kun 维护，最后更新 2026-06-20*

## 工作区技能文件

以下技能文件位于 `~/Documents/Deepseek/`，处理相关任务时请主动读取：

| 文件 | 何时读取 |
|------|----------|
| `skill-ssh-tailscale.md` | SSH 连接、Tailscale 组网、新机器上线 |
| `skill-tailscale-derp.md` | 自建 DERP、中继兜底、Tailscale netcheck/derp-map 排查 |
| `skill-codex-sandbox-repair.md` | Windows `shell_command` sandbox helper 启动失败、ACL/`.sandbox` 修复 |
| `skill-mcp-servers.md` | MCP 服务器配置、Kun GUI 工具对齐 |
| `skill-kun-skills-sync.md` | Kun / `.agents` skills 多机同步、GitHub 推送和首次拉取 |
| `skill-web-app-dev-standards.md` | 搭建或维护网页服务、前端 UI、后台、管理台、看板、React/Next/Vite 项目 |
| `skill-code-review-eval.md` | 代码评估、code review、重构前体检、风险分级、测试缺口、安全/性能/UI 审查 |
| `skill-engineering-handoff-memory.md` | 代码行为、模块设计、架构选择、SSH/MCP/同步/机器配置变更和智能体接力 |

Codex 专用技能包位于 `~/Documents/Deepseek/codex-skills/`：

| 路径 | 何时读取 |
|------|----------|
| `codex-skills/table-data/` | Excel、CSV、TSV、Google Sheets 表格数据整理、清洗、汇总、校验 |
| `codex-skills/web-app-dev/` | 创建或修改网站、网页服务、后台、管理台、看板、React/Next/Vite、Tailwind/shadcn UI |
| `codex-skills/code-review-eval/` | 评估现有代码质量、审查 PR/项目风险、重构前体检、查测试缺口或 UI 质量问题 |
| `codex-skills/engineering-handoff-memory/` | 读取/更新 `memory/`，记录代码和运维变更原因、验证、风险和接力点 |

如需修改这些文件，改完后提交：
```bash
cd ~/Documents/Deepseek
git add AGENTS.md skill-*.md codex-skills memory scripts machine-profiles mcp-templates setup-*.sh setup-*.ps1 auto-sync.sh sync.ps1 sync-hidden.vbs codex-config-*.toml
git commit -m "描述"
git push
```
