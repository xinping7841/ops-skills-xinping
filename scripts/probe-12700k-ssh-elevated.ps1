$ErrorActionPreference = 'Continue'

$repo = 'D:\Deepseek'
$logDir = Join-Path $repo '.sync-reports'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$log = Join-Path $logDir "probe-12700k-ssh-$stamp.log"
$latest = Join-Path $logDir 'probe-12700k-ssh-latest.log'

function Write-Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
}

function Run-Step {
    param([string]$Title, [scriptblock]$Block)
    Write-Log "== $Title =="
    try {
        & $Block 2>&1 | ForEach-Object { Write-Log ($_ | Out-String).TrimEnd() }
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    }
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Log "isAdmin=$isAdmin"

Run-Step 'tailscale status selected' { tailscale status | Select-String '12700|lk402|node-121|aliyun' }
Run-Step 'tailscale ping 12700K count 3' { tailscale ping --c 3 --timeout=8s 100.94.150.23 }
Run-Step 'tcp 12700K ssh port' { Test-NetConnection 100.94.150.23 -Port 22 -InformationLevel Detailed }

$keys = @(
    Join-Path $env:USERPROFILE '.ssh\id_ed25519_nodes',
    Join-Path $env:USERPROFILE '.ssh\codex_rdp_ed25519',
    Join-Path $env:USERPROFILE '.ssh\codex_rdp_rsa'
)

foreach ($key in $keys) {
    Run-Step "ssh probe with $key" {
        if (Test-Path -LiteralPath $key) {
            ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 -o BatchMode=yes gaoxi@100.94.150.23 "hostname; whoami"
        } else {
            "key not found: $key"
        }
    }
}

Copy-Item -LiteralPath $log -Destination $latest -Force
Write-Log "latestLog=$latest"
Write-Log 'DONE'
