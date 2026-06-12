$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 800
$port.Open()
Start-Sleep -Milliseconds 300

# Flush buffer
try { while($true){$null=$port.ReadChar()} } catch {}

# Send display version command
$cmd = "display version`r"
$port.Write($cmd)
Start-Sleep -Seconds 3

$buf = ""
$chars = 0
try { 
    while($chars -lt 5000) { 
        $c = $port.ReadChar()
        $buf += [char][int]$c
        $chars++
    } 
} catch {}

# Convert to readable ASCII
$out = ""
foreach ($ch in $buf.ToCharArray()) {
    $code = [int]$ch
    if ($code -ge 32 -and $code -le 126) { $out += $ch }
    elseif ($code -eq 10) { $out += "`n" }
    elseif ($code -eq 13) { $out += "`r" }
}
Write-Host $out
$port.Close()
