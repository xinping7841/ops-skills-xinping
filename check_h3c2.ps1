Write-Host "=== Check if plink/putty installed ==="
Get-Command plink -ErrorAction SilentlyContinue | Select Source
Get-Command putty -ErrorAction SilentlyContinue | Select Source

Write-Host "=== Try H3C-related files ==="
Get-ChildItem C:\Users\gaoxi\ -Recurse -Filter "*h3c*" -ErrorAction SilentlyContinue | Select FullName
Get-ChildItem C:\Users\gaoxi\ -Recurse -Filter "*switch*" -ErrorAction SilentlyContinue | Select FullName
Get-ChildItem C:\Users\gaoxi\ -Recurse -Filter "*console*" -ErrorAction SilentlyContinue | Select FullName

Write-Host "=== Check common terminal software install paths ==="
foreach ($dir in @("C:\Program Files\PuTTY", "C:\Program Files (x86)\PuTTY", "C:\Program Files\VanDyke Software", "C:\Program Files\NetSarang")) {
    if (Test-Path $dir) { Write-Host "Found: $dir" }
}
Write-Host "=== Done ==="
