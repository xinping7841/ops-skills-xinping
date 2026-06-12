$tcp = New-Object System.Net.Sockets.TcpClient
$tcp.Connect("192.168.99.3", 23)
$stream = $tcp.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)
$writer.AutoFlush = $true

Start-Sleep -Milliseconds 500
# Read banner
$buf = ""
try {
    while ($stream.DataAvailable -or $buf.Length -lt 200) {
        if ($stream.DataAvailable) {
            $c = $reader.Read()
            if ($c -ge 0) { $buf += [char]$c }
        } else { Start-Sleep -Milliseconds 100; break }
    }
    Write-Host "BANNER: $buf"
} catch { Write-Host "Read error: $_" }

# Try login
$writer.WriteLine("root")
Start-Sleep -Milliseconds 500
$buf = ""
try {
    while ($stream.DataAvailable) { $c = $reader.Read(); if ($c -ge 0) { $buf += [char]$c } }
    Write-Host "AFTER USER: $buf"
} catch {}

$tcp.Close()
