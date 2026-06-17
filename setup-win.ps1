# setup-win.ps1 - Windows one-click setup
# Usage:
#   git clone git@github.com:xinping7841/ops-skills-xinping.git D:\Deepseek
#   cd D:\Deepseek; powershell -ExecutionPolicy Bypass -File setup-win.ps1

$ErrorActionPreference = 'Continue'
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host '=== Ops skills setup (Windows) ===' -ForegroundColor Cyan

# 1. Codex global instructions
$codexDir = Join-Path $env:USERPROFILE '.codex'
if (Test-Path -LiteralPath $codexDir) {
    Copy-Item -LiteralPath (Join-Path $RepoDir 'AGENTS.md') -Destination (Join-Path $codexDir 'AGENTS.md') -Force
    Write-Host '[OK] Codex AGENTS.md installed' -ForegroundColor Green
} else {
    Write-Host '[WARN] Codex directory not found; skipped AGENTS.md' -ForegroundColor Yellow
}

# 1.5 Codex skill
$skillSourceRoot = Join-Path $RepoDir 'codex-skills'
$skillRoot = Join-Path $codexDir 'skills'
if ((Test-Path -LiteralPath $codexDir) -and (Test-Path -LiteralPath $skillSourceRoot)) {
    New-Item -ItemType Directory -Path $skillRoot -Force | Out-Null
    $resolvedRoot = (Resolve-Path -LiteralPath $skillRoot).Path
    Get-ChildItem -LiteralPath $skillSourceRoot -Directory | ForEach-Object {
        $skillSource = $_.FullName
        $skillDest = Join-Path $skillRoot $_.Name
        if (Test-Path -LiteralPath $skillDest) {
            $resolvedDest = (Resolve-Path -LiteralPath $skillDest).Path
            if ($resolvedDest.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                Remove-Item -LiteralPath $skillDest -Recurse -Force
            } else {
                Write-Host "[WARN] Refusing to replace unexpected skill path: $resolvedDest" -ForegroundColor Yellow
                return
            }
        }
        Copy-Item -LiteralPath $skillSource -Destination $skillDest -Recurse -Force
        Write-Host "[OK] Codex skill $($_.Name) installed" -ForegroundColor Green
    }
}

# 1.5. Codex 技能同步
if (Test-Path $codexDir) {
    Get-ChildItem "$RepoDir\skill-*.md" | ForEach-Object {
        $skillName = $_.BaseName -replace '^skill-', ''
        $skillDir = "$codexDir\skills\$skillName"
        New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
        $firstLine = (Get-Content $_ -TotalCount 1) -replace '^# ', ''
        @"
---
name: $skillName
description: $firstLine
---

$(Get-Content $_ -Raw)
"@ | Set-Content "$skillDir\SKILL.md" -Force
    }
    Write-Host "✅ Codex 技能已同步 ($((Get-ChildItem $RepoDir\skill-*.md).Count) 个)" -ForegroundColor Green
}

# 2. SSH config
$sshDir = Join-Path $env:USERPROFILE '.ssh'
$sshConfig = Join-Path $sshDir 'config'
New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
if (-not (Select-String -Path $sshConfig -Pattern '### ops-skills ###' -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -LiteralPath $sshConfig -Encoding UTF8 -Value @'

### ops-skills ###
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
'@
    Write-Host '[OK] SSH github config appended' -ForegroundColor Green
} else {
    Write-Host '[SKIP] SSH config already has ops-skills marker' -ForegroundColor Gray
}

# 3. Scheduled sync task
$taskName = 'Deepseek-Sync'
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$hiddenLauncher = Join-Path $RepoDir 'sync-hidden.vbs'
$taskArgs = '//B //NoLogo "{0}"' -f $hiddenLauncher
$Action = New-ScheduledTaskAction -Execute 'wscript.exe' `
    -Argument $taskArgs `
    -WorkingDirectory $RepoDir
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Days 3650)
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive
Register-ScheduledTask -TaskName $taskName -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null
if ($existing) {
    Write-Host '[OK] Scheduled task Deepseek-Sync refreshed (every 5 minutes)' -ForegroundColor Green
} else {
    Write-Host '[OK] Scheduled task Deepseek-Sync created (every 5 minutes)' -ForegroundColor Green
}

# 4. Run one immediate sync so Codex UI skill registrations are available now.
$syncScript = Join-Path $RepoDir 'sync.ps1'
if (Test-Path -LiteralPath $syncScript) {
    Write-Host '[INFO] Running initial sync...' -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File $syncScript
} else {
    Write-Host '[WARN] sync.ps1 not found; initial sync skipped' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '=== Setup complete ===' -ForegroundColor Cyan
Write-Host 'Manual follow-up:'
Write-Host '  1. Ensure ~/.ssh/id_ed25519_nodes exists and is added to GitHub.'
Write-Host '  2. Configure Kun GUI MCP using skill-mcp-servers.md.'
Write-Host "  3. Add this path to Kun skill extraDirs: $RepoDir"
Write-Host ''
Write-Host 'Kun skill files:'
Get-ChildItem -LiteralPath $RepoDir -Filter 'skill-*.md' | ForEach-Object { Write-Host "  $($_.Name)" }
