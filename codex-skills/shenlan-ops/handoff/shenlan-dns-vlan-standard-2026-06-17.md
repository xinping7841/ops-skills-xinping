# Shenlan DNS, VLAN and Routing Standard

Updated: 2026-06-17 15:20 Asia/Shanghai

This document is the current operational baseline after the LinkedIn DNS issue was fixed. It is intended for later agents, scripts, and handoff to other machines.

## Current Principle

- H3C core switch remains the internal L3 gateway and DHCP server for VLAN clients.
- OpenWrt `192.168.99.3` remains the main egress, NAT, QoS, DNS control, monitoring and policy-routing point.
- ER5200G3 remains in router mode only as AC/MiniAP controller. Its ordinary DHCP is disabled.
- DNS for all internal clients should ultimately point to OpenWrt `192.168.99.3`.
- WAN2 optical modem DNS must not be used as normal client DNS because it resolves `www.linkedin.com` to the `.cn` chain.

## DNS Standard

| Item | Standard Value | Status | Notes |
|---|---|---|---|
| Authoritative LAN DNS | `192.168.99.3` | Active | OpenWrt dnsmasq |
| OpenWrt upstream DNS | `192.168.77.1` | Active | WAN1/SDWAN gateway, currently clean for LinkedIn |
| OpenWrt WAN2 upstream DNS | Avoid for client DNS | Active by policy | WAN2 gateway `192.168.201.1` caused LinkedIn `.cn` resolution |
| H3C DHCP DNS target | `192.168.99.3` | Partially standardized | New/ASCII pools are correct; older Chinese-named pools still show public DNS |
| DNS interception | TCP/UDP 53 from LAN to OpenWrt | Active | Protects clients even if DHCP hands out old DNS |

Verified result:

```text
nslookup www.linkedin.com 192.168.99.3
www.linkedin.com -> 104.18.41.41 / 172.64.146.215
```

OpenWrt effective config:

```text
dhcp.@dnsmasq[0].noresolv='1'
dhcp.@dnsmasq[0].server='192.168.77.1'
firewall.dns_hijack_tcp: Force-LAN-DNS-to-OpenWrt-TCP, src lan, tcp/53, DNAT
firewall.dns_hijack_udp: Force-LAN-DNS-to-OpenWrt-UDP, src lan, udp/53, DNAT
```

## H3C VLAN Baseline

| VLAN | Description | Gateway | DHCP/DNS Status | Notes |
|---:|---|---|---|---|
| 1 | Default / legacy | `192.168.0.233` via DHCP | Not standardized | Keep only for legacy/rescue, do not use for new business |
| 10 | office | `192.168.10.1/24` | DHCP exists, old DNS shown | Office wired |
| 11 | reserved room A | `192.168.11.1/24`, shutdown | DNS `192.168.99.3` | Reserved/room trunk on GE1/0/21 and XGE1/0/28 |
| 12 | reserved room B | `192.168.12.1/24`, shutdown | DNS `192.168.99.3` | Reserved/room trunk on GE1/0/21 and XGE1/0/28 |
| 13 | reserved room C | `192.168.13.1/24`, shutdown | DNS `192.168.99.3` | Reserved/room trunk on GE1/0/21 and XGE1/0/28 |
| 16 | reserved/historical | `192.168.16.1/24` | DNS `192.168.99.3` | Need business owner confirmation |
| 17 | reserved/historical | `192.168.17.1/24` | DNS `192.168.99.3` | Need business owner confirmation |
| 18 | reserved/historical | `192.168.18.1/24` | DNS `192.168.99.3` | Need business owner confirmation |
| 19 | Reception | `192.168.19.1/24` | DHCP exists, old DNS shown | Reception |
| 20 | Wifi Control | `192.168.20.1/24` | DHCP exists, old DNS shown | AP/AC management |
| 30 | NAS | `192.168.30.1/24` | DHCP exists, old DNS shown | NAS/storage |
| 40 | NVR | `192.168.40.1/24` | DHCP pool exists, interface DHCP server disabled | Monitoring/NVR network |
| 50 | Exhibition | `192.168.50.1/23` | H3C DHCP disabled | Servers, central control, NTP/SNMP targets |
| 60 | Wifi | `192.168.60.1/23` | DHCP exists, old DNS shown | Wireless clients |
| 70 | Workshop | `192.168.70.1/24` | DHCP pool exists, interface DHCP server disabled | Workshop |
| 80 | Number 2 | `192.168.80.1/24` | DHCP exists, old DNS shown | Hall 2 |
| 90 | XR | `192.168.90.1/24` | DHCP pool exists, interface DHCP server disabled | XR studio |
| 99 | Switch Control | `192.168.99.1/24` | No client DHCP | Core/OpenWrt/AC management transit |
| 110 | reserved | `192.168.110.1/24`, down | Empty pool | Reserved/historical |
| 120 | Free-DHCP-VLAN120 | `192.168.120.1/24` | DHCP DNS `192.168.99.3` | Free test ports GE1/0/20,22,23,24 |
| 201 | reserved/special | `172.16.201.254/24`, down | H3C DHCP disabled | Historical/special path |

