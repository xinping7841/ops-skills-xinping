# Codex Windows Sandbox Repair Skill

用于记录和修复 Codex Desktop 在 Windows 上的本地 sandbox helper 启动失败问题。典型场景是 `shell_command` 在执行任何真实命令前就失败，即使是 `Write-Output OK` 也跑不起来。

## 症状

常见错误：

```text
windows sandbox: helper_unknown_error: setup refresh had errors
windows sandbox: orchestrator_helper_report_read_failed
failed to read setup_error.json
CreateProcessAsUserW failed: 5
```

这表示 Codex Windows sandbox helper 在启动阶段失败，不是当前项目命令本身的问题。常见诱因是 `~/.codex/.sandbox` 内部状态损坏或 ACL 异常。

## 修复脚本

脚本位置：`scripts/repair-codex-sandbox.ps1`。

保守修复模式会备份并重建 `C:\Users\gaoxi\.codex\.sandbox`，不会删除 Codex 会话、skills、config、SSH key 或项目文件。

普通 PowerShell 中执行：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Deepseek\scripts\repair-codex-sandbox.ps1
```

执行后完整退出并重新打开 Codex，再测试：

```powershell
Write-Output OK
```

如果仍出现 access denied 相关错误，用管理员 PowerShell 追加 ACL 修复：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Deepseek\scripts\repair-codex-sandbox.ps1 -ApplyAcl
```

如果 OpenSSH 仍提示无法读取 `C:\Users\gaoxi\.ssh\config`，可执行可选 SSH config ACL 修复：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Deepseek\scripts\repair-codex-sandbox.ps1 -RepairSshConfigAcl
```

## 脚本行为

1. 检查 `~/.codex` 是否存在。
2. 若 `~/.codex/.sandbox` 存在，将其移动为 `.sandbox.bak-<timestamp>`。
3. 创建新的 `.sandbox` 和 `.sandbox/tmp`。
4. 写入 `repair-check.txt` 作为哨兵文件。
5. 如果传入 `-ApplyAcl`，给当前 Windows 用户补充 sandbox 目录完整权限。
6. 如果传入 `-RepairSshConfigAcl`，给当前 Windows 用户补充 `~/.ssh/config` 读取权限。
7. 通过隐藏 PowerShell 子进程测试普通进程创建是否可用。

## 注意事项

- 先用默认模式；只有重启 Codex 后仍失败，再用 `-ApplyAcl`。
- `-RepairSshConfigAcl` 只在 SSH config 读取权限异常时使用。
- 修复脚本不处理项目内 Git 状态，也不清理 `.playwright-mcp/`、本地仓库副本或其他工作区文件。
- 如果修复后 `shell_command` 仍失败，但提权 shell 可用，优先把关键配置写入 `skill-*.md` 并推送 GitHub，保证多机可查。

---

*最后更新：2026-06-19 | Codex 整理*
