# Shenlan WAN1 Domain Manager Web Console

Updated: 2026-06-18 18:25 Asia/Shanghai

## Summary

Created and enhanced a local web console for managing the existing conservative WAN1 overseas/AI domain policy.

Local tool path on 12700K:

```text
D:\IDE\AI\network-ops\tools\wan1-domain-manager
```

Current local URL while running:

```text
http://127.0.0.1:8765/
```

Current local service state after the 18:20 enhancement:

```text
Server header: ShenlanDomainManager/1.1
Listener: 127.0.0.1:8765
Verified process at the time of update: python app.py 8765
```

This is still a local development/emergency-maintenance deployment. The durable target is `192.168.50.121`, but migration is not complete.

## What The Tool Does

For each full add/delete domain operation it keeps both current policy layers in sync:

```text
/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf
server=/example.com/192.168.77.1
```

and:

```text
dhcp.shenlan_foreign_wan1_nftset.domain += example.com
```

Then it commits `dhcp` and restarts dnsmasq. The tool does not enable OpenClash and does not activate the broad non-China routing staging file.

## New 18:20 Enhancements

1. Added a connectivity column in the table.
2. Added per-row verification and visible-row batch verification.
3. Verification runs from OpenWrt and checks local dnsmasq resolution, membership in `inet fw4 shenlan_foreign_wan1_v4`, and basic HTTPS HEAD reachability.
4. Added per-row `fix DNS` action for domains that are already in the nftset UCI list but missing `server=/domain/192.168.77.1`.
5. Added confirmed batch `fix missing DNS` action.
6. Added a security guardrail for future server deployment: the app refuses to bind to a non-local address unless `WAN1_MANAGER_PASSWORD` is set.
7. Added environment-variable support for server deployment:

```text
SHENLAN_CONFIG_PATH
WAN1_MANAGER_BIND
WAN1_MANAGER_USER
WAN1_MANAGER_PASSWORD
```

## Missing DNS Meaning

`Missing DNS` means the domain exists in:

```text
dhcp.shenlan_foreign_wan1_nftset.domain
```

but does not have a corresponding dnsmasq upstream exception:

```text
server=/domain/192.168.77.1
```

For domains intended to fully use WAN1, this should usually be fixed. Without the DNS upstream exception, the domain may resolve through domestic upstream DNS and receive an unwanted answer.

Do not silently batch-fix all domains. Current missing-DNS domains include broad Apple/Microsoft/cloud domains, so batch repair requires explicit operator confirmation.

At verification time, current counts were:

```text
total policy domains: 68
missing DNS domains: 27
dnsmasq: running
```

## Connectivity Result Semantics

The API returns:

```json
{
  "domain": "figma.com",
  "addresses": ["..."],
  "matches": {"ip": "in_wan1_set"},
  "wan1SetOk": true,
  "httpStatus": "200",
  "curlRc": "0",
  "ok": true,
  "summary": "..."
}
```

Interpretation:

```text
Reachable HTTP xxx                  DNS, nftset, and HTTPS basic reachability passed.
DNS/WAN1 OK, HTTP inconclusive      Policy looks correct; apex/CDN HTTP did not prove reachability.
DNS failed                          Local dnsmasq did not return IPv4 answers.
Not in WAN1 set                     DNS returned IPv4 addresses, but they were not inserted into the WAN1 nftset.
```

CDN-only or non-apex domains may be HTTP-inconclusive even when the policy is correct.

## Input Format

User can paste a full URL or a plain domain. The tool automatically extracts and normalizes the policy domain before adding it.

Accepted examples:

```text
https://notebooklm.google/?location=unsupported
https://www.figma.com/file/abc/project
www.figma.com
figma.com
*.example.com
```

Normalization examples:

```text
https://www.figma.com/file/abc/project -> figma.com
https://notebooklm.google/?location=unsupported -> notebooklm.google
*.example.com -> example.com
```

## Safety

- The local tool reads sensitive `D:\IDE\AI\network-ops\config.json` and uses PuTTY plink from the operator PC.
- Router credentials are not sent to the browser.
- The server binds to `127.0.0.1` only by default.
- Non-local bind requires `WAN1_MANAGER_PASSWORD`.
- Every add/delete/fix creates a router-side backup under:

```text
/root/shenlan-usage/backups/domain-manager-*
```

## Run Command

Local dev/emergency mode:

```powershell
cd D:\IDE\AI\network-ops\tools\wan1-domain-manager
python app.py 8765
```

Future 121-style run requires a private config path and password:

```bash
export SHENLAN_CONFIG_PATH=/opt/shenlan-network-ops/config.json
export WAN1_MANAGER_BIND=192.168.50.121
export WAN1_MANAGER_USER=admin
export WAN1_MANAGER_PASSWORD='set-a-strong-local-password'
python3 /opt/shenlan-network-ops/tools/wan1-domain-manager/app.py 8765
```

## 192.168.50.121 Migration Status

Target decision: this should eventually run on `192.168.50.121`, not on the operator PC.

Status now: not migrated. A quick ping/SSH probe to 121 timed out during this update, so do not assume the host is currently reachable or ready.

Before migration, verify:

```text
1. 121 is reachable from the admin network.
2. 121 can SSH to OpenWrt 192.168.99.3.
3. Python 3 is available.
4. The SSH command path in config.json works on 121.
5. config.json paths and credentials are private and local to 121.
6. Only trusted office/admin networks can reach the web port.
7. Add a systemd service or Windows scheduled service after manual verification.
```

## Verification Completed

- `python -m py_compile app.py` passed.
- `/api/domains` read current router rules successfully.
- `/api/analyze` normalized `https://www.figma.com/file/abc` to `figma.com`.
- `/api/verify` for `figma.com` returned:

```text
wan1SetOk: true
httpStatus: 200
curlRc: 0
ok: true
summary: reachable HTTP 200
```

OpenClash remains disabled. Broad non-China routing remains inactive.
