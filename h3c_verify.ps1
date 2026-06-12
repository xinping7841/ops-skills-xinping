$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 600
$port.Open()
Start-Sleep -Milliseconds 200

function send-cmd {
    param($cmd, $wait=3)
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

Write-Host "=== PING 223.5.5.5 ==="
Write-Host (send-cmd "ping -c 3 223.5.5.5" 6)

Write-Host "=== PING iKuai ==="
Write-Host (send-cmd "ping -c 2 192.168.99.3" 3)

$port.Close()
