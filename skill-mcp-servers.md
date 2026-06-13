# MCP 服务器配置 Skill

> 本文档帮助新机器上的 Kun 对齐 MCP 工具列表。每台机器需要在 GUI 中各自配置以下 MCP 服务器。

## 应配置的 MCP 服务器

| 序号 | 服务器名称 | 用途 | 必配 |
|------|-----------|------|------|
| 1 | **github** | GitHub 仓库操作（PR/Issue/Commit/文件读写） | ✅ |
| 2 | **gui_schedule** | 定时任务管理（创建/删除/列出计划任务） | ✅ |
| 3 | **playwright** | 浏览器自动化（截图/导航/交互） | ✅ |
| 4 | **context7** | 开发文档查询（库/框架最新文档和代码示例） | ✅ |

## 配置步骤

### 1. 检查当前状态

打开 Kun GUI → 设置 → 工具/MCP，查看已有服务器列表。

### 2. github 配置

- 类型：GitHub MCP
- 需要 GitHub Personal Access Token (PAT)
- Token 权限：`repo`、`read:org`、`issues`
- 去 https://github.com/settings/tokens 创建或沿用已有 token

### 3. gui_schedule 配置

- 类型：Kun 内置 MCP
- 无需额外配置，启用即可
- 用于管理 Kun 的定时任务

### 4. playwright 配置

- 类型：Playwright MCP
- 需要在主机上安装 Chromium：
  ```bash
  npx playwright install chromium
  ```
- 启用即可，Kun 内置支持

### 5. context7 配置

- 类型：Context7 MCP
- 用于查询最新开发文档
- 需要 Context7 API 密钥（在 https://context7.com 获取）
- 启用后填入 API Key

## 验证

配置完成后，Kun 对话中可以尝试调用：
- `github`: "列出 my-repo 的 issue"
- `gui_schedule`: "列出当前定时任务"
- `playwright`: "打开 https://example.com"
- `context7`: "查 Python requests 库文档"

如果返回结果正常，说明配置成功。

## 维护

- 本文档通过 Git 同步：每台机器的 `D:\Deepseek` 或 `~/Documents/Deepseek`
- 新增 MCP 服务器时更新本文档，所有机器 Kun 自动收到
- 各机器 MCP 认证信息（Token/Key）独立管理，不通过 Git 同步

---

*最后更新：2026-06-13 | 由 macair Kun 创建*
