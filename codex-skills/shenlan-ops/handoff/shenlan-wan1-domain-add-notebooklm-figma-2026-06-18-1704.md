# Shenlan WAN1 Domain Policy Additions - NotebookLM And Figma

Updated: 2026-06-18 17:04 Asia/Shanghai

## Summary

Added two user-requested sites to the existing conservative overseas/AI WAN1 policy:

```text
notebooklm.google
figma.com
```

This did not enable OpenClash and did not activate broad non-China routing. WAN2 remains the global default route; these domains use the existing dnsmasq-full + nftset + fwmark policy path to WAN1.

## Changes Applied On OpenWrt

Added DNS upstream exceptions in:

```text
/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf
```

New lines:

```text
server=/notebooklm.google/192.168.77.1
server=/figma.com/192.168.77.1
```

Added domains to the nftset population list:

```text
dhcp.shenlan_foreign_wan1_nftset.domain += notebooklm.google
dhcp.shenlan_foreign_wan1_nftset.domain += figma.com
```

Restarted dnsmasq after the changes.

## Verification

Local dnsmasq resolution succeeded:

```text
notebooklm.google -> 216.239.32.27
www.figma.com -> 52.222.244.51, 52.222.244.27, 52.222.244.111, 52.222.244.91
```

All returned IPv4 addresses were verified present in:

```text
inet fw4 shenlan_foreign_wan1_v4
```

Policy route remains active:

```text
fwmark 0x1 -> table 100 -> default via 192.168.77.1 dev eth1
```

## Rollback

Remove these two `server=/.../192.168.77.1` lines from `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf`, remove the two domain values from `dhcp.shenlan_foreign_wan1_nftset.domain`, commit `dhcp`, and restart dnsmasq.
