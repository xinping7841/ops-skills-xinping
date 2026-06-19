<#
Repair Codex Windows sandbox local state.

Run this from a normal PowerShell outside Codex when shell_command fails before
running even trivial commands, for example:

  windows sandbox: helper_unknown_error: setup refresh had errors
  failed to read setup_error.json
  CreateProcessAsUserW failed: 5
  write ACE failed on D:\Deepseek: SetNamedSecurityInfoW failed: 5

Default mode is conservative: back up and recreate only ~/.codex/.sandbox.
Use -ApplyAcl if Access denied persists after a Codex restart.
Use -RepairWorkspaceAcl when sandbox logs show write ACE failures on D:\Deepseek.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$ApplyAcl,
    [switch]$RepairWorkspaceAcl,
    [string]$WorkspacePath = 'D:\Deepseek',
    [switch]$RepairSshConfigAcl
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE`: $FilePath $($Arguments -join ' ')"
    }
}

$codexHome = Join-Path $env:USERPROFILE '.codex'
$sandboxDir = Join-Path $codexHome '.sandbox'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Step 'Checking Codex home'
if (-not (Test-Path -LiteralPath $codexHome)) {
    throw "Codex home not found: $codexHome"
}

Write-Host "Codex home: $codexHome"
Write-Host "Sandbox:    $sandboxDir"

Write-Step 'Backing up stale sandbox state'
if (Test-Path -LiteralPath $sandboxDir) {
    $backupDir = Join-Path $codexHome ".sandbox.bak-$stamp"
    Move-Item -LiteralPath $sandboxDir -Destination $backupDir -Force
    Write-Host "Backed up old sandbox to: $backupDir"
} else {
    Write-Host 'No existing sandbox directory found.'
}

Write-Step 'Creating fresh sandbox directory'
New-Item -ItemType Directory -Path $sandboxDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $sandboxDir 'tmp') -Force | Out-Null
$sentinel = Join-Path $sandboxDir 'repair-check.txt'
Set-Content -LiteralPath $sentinel -Value "repaired $((Get-Date).ToString('s'))" -Encoding UTF8
Write-Host "Wrote sentinel: $sentinel"

if ($ApplyAcl) {
    Write-Step 'Applying ACL repair to Codex sandbox directory'
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Host "Current identity: $identity"
    Invoke-Checked icacls.exe @($sandboxDir, '/inheritance:e')
    Invoke-Checked icacls.exe @($sandboxDir, '/grant', "${identity}:(OI)(CI)F", '/T')
    Invoke-Checked icacls.exe @($codexHome, '/grant', "${identity}:(OI)(CI)RX")
}

if ($RepairWorkspaceAcl) {
    Write-Step "Applying ACL repair to workspace root: $WorkspacePath"
    if (-not (Test-Path -LiteralPath $WorkspacePath)) {
        throw "Workspace path not found: $WorkspacePath"
    }

    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Host "Current identity: $identity"

    # Keep this non-recursive. Codex setup only needs to update the workspace root
    # security descriptor; existing inherited child permissions can stay as they are.
    Invoke-Checked takeown.exe @('/F', $WorkspacePath, '/A')
    Invoke-Checked icacls.exe @($WorkspacePath, '/inheritance:e')
    Invoke-Checked icacls.exe @($WorkspacePath, '/grant', "${identity}:(F)")
    Invoke-Checked icacls.exe @($WorkspacePath, '/grant', 'BUILTIN\Administrators:(F)')
    Invoke-Checked icacls.exe @($WorkspacePath, '/grant', 'SYSTEM:(F)')
    Invoke-Checked icacls.exe @($WorkspacePath, '/grant', 'CodexSandboxUsers:(OI)(CI)(M,DC)')
    Write-Host 'Workspace ACL after repair:'
    & icacls.exe $WorkspacePath
}

if ($RepairSshConfigAcl) {
    Write-Step 'Applying optional ACL repair to ~/.ssh/config'
    $sshConfig = Join-Path $env:USERPROFILE '.ssh\config'
    if (Test-Path -LiteralPath $sshConfig) {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        Invoke-Checked icacls.exe @($sshConfig, '/inheritance:e')
        Invoke-Checked icacls.exe @($sshConfig, '/grant', "${identity}:R")
    } else {
        Write-Host "SSH config not found: $sshConfig"
    }
}

Write-Step 'Testing ordinary process creation'
$outFile = Join-Path $env:TEMP "codex-sandbox-repair-$stamp.out"
$errFile = Join-Path $env:TEMP "codex-sandbox-repair-$stamp.err"
$proc = Start-Process -FilePath 'powershell.exe' `
    -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', 'Write-Output codex-sandbox-repair-process-ok') `
    -Wait -PassThru -WindowStyle Hidden `
    -RedirectStandardOutput $outFile `
    -RedirectStandardError $errFile

if ($proc.ExitCode -ne 0) {
    Write-Host 'stdout:' -ForegroundColor Yellow
    if (Test-Path -LiteralPath $outFile) { Get-Content -LiteralPath $outFile }
    Write-Host 'stderr:' -ForegroundColor Yellow
    if (Test-Path -LiteralPath $errFile) { Get-Content -LiteralPath $errFile }
    throw "Ordinary process creation test failed with exit code $($proc.ExitCode)."
}

Get-Content -LiteralPath $outFile

Write-Step 'Done'
Write-Host 'Now fully quit and reopen Codex, then run a trivial shell test such as: Write-Output OK' -ForegroundColor Green
Write-Host 'If sandbox logs show write ACE failed on D:\Deepseek, rerun this script with -RepairWorkspaceAcl from an elevated PowerShell.' -ForegroundColor Green
