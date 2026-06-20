$ErrorActionPreference = 'Stop'

$Repo = 'D:\Deepseek'
$ReportDir = Join-Path $Repo '.sync-reports'
$InstallLog = Join-Path $ReportDir 'admin-bridge-install.log'
$TaskName = 'Deepseek-Admin-Bridge'
$Script = Join-Path $Repo 'scripts\admin-bridge-dispatch.ps1'

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

function Write-InstallLog {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -LiteralPath $InstallLog -Value $line -Encoding UTF8
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Set-Content -LiteralPath $InstallLog -Value '' -Encoding UTF8
Write-InstallLog "isAdmin=$(Test-Admin)"
if (-not (Test-Admin)) {
    throw 'Run this installer as Administrator.'
}

if (-not (Test-Path -LiteralPath $Script)) {
    throw "Admin bridge script not found: $Script"
}

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$Script`""
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).Date.AddHours(23).AddMinutes(59))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -MultipleInstances IgnoreNew

Write-InstallLog "Registering task $TaskName"
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null

$requestPath = Join-Path $ReportDir 'admin-bridge-request.json'
Set-Content -LiteralPath $requestPath -Value '{"action":"probe-12700k"}' -Encoding UTF8

Write-InstallLog 'Starting initial bridge probe'
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 2

$task = Get-ScheduledTask -TaskName $TaskName
Write-InstallLog "taskState=$($task.State)"

Write-InstallLog 'Installed successfully.'
Write-InstallLog "requestPath=$requestPath"
Write-InstallLog "bridgeLog=$(Join-Path $ReportDir 'admin-bridge-latest.log')"
