# Codex 本机协同配置

> 粘贴到 Codex 对话中，让它自己完成所有配置

---

## 你的任务

帮我把本机 Codex 配置成和 Kun 同等能力的协同开发环境。以下是现状和需要你做的事。

## 一、当前已完成（不要改）

1. `~/.codex/AGENTS.md` — 已包含三机拓扑、SSH 速查、GitHub 仓库、协作规则
2. `~/.codex/skills/ssh-tailscale/SKILL.md` — SSH 连接技能
3. `~/.codex/skills/mcp-servers/SKILL.md` — MCP 配置指南
4. `~/.codex/config.toml` — 已追加 GitHub + Context7 MCP 配置（token 待填）

## 二、需要你做的事

### 1. 填 GitHub Token

打开 `~/.codex/config.toml`，找到：
```
GITHUB_PERSONAL_ACCESS_TOKEN = "<你的 GitHub PAT>"
```
从 https://github.com/settings/tokens 创建 token（权限：repo、read:org），替换占位符。

### 2. 验证 MCP 已生效

重启 Codex，确认 MCP 数量 ≥ 3（node_repl + github + context7）。

### 3. 验证技能已加载

确认以下技能在 Codex 中可见：
- `ssh-tailscale` — SSH/Tailscale 连接
- `mcp-servers` — MCP 服务器配置
- `playwright` — 浏览器自动化
- `pdf` — PDF 处理

如果 Skills 显示 0，检查 `~/.codex/config.toml` 是否需要注册技能路径。参考已有 `[skills]` 段的格式。

### 4. 确认协同可工作

```bash
cd ~/Documents/Deepseek
git pull --rebase
```

确认能拉取到最新。然后随便改个文件，commit + push 验证推送正常。

### 5. 确认 smart-center 仓库可访问

```bash
cd ~/Documents/smart-center
git pull --rebase
git log --oneline -3
```

## 三、本机工作区总览

```
~/Documents/
├── Deepseek/              ← 技能/配置共享（主仓库）
│   ├── AGENTS.md          ← 通用指令
│   ├── skill-ssh-tailscale.md
│   ├── skill-mcp-servers.md
│   ├── setup-mac.sh       ← 新机一键部署
│   └── auto-sync.sh       ← 每5分钟自动同步（含→Codex）
└── smart-center/          ← 展厅中控源码
    └── AGENTS.md          ← 项目自带指令
```

## 四、协作规则

- 开工 `git pull`
- 改完 `git commit` + `git push`
- 冲突不自动解决，等我裁决

---

现在开始执行。有问题随时问我。
