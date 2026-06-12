#!/bin/bash
set -e
# Remove old IP
sudo ip addr del 192.168.77.225/24 dev enx6c1ff7016e7a 2>/dev/null || true

# Add routes to H3C subnets
sudo ip route add 192.168.10.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.19.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.20.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.30.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.40.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.50.0/23 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.60.0/23 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.70.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.80.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.90.0/24 via 192.168.99.1 2>/dev/null || true
sudo ip route add 192.168.120.0/24 via 192.168.99.1 2>/dev/null || true

echo "ROUTES_DONE"
ip route show | grep "via 192.168.99.1"
