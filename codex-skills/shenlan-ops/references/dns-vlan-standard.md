# Shenlan DNS/VLAN Standard Baseline

Updated: 2026-06-17 15:20 Asia/Shanghai

Primary human-readable document:

```text
D:\IDE\AI\network-ops\handoff\shenlan-dns-vlan-standard-2026-06-17.md
```

Primary machine-readable document:

```text
D:\IDE\AI\network-ops\inventory\shenlan-network-standard.json
```

## Current DNS Standard

```text
Client DNS: 192.168.99.3
OpenWrt upstream DNS: 192.168.77.1
Avoid WAN2/optical-modem DNS 192.168.201.1 for client DNS because it resolved www.linkedin.com to the .cn chain.
OpenWrt DNS interception for TCP/UDP 53 from lan is active.
```

Verified:

```text
nslookup www.linkedin.com 192.168.99.3
www.linkedin.com -> 104.18.41.41 / 172.64.146.215
```

## Device Roles

```text
H3C core 192.168.99.1: internal L3 gateway and DHCP server.
OpenWrt 192.168.99.3: egress/NAT/QoS/DNS/policy-routing/monitoring.
ER5200G3 192.168.99.4: AC/MiniAP controller, router mode, ordinary DHCP disabled.
```

## Important Warning

Do not modify Chinese-named H3C DHCP pools through raw SSH/console input. Encoding previously created garbled or partial pool names. Use H3C Web/API or manual Web UI edits for old DHCP pool DNS cleanup.

## Latest Backups

```text
D:\IDE\AI\network-ops\backups\h3c-current-config-dns-standard-20260617-151348.txt
D:\IDE\AI\network-ops\backups\openwrt\openwrt-dns-standard-20260617-150738.tar.gz
```
