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
- **关键**：Kun 内置 10s 启动超时，npx 首次下载容易超时。需要先全局安装：
  ```bash
  npm install -g @upstash/context7-mcp
  ```
- 然后配置使用直接 node 路径调用（非 npx）：
  - command: `node`
  - args: `["npm-global-path/node_modules/@upstash/context7-mcp/dist/index.js", "--api-key", "your-key"]`
  - npm 全局路径：Windows 为 `%APPDATA%/npm`，macOS/Linux 为 `/usr/local/lib/node_modules`


### 配置文件位置

MCP 配置实际涉及两个文件：

| 文件 | 路径 | 作用 |
|------|------|------|
| mcp.json | ~/.kun/mcp.json | 初始配置模板，由 GUI 管理 |
| config.json | ~/.kun/data/config.json | 运行时实际配置，capabilities.mcp.servers 是真正决定 MCP 启用的位置 |

> 修改 mcp.json 后 Kun 重启时会同步到 config.json，但直接修改 config.json 然后重启更可靠。

### context7 启动超时

Kun 对 MCP 有硬编码 10s 启动超时。`@upstash/context7-mcp` 通过 npx 下载时容易超时，需全局安装后用直接 node 路径调用（见上方配置步骤）。

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

*最后更新：2026-06-13 | 由 macair Kun 创建 | k402 补充关键发现*
