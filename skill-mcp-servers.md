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

## macair 当前对齐状态（2026-06-21）

| 环境 | 已配置 MCP | 备注 |
|------|------------|------|
| Codex | `filesystem`, `context7`, `playwright`, `github` 等插件/技能按 Codex 本机配置加载 | 工作区为 `~/Documents/Deepseek` |
| Kun | `gui_schedule`, `filesystem`, `context7`, `playwright`, `github` | 配置在 `~/.kun/mcp.json` 和 `~/.kun/data/config.json`，页面显示 `5/5` 已连接 |

macair filesystem 当前授权目录：

```text
/Users/xinping/Documents/Deepseek
```

macair 使用用户级 Node.js（mise 安装）作为 MCP 运行时：

```text
/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node
```

macair Kun 的个人 MCP 不使用 `npx` 作为 `command`，而是使用绝对 `node` 路径直接运行模块入口，以避免 macOS 图形应用重启后不继承 shell `PATH` 导致 `MCP error -32000: Connection closed`：

| MCP | command | args |
|-----|---------|------|
| filesystem | `/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node` | `.../@modelcontextprotocol/server-filesystem/dist/index.js /Users/xinping/Documents/Deepseek` |
| github | `/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node` | `.../@modelcontextprotocol/server-github/dist/index.js` |
| playwright | `/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node` | `.../@playwright/mcp/cli.js` |
| context7 | `/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node` | `.../@upstash/context7-mcp/dist/index.js` |

每个个人 MCP 的 `env.PATH` 显式包含 Node bin：

```text
/Users/xinping/.local/share/mise/installs/node/22.23.0/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

`github` 和 `context7` 的密钥只写入 macair 本机 Kun 配置和 `launchctl` 环境，不进入 Git。

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

macOS Kun 建议改为直接 node 启动 `@playwright/mcp/cli.js`，并显式设置 `env.PATH`，不要依赖 GUI 继承 shell 环境。

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
- **Windows 注意**：部分版本可能与 Node.js 存在 ESM 兼容问题，可固定版本：
  ```bash
  npm install -g @modelcontextprotocol/server-filesystem@0.6.2
  ```
- **macair 注意**：`@modelcontextprotocol/server-filesystem@0.6.2` 的部分工具 `inputSchema` 缺少 `type: "object"`，Kun 会报 `Invalid input: expected "object"`。macair 已改用 `@modelcontextprotocol/server-filesystem@2025.11.25`。
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

## macOS 注意事项

### GUI 环境 PATH 不等于 shell PATH

macOS 图形应用从 Finder/LaunchServices 启动时通常不会读取 `~/.zshrc` / `~/.zprofile`。如果 MCP 配置使用 `npx`，而 `npx` 的 shebang 是 `/usr/bin/env node`，Kun 重启后可能找不到 `node`，表现为：

```text
MCP error -32000: Connection closed
```

解决方式：

1. 使用绝对 `node` 路径作为 MCP `command`
2. `args` 指向已安装 MCP 包的 JS 入口
3. 在 MCP `env.PATH` 中显式加入 Node bin
4. 保存后重启 Kun

### filesystem schema 兼容

如果 Kun 报类似：

```text
Invalid input: expected "object", path: ["tools", 0, "inputSchema", "type"]
```

说明 MCP 返回的 tool schema 不符合 Kun 校验。macair 的修复是安装并使用：

```bash
npm install -g @modelcontextprotocol/server-filesystem@2025.11.25
```

然后用绝对 `node` 路径直接启动 `dist/index.js`。

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

*最后更新：2026-06-21 | macair Kun MCP 5/5 接入并记录 macOS direct-node 配置*
