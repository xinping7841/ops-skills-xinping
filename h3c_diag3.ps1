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

# Just 3 critical commands
Write-Host "=== 1. GE1/0/1 STATUS ==="
Write-Host (send-cmd "display interface g1/0/1" 3)

Write-Host "=== 2. PING iKuai ==="
Write-Host (send-cmd "ping 192.168.99.3" 5)

Write-Host "=== 3. ARP for 192.168.99.3 ==="
Write-Host (send-cmd "display arp | include 192.168.99" 2)

Write-Host "=== 4. VLAN 99 member ports ==="
Write-Host (send-cmd "display vlan 99" 2)

Write-Host "=== 5. GE1/0/2 STATUS ==="
Write-Host (send-cmd "display interface g1/0/2" 3)

$port.Close()
