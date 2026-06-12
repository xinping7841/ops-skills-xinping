$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 600
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

# Check if iKuai web is accessible from H3C
Write-Host "=== PING from H3C source Vlan30 ==="
Write-Host (send-cmd "ping -a 192.168.30.1 223.5.5.5" 5)

Write-Host "=== PING from H3C source Vlan99 ==="
Write-Host (send-cmd "ping -a 192.168.99.1 223.5.5.5" 5)

Write-Host "=== Check iKuai ARP entry MAC ==="
Write-Host (send-cmd "display arp | include 192.168.99" 2)

Write-Host "=== H3C MAC for Vlan99 ==="
Write-Host (send-cmd "display interface vlan 99" 2)

$port.Close()
