#!/bin/bash
set -e

echo "=== Adding routes to NM ==="
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.10.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.19.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.20.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.30.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.40.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.50.0/23 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.60.0/23 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.70.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.80.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.90.0/24 192.168.99.1"
sudo nmcli con mod lan-h3c-uplink +ipv4.routes "192.168.120.0/24 192.168.99.1"
echo "Routes added to NM"

echo "=== Adding FORWARD rules ==="
sudo iptables -A FORWARD -i enx6c1ff7016e7a -o enx9c69d31fc801 -j ACCEPT 2>/dev/null || true
sudo iptables -A FORWARD -i enx9c69d31fc801 -o enx6c1ff7016e7a -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

echo "=== Saving iptables ==="
sudo netfilter-persistent save

echo "=== Reapplying NM connection ==="
sudo nmcli con down lan-h3c-uplink 2>/dev/null || true
sudo nmcli con up lan-h3c-uplink

echo "=== Verify ==="
echo "Routes: $(ip route show | grep 'via 192.168.99.1' | wc -l)"
echo "FORWARD: $(sudo iptables -L FORWARD -n 2>/dev/null | grep enx | wc -l)"
echo "DONE"
