$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 1200
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
    # Handle More pagination
    for ($i=0; $i -lt 8; $i++) {
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

# 1. Interface status - critical to see link state
Write-Host "=== DISPLAY INTERFACE BRIEF ==="
Write-Host (send-cmd "display interface brief" 3)

# 2. VLAN brief
Write-Host "=== DISPLAY VLAN BRIEF ==="
Write-Host (send-cmd "display vlan brief" 3)

# 3. IP interfaces
Write-Host "=== DISPLAY IP INTERFACE BRIEF ==="
Write-Host (send-cmd "display ip interface brief" 3)

# 4. Routing table
Write-Host "=== DISPLAY IP ROUTING-TABLE ==="
Write-Host (send-cmd "display ip routing-table" 3)

# 5. Check trunk link to iKuai
Write-Host "=== DISPLAY CURRENT-CONFIGURATION INTERFACE ==="
Write-Host (send-cmd "display current-configuration interface" 4)

# 6. DHCP relay config
Write-Host "=== DISPLAY DHCP RELAY ==="
Write-Host (send-cmd "display dhcp relay information" 2)

# 7. Ping test
Write-Host "=== PING 192.168.1.1 ==="
Write-Host (send-cmd "ping -c 3 192.168.1.1" 5)

$port.Close()
