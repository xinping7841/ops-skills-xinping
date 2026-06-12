#!/bin/bash
echo "=== WAN NIC (enx9c69d31fc801) ==="
ethtool enx9c69d31fc801 2>/dev/null | grep -iE "speed|duplex|link|negot"
echo ""
echo "=== LAN NIC (enx6c1ff7016e7a) ==="
ethtool enx6c1ff7016e7a 2>/dev/null | grep -iE "speed|duplex|link|negot"
echo ""
echo "=== Routing ==="
ip route show default
echo ""
echo "=== CPU ==="
grep -c processor /proc/cpuinfo
echo "cores"
echo ""
echo "=== USB ==="
lsusb | grep -i "ethernet\|net\|realtek\|asix\|ax88"
echo ""
echo "=== iperf test to aliyun ==="
ping -c 4 223.5.5.5 -W 2 | tail -3
echo ""
echo "=== DNS test ==="
nslookup -timeout=2 baidu.com 223.5.5.5 2>&1 | head -3
