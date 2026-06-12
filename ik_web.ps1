$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Step 1: Get login page to get any needed tokens
$login = Invoke-WebRequest -Uri "http://192.168.99.3" -TimeoutSec 5 -UseBasicParsing -SessionVariable s

# Step 2: Try to login with different methods
$methods = @(
    @{uri="/Action/login"; body="username=admin&passwd=shenlan.123&remember=0"},
    @{uri="/Action/login"; body="username=admin&passwd=shenlan.123"},
    @{uri="/index.php/Action/login"; body="username=admin&passwd=shenlan.123"}
)

foreach ($m in $methods) {
    try {
        $r = Invoke-WebRequest -Uri "http://192.168.99.3$($m.uri)" -Method POST -Body $m.body -ContentType "application/x-www-form-urlencoded" -TimeoutSec 5 -UseBasicParsing -WebSession $s
        Write-Host "Method $($m.uri): $($r.StatusCode) Len=$($r.Content.Length)"
        if ($r.Content -match "success|ok|跳转|redirect|登录成功") {
            Write-Host "LOGIN SUCCESS with $($m.uri)!"
            
            # Try to access NAT page
            $natPages = @("/NAT", "/Action/nat", "/index.php/NAT", "/network/nat", "/System/nat")
            foreach ($np in $natPages) {
                try {
                    $nr = Invoke-WebRequest -Uri "http://192.168.99.3$np" -TimeoutSec 5 -UseBasicParsing -WebSession $s
                    Write-Host "NAT page $np : $($nr.StatusCode) Len=$($nr.Content.Length)"
                    if ($nr.Content -match "NAT|nat|转发|SNAT") {
                        Write-Host "FOUND NAT CONTENT!"
                        Write-Host $nr.Content.Substring(0, [Math]::Min(1000, $nr.Content.Length))
                    }
                } catch {
                    Write-Host "NAT $np : $($_.Exception.Message.Substring(0,80))"
                }
            }
            break
        }
    } catch {
        Write-Host "Method $($m.uri): $($_.Exception.Message.Substring(0,80))"
    }
}
