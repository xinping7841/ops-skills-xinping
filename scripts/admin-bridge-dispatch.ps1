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
        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Log $_.InvocationInfo.PositionMessage
        }
    }
}

function Invoke-Native {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 30
    )

    function Quote-Arg {
        param([string]$Value)
        if ($Value -notmatch '[\s"]') { return $Value }
        return '"' + ($Value -replace '"', '\"') + '"'
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = ($Arguments | ForEach-Object { Quote-Arg $_ }) -join ' '
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
    'before processes:'
    $before = @(Get-Process -Name tailscaled,tailscale-ipn -ErrorAction SilentlyContinue)
    if ($before.Count -eq 0) {
        'no tailscale processes found before repair'
    } else {
        foreach ($process in $before) { "$($process.ProcessName) pid=$($process.Id)" }
    }

    'stopping Tailscale service'
    Stop-Service -Name Tailscale -Force -ErrorAction Continue
    Start-Sleep -Seconds 3

    'killing remaining tailscaled processes'
    $remaining = @(Get-Process -Name tailscaled -ErrorAction SilentlyContinue)
    foreach ($process in $remaining) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            "stopped pid=$($process.Id)"
        } catch {
            "failed to stop pid=$($process.Id): $($_.Exception.Message)"
        }
    }
    Start-Sleep -Seconds 2

    'starting Tailscale service'
    Start-Service -Name Tailscale -ErrorAction Continue
    Start-Sleep -Seconds 10

    $service = Get-Service -Name Tailscale -ErrorAction Continue
    "service status=$($service.Status) name=$($service.Name)"

    'after processes:'
    $after = @(Get-Process -Name tailscaled,tailscale-ipn -ErrorAction SilentlyContinue)
    if ($after.Count -eq 0) {
        'no tailscale processes found after repair'
    } else {
        foreach ($process in $after) { "$($process.ProcessName) pid=$($process.Id)" }
    }
}

function Probe-TailscaleAndSsh {
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('status') -TimeoutSeconds 20
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('netcheck') -TimeoutSeconds 30
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('ping', '--c', '3', '--timeout=8s', '100.94.150.23') -TimeoutSeconds 35
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('ping', '--c', '2', '--timeout=5s', '100.122.235.56') -TimeoutSeconds 20
    Invoke-Native -FilePath 'tailscale.exe' -Arguments @('ping', '--c', '2', '--timeout=5s', '100.97.0.61') -TimeoutSeconds 20
    Invoke-Native -FilePath 'powershell.exe' -Arguments @('-NoProfile', '-Command', 'Test-NetConnection 100.94.150.23 -Port 22 -InformationLevel Quiet') -TimeoutSeconds 35

    $sshDir = Join-Path $env:USERPROFILE '.ssh'
    $keys = @(
        (Join-Path $sshDir 'id_ed25519_nodes'),
        (Join-Path $sshDir 'codex_rdp_ed25519'),
        (Join-Path $sshDir 'codex_rdp_rsa')
    )
    foreach ($key in $keys) {
        "--- ssh with $key ---"
        if (Test-Path -LiteralPath $key) {
            Invoke-Native -FilePath 'ssh.exe' -Arguments @('-i', $key, '-o', 'IdentitiesOnly=yes', '-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=8', '-o', 'BatchMode=yes', 'gaoxi@100.94.150.23', 'hostname & whoami') -TimeoutSeconds 20
        } else {
            "missing key: $key"
        }
    }
}

function Probe-Node121Via12700K {
    $sshDir = Join-Path $env:USERPROFILE '.ssh'
    $keys = @(
        (Join-Path $sshDir 'id_ed25519_nodes'),
        (Join-Path $sshDir 'codex_rdp_ed25519'),
        (Join-Path $sshDir 'codex_rdp_rsa')
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

function Test-WithMetaDisabled {
    $meta = Get-NetAdapter -Name 'Meta' -ErrorAction SilentlyContinue
    if (-not $meta) {
        'Meta adapter not found; running probe without adapter change.'
        Probe-TailscaleAndSsh
        return
    }

    "Meta adapter status before=$($meta.Status) ifIndex=$($meta.ifIndex)"
    try {
        if ($meta.Status -ne 'Disabled') {
            'disabling Meta adapter'
            Disable-NetAdapter -Name 'Meta' -Confirm:$false -ErrorAction Stop
            Start-Sleep -Seconds 5
        }

        'forcing Tailscale rebind after Meta change'
        Invoke-Native -FilePath 'tailscale.exe' -Arguments @('debug', 'rebind') -TimeoutSeconds 15
        Start-Sleep -Seconds 3

        'routes while Meta is disabled:'
        Invoke-Native -FilePath 'route.exe' -Arguments @('print', '100.94.150.23') -TimeoutSeconds 15

        Probe-TailscaleAndSsh
    } finally {
        $current = Get-NetAdapter -Name 'Meta' -ErrorAction SilentlyContinue
        if ($current -and $current.Status -eq 'Disabled') {
            're-enabling Meta adapter'
            Enable-NetAdapter -Name 'Meta' -Confirm:$false -ErrorAction Continue
            Start-Sleep -Seconds 5
        }
        $restored = Get-NetAdapter -Name 'Meta' -ErrorAction SilentlyContinue
        if ($restored) { "Meta adapter status after=$($restored.Status)" }
    }
}

function Update-AdminAuthorizedKeys {
    param($Request)

    if (-not $Request.key) {
        throw 'Request is missing key.'
    }

    $key = [string]$Request.key
    if ($key -notmatch '^ssh-ed25519\s+[A-Za-z0-9+/=]+\s+.+$') {
        throw 'Only ssh-ed25519 public keys are supported by this bridge action.'
    }

    $file = 'C:\ProgramData\ssh\administrators_authorized_keys'
    if (-not (Test-Path -LiteralPath $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }

    $removeKeys = @()
    if ($Request.removeKeys) {
        $removeKeys = @($Request.removeKeys | ForEach-Object { [string]$_ })
    }

    $lines = @(Get-Content -LiteralPath $file -ErrorAction SilentlyContinue) |
        Where-Object { $_ -and ($removeKeys -notcontains $_) }

    if ($lines -contains $key) {
        'key already present'
    } else {
        $lines += $key
        'key added'
    }

    Set-Content -LiteralPath $file -Encoding ascii -Value $lines
    icacls.exe $file /inheritance:r /grant 'SYSTEM:(R)' /grant 'BUILTIN\Administrators:(R)'
    Restart-Service sshd -ErrorAction SilentlyContinue

    $tmp = New-TemporaryFile
    try {
        Set-Content -LiteralPath $tmp -Encoding ascii -Value $key
        ssh-keygen.exe -l -f $tmp
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
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
    'test-with-meta-disabled' { Run-Step 'test with Meta adapter disabled' { Test-WithMetaDisabled } }
    'update-admin-authorized-keys' { Run-Step 'update admin authorized_keys' { Update-AdminAuthorizedKeys -Request $request } }
    'all' {
        Run-Step 'fix SSH ACL' { Repair-SshAcl }
        Run-Step 'repair Tailscale' { Repair-Tailscale }
        Run-Step 'probe Tailscale and SSH' { Probe-TailscaleAndSsh }
    }
    default { Write-Log "Unsupported action: $action"; exit 2 }
}

Write-Log 'DONE'
