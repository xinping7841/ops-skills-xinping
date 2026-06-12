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
    for ($i=0; $i -lt 5; $i++) {
        if ($result -match "More\s*$") {
            $port.Write(" ")
            Start-Sleep -Milliseconds 500
            try { while($true){ $result += [char][int]$port.ReadChar() } } catch {}
        } else { break }
    }
    return $result
}

Write-Host "=== 1. COMPLETE ROUTING TABLE ==="
send-cmd "screen-length disable" 1 | Out-Null
Write-Host (send-cmd "display ip routing-table" 4)

Write-Host "=== 2. PACKET FILTER ==="
Write-Host (send-cmd "display packet-filter" 2)

Write-Host "=== 3. TRACE to 223.5.5.5 ==="
Write-Host (send-cmd "tracert -q 1 223.5.5.5" 6)

Write-Host "=== 4. PING with source Vlan30 ==="
Write-Host (send-cmd "ping -a 192.168.30.1 -c 2 192.168.99.3" 3)

Write-Host "=== 5. iKuai MAC ARP ==="
Write-Host (send-cmd "display arp 192.168.99.3" 2)

$port.Close()
