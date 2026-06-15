# sync.ps1 - Windows scheduled sync for the Deepseek ops skills repo

$ErrorActionPreference = 'Continue'
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $RepoDir 'sync.log'

function Write-SyncLog {
    param([string]$Message)
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoDir '.git'))) {
    Write-SyncLog "ERROR: not a git repository: $RepoDir"
    exit 1
}

Set-Location -LiteralPath $RepoDir

$CodexDir = Join-Path $env:USERPROFILE '.codex'
$AgentsSource = Join-Path $RepoDir 'AGENTS.md'
if ((Test-Path -LiteralPath $AgentsSource) -and (Test-Path -LiteralPath $CodexDir)) {
    Copy-Item -LiteralPath $AgentsSource -Destination (Join-Path $CodexDir 'AGENTS.md') -Force
    Write-SyncLog 'Codex AGENTS.md refreshed.'
}

$SkillSource = Join-Path $RepoDir 'codex-skills\ops-terminal-sync'
$SkillDest = Join-Path $CodexDir 'skills\ops-terminal-sync'
if ((Test-Path -LiteralPath $SkillSource) -and (Test-Path -LiteralPath $CodexDir)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $SkillDest) -Force | Out-Null
    if (Test-Path -LiteralPath $SkillDest) {
        $ResolvedSkillsRoot = (Resolve-Path -LiteralPath (Join-Path $CodexDir 'skills')).Path
        $ResolvedSkillDest = (Resolve-Path -LiteralPath $SkillDest).Path
        if (-not $ResolvedSkillDest.StartsWith($ResolvedSkillsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-SyncLog "ERROR: refusing to remove unexpected skill path: $ResolvedSkillDest"
            exit 1
        }
        Remove-Item -LiteralPath $SkillDest -Recurse -Force
    }
    Copy-Item -LiteralPath $SkillSource -Destination $SkillDest -Recurse -Force
    Write-SyncLog 'Codex skill ops-terminal-sync refreshed.'
}

$status = & git status --porcelain
if ($status) {
    Write-SyncLog 'local changes detected; committing before pull...'
    & git add -A 2>&1 | ForEach-Object { Write-SyncLog $_ }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $machine = $env:COMPUTERNAME
    $message = 'auto: sync from {0} {1}' -f $machine, (Get-Date -Format 'MM-dd HH:mm')
    & git commit -m $message 2>&1 | ForEach-Object { Write-SyncLog $_ }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} else {
    Write-SyncLog 'no local changes before pull.'
}

Write-SyncLog 'pull --rebase...'
& git pull --rebase 2>&1 | ForEach-Object { Write-SyncLog $_ }
if ($LASTEXITCODE -ne 0) {
    Write-SyncLog 'ERROR: pull --rebase failed; manual conflict resolution required.'
    exit $LASTEXITCODE
}

$unpushed = & git log --branches --not --remotes --oneline
if ($unpushed) {
    & git push 2>&1 | ForEach-Object { Write-SyncLog $_ }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-SyncLog 'push complete.'
} else {
    Write-SyncLog 'no commits to push.'
}
