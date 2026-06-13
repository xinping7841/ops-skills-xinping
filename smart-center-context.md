# smart-center 项目上下文

> 粘贴到新 Kun 对话即可开始工作

---

**项目**：smart-center — 多媒体展厅智能中控系统

**仓库**：`xinping7841/smart-center`（GitHub）

**本机路径**：`~/Documents/smart-center`

**生产机**：node-120（Tailscale `100.80.138.78`，用户 `xinping`）
- 生产部署：`/srv/smart-center/current`
- 本地 bare repo：`/srv/git/smart-center.git`（push → post-receive hook → 自动推 GitHub）

**分支**：`main` 为主，另有 `codex/12700k-dev` 等开发分支

**协同方式**：
```
任意机器 clone → 本地开发 → push GitHub
    ↓
node-120 需要时 git pull（或通过 bare repo 中转）
```

**协作规则**：
- 开工先 `git pull`
- 改完立即 `git commit` + `git push`
- 冲突不自动解决，等人裁决

---

请帮我修改 smart-center 项目。
