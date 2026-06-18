# Shenlan DNS Full Upgrade And WAN1 Foreign Split

Time: 2026-06-18 10:15 Asia/Shanghai

## Summary

OpenWrt DNS was upgraded from the minimal `dnsmasq` package to `dnsmasq-full` after the user requested the full version so clients no longer need frequent manual DNS changes. The router now keeps WAN2/direct optical modem as the global default route, while foreign-domain DNS answers are inserted into an nftables set and marked for WAN1/ADWAN policy routing.

## Important Access Note

During changes, use the wireless/local management path, not the wired ADWAN path:

```bash
ssh -b 192.168.60.74 -i ~/.ssh/id_ed25519_nodes -o IdentitiesOnly=yes root@192.168.99.3
```

## Package Repair

An earlier online `apk add dnsmasq-full smartdns ...` attempt was interrupted after purging the old `dnsmasq`, leaving `/usr/sbin/dnsmasq` and `/etc/init.d/dnsmasq` missing while the apk database still listed `dnsmasq`.

Recovery was done by downloading official OpenWrt packages on macair and copying them to `/tmp/shenlan-dns-repair/` on OpenWrt:

- `dnsmasq-full-2.93-r1.apk`
- `libnetfilter-conntrack3-1.1.0-r1.apk`
- `libnfnetlink0-1.0.2-r1.apk`
- `libgmp10-6.3.0-r2.apk`
- `libnettle8-3.10.2-r1.apk`

Installed with local package files:

```sh
apk add --allow-untrusted --force-overwrite /tmp/shenlan-dns-repair/lib*.apk /tmp/shenlan-dns-repair/dnsmasq-full-2.93-r1.apk
```

`--allow-untrusted` was used only because these were local files copied from macair after HTTPS download from the official OpenWrt release directory. The router could not reliably fetch packages itself while DNS was broken.

Verified:

```text
Dnsmasq version 2.93
Compile time options: ... DHCP DHCPv6 ... TFTP conntrack no-ipset nftset auth DNSSEC ...
```

## Current DNS Config

OpenWrt remains the client-facing DNS endpoint:

```text
192.168.99.3
```

UCI dnsmasq key settings:

```text
noresolv=1
filter_aaaa=1
cachesize=4000
dnsforwardmax=800
allservers=1
server=219.141.136.10
server=192.168.77.1
```

Beijing Telecom `219.141.136.10` was retained, but it timed out during the 10:10 router-side test. `192.168.77.1` answered normally and is used both as fallback and as the specific upstream for foreign domains.

Foreign domains from `/root/shenlan-usage/policy/foreign-wan1-domains.txt` are configured as:

```text
server=/github.com/192.168.77.1
server=/openai.com/192.168.77.1
...
nftset=/.../4#inet#fw4#shenlan_foreign_wan1_v4
```

The UCI section is:

```text
dhcp.shenlan_foreign_wan1_nftset=ipset
dhcp.shenlan_foreign_wan1_nftset.name='shenlan_foreign_wan1_v4'
dhcp.shenlan_foreign_wan1_nftset.table='fw4'
dhcp.shenlan_foreign_wan1_nftset.table_family='inet'
dhcp.shenlan_foreign_wan1_nftset.family='4'
```

Although the UCI section type is `ipset`, `dnsmasq-full` on this build has `no-ipset nftset`; OpenWrt's init script ignores unsupported `--ipset` and emits the valid `--nftset`.

## Routing Policy

Default route remains WAN2:

```text
network.wan.metric='30'
network.wan2.metric='10'
```

Marked traffic uses WAN1 table 100:

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

The nftables policy set and marking chain are in `/etc/nftables.d/20-shenlan-foreign-wan1.nft`:

```nft
set shenlan_foreign_wan1_v4 {
	type ipv4_addr
	flags interval
	auto-merge
	comment "DNS-resolved foreign destinations routed via WAN1"
}

chain shenlan_mark_foreign_wan1 {
	type filter hook prerouting priority mangle - 10; policy accept;
	iifname { "br-lan", "eth3.99" } ip daddr @shenlan_foreign_wan1_v4 meta mark set 0x1 comment "Shenlan foreign-domain policy -> WAN1"
}
```

DNS interception was re-enabled so clients do not need manual DNS settings:

