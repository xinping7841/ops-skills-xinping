# Shenlan Scanopy 121 Deployment - 2026-06-18 21:45

## Summary

Scanopy Community was deployed on the long-term ops service host `192.168.50.121` / `node-121` to evaluate automated Shenlan topology documentation.

This deployment is for topology discovery evaluation only. It did not change OpenWrt routing, DNS, firewall, SQM, H3C configuration, ER5200G3 configuration, or live client VLAN configuration.

## Runtime

```text
Host:        node-121
LAN IP:      192.168.50.121
Tailscale:   100.122.235.56
OS:          Ubuntu 24.04
Path:        /opt/scanopy
Compose:     /opt/scanopy/docker-compose.yml
Web UI:      http://192.168.50.121:60072/
Remote UI:   http://100.122.235.56:60072/
API health:  /api/health
Version:     Scanopy Server 0.16.2, Daemon 0.16.2
```

Running containers:

```text
scanopy-server-1
scanopy-daemon
scanopy-postgres-1
```

The server health endpoint returned:

```json
{"data":"Scanopy Server 0.16.2","error":null,"success":true}
```

The daemon health endpoint returned:

```json
{"success":true,"data":"Scanopy Daemon Running","meta":{"api_version":1,"server_version":"0.16.2"}}
```

## Current UI State

The UI is reachable from macair over Tailscale at:

```text
http://100.122.235.56:60072/
```

The page redirects to:

```text
/onboarding
```

Current state: first-run onboarding, step 1 of 3. No administrator account was created by Codex. A human operator should create the initial local account and initialize the network before discovery starts.

## Docker Proxy Fix

Initial image pulls failed because Docker daemon had a stale proxy drop-in:

```text
/etc/systemd/system/docker.service.d/proxy.conf
HTTP_PROXY=http://127.0.0.1:3128
HTTPS_PROXY=http://127.0.0.1:3128
```

No service was listening on `127.0.0.1:3128`, while direct HTTPS from 121 to `ghcr.io`, Docker Hub, and `scanopy.net` worked. The stale proxy file was moved aside:

```text
/etc/systemd/system/docker.service.d/proxy.conf.disabled-20260618-scanopy-pull
```

Then Docker was restarted. Existing containers `new-api`, `homeassistant`, and `mosquitto` restarted successfully.

## Compose Deviation From Upstream

The upstream Scanopy compose file uses:

```yaml
image: postgres:17-alpine
```

Docker Hub authorization from 121 repeatedly reset while pulling that image, so the local compose file was changed to the Docker official image mirror on public ECR:

```yaml
image: public.ecr.aws/docker/library/postgres:17-alpine
```

The original compose file was saved under `/opt/scanopy/docker-compose.yml.upstream-*`.

## Access Notes

- From macair, `http://100.122.235.56:60072/` works.
- From macair, `http://192.168.50.121:60072/` resets, matching earlier direct-LAN access behavior from macair.
- From 12700K/admin LAN, `192.168.50.121:60072` should be the preferred URL.
- Existing WAN1 domain manager remains at `http://192.168.50.121:8765/` and was not changed.

## Next Steps

1. A human operator should complete Scanopy onboarding and create the first local admin account.
2. Add Shenlan network scope and discovery credentials only after reviewing what Scanopy stores.
3. Prefer read-only SNMP for H3C/S5735S/OpenWrt discovery. Do not paste shared secrets into Git or screenshots.
4. After the first scan, compare Scanopy L2/L3 output with `codex-skills/shenlan-ops/references/network-inventory.sanitized.json` and the latest H3C/OpenWrt handoffs.
5. If Scanopy L2 topology is incomplete, evaluate Netdisco next for switch-port and MAC/IP attribution.
