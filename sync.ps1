# sync.ps1 - Windows scheduled sync for the Deepseek ops skills repo

$ErrorActionPreference = 'Continue'
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $RepoDir 'sync.log'
$LockDir = Join-Path $RepoDir '.sync.lock'
$ReportDir = Join-Path $RepoDir '.sync-reports'

function Write-SyncLog {
    param([string]$Message)
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

function Exit-WithLockCleanup {
    param([int]$Code)
    if (Test-Path -LiteralPath $LockDir) {
        Remove-Item -LiteralPath $LockDir -Force -ErrorAction SilentlyContinue
    }
    exit $Code
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoDir '.git'))) {
    Write-SyncLog "ERROR: not a git repository: $RepoDir"
    exit 1
}

Set-Location -LiteralPath $RepoDir

try {
    New-Item -ItemType Directory -Path $LockDir -ErrorAction Stop | Out-Null
} catch {
    Write-SyncLog "SKIP: sync lock already exists: $LockDir"
    exit 0
}

$remote = (& git remote get-url origin 2>$null)
if ($remote -notmatch 'xinping7841[/\\]ops-skills-xinping') {
    Write-SyncLog "ERROR: unexpected origin remote: $remote"
    Exit-WithLockCleanup 1
}

function Add-CodexSkillConfig {
    param(
        [string]$SkillName,
        [string]$SkillPath
    )

    $config = Join-Path $env:USERPROFILE '.codex\config.toml'
    if (-not (Test-Path -LiteralPath $config)) { return }

    $pattern = '^\[skills\.' + [regex]::Escape($SkillName) + '\]'
    if (-not (Select-String -LiteralPath $config -Pattern $pattern -Quiet -ErrorAction SilentlyContinue)) {
        Add-Content -LiteralPath $config -Encoding UTF8 -Value ''
        Add-Content -LiteralPath $config -Encoding UTF8 -Value "[skills.$SkillName]"
        Add-Content -LiteralPath $config -Encoding UTF8 -Value ("path = '{0}'" -f $SkillPath)
        Write-SyncLog "Codex skill registered: $SkillName"
    }
}

function Link-CodexSkillForUi {
    param([string]$SkillName)

    $src = Join-Path $env:USERPROFILE ".codex\skills\$SkillName"
    $dst = Join-Path $env:USERPROFILE ".agents\skills\$SkillName"
    $agentsRoot = Join-Path $env:USERPROFILE '.agents\skills'

    if (-not (Test-Path -LiteralPath $src)) { return }
    New-Item -ItemType Directory -Path $agentsRoot -Force | Out-Null

    if (Test-Path -LiteralPath $dst) {
        $item = Get-Item -LiteralPath $dst -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $src) {
            # Already linked.
        } else {
            Write-SyncLog "WARN: .agents\skills already has skill, skipped link: $SkillName"
        }
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction Stop | Out-Null
            Write-SyncLog "Codex UI skill linked: $SkillName"
        } catch {
            Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
            Write-SyncLog "Codex UI skill copied: $SkillName"
        }
    }

    Add-CodexSkillConfig -SkillName $SkillName -SkillPath $src
}

function Sync-MarkdownSkill {
    param([string]$SkillMd)

    $codexDir = Join-Path $env:USERPROFILE '.codex'
    if (-not (Test-Path -LiteralPath $codexDir)) { return }

    $skillName = ([IO.Path]::GetFileNameWithoutExtension($SkillMd)) -replace '^skill-', ''
    $skillDir = Join-Path $codexDir "skills\$skillName"
    New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
    $firstLine = (Get-Content -LiteralPath $SkillMd -TotalCount 1 -Encoding UTF8) -replace '^# ', ''
    @"
---
name: $skillName
description: $firstLine
---

$(Get-Content -LiteralPath $SkillMd -Raw -Encoding UTF8)
"@ | Set-Content -LiteralPath (Join-Path $skillDir 'SKILL.md') -Force -Encoding UTF8
    Link-CodexSkillForUi -SkillName $skillName
}

function Sync-CodexSkillDir {
    param([string]$SkillSource)

    $codexDir = Join-Path $env:USERPROFILE '.codex'
    if (-not (Test-Path -LiteralPath $codexDir)) { return }

    $skillRoot = Join-Path $codexDir 'skills'
    New-Item -ItemType Directory -Path $skillRoot -Force | Out-Null
    $resolvedRoot = (Resolve-Path -LiteralPath $skillRoot).Path
    $skillName = Split-Path -Leaf $SkillSource
    $skillDest = Join-Path $skillRoot $skillName

    if (Test-Path -LiteralPath $skillDest) {
        $resolvedDest = (Resolve-Path -LiteralPath $skillDest).Path
        if (-not $resolvedDest.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-SyncLog "ERROR: refusing to remove unexpected skill path: $resolvedDest"
            Exit-WithLockCleanup 1
        }
        Remove-Item -LiteralPath $skillDest -Recurse -Force
    }

    Copy-Item -LiteralPath $SkillSource -Destination $skillDest -Recurse -Force
    Link-CodexSkillForUi -SkillName $skillName
}