```text
firewall.dns_hijack_tcp.enabled deleted
firewall.dns_hijack_udp.enabled deleted
```

Active rules were verified:

```text
tcp dport 53 redirect to :53 comment "!fw4: Force-LAN-DNS-to-OpenWrt-TCP"
udp dport 53 redirect to :53 comment "!fw4: Force-LAN-DNS-to-OpenWrt-UDP"
```

## Verification

Router-side DNS:

```text
nslookup github.com 127.0.0.1 -> 140.82.116.3
nslookup www.baidu.com 127.0.0.1 -> 220.181.111.1 / 220.181.111.232
```

Route checks:

```text
ip route get 220.181.111.1
220.181.111.1 via 192.168.201.1 dev eth2 src 192.168.201.108

ip route get 140.82.116.3 mark 0x1
140.82.116.3 via 192.168.77.1 dev eth1 table 100 src 192.168.77.197 mark 1
```

Firewall:

```text
fw4 check -> Ruleset passes nftables check.
```

The nft set `inet fw4 shenlan_foreign_wan1_v4` was populated by DNS answers after resolving foreign domains.

## Caveats

- macair wireless management network could SSH and ping `192.168.99.3`, but direct DNS queries from macair to `192.168.99.3:53` timed out. This appears to be cross-management-path policy behavior, not a dnsmasq failure. Router-side DNS and LAN DNS interception were verified.
- `219.141.136.10` timed out during one router-side test. Keep `192.168.77.1` fallback until Beijing Telecom DNS stability is proven from OpenWrt.
- The old cron-based helper for resolving foreign domains should remain disabled. `dnsmasq-full` now maintains the nft set directly.

## WAN Check And Tools Added

At about 2026-06-18 10:20, extra troubleshooting tools were installed on OpenWrt:

```text
curl
ethtool-full
mtr-json
tcpdump-mini
```

WAN interface check:

```text
WAN1 eth1: 192.168.77.197/24, gateway 192.168.77.1, link 2500Mb/s full duplex, link detected yes
WAN2 eth2: 192.168.201.108/24, gateway 192.168.201.1, link 1000Mb/s full duplex, link detected yes
```

Both upstream gateways were healthy:

```text
ping -I eth1 192.168.77.1 -> 0% loss, about 0.3 ms
ping -I eth2 192.168.201.1 -> 0% loss, about 0.6 ms
```

Driver stats showed no CRC, carrier, collision, or link-layer errors on either WAN port. WAN1 had a small historical `rx_fifo_errors` count, but no current interface-level `rx_errors/tx_errors`. WAN2 had cumulative `rx_dropped`, but driver error counters stayed clean.

HTTP/TLS checks with `curl --interface`:

```text
eth1 -> https://github.com/  HTTP/2 200
eth2 -> https://www.baidu.com/ HTTP/1.1 200 OK
eth2 -> https://github.com/  HTTP/2 200
eth1 -> https://www.baidu.com/ timed out
```

Interpretation: both WAN links are physically up and usable. WAN2 is the better domestic/default path. WAN1/ADWAN is usable for foreign HTTPS targets such as GitHub, but is not a good domestic default path, matching the current policy design.

## Foreign Site Split Check

At about 2026-06-18 10:30, the user provided a site list to verify local access and DNS split behavior:

```text
Pinterest
Youtube
Instagram
Facebook
Linkedin
Google Analytics 4
Gemini
Claude
Chatgpt
Google
Reddit
Discord
```

Initial check found that Pinterest and Reddit were not in `/root/shenlan-usage/policy/foreign-wan1-domains.txt`. The following domains were added and dnsmasq UCI/nftset config was regenerated:

```text
pinterest.com
pinimg.com
reddit.com
redd.it
redditstatic.com
redditmedia.com
```

After restart, all requested primary domains were configured for foreign split and resolved IPs routed via WAN1 under mark `0x1`:

