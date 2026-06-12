$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 800
$port.Open()
Start-Sleep -Milliseconds 200

function send-cmd {
    param($cmd, $wait=2)
    try { while($true){$null=$port.ReadChar()} } catch {}
    foreach ($ch in ($cmd + "`r").ToCharArray()) {
        $port.Write([string]$ch)
        Start-Sleep -Milliseconds 2
    }
    Start-Sleep -Seconds $wait
    $result = ""
    try { while($true){ $result += [char][int]$port.ReadChar() } } catch {}
    return $result
}

Write-Host "=== GE1/0/23 CONFIG ==="
Write-Host (send-cmd "display current-configuration interface g1/0/23" 3)

Write-Host "=== GE1/0/23 STATUS ==="
Write-Host (send-cmd "display interface g1/0/23" 3)

Write-Host "=== H3C Current Running Config (filtered) ==="
Write-Host (send-cmd "display current-configuration | include nat|acl|filter|firewall" 2)

$port.Close()
