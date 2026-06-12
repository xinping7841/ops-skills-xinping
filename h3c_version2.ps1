$port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,One
$port.ReadTimeout = 1000
$port.Open()

# Wait for switch to be ready
Start-Sleep -Milliseconds 500

# Drain any pending input
try { while($true){$null=$port.ReadChar()} } catch {}

# Send command with a small preamble
$port.Write("`r")
Start-Sleep -Milliseconds 200
try { while($true){$null=$port.ReadChar()} } catch {}

# Now send the real command
$cmd = "display version`r"
foreach ($ch in $cmd.ToCharArray()) {
    $port.Write([string]$ch)
    Start-Sleep -Milliseconds 5
}

Start-Sleep -Seconds 4

$raw = ""
try { while($true){ $raw += [char][int]$port.ReadChar() } } catch {}
$port.Close()

Write-Host $raw
