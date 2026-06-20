param(
    [switch]$SkipPause
)

$ErrorActionPreference = 'Continue'

function Write-Step {
    param([string]$Message)
    Write-Host "`n== $Message ==" -ForegroundColor Cyan
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host 'This script must run as Administrator. Relaunching elevated...' -ForegroundColor Yellow
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    if ($SkipPause) { $argList += '-SkipPause' }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs
    exit
}

Write-Step 'Before: Tailscale processes'
Get-Process tailscaled,tailscale-ipn -ErrorAction SilentlyContinue |
    Select-Object ProcessName,Id,Path |
    Format-Table -AutoSize

Write-Step 'Restarting Tailscale service'
try {
    Stop-Service Tailscale -Force -ErrorAction Stop
    Start-Sleep -Seconds 3
} catch {
    Write-Host "Stop-Service failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Get-Process tailscaled -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

try {
    Start-Service Tailscale -ErrorAction Stop
    Start-Sleep -Seconds 8
} catch {
    Write-Host "Start-Service failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Step 'After: Tailscale service and processes'
Get-Service Tailscale | Format-Table -AutoSize Status,Name,DisplayName
Get-Process tailscaled,tails-ipn,tailscale-ipn -ErrorAction SilentlyContinue |
    Select-Object ProcessName,Id,Path |
    Format-Table -AutoSize

Write-Step 'Tailscale status'
tailscale status

Write-Step 'Tailscale netcheck'
tailscale netcheck

Write-Step 'Peer ping checks'
$peers = @(
    @{ Name = '12700K'; IP = '100.94.150.23' },
    @{ Name = 'node-121'; IP = '100.122.235.56' },
    @{ Name = 'aliyun-beijing'; IP = '100.97.0.61' }
)

foreach ($peer in $peers) {
    Write-Host "`n--- tailscale ping $($peer.Name) $($peer.IP) ---" -ForegroundColor Green
    tailscale ping --timeout=8s $peer.IP
}

Write-Step 'SSH probe to 12700K'
$key = Join-Path $env:USERPROFILE '.ssh\id_ed25519_nodes'
if (Test-Path -LiteralPath $key) {
    ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 -o BatchMode=yes gaoxi@100.94.150.23 "hostname; whoami"
} else {
    Write-Host "SSH key not found: $key" -ForegroundColor Yellow
}

Write-Host "`nDone. Leave this window open and send the output to Codex if anything still fails." -ForegroundColor Cyan
if (-not $SkipPause) {
    Read-Host 'Press Enter to close'
}
