#!/bin/bash
# Proper speed test
echo "=== Testing from node-121 (ONT) ==="

# Install perf tools
sudo apt-get install -y iperf3 netperf 2>/dev/null | tail -1

# Speedtest with specific China servers (Telecom)
speedtest-cli --server 3633 2>/dev/null && echo "SPEEDTEST_DONE" 

# If that fails, try iperf3
if [ $? -ne 0 ]; then
    echo "Using iperf3 fallback..."
    # Download test file from aliyun
    curl -s -o /dev/null -w "Aliyun download: %{speed_download} Bytes/sec\n" \
        --max-time 10 http://speed.aliyun.com/upload/100m 2>/dev/null
    
    # Or test via simple download
    curl -s -o /dev/null -w "Baidu download: %{speed_download} Bytes/sec\n" \
        --max-time 10 https://dldir1.qq.com/qqfile/qq/TIM3.5.0/TIM3.5.0.22042.exe 2>/dev/null
fi

echo "=== Check iptables counters ==="
sudo iptables -L FORWARD -n -v | head -3
