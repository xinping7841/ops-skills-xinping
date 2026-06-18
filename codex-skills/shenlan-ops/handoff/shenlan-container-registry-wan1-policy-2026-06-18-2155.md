# Shenlan Container Registry WAN1 Policy - 2026-06-18 21:55

## Summary

Container image registry domains were added to the existing conservative WAN1 domain policy so image pulls from `node-121` and other LAN clients can use the WAN1/SDWAN path when DNS is resolved through OpenWrt.

This change used the existing WAN1 domain manager on `192.168.50.121:8765` and the existing OpenWrt policy mechanism:

- dnsmasq per-domain upstream exception to `192.168.77.1`
- `dhcp.shenlan_foreign_wan1_nftset.domain`
- `inet fw4 shenlan_foreign_wan1_v4`
- existing fwmark table 100 route to WAN1

No broad non-China routing, OpenClash, PBR, MWAN, H3C, VLAN, DHCP, or SQM changes were made.

## Domains Added

```text
docker.io
docker.com
ghcr.io
pkg-containers.githubusercontent.com
github.com
githubusercontent.com
githubassets.com
public.ecr.aws
ecr.aws
quay.io
```

Why:

- Docker Hub: `docker.io`, `docker.com`
- GitHub Container Registry: `ghcr.io`, `pkg-containers.githubusercontent.com`
- GitHub release/content dependencies: `github.com`, `githubusercontent.com`, `githubassets.com`
- Public ECR: `public.ecr.aws`, `ecr.aws`
- Quay: `quay.io`

## Verification

WAN1 domain manager `/api/domains` reported all target domains as complete:

```text
docker.com: dns=True nftset=True complete=True
docker.io: dns=True nftset=True complete=True
ecr.aws: dns=True nftset=True complete=True
ghcr.io: dns=True nftset=True complete=True
github.com: dns=True nftset=True complete=True
githubassets.com: dns=True nftset=True complete=True
githubusercontent.com: dns=True nftset=True complete=True
pkg-containers.githubusercontent.com: dns=True nftset=True complete=True
public.ecr.aws: dns=True nftset=True complete=True
quay.io: dns=True nftset=True complete=True
```

OpenWrt local dnsmasq resolved representative domains through `127.0.0.1`, and sample `docker.io` answers were present in the WAN1 nftset:

```text
100.50.161.123 in_wan1_set
3.92.99.2 in_wan1_set
54.242.127.127 in_wan1_set
```

`node-121` Docker Hub pull test succeeded after the change:

```text
docker pull hello-world:latest
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
```

## Backups

The WAN1 domain manager created one OpenWrt-side backup per add under:

```text
/root/shenlan-usage/backups/domain-manager-add-20260618-215024
/root/shenlan-usage/backups/domain-manager-add-20260618-215028
/root/shenlan-usage/backups/domain-manager-add-20260618-215031
/root/shenlan-usage/backups/domain-manager-add-20260618-215035
/root/shenlan-usage/backups/domain-manager-add-20260618-215039
/root/shenlan-usage/backups/domain-manager-add-20260618-215042
/root/shenlan-usage/backups/domain-manager-add-20260618-215046
/root/shenlan-usage/backups/domain-manager-add-20260618-215050
/root/shenlan-usage/backups/domain-manager-add-20260618-215053
/root/shenlan-usage/backups/domain-manager-add-20260618-215057
```

## Follow-Up

`node-121` currently reports multiple DNS servers through `resolvectl`, including public DNS and Tailscale DNS. Because OpenWrt DNS interception is active, normal UDP/TCP 53 still routes through the centralized policy, but the cleaner long-term state is to standardize `node-121` DNS to `192.168.99.3` unless a local service specifically requires otherwise.
