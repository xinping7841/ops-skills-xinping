$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 3000
$port.WriteTimeout = 1000

try {
    $port.Open()
    Write-Host "COM3 opened successfully at 9600-8-N-1"
    Start-Sleep -Milliseconds 500
    
    # Send Enter to wake up the switch
    $port.WriteLine("")
    Start-Sleep -Seconds 1
    
    # Read whatever is in the buffer
    $buf = ""
    try {
        while ($true) {
            $ch = $port.ReadChar()
            $buf += $ch
        }
    } catch {
        # timeout is expected
    }
    
    Write-Host "=== Response (raw) ==="
    Write-Host $buf
    
    if ($buf -match "H3C|HP|Comware|Huawei|Cisco|Ruijie|Juniper|Arista") {
        Write-Host "=== MATCH: Switch detected ==="
    } elseif ($buf.Length -gt 0) {
        Write-Host "=== Unknown device, got $($buf.Length) chars ==="
        # Try to show printable chars
        $printable = $buf -replace '[^\x20-\x7E\r\n]', '.'
        Write-Host $printable
    } else {
        Write-Host "=== No response (empty buffer) ==="
    }
    
    # Try different baud rates
    $port.Close()
    
    foreach ($baud in @(115200, 38400, 19200)) {
        $port2 = New-Object System.IO.Ports.SerialPort COM3,$baud,None,8,One
        $port2.ReadTimeout = 2000
        try {
            $port2.Open()
            Write-Host "Try $baud baud..."
            Start-Sleep -Milliseconds 300
            $port2.WriteLine("")
            Start-Sleep -Milliseconds 500
            $buf2 = ""
            try { while ($true) { $buf2 += $port2.ReadChar() } } catch {}
            if ($buf2.Length -gt 0) {
                Write-Host "Got response at $baud baud:"
                Write-Host ($buf2 -replace '[^\x20-\x7E\r\n]', '.')
            }
            $port2.Close()
        } catch {
            Write-Host "Error at $baud : $_"
        }
    }
    
} catch {
    Write-Host "COM3 open failed: $_"
} finally {
    if ($port.IsOpen) { $port.Close() }
}
