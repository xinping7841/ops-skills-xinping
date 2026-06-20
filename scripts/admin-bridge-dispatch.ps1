$ErrorActionPreference = 'Continue'

$Repo = 'D:\Deepseek'
$ReportDir = Join-Path $Repo '.sync-reports'
$RequestPath = Join-Path $ReportDir 'admin-bridge-request.json'
$LogPath = Join-Path $ReportDir 'admin-bridge-latest.log'
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

Set-Content -LiteralPath $LogPath -Value '' -Encoding UTF8

function Write-Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
}

function Run-Step {
    param([string]$Title, [scriptblock]$Block)
    Write-Log "== $Title =="
    try {
        & $Block 2>&1 | ForEach-Object {
            $text = ($_ | Out-String).TrimEnd()
            if ($text) { Write-Log $text }
        }
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    }
}

function Invoke-Native {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 30
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    foreach ($arg in $Arguments) { [void]$psi.ArgumentList.Add($arg) }
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $process = [System.Diagnostics.Process]::Start($psi)
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        try { $process.Kill() } catch {}
        "TIMEOUT after ${TimeoutSeconds}s: $FilePath $($Arguments -join ' ')"
        return
    }
    $stdout = $process.StandardOutput.ReadToEnd().TrimEnd()
    $stderr = $process.StandardError.ReadToEnd().TrimEnd()
    if ($stdout) { $stdout }
    if ($stderr) { $stderr }
    "exitCode=$($process.ExitCode)"
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Repair-SshAcl {
    $sshDir = Join-Path $env:USERPROFILE '.ssh'
    $user = "$env:USERDOMAIN\$env:USERNAME"
    $paths = @(
        @{ Path = Join-Path $sshDir 'config'; Grant = 'M' },
        @{ Path = Join-Path $sshDir 'id_ed25519_nodes'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'id_ed25519_nodes.pub'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'codex_rdp_ed25519'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'codex_rdp_ed25519.pub'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'codex_rdp_rsa'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'codex_rdp_rsa.pub'; Grant = 'R' },
        @{ Path = Join-Path $sshDir 'known_hosts'; Grant = 'M' }
    )

    foreach ($item in $paths) {
        if (Test-Path -LiteralPath $item.Path) {
            icacls.exe $item.Path /grant "${user}:($($item.Grant))"
        } else {
            "missing: $($item.Path)"
        }
    }
}

function Repair-Tailscale {
    @(Get-Process tailscaled,tailscale-ipn -ErrorAction SilentlyContinue) | Select-Object ProcessName,Id,Path | Format-Table -AutoSize
    Stop-Service Tailscale -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Get-Process tailscaled -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Service Tailscale -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    Get-Service Tailscale | Format-Table -AutoSize Status,Name,DisplayName
    @(Get-Process tailscaled,tailscale-ipn -ErrorAction SilentlyContinue) | Select-Object ProcessName,Id,Path | Format-Table -AutoSize
}

function Probe-TailscaleAndSsh {
    tailscale status | Select-String 'lk402|12700|node-121|aliyun'
    tailscale netcheck
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('ping', '--c', '3', '--timeout=8s', '100.94.150.23') -TimeoutSeconds 35
    Test-NetConnection 100.94.150.23 -Port 22 -InformationLevel Detailed

    $keys = @(
        Join-Path $env:USERPROFILE '.ssh\id_ed25519_nodes',
        Join-Path $env:USERPROFILE '.ssh\codex_rdp_ed25519',
        Join-Path $env:USERPROFILE '.ssh\codex_rdp_rsa'
    )
    foreach ($key in $keys) {
        "--- ssh with $key ---"
        if (Test-Path -LiteralPath $key) {
            Invoke-Native -FilePath 'ssh.exe' -Arguments @('-i', $key, '-o', 'IdentitiesOnly=yes', '-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=8', '-o', 'BatchMode=yes', 'gaoxi@100.94.150.23', 'hostname; whoami') -TimeoutSeconds 20
        } else {
            "missing key: $key"
        }
    }
}

function Probe-Node121Via12700K {
    $keys = @(
        Join-Path $env:USERPROFILE '.ssh\id_ed25519_nodes',
        Join-Path $env:USERPROFILE '.ssh\codex_rdp_ed25519',
        Join-Path $env:USERPROFILE '.ssh\codex_rdp_rsa'
    )

    foreach ($key in $keys) {
        "--- 12700K jump probe with $key ---"
        if (Test-Path -LiteralPath $key) {
            Invoke-Native -FilePath 'ssh.exe' -Arguments @(
                '-i', $key,
                '-o', 'IdentitiesOnly=yes',
                '-o', 'StrictHostKeyChecking=accept-new',
                '-o', 'ConnectTimeout=8',
                '-o', 'BatchMode=yes',
                'gaoxi@100.94.150.23',
                'powershell -NoProfile -Command "hostname; whoami; Test-NetConnection 192.168.50.121 -Port 22; Test-NetConnection 192.168.50.121 -Port 18080"'
            ) -TimeoutSeconds 40
        } else {
            "missing key: $key"
        }
    }
}

$isAdmin = Test-Admin
Write-Log "isAdmin=$isAdmin"
if (-not $isAdmin) {
    Write-Log 'Admin bridge task is not elevated; aborting.'
    exit 1
}

$action = 'probe-12700k'
if (Test-Path -LiteralPath $RequestPath) {
    try {
        $request = Get-Content -LiteralPath $RequestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($request.action) { $action = [string]$request.action }
    } catch {
        Write-Log "Failed to parse request; using default action. $($_.Exception.Message)"
    }
}

Write-Log "action=$action"

switch ($action) {
    'fix-ssh-acl' { Run-Step 'fix SSH ACL' { Repair-SshAcl } }
    'repair-tailscale' { Run-Step 'repair Tailscale' { Repair-Tailscale } }
    'probe-12700k' { Run-Step 'probe Tailscale and SSH' { Probe-TailscaleAndSsh } }
    'probe-node121-via-12700k' { Run-Step 'probe node-121 via 12700K' { Probe-Node121Via12700K } }
    'all' {
        Run-Step 'fix SSH ACL' { Repair-SshAcl }
        Run-Step 'repair Tailscale' { Repair-Tailscale }
        Run-Step 'probe Tailscale and SSH' { Probe-TailscaleAndSsh }
    }
    default { Write-Log "Unsupported action: $action"; exit 2 }
}

Write-Log 'DONE'
