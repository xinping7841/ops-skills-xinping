# Shenlan node-121 Tailscale Scanopy Remote Fix - 2026-06-18 22:16

## Summary

Remote access to Scanopy at `http://100.122.235.56:60072/` was unavailable because `node-121` was offline from the macair Tailscale view.

The LAN-side service was healthy:

```text
12700K -> 192.168.50.121 ping: 0% loss
12700K -> 192.168.50.121:22: true
12700K -> 192.168.50.121:60072: true
12700K -> 192.168.50.121:8765: true
```

So this was not a Scanopy container failure and not a node-121 LAN outage.

## Cause

`tailscaled` on `node-121` was active but stale from the tailnet perspective:

```text
100.122.235.56 node-121 ... offline
Health check: Unable to connect to the Tailscale coordination server to synchronize the state of your tailnet.
```

Direct HTTPS to Tailscale control endpoints worked from `node-121`, and `tailscale netcheck` showed UDP/DERP connectivity was available. The issue appeared to be a stuck tailscaled control-plane long-poll/session state rather than DNS or WAN reachability.

## Action

Restarted tailscaled on `node-121` from the LAN side via 12700K:

```bash
sudo systemctl restart tailscaled
```

## Verification

After restart:

```text
tailscaled: active
control RegisterReq: machineAuthorized=true
node-121: active; direct 219.142.184.185:10171
```

Remote health check from macair succeeded:

```text
curl http://100.122.235.56:60072/api/health
{"data":"Scanopy Server 0.16.2","error":null,"success":true}
```

SSH over Tailscale also succeeded:

```text
ssh node-121 'hostname; curl -fsS http://127.0.0.1:60072/api/health'
node-121
{"data":"Scanopy Server 0.16.2","error":null,"success":true}
```

## Current URLs

```text
Remote/Tailscale: http://100.122.235.56:60072/
LAN:              http://192.168.50.121:60072/
```

If remote access fails again while LAN access still works, first check:

```bash
tailscale status
systemctl status tailscaled --no-pager
journalctl -u tailscaled --no-pager -n 100
```
