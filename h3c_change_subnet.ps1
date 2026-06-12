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

# ENTER system-view to change config
Write-Host "=== Entering system-view ==="
send-cmd "system-view" 2 | Out-Null

# Change VLAN 99 IP
Write-Host "=== Changing VLAN 99 IP to 192.168.100.1 ==="
Write-Host (send-cmd "interface vlan 99" 1)
Write-Host (send-cmd "ip address 192.168.100.1 24" 1)

# Change default route
Write-Host "=== Changing default route ==="
Write-Host (send-cmd "undo ip route-static 0.0.0.0 0 192.168.99.3" 1)
Write-Host (send-cmd "ip route-static 0.0.0.0 0 192.168.100.3" 1)

# Verify
Write-Host "=== Verify new config ==="
Write-Host (send-cmd "display ip interface brief | include Vlan99" 1)
Write-Host (send-cmd "display ip routing-table | include 0.0.0.0/0" 1)

# Exit system-view
send-cmd "return" 1 | Out-Null

$port.Close()
