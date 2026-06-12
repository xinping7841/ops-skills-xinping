$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 1000
$port.Open()
Start-Sleep -Milliseconds 300

function send-cmd {
    param($cmd, $wait=2)
    try { while($true){$null=$port.ReadChar()} } catch {}
    foreach ($ch in ($cmd + "`r").ToCharArray()) {
        $port.Write([string]$ch)
        Start-Sleep -Milliseconds 3
    }
    Start-Sleep -Seconds $wait
    $result = ""
    try { while($true){ $result += [char][int]$port.ReadChar() } } catch {}
    for ($i=0; $i -lt 10; $i++) {
        if ($result -match "More\s*$") {
            $port.Write(" ")
            Start-Sleep -Milliseconds 600
            try { while($true){ $result += [char][int]$port.ReadChar() } } catch {}
        } else { break }
    }
    return $result
}

# Disable pagination
$null = send-cmd "screen-length disable"

# 1. Complete interface brief (bridge mode) to see physical ports
Write-Host "=== 1. ALL INTERFACES (BRIDGE) ==="
Write-Host (send-cmd "display interface brief" 4)

# 2. Ping iKuai on transit VLAN
Write-Host "=== 2. PING iKuai (192.168.99.3) ==="
Write-Host (send-cmd "ping -c 4 192.168.99.3" 6)

# 3. ARP table
Write-Host "=== 3. ARP TABLE ==="
Write-Host (send-cmd "display arp" 4)

# 4. DHCP server config
Write-Host "=== 4. DHCP SERVER ==="
Write-Host (send-cmd "display dhcp server ip-pool" 4)

# 5. Trunk port config
Write-Host "=== 5. TRUNK PORTS ==="
Write-Host (send-cmd "display port trunk" 3)

# 6. Ping external
Write-Host "=== 6. PING 223.5.5.5 ==="
Write-Host (send-cmd "ping -c 3 223.5.5.5" 6)

# 7. Check last reboot reason / logs
Write-Host "=== 7. LOG BUFFER (last 20) ==="
Write-Host (send-cmd "display logbuffer reverse level 3" 4)

$port.Close()
