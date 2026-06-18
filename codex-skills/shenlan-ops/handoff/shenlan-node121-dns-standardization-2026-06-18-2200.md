# Shenlan node-121 DNS Standardization - 2026-06-18 22:00

## Summary

`node-121` / `192.168.50.121` was standardized so ordinary DNS resolution goes through OpenWrt DNS at `192.168.99.3`.

This aligns the ops server with the Shenlan DNS policy:

- OpenWrt remains the client-facing DNS endpoint.
- OpenWrt dnsmasq applies the existing domestic defaults plus selected WAN1 domain exceptions.
- Container registry domains added earlier now resolve through the same centralized policy from `node-121`.

No OpenWrt, H3C, VLAN, routing, firewall, SQM, OpenClash, PBR, or MWAN changes were made.

## Changes On node-121

Backups were created with timestamp:

```text
20260618-215725
```

Backed up files:

```text
/etc/systemd/resolved.conf.d/codex-public-dns.conf.bak.20260618-215725
/etc/netplan/90-NM-23ed7651-c4f5-4380-bb4d-7481065923cf.yaml.bak.20260618-215725
```

Updated systemd-resolved global default DNS:

```text
/etc/systemd/resolved.conf.d/codex-public-dns.conf
```

Current content:

```ini
[Resolve]
DNS=192.168.99.3
FallbackDNS=
Domains=~.
```

Updated NetworkManager connection:

```text
lan-enp1s0
ipv4.dns: 192.168.99.3
ipv4.ignore-auto-dns: yes
```

Updated matching netplan source:

```text
/etc/netplan/90-NM-23ed7651-c4f5-4380-bb4d-7481065923cf.yaml
```

The `nameservers.addresses` list is now:

```text
192.168.99.3
```

Netplan YAML permissions were tightened to `600`; `sudo netplan generate` then completed without warnings.

## Deliberately Preserved

Tailscale split DNS remains on `tailscale0` for tailnet names.

NodeBabyLink keeps its `~link` split DNS entry from:

```text
/etc/systemd/resolved.conf.d/nblink.conf
```

This means `resolvectl status` can still show `100.66.66.66` in the global DNS list, but ordinary public domains are routed to the `~.` DNS default on `enp1s0` / `192.168.99.3`. Do not remove the NodeBabyLink entry unless that service is intentionally retired.

## Verification

OpenWrt DNS was reachable from `node-121`:

```text
ping 192.168.99.3 -> 0% loss
dig @192.168.99.3 docker.io A +short -> returned IPv4 answers
```

After the change:

```text
resolvectl dns enp1s0
Link 2 (enp1s0): 192.168.99.3
```

Representative public domains resolved via `enp1s0`:

```text
docker.io: ... -- link: enp1s0
github.com: ... -- link: enp1s0
ghcr.io: ... -- link: enp1s0
```

Docker pull succeeded through the standardized resolver path:

```text
docker pull alpine:3.20
Status: Downloaded newer image for alpine:3.20
docker.io/library/alpine:3.20
```

Local services remained healthy:

```text
Scanopy /api/health -> Scanopy Server 0.16.2
shenlan-wan1-domain-manager.service -> active
http://192.168.50.121:8765/ -> 401 unauthenticated, expected
```

## Rollback

If needed:

```bash
sudo cp -a /etc/systemd/resolved.conf.d/codex-public-dns.conf.bak.20260618-215725 /etc/systemd/resolved.conf.d/codex-public-dns.conf
sudo cp -a /etc/netplan/90-NM-23ed7651-c4f5-4380-bb4d-7481065923cf.yaml.bak.20260618-215725 /etc/netplan/90-NM-23ed7651-c4f5-4380-bb4d-7481065923cf.yaml
sudo systemctl restart systemd-resolved
sudo nmcli connection reload
sudo nmcli device reapply enp1s0 || sudo nmcli connection up lan-enp1s0
```
