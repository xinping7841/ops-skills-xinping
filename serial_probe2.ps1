Write-Host "=== Processes using COM3 ==="
$handles = handle64 -a COM3 -accepteula 2>$null
if (-not $handles) { 
    # Try to find via CMD
    cmd /c 'handle -a COM3 -accepteula 2>nul'
}

Write-Host "=== Check if any terminal emu running ==="
Get-Process | Where-Object { $_.ProcessName -match "putty|securecrt|xshell|mobaxterm|teraterm|serial" } | Select ProcessName, Id, MainWindowTitle

Write-Host "=== Try 9600 more carefully ==="
Add-Type -AssemblyName System.IO.Ports
$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 500
$port.Open()
Start-Sleep -Milliseconds 200
# Flush any pending
try { while($true){$null=$port.ReadChar()} } catch {}
# Send CR
$port.Write([char]13)
Start-Sleep -Seconds 2
$buf = ""
try { while($true){$buf+=$port.ReadChar()} } catch {}
Write-Host "9600 response length: $($buf.Length)"
Write-Host ($buf -replace '[^\x20-\x7E\r\n]','.')
$port.Close()

Write-Host "=== Try 115200 more carefully ===" 
$port = New-Object System.IO.Ports.SerialPort COM3,115200,None,8,One
$port.ReadTimeout = 500
$port.Open()
Start-Sleep -Milliseconds 200
try { while($true){$null=$port.ReadChar()} } catch {}
$port.Write([char]13)
Start-Sleep -Seconds 2
$buf = ""
try { while($true){$buf+=$port.ReadChar()} } catch {}
Write-Host "115200 response length: $($buf.Length)"
Write-Host ($buf -replace '[^\x20-\x7E\r\n]','.')
$port.Close()

Write-Host "=== Done ==="
