# Shenlan WAN2 Default And DNS Adjustment - 2026-06-18 09:50

## Context

On 2026-06-18 morning, users again reported short Internet disconnects. The local Mac was temporarily wired directly into the ADWAN network and also connected to the local Wi-Fi network. During live router work, avoid using the direct ADWAN wired path as the management path; use the local Wi-Fi path or another inside-management path.

## Evidence

- The Mac on VLAN16 previously showed stable reachability to OpenWrt (`192.168.99.3`) with no packet loss, while WAN/public HTTP tests intermittently failed.
- OpenWrt itself saw intermittent public HTTP failures across multiple targets, so the issue was not isolated to one client or VLAN16 cabling.
- OpenWrt logged `dnsmasq: Maximum number of concurrent DNS queries reached (max: 150)` around the incident window.
- OpenWrt control-plane ICMP to H3C gateway addresses showed latency spikes, but OpenWrt to the Mac client was sub-millisecond and stable, so H3C ICMP spikes were treated as control-plane behavior rather than conclusive forwarding failure.

## Changes Applied

OpenWrt default routing was changed so WAN2/direct optical modem is the global default:

```text
network.wan.metric='30'
network.wan2.metric='10'
```

WAN1/SDWAN was retained in routing table `100` for marked traffic:

```text
network.shenlan_wan1_default=route
network.shenlan_wan1_default.interface='wan'
network.shenlan_wan1_default.target='0.0.0.0/0'
network.shenlan_wan1_default.gateway='192.168.77.1'
network.shenlan_wan1_default.table='100'
network.shenlan_foreign_wan1_rule=rule
network.shenlan_foreign_wan1_rule.mark='0x1/0xffffffff'
network.shenlan_foreign_wan1_rule.lookup='100'
network.shenlan_foreign_wan1_rule.priority='10000'
```

The current route validation after the change:

```text
ip route get 220.181.111.1
-> via 192.168.201.1 dev eth2

ip route get 140.82.116.4 mark 0x1
-> via 192.168.77.1 dev eth1 table 100
```

DNS was changed to Beijing Telecom, with only the reachable server retained:

```text
dhcp.@dnsmasq[0].server='219.141.136.10'
dhcp.@dnsmasq[0].noresolv='1'
dhcp.@dnsmasq[0].dnsforwardmax='500'
dhcp.@dnsmasq[0].filter_aaaa='1'
```

Reason for keeping only `219.141.136.10`: `219.141.140.10` timed out from the current path during live tests.

## Foreign-Domain WAN1 Policy State

A manual nft mark set was added for foreign-domain resolved IPv4 destinations:

```text
/etc/nftables.d/20-shenlan-foreign-wan1.nft
/root/shenlan-usage/policy/foreign-wan1-domains.txt
/root/shenlan-usage/bin/update-foreign-wan1-set.sh
```

Important caveat: the installed dnsmasq binary reports `no-ipset no-nftset`, so dnsmasq cannot dynamically populate nft/ipset sets itself. A helper script was used to periodically resolve starter foreign domains and fill the nft set. That cron refresh was disabled after it appeared to contribute to DNS pressure:

```text
# disabled:
*/5 * * * * /root/shenlan-usage/bin/update-foreign-wan1-set.sh >/dev/null 2>&1
```

The nft set may still contain the last populated addresses, but it will not automatically track fast-changing DNS answers until a safer resolver-driven policy method is implemented.

## Current Caveats

- Beijing Telecom DNS may return China-specific answers for some foreign services. Example observed: LinkedIn resolved through `linkedin.cn` / Azure Beijing path. This may not match the original goal of routing foreign services through WAN1.
- A true DNS-based policy routing design should use either a dnsmasq build with nftset/ipset support, `pbr` with supported resolver integration, or a dedicated China/foreign routing list workflow.
- During the change window, client tests improved intermittently but still showed occasional HTTP timeouts. Continue observing before calling the issue resolved.

## Rollback

A rollback helper was created on OpenWrt:

```text
/root/shenlan-usage/bin/rollback-wan2-default-foreign-wan1.sh
```

It restores WAN1 as preferred default, disables the foreign nft snippet, removes the policy route/rule, removes the DNS forward max override, stops the foreign refresh cron, and reloads firewall/dnsmasq/network.

Backups were saved under:

```text
/root/shenlan-usage/backups/pre-wan2-default-foreign-wan1-*
/root/shenlan-usage/backups/pre-beijing-telecom-dns-*
```

## Recommended Next Step

Observe user experience for 15-30 minutes with:

1. WAN2 as global default.
2. Beijing Telecom DNS `219.141.136.10`.
3. Foreign-domain nft refresh disabled.

If domestic sites stabilize but foreign services route poorly or resolve to domestic special endpoints, replace the current ad hoc foreign routing with a proper dnsmasq-nftset-capable resolver or `pbr` policy design.