function Deploy-RepoToLocal {
    $codexDir = Join-Path $env:USERPROFILE '.codex'
    $agentsSource = Join-Path $RepoDir 'AGENTS.md'
    if ((Test-Path -LiteralPath $agentsSource) -and (Test-Path -LiteralPath $codexDir)) {
        Copy-Item -LiteralPath $agentsSource -Destination (Join-Path $codexDir 'AGENTS.md') -Force
        Write-SyncLog 'Codex AGENTS.md refreshed.'
    }

    if (Test-Path -LiteralPath $codexDir) {
        Get-ChildItem -LiteralPath $RepoDir -Filter 'skill-*.md' -File | ForEach-Object {
            Sync-MarkdownSkill -SkillMd $_.FullName
        }

        $skillSourceRoot = Join-Path $RepoDir 'codex-skills'
        if (Test-Path -LiteralPath $skillSourceRoot) {
            Get-ChildItem -LiteralPath $skillSourceRoot -Directory | ForEach-Object {
                Sync-CodexSkillDir -SkillSource $_.FullName
            }
        }

        $skillRoot = Join-Path $codexDir 'skills'
        if (Test-Path -LiteralPath $skillRoot) {
            Get-ChildItem -LiteralPath $skillRoot -Directory | Where-Object {
                Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
            } | ForEach-Object {
                Link-CodexSkillForUi -SkillName $_.Name
            }
        }
    }
}

function Write-OrphanSkillReport {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    $safeMachine = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'windows' }
    $report = Join-Path $ReportDir ('skills-orphans-{0}-{1}.txt' -f $safeMachine, (Get-Date -Format 'yyyyMMdd-HHmmss'))

    $repoNames = New-Object System.Collections.Generic.HashSet[string]
    Get-ChildItem -LiteralPath $RepoDir -Filter 'skill-*.md' -File | ForEach-Object {
        [void]$repoNames.Add(($_.BaseName -replace '^skill-', ''))
    }
    $repoSkillRoot = Join-Path $RepoDir 'codex-skills'
    if (Test-Path -LiteralPath $repoSkillRoot) {
        Get-ChildItem -LiteralPath $repoSkillRoot -Directory | ForEach-Object {
            [void]$repoNames.Add($_.Name)
        }
    }

    $orphans = @()
    $localSkillRoot = Join-Path $env:USERPROFILE '.codex\skills'
    if (Test-Path -LiteralPath $localSkillRoot) {
        Get-ChildItem -LiteralPath $localSkillRoot -Directory | Where-Object {
            Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
        } | ForEach-Object {
            if (-not $repoNames.Contains($_.Name)) {
                $orphans += $_.Name
            }
        }
    }

    if ($orphans.Count -gt 0) {
        $orphans | Sort-Object -Unique | Set-Content -LiteralPath $report -Encoding UTF8
        Write-SyncLog "WARN: found $($orphans.Count) local Codex skills not in repo; report: $report"
    }
}

function Repair-CodexThreadIndex {
    $repairScript = Join-Path $RepoDir 'scripts\repair-codex-thread-index.ps1'
    if (-not (Test-Path -LiteralPath $repairScript)) { return }

    try {
        powershell -ExecutionPolicy Bypass -File $repairScript 2>&1 | ForEach-Object { Write-SyncLog $_ }
        if ($LASTEXITCODE -ne 0) {
            Write-SyncLog 'WARN: Codex thread index repair failed; continuing sync.'
        }
    } catch {
        Write-SyncLog "WARN: Codex thread index repair failed; continuing sync. $_"
    }
}

function Add-WhitelistedChanges {
    $files = @('AGENTS.md', '.gitattributes', '.gitignore', 'setup-mac.sh', 'setup-win.ps1', 'setup-codex-macos.sh', 'auto-sync.sh', 'sync.ps1', 'sync-hidden.vbs')
    foreach ($file in $files) {
        if (Test-Path -LiteralPath (Join-Path $RepoDir $file)) {
            & git add -- $file
        }
    }

    Get-ChildItem -LiteralPath $RepoDir -File | Where-Object {
        $_.Name -like 'skill-*.md' -or $_.Name -like 'codex-config-*.toml'
    } | ForEach-Object {
        & git add -- $_.Name
    }

    foreach ($dir in @('codex-skills', 'scripts', 'machine-profiles', 'mcp-templates')) {
        if (Test-Path -LiteralPath (Join-Path $RepoDir $dir)) {
            & git add -- $dir
        }
    }
}

Deploy-RepoToLocal
Write-OrphanSkillReport
Repair-CodexThreadIndex

Add-WhitelistedChanges
$cached = & git diff --cached --name-only
if ($cached) {
    $machine = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'windows' }
    $message = 'auto: sync from {0} {1}' -f $machine, (Get-Date -Format 'MM-dd HH:mm')
    Write-SyncLog 'committing whitelisted sync changes.'
    & git commit -m $message 2>&1 | ForEach-Object { Write-SyncLog $_ }
    if ($LASTEXITCODE -ne 0) { Exit-WithLockCleanup $LASTEXITCODE }
} else {
    Write-SyncLog 'no whitelisted local changes to commit.'
}

$untracked = & git status --porcelain --untracked-files=all | Where-Object { $_ -like '??*' }
if ($untracked) {
    Write-SyncLog 'INFO: untracked or non-whitelisted files left untouched:'
    $untracked | ForEach-Object { Write-SyncLog $_ }
}

Write-SyncLog 'pull --rebase...'
& git pull --rebase 2>&1 | ForEach-Object { Write-SyncLog $_ }
if ($LASTEXITCODE -ne 0) {
    Write-SyncLog 'ERROR: pull --rebase failed; manual conflict resolution required.'
    Exit-WithLockCleanup $LASTEXITCODE
}

Deploy-RepoToLocal
Write-OrphanSkillReport
Repair-CodexThreadIndex

$unpushed = & git log --branches --not --remotes --oneline
if ($unpushed) {
    & git push 2>&1 | ForEach-Object { Write-SyncLog $_ }
    if ($LASTEXITCODE -ne 0) { Exit-WithLockCleanup $LASTEXITCODE }
    Write-SyncLog 'push complete.'
} else {
    Write-SyncLog 'no commits to push.'
}

Exit-WithLockCleanup 0
