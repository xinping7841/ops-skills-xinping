#!/bin/bash
set -e
echo "=== Persisting NAT Gateway Config ==="

# 1. Fix default route (remove stale ones, keep ONT)
sudo ip route del default via 192.168.50.1 2>/dev/null || true
sudo ip route del default via 192.168.77.1 2>/dev/null || true

# 2. Configure LAN interface (enx6c1ff7016e7a) with static IP via nmcli
LAN_IF="enx6c1ff7016e7a"

# Remove any old NM connections for this interface
for conn in $(nmcli -t -f UUID,DEVICE con show | grep "$LAN_IF" | cut -d: -f1); do
    sudo nmcli con delete "$conn" 2>/dev/null || true
done

# Create new static connection
sudo nmcli con add type ethernet ifname "$LAN_IF" con-name "lan-h3c-uplink" \
    ipv4.method manual \
    ipv4.addresses 192.168.99.3/24 \
    ipv4.never-default yes \
    connection.autoconnect yes

sudo nmcli con up "lan-h3c-uplink" 2>/dev/null || true

echo "NM connection created: lan-h3c-uplink"

# 3. Add static routes via nmcli
ROUTES="192.168.10.0/24,192.168.19.0/24,192.168.20.0/24,192.168.30.0/24,192.168.40.0/24"
ROUTES="$ROUTES,192.168.50.0/23,192.168.60.0/23,192.168.70.0/24,192.168.80.0/24"
ROUTES="$ROUTES,192.168.90.0/24,192.168.120.0/24"

ROUTE_STR=""
for r in ${ROUTES//,/ }; do
    ROUTE_STR="$ROUTE_STR ipv4.routes \"$r 192.168.99.1\""
done

eval sudo nmcli con mod "lan-h3c-uplink" $ROUTE_STR

echo "Routes added to NM connection"

# 4. Enable ip_forward permanently
if ! grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p /etc/sysctl.conf

# 5. Save iptables rules
# Install iptables-persistent if not present
if ! dpkg -l iptables-persistent 2>/dev/null | grep -q "^ii"; then
    echo "Installing iptables-persistent..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent 2>/dev/null || true
fi

# Ensure NAT rules are present
sudo iptables -t nat -C POSTROUTING -o enx9c69d31fc801 -j MASQUERADE 2>/dev/null || \
    sudo iptables -t nat -A POSTROUTING -o enx9c69d31fc801 -j MASQUERADE

sudo iptables -C FORWARD -i enx6c1ff7016e7a -o enx9c69d31fc801 -j ACCEPT 2>/dev/null || \
    sudo iptables -A FORWARD -i enx6c1ff7016e7a -o enx9c69d31fc801 -j ACCEPT

sudo iptables -C FORWARD -i enx9c69d31fc801 -o enx6c1ff7016e7a -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
    sudo iptables -A FORWARD -i enx9c69d31fc801 -o enx6c1ff7016e7a -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save rules
sudo netfilter-persistent save 2>/dev/null || sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

echo ""
echo "=== VERIFICATION ==="
echo "NM connections:"
nmcli con show | grep lan-h3c
echo ""
echo "Routes:"
ip route show | grep "via 192.168.99.1"
echo ""
echo "iptables NAT:"
sudo iptables -t nat -L POSTROUTING -n | grep MASQUERADE
echo ""
echo "=== DONE ==="
