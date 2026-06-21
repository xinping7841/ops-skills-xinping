# CC Switch 跨平台 CUA 路径污染修复

## 症状

- Codex Desktop 用 cc-switch 切换到 API 登录后，**手机控制（远程控制）连接不上**
- Codex Desktop 可能打不开或卡住
- `codex doctor` 显示 `mcp_servers.node_repl` 命令不可解析

## 根因

cc-switch 在多台不同操作系统的机器间同步配置时，会把一台机器的**平台特定路径**（CUA 运行时路径、named pipe、CLI 路径等）写入另一台机器的 `config.toml`，导致：

| 被污染项 | macOS 被写入 | Windows 被写入 |
|---|---|---|
| `mcp_servers.node_repl.command` | `C:\...\node_repl.exe` | `/Applications/.../node_repl` |
| `NODE_REPL_NODE_PATH` | `C:\...\node.exe` | `/Applications/.../node` |
| `SKY_CUA_NATIVE_PIPE_DIRECTORY` | `\\.\pipe\...` (无效) | (macOS 没有这个) |
| `CODEX_CLI_PATH` | `C:\...\codex.exe` | `/Applications/.../codex` |
| skills 路径 | `C:\Users\gaoxi\...` | `/Users/xinping/...` |

### 影响链路

```
cc-switch 切换 provider
  → 写入 common_config（含跨平台路径）
  → config.toml 被覆盖
  → node_repl 无法启动
  → CUA (Computer Use Agent) 不可用
  → 手机控制失效
```

此外，**远程控制还需要 ChatGPT 会话令牌**（不是 API Key）。如果 cc-switch 的 `preserveCodexOfficialAuthOnSwitch` 为 `false`，切换到 API 登录时会丢弃 ChatGPT 令牌，手机控制也会断。

## 修复

### 一键修复

```bash
# macOS
python3 scripts/repair-cua-platform-paths.py

# Windows (PowerShell)
python scripts/repair-cua-platform-paths.py
```

脚本会自动：
1. 检测当前操作系统
2. 修复 `~/.codex/config.toml` 中的平台路径
3. 修复 `~/.cc-switch/cc-switch.db` 中所有 provider 的内嵌配置
4. 修复 `common_config_codex`
5. 修复 `mcp_servers` 表
6. 启用 cc-switch 代理（如果被关闭）
7. 重启 app-server daemon

### 手动步骤（如果自动修复后仍不行）

1. **在 cc-switch 中**：先切换到「OpenAI Official」，等令牌刷新，再切回 API provider
2. **重启 Codex Desktop**（Cmd+Q 再打开）
3. **验证**：
   ```bash
   codex doctor | grep -E "node_repl|app-server|ChatGPT"
   ```

### 预防

在 cc-switch 设置中确保 `preserveCodexOfficialAuthOnSwitch: true`，这样切换 provider 时 ChatGPT 令牌会被保留。

## 跨机器应用

三台机器都需要运行修复脚本：

| 机器 | 系统 | 操作 |
|---|---|---|
| **macair** (当前) | macOS | ✅ 已修复 |
| **12700k** | Windows | `python scripts\repair-cua-platform-paths.py` |
| **lk402** | Windows | `python scripts\repair-cua-platform-paths.py` |

Windows 上运行前确保 Python 3 和 sqlite3 可用。

## 相关文件

- `scripts/repair-cua-platform-paths.py` — 跨平台自动修复脚本
- `scripts/repair-macos-cua-paths.py` — 旧版（仅 macOS，保留作参考）
- `scripts/localize-cc-switch-skills.py` — 增加了 `--fix-cua-paths` 选项

## 最后验证

- 日期：2026-06-22
- macair 修复后：手机控制 ✅ 第三方 API ✅ 会话保留 ✅
