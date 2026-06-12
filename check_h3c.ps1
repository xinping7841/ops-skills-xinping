Write-Host "=== COM Ports ==="
Get-CimInstance Win32_SerialPort | Select DeviceID, Name, MaxBaudRate | Format-Table

Write-Host "=== COM3 Status ==="
[System.IO.Ports.SerialPort]::GetPortNames()

Write-Host "=== Looking for terminal configs ==="
$putty = "HKCU:\Software\SimonTatham\PuTTY\Sessions"
if (Test-Path $putty) {
    Write-Host "--- PuTTY Sessions ---"
    Get-ChildItem $putty | ForEach-Object { $_.PSChildName }
}

$scrt = "$env:APPDATA\VanDyke\SecureCRT\Sessions"
if (Test-Path $scrt) {
    Write-Host "--- SecureCRT Sessions ---"
    Get-ChildItem $scrt | ForEach-Object { $_.Name }
}

Write-Host "=== Done ==="
