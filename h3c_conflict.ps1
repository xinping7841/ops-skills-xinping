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

Write-Host "=== CHECK FOR DUPLICATE IPs ==="
Write-Host (send-cmd "display arp | include 192.168.99.1" 2)
Write-Host (send-cmd "display arp | include 192.168.99.3" 2)

Write-Host "=== CHECK H3C MAC TABLE for iKuai MAC ==="
Write-Host (send-cmd "display mac-address 60be-b423-60f7" 2)

Write-Host "=== CHECK IF ANOTHER DEVICE HAS 192.168.99.3 ==="
Write-Host (send-cmd "display arp all | include 192.168.99" 2)

Write-Host "=== PHYSICAL PORTS STATUS ==="
Write-Host (send-cmd "display interface brief | include GE1" 3)

Write-Host "=== CHECK VLAN 99 interface counters ==="
Write-Host (send-cmd "display interface vlan 99" 2)

$port.Close()
