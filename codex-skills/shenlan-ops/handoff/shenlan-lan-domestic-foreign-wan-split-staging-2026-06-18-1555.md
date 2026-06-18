# Shenlan LAN Domestic/Foreign WAN Split Staging

Time: 2026-06-18 15:55 Asia/Shanghai
Operator: Codex on 12700K

## User Clarification

User clarified the real goal is not proxy/OpenClash takeover, but LAN-side domestic/foreign split across different WAN links:

- Domestic/internal traffic should stay on the current stable default path, WAN2/direct optical modem.
- Overseas/foreign traffic should use WAN1/SDWAN where appropriate.
- There is no subscription URL and no proxy nodes/profile.

## Important Correction

OpenClash is not the right primary tool for this no-subscription requirement.

OpenClash is mainly useful for transparent proxy/subscription/node management. Without a subscription/profile/node list, enabling it would not solve LAN domestic/foreign WAN split and could disturb DNS/TProxy behavior.

The suitable approach on this OpenWrt is native policy routing:

- current working base: `dnsmasq-full nftset + nft mark + ip rule/table 100`
- optional next stage: PBR/mwan3 or direct nft rules for broad China/non-China split

## Current Router Package State

Installed:

- `dnsmasq-full`
- `pbr`
- `luci-app-pbr`
- `mwan3`
- `luci-app-mwan3`
- `luci-app-openclash`

Inactive/disabled:

- `pbr` config enabled: `0`
- `mwan3`: inactive
- `openclash.config.enable='0'`, service inactive

Current active production path remains the hand-made policy:

- `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf`
- nft set `shenlan_foreign_wan1_v4`
- nft rule marks resolved target IPs with `0x1`
- `ip rule fwmark 0x1 -> table 100`
- table 100 default route via WAN1/SDWAN `192.168.77.1`

## Staging Added, Not Enabled

A disabled staging file was added on OpenWrt:

```text
/etc/nftables.d/21-shenlan-nonchina-wan1.nft.disabled
```

Backup before adding it:

```text
/root/shenlan-usage/backups/pre-nonchina-wan1-staging-20260618-155359
```

The file is not active because it ends in `.disabled` and firewall was not reloaded to include it.

Design of the staging file:

1. Include `/etc/openclash/china_ip_route.ipset` only as a China IPv4 CIDR data source. This does not require OpenClash to run.
2. Create `shenlan_china_v4` from that China CIDR list.
3. Create `shenlan_no_policy_v4` for private/internal/link-local/multicast/special ranges.
4. In prerouting, for LAN/H3C-side traffic from `br-lan` or `eth3.99`:
   - internal/private/special destinations: no mark, direct/internal route
   - China IPv4 destinations: no mark, main table default WAN2
   - non-China IPv4 TCP/UDP/ICMP: mark `0x1`, route table 100 to WAN1

## Current Live State After This Work

No traffic path was changed.

Verified after staging:

- `/etc/nftables.d/21-shenlan-nonchina-wan1.nft.disabled` exists
- active nft rules still only show the previous `shenlan_foreign_wan1_v4` domain-based WAN1 rule
- OpenClash remains `0/inactive`

## Enable Procedure Later

Only after user confirms a broad China/non-China split maintenance window:

```sh
cp /etc/nftables.d/21-shenlan-nonchina-wan1.nft.disabled /etc/nftables.d/21-shenlan-nonchina-wan1.nft
fw4 check
fw4 reload
```

Then verify:

```sh
nft list table inet fw4 | grep -E 'shenlan_mark_nonchina|shenlan_china_v4|Non-China'
ip route get 8.8.8.8 mark 0x1
ip route get 223.5.5.5
ip route get 192.168.99.1
```

Functional verification from clients/VLANs:

- domestic site and DNS remain stable via WAN2/default path
- overseas IP/site uses WAN1 when matched as non-China
- internal VLAN/H3C/NAS/AC addresses remain direct
- no DNS/rebind/log storm regression

## Rollback If Enabled Later

```sh
rm -f /etc/nftables.d/21-shenlan-nonchina-wan1.nft
fw4 reload
```

The previous domain-based WAN1 policy is separate and remains controlled by:

```text
/etc/nftables.d/20-shenlan-foreign-wan1.nft
/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf
```

## Recommendation

Do not enable OpenClash for this requirement unless a future subscription/proxy goal returns.

For pure WAN split, continue with either:

1. Current conservative domain-based WAN1 policy, or
2. The staged broad China/non-China nft policy after a controlled enable/verification window, or
3. Convert this logic into `pbr` once the exact interface names and UI behavior are validated.