## H3C Port Baseline

| Port | Link | Mode | VLAN/PVID | Description | Notes |
|---|---|---|---|---|---|
| GE1/0/1 | UP | Access | 99 | none | VLAN99 access |
| GE1/0/2 | DOWN | Access | 50 | TO-Server-50.121 | Ops server target port |
| GE1/0/3 | UP | Trunk | PVID 20, permit 20/60 | none | Wireless/AP trunk |
| GE1/0/4 | UP | Trunk | PVID 20, permit 20/60/99 | none | Wireless/AP/rescue trunk |
| GE1/0/5 | UP | Access | 40 | none | NVR |
| GE1/0/6 | UP | Access | 40 | none | NVR |
| GE1/0/7 | UP 100M | Access | 30 | none | NAS/storage, check 100M link if unexpected |
| GE1/0/8 | UP | Access | 50 | TO-ShowRoom-Control-50.120 | Central control/NTP/SNMP trap target |
| GE1/0/9-16 | UP | Access | 50 | mostly none | Exhibition/server VLAN |
| GE1/0/17 | UP | Access | 70 | none | Workshop |
| GE1/0/18 | UP | Access | 80 | none | Hall 2 |
| GE1/0/19 | UP | Access | 19 | none | Reception |
| GE1/0/20 | DOWN | Access | 120 | VLAN120-Free-DHCP | Free DHCP port |
| GE1/0/21 | DOWN | Trunk | PVID 1, permit 1/10/11/12/13 | TO-SKS3200-Room | Do not overwrite; room switch trunk |
| GE1/0/22 | DOWN | Access | 120 | VLAN120-Free-DHCP | Free DHCP port |
| GE1/0/23 | DOWN | Access | 120 | VLAN120-Free-DHCP | Free DHCP port |
| GE1/0/24 | UP | Access | 120 | VLAN120-Free-DHCP | Free DHCP port in use |
| XGE1/0/25 | DOWN | Access | 10 | none | Office wired 10G spare/down |
| XGE1/0/26 | UP 10G | Access | 90 | none | XR |
| XGE1/0/27 | UP 10G | Access | 30 | none | NAS/storage |
| XGE1/0/28 | UP 1G | Trunk | PVID 1, permit 1/10-13/16-18/99 | TO-Huawei5130 | Downstream Huawei switch trunk |

## Static Routing and Policy Notes

H3C active default route:

```text
0.0.0.0/0 -> 192.168.99.3 via Vlan99
```

OpenWrt must keep static return routes for all H3C VLANs via `192.168.99.1`.

Existing H3C PBR entries reference next hop `172.16.201.1` for selected VLAN30/VLAN50 traffic. Treat these as historical/special rules and do not remove without confirming the business owner.

## Known Gaps To Fix Later

1. Older H3C DHCP pools with Chinese/garbled names still show public DNS `223.5.5.5 119.29.29.29`.
2. Do not edit Chinese-named DHCP pools through raw SSH/console input; prior attempts created bad garbled pools because of encoding.
3. Preferred long-term fix is H3C Web/API update of pool DNS to `192.168.99.3`, or manual Web UI edit by user.
4. DNS interception already protects production traffic, so this is not urgent unless clients bypass OpenWrt by DoH/DoT.
5. Vlan-interface10 still has IPv6 DHCP/RA config. If IPv6 should stay disabled everywhere, clean this in a planned maintenance window.
6. H3C global DNS is still `114.114.114.114`; this affects the switch itself, not normal clients. Consider changing to `192.168.99.3` or `192.168.50.120` later.

## Latest Backup

H3C read-only config snapshot:

```text
D:\IDE\AI\network-ops\backups\h3c-current-config-dns-standard-20260617-151348.txt
```

OpenWrt DNS standard backup:

```text
D:\IDE\AI\network-ops\backups\openwrt\openwrt-dns-standard-20260617-150738.tar.gz
```
