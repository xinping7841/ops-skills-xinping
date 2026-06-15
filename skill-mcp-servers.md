# MCP 服务器配置 Skill

> 本文档帮助新机器上的 Kun / Codex 对齐 MCP 工具列表。每台机器需要各自配置 MCP 服务器；Token/Key 不通过 Git 同步。

## 应配置的 MCP 服务器

| 序号 | 服务器名称 | 用途 | 必配 |
|------|-----------|------|------|
| 1 | **github** | GitHub 仓库操作（PR/Issue/Commit/文件读写） | ✅ |
| 2 | **gui_schedule** | 定时任务管理（创建/删除/列出计划任务） | ✅ |
| 3 | **playwright** | 浏览器自动化（截图/导航/交互） | ✅ |
| 4 | **context7** | 开发文档查询（库/框架最新文档和代码示例） | ✅ |
| 5 | **filesystem** | 本地文件系统操作（读/写/搜索工作区文件） | 推荐 |

## 12700K 当前对齐状态（2026-06-15）

| 环境 | 已配置 MCP | 备注 |
|------|------------|------|
| Codex | `node_repl`, `gui_schedule`, `filesystem`, `context7`, `playwright`, `github` | 配置在 `~/.codex/config.toml`；重启 Codex 后生效 |
| Kun | `gui_schedule`, `filesystem`, `context7`, `playwright`, `github` | 配置在 `~/.kun/mcp.json` 和 `~/.kun/data/config.json` |

12700K filesystem 当前授权目录：

```text
D:\12700KGUI
D:\IDE\AI
C:\Users\gaoxi\Documents\Deepseek
```

注意：`github` 和 `context7` 需要本机环境变量提供密钥。不要把 Token 写进 Git。推荐变量名：

```text
GITHUB_PERSONAL_ACCESS_TOKEN
CONTEXT7_API_KEY
```

## 配置步骤

### 1. 检查当前状态

打开 Kun GUI → 设置 → 工具/MCP，查看已有服务器列表。

Codex 检查：

```powershell
Select-String -LiteralPath "$env:USERPROFILE\.codex\config.toml" -Pattern '^\[mcp_servers\.' -Context 0,4
```

Kun 检查：

```powershell
Get-Content "$env:USERPROFILE\.kun\data\config.json" -Raw -Encoding UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty capabilities | ConvertTo-Json -Depth 20
```

### 2. github 配置

- 类型：GitHub MCP
- 需要 GitHub Personal Access Token (PAT)
- Token 权限：`repo`、`read:org`、`issues`
- 去 https://github.com/settings/tokens 创建或沿用已有 token
- 推荐设置到用户环境变量：`GITHUB_PERSONAL_ACCESS_TOKEN`

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
- 启用即可，Kun/Codex 均可使用 stdio MCP 启动

### 5. context7 配置

- 类型：Context7 MCP
- 用于查询最新开发文档
- 需要 Context7 API 密钥（在 https://context7.com 获取）
- 推荐设置到用户环境变量：`CONTEXT7_API_KEY`
- **关键**：Kun 内置 10s 启动超时，npx 首次下载容易超时。需要先全局安装：
  ```bash
  npm install -g @upstash/context7-mcp
  ```
- 然后配置使用直接 node 路径调用（非 npx）：
  - Windows command: `C:\Program Files\nodejs\node.exe`
  - Windows args: `C:\Users\gaoxi\AppData\Roaming\npm\node_modules\@upstash\context7-mcp\dist\index.js`
  - macOS/Linux command: `node`
  - macOS/Linux npm 全局路径通常为 `/usr/local/lib/node_modules`

### 6. filesystem 配置

- 类型：Filesystem MCP
- 用于在工作区内读取、写入和搜索文件
- **注意**：最新版可能与 Node.js 存在 ESM 兼容问题，需固定版本：
  ```bash
  npm install -g @modelcontextprotocol/server-filesystem@0.6.2
  ```
- `trustScope` 设为 `workspace`
- `trustedWorkspaceRoots` 指定允许访问的目录

## 配置文件位置

| 文件 | 路径 | 作用 |
|------|------|------|
| Codex config | `~/.codex/config.toml` | Codex MCP、插件、skills 配置 |
| Kun mcp.json | `~/.kun/mcp.json` | Kun MCP 初始配置模板，由 GUI 管理 |
| Kun config.json | `~/.kun/data/config.json` | Kun 运行时实际配置，`capabilities.mcp.servers` 决定 MCP 启用 |

> 修改 `mcp.json` 后 Kun 重启时会同步到 `config.json`，但直接修改 `config.json` 然后重启更可靠。

## Windows 注意事项

### context7 启动超时

Kun 对 MCP 有硬编码 10s 启动超时。`@upstash/context7-mcp` 通过 npx 下载时容易超时，需全局安装后用直接 node 路径调用。

### filesystem 版本兼容

最新版 `@modelcontextprotocol/server-filesystem` 可能与 Node.js 存在 ESM 模块兼容问题（`ERR_UNSUPPORTED_DIR_IMPORT`），需固定到 `@0.6.2` 版本。

### npx 执行策略

PowerShell 可能阻止 `npm.ps1` / `npx.ps1`。MCP 配置里建议使用：

```text
C:\Program Files\nodejs\npx.cmd
```

而不是裸 `npx`。

## 验证

配置完成后，Kun/Codex 对话中可以尝试调用：

- `github`: “列出 my-repo 的 issue”
- `gui_schedule`: “列出当前定时任务”
- `playwright`: “打开 https://example.com”
- `context7`: “查 Python requests 库文档”
- `filesystem`: “列出 D:\IDE\AI 下的文件”

本机命令级验证：

```powershell
& 'C:\Program Files\nodejs\node.exe' 'C:\Users\gaoxi\AppData\Roaming\npm\node_modules\@upstash\context7-mcp\dist\index.js' --help
& 'C:\Program Files\nodejs\npx.cmd' -y '@playwright/mcp@latest' --help
& 'C:\Program Files\nodejs\npx.cmd' -y '@modelcontextprotocol/server-github' --help
```

## 维护

- 本文档通过 Git 同步：每台机器的 `D:\Deepseek` 或 `~/Documents/Deepseek`
- 新增 MCP 服务器时更新本文档，所有机器自动收到
- 各机器 MCP 认证信息（Token/Key）独立管理，不通过 Git 同步

---

*最后更新：2026-06-15 | 12700K 已补齐 Codex MCP 并扩展 Kun filesystem*
