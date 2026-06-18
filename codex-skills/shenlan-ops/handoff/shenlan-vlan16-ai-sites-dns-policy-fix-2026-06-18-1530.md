# Shenlan VLAN16 AI Sites Intermittent Access - 2026-06-18 15:30

Updated: 2026-06-18 15:30 Asia/Shanghai

## Trigger

User reported that clients under VLAN16 Marketing / office access switch had intermittent access to overseas AI websites.

## Scope Checked

- Office access switch: `S5735S-Office-Access`, management `192.168.99.2`.
- VLAN16 access ports: `GE0/0/1`, `GE0/0/2`; uplink `GE0/0/25`.
- OpenWrt DNS/egress policy: `192.168.99.3`.
- Relevant AI domains: `chatgpt.com`, `chat.openai.com`, `api.openai.com`, `gemini.google.com`, `perplexity.ai`, `claude.ai`, `cursor.com`.

## Findings

Access layer is currently healthy:

- S5735S `GE0/0/1`: up/up, 1G full duplex, 0 CRC/input/output errors.
- S5735S `GE0/0/2`: up/up, 1G full duplex, 0 CRC/input/output errors. Last physical flap was `2026-06-18 11:46:24` down and `11:47:24` up.
- S5735S `GE0/0/25` uplink to H3C: up/up, 1G full duplex, 0 CRC/input/output errors.
- VLAN16 MAC table contains clients on `GE0/0/1` and `GE0/0/2`, and uplink MAC on `GE0/0/25`.
- VLAN16 access switch state does not explain the reported AI-site intermittency.

DNS/egress finding:

- After the 10:55 domestic-priority DNS change, OpenWrt default DNS upstreams were domestic public DNS servers.
- Domestic upstreams returned abnormal / poor addresses for several AI domains, for example OpenAI/Gemini/Perplexity domains resolving to non-service IPs that timed out or reset connections.
- Querying WAN1/SDWAN DNS `192.168.77.1` returned expected Cloudflare/Google/Anthropic/Vercel addresses.
- WAN2/default path to correct AI IPs often reset/timed out, while WAN1/SDWAN path completed TLS/HTTP for the same targets.
- `dnsmasq` logged `Maximum number of concurrent DNS queries reached (max: 800)` around `14:57:50`, consistent with user-visible DNS/web intermittency under bad upstream answers or query pressure.

## Change Applied

Goal: keep domestic default DNS stable, but resolve AI domains through WAN1/SDWAN DNS and let the existing nftset policy route those destination IPs through WAN1.

OpenWrt changes:

- Added domain-specific dnsmasq upstream rules for AI/foreign domains to `192.168.77.1`.
- Added `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf` and enabled dnsmasq `confdir=/etc/dnsmasq.d` so bare `chatgpt.com` is also covered.
- Restarted dnsmasq.
- Flushed `inet fw4 shenlan_foreign_wan1_v4` so bad cached IPs are replaced by newly resolved correct IPs.
- Did not change default route, VLAN config, H3C config, or access switch config.

Configured AI-domain DNS exceptions include:

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
gemini.google.com
perplexity.ai
anthropic.com
claude.ai
cursor.com
```

Backups on OpenWrt:

```text
/root/shenlan-usage/backups/pre-ai-domain-dns-fix-20260618-151935
/root/shenlan-usage/backups/pre-ai-domain-dns-fix2-20260618-152335
/root/shenlan-usage/backups/pre-chatgpt-dnsmasq-include-20260618-152547
```

## Verification

Final DNS through OpenWrt `127.0.0.1` returned expected addresses:

- `chatgpt.com` -> `172.64.155.209`, `104.18.32.47`.
- `chat.openai.com` -> `104.18.37.228`, `172.64.150.28`.
- `api.openai.com` -> `172.66.0.243`, `162.159.140.245`.
- `gemini.google.com` -> Google `142.251.x.x` addresses.
- `perplexity.ai` -> `104.18.27.48`, `104.18.26.48`.
- `claude.ai` -> `160.79.104.10`.
- `cursor.com` -> `76.76.21.21`.

Policy routing verification:

- Resolved OpenAI/Gemini/Claude/ChatGPT IPs were present in `inet fw4 shenlan_foreign_wan1_v4` after lookup.
- `ip route get <AI_IP> mark 0x1` selects table 100 via `192.168.77.1 dev eth1`.
- WAN1 forced curl reached targets: ChatGPT/OpenAI/Perplexity/Claude returned HTTP 403/421 style service responses, Gemini returned 200, Cursor returned 200. These are application/CDN responses, not network timeouts.

## Notes / Caveats

- OpenWrt local-origin curl without `--interface eth1` still uses the main routing table and may not represent client traffic, because client traffic is marked in prerouting.
- `perplexity.ai` and `cursor.com` may not always appear in the nftset immediately depending on DNS/cache behavior, but forced WAN1 path works. If users still report intermittent access, test from a real VLAN16 client and watch nft counters for `shenlan_mark_foreign_wan1`.
- The current change intentionally preserves domestic DNS defaults and WAN2 global default route.
- If later overseas AI access becomes a primary requirement, consider a cleaner policy: domain-specific DNS plus nftset routing maintained in one config path, or a dedicated VLAN/SSID using WAN1/SDWAN by policy.

## Rollback

Rollback the AI DNS exception by removing the include file and `confdir` if it was only used for this purpose, then restart dnsmasq and flush the set:

```sh
rm -f /etc/dnsmasq.d/shenlan-ai-domain-wan1.conf
# optionally restore /etc/config/dhcp from /root/shenlan-usage/backups/pre-chatgpt-dnsmasq-include-20260618-152547/dhcp
/etc/init.d/dnsmasq restart
nft flush set inet fw4 shenlan_foreign_wan1_v4
```

