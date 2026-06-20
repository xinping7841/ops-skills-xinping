$ErrorActionPreference = 'Continue'

$repo = 'D:\Deepseek'
$logDir = Join-Path $repo '.sync-reports'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$log = Join-Path $logDir "lk402-tailscale-repair-$stamp.log"
$latest = Join-Path $logDir 'lk402-tailscale-repair-latest.log'

function Write-Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
}

function Run-Step {
    param(
        [string]$Title,
        [scriptblock]$Block
    )
    Write-Log "== $Title =="
    try {
        & $Block 2>&1 | ForEach-Object { Write-Log ($_ | Out-String).TrimEnd() }
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    }
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Log "isAdmin=$isAdmin"
if (-not $isAdmin) {
    Write-Log 'Not elevated; exiting.'
    Copy-Item -LiteralPath $log -Destination $latest -Force
    exit 1
}

Run-Step 'before tailscale processes' {
    Get-Process tailscaled,tailscale-ipn -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,Path | Format-Table -AutoSize
}

Run-Step 'stop Tailscale service' {
    Stop-Service Tailscale -Force -ErrorAction Stop
    Start-Sleep -Seconds 3
}

Run-Step 'kill remaining tailscaled processes' {
    Get-Process tailscaled -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Run-Step 'start Tailscale service' {
    Start-Service Tailscale -ErrorAction Stop
    Start-Sleep -Seconds 10
}

Run-Step 'after Tailscale service and processes' {
    Get-Service Tailscale | Format-Table -AutoSize Status,Name,DisplayName
    Get-Process tailscaled,tailscale-ipn -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,Path | Format-Table -AutoSize
}

Run-Step 'tailscale status' { tailscale status }
Run-Step 'tailscale netcheck' { tailscale netcheck }

Run-Step 'tailscale ping 12700K' { tailscale ping --timeout=8s 100.94.150.23 }
Run-Step 'tailscale ping node-121' { tailscale ping --timeout=8s 100.122.235.56 }
Run-Step 'tailscale ping aliyun-beijing' { tailscale ping --timeout=8s 100.97.0.61 }

Run-Step 'ssh probe 12700K with id_ed25519_nodes' {
    $key = Join-Path $env:USERPROFILE '.ssh\id_ed25519_nodes'
    ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 -o BatchMode=yes gaoxi@100.94.150.23 "hostname; whoami"
}

Copy-Item -LiteralPath $log -Destination $latest -Force
Write-Log "latestLog=$latest"
Write-Log 'DONE'