```text
pinterest.com          configured=yes -> eth1 via 192.168.77.1
youtube.com            configured=yes -> eth1 via 192.168.77.1
instagram.com          configured=yes -> eth1 via 192.168.77.1
facebook.com           configured=yes -> eth1 via 192.168.77.1
linkedin.com           configured=yes -> eth1 via 192.168.77.1
analytics.google.com   configured=yes -> eth1 via 192.168.77.1
gemini.google.com      configured=yes -> eth1 via 192.168.77.1
claude.ai              configured=yes -> eth1 via 192.168.77.1
chatgpt.com            configured=yes -> eth1 via 192.168.77.1
google.com             configured=yes -> eth1 via 192.168.77.1
reddit.com             configured=yes -> eth1 via 192.168.77.1
discord.com            configured=yes -> eth1 via 192.168.77.1
```

Local macair caveat: at the time of the test, macair's default route was direct wired ADWAN:

```text
default -> 192.168.77.1 on en6
```

That path bypasses OpenWrt's client-side DNS interception and nft marking, so local Mac browser/curl tests are useful for ADWAN reachability but not a pure test of OpenWrt split policy.

Observed reachability:

- Google was OK on WAN1 after testing with browser user-agent / HTTP/1.1: `www.google.com` returned `200`, `generate_204` returned `204`.
- Youtube, Instagram, Facebook, Google Analytics, Gemini, Claude, ChatGPT, Reddit, and Discord returned an HTTP response from local Mac and/or OpenWrt WAN1 tests. Several returned `403`, which is expected for some SaaS/WAF endpoints and does not indicate DNS split failure.
- Pinterest remained abnormal on both local direct ADWAN and OpenWrt WAN tests. DNS split is now configured correctly, but HTTPS ended with TLS EOF or timeout. Treat Pinterest as an upstream/ADWAN reachability issue rather than a DNS split miss.

## Domestic Stability Priority Change

Time: 2026-06-18 10:55 Asia/Shanghai

User decided to prioritize stable domestic access for wired and wireless clients. WAN1/SDWAN is currently not reliable enough to solve foreign access, so it was removed from the client DNS dependency path.

OpenWrt remains the client-facing DNS endpoint:

```text
192.168.99.3
```

dnsmasq upstreams were changed to domestic-only DNS with parallel fastest-response behavior:

```text
server=223.5.5.5
server=119.29.29.29
server=114.114.114.114
all-servers
no-resolv
filter-AAAA
cache-size=4000
dns-forward-max=800
```

Removed from dnsmasq `server` list for now:

```text
192.168.77.1
219.141.136.10
server=/foreign-domain/192.168.77.1 rules
```

Reason:

- `192.168.77.1` is WAN1/SDWAN and should not affect domestic stability.
- `219.141.136.10` repeatedly timed out from OpenWrt.
- `192.168.201.1` returned an incomplete result for `www.baidu.com` during one test, so it was not kept as the primary client DNS upstream.
- Domestic DNS repeated tests succeeded after enabling `allservers=1` with only `223.5.5.5`, `119.29.29.29`, and `114.114.114.114`.

WAN routing remains:

```text
default via 192.168.201.1 dev eth2 metric 10
default via 192.168.77.1 dev eth1 metric 30
```

Wired VLAN120 test after the DNS change:

```text
192.168.120.2 -> domestic sites: 5 repeated rounds succeeded
OpenWrt eth2 -> domestic sites: succeeded
```

Wireless VLAN60 test after the DNS change:

```text
192.168.60.74 -> domestic DNS: OK
192.168.60.74 -> domestic sites: mostly OK, but periodic 2.5-5s TCP connect stalls remained
```

Wireless evidence:

```text
ping 192.168.60.1 from 192.168.60.74: 60/60 received, avg 53.6 ms, max 241.8 ms
ping 192.168.99.3 from 192.168.60.74: 60/60 received, avg 20.1 ms, max 103.2 ms
curl from 192.168.60.74 to domestic HTTPS: repeated TCP connect stalls up to 5s
```

Interpretation:

- Wired domestic path is now stable in the tested window.
- OpenWrt/WAN2/DNS are not the remaining wireless bottleneck.
- Wireless instability is likely AP/AC/H3C wireless-side jitter: RF channel/interference, AP steering/roaming/load-balancing, AP uplink/trunk, or ER5200G3 AC settings.
- ER5200G3 AC management `http://192.168.99.4/router_index.html` is reachable from Wi-Fi; next step is to inspect AP status, channels, widths, power, client RSSI, roaming/steering, load balancing, and AP uplink errors.
