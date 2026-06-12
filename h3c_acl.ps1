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
    for ($i=0; $i -lt 8; $i++) {
        if ($result -match "More\s*$") {
            $port.Write(" ")
            Start-Sleep -Milliseconds 500
            try { while($true){ $result += [char][int]$port.ReadChar() } } catch {}
        } else { break }
    }
    return $result
}

send-cmd "screen-length disable" 1 | Out-Null

Write-Host "=== FULL ACL 3300 ==="
Write-Host (send-cmd "display acl 3300" 3)

Write-Host "=== WHERE IS ACL 3300 APPLIED ==="
Write-Host (send-cmd "display current-configuration | include 3300" 3)

Write-Host "=== CHECK TRAFFIC-FILTER ON GE1/0/23 ==="
Write-Host (send-cmd "display current-configuration interface g1/0/23" 2)

$port.Close()
