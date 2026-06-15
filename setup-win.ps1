# setup-win.ps1 — Windows 新机一键部署
# 用法(管理员 PowerShell):
#   git clone git@github.com:xinping7841/ops-skills-xinping.git D:\Deepseek
#   cd D:\Deepseek; powershell -ExecutionPolicy Bypass -File setup-win.ps1

$ErrorActionPreference = "Continue"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "=== Kun 生态部署 (Windows) ===" -ForegroundColor Cyan

# 1. Codex 全局指令
$codexDir = "$env:USERPROFILE\.codex"
if (Test-Path $codexDir) {
    Copy-Item "$RepoDir\AGENTS.md" "$codexDir\AGENTS.md" -Force
    Write-Host "✅ Codex AGENTS.md 已部署" -ForegroundColor Green
} else {
    Write-Host "⚠️  未找到 Codex (.codex)，跳过" -ForegroundColor Yellow
}

# 2. SSH config
$sshConfig = "$env:USERPROFILE\.ssh\config"
if (-not (Select-String -Path $sshConfig -Pattern "### ops-skills ###" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content $sshConfig @"

### ops-skills ###
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
"@
    Write-Host "✅ SSH github config 已追加" -ForegroundColor Green
} else {
    Write-Host "⏭️  SSH config 已有 ops-skills 标记，跳过" -ForegroundColor Gray
}

# 3. 定时同步 (计划任务)
$taskName = "Deepseek-Sync"
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if (-not $existing) {
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $RepoDir\sync.ps1" `
        -WorkingDirectory $RepoDir
    $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes 5) `
        -RepetitionDuration (New-TimeSpan -Days 3650)
    $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive
    Register-ScheduledTask -TaskName $taskName -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null
    Write-Host "✅ 计划任务 Deepseek-Sync 已创建（每5分钟）" -ForegroundColor Green
} else {
    Write-Host "⏭️  计划任务已存在，跳过" -ForegroundColor Gray
}

# 4. 提醒
Write-Host ""
Write-Host "=== 部署完成 ===" -ForegroundColor Cyan
Write-Host "还需手动操作："
Write-Host "  1. 确保 ~/.ssh/id_ed25519_nodes 密钥已生成并添加到 GitHub"
Write-Host "  2. Kun GUI → 设置 → MCP 参考 skill-mcp-servers.md 配置"
Write-Host "  3. Kun GUI → 设置 → 技能 extraDirs 添加: $RepoDir"
Write-Host ""
Write-Host "技能文件已就位："
Get-ChildItem "$RepoDir\skill-*.md" | ForEach-Object { Write-Host "  $_" }
