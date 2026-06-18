# Shenlan WAN1 Domain Manager Web Console

Updated: 2026-06-18 17:16 Asia/Shanghai

## Summary

Created a local web console on 12700K for managing the existing conservative WAN1 overseas/AI domain policy.

Local tool path on 12700K:

```text
D:\IDE\AI\network-ops\tools\wan1-domain-manager
```

Current local URL while running:

```text
http://127.0.0.1:8765/
```

The service was started locally and `/api/domains` successfully read the current OpenWrt policy list. `figma.com` and `notebooklm.google` showed complete status.

## What The Tool Does

For each added/deleted domain it keeps both current policy layers in sync:

```text
/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf
server=/example.com/192.168.77.1
```

and:

```text
dhcp.shenlan_foreign_wan1_nftset.domain += example.com
```

Then it commits `dhcp` and restarts dnsmasq. The tool does not enable OpenClash and does not activate the broad non-China routing staging file.

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

The web UI previews the normalized domain while typing, e.g. `将加入策略域名: figma.com`.

## Safety

- The tool reads local sensitive `D:\IDE\AI\network-ops\config.json` and uses PuTTY plink from the operator PC.
- Router credentials are not sent to the browser.
- The server binds to `127.0.0.1` only by default.
- Every add/delete creates a router-side backup under `/root/shenlan-usage/backups/domain-manager-*`.

## Run Command

```powershell
cd D:\IDE\AI\network-ops\tools\wan1-domain-manager
python app.py 8765
```

## Verification Completed

- `python -m py_compile app.py` passed.
- Normalization tests passed:

```text
https://notebooklm.google/?location=unsupported => notebooklm.google
https://www.figma.com/file/abc/project => figma.com
www.figma.com => figma.com
*.example.com => example.com
```

- `/api/domains` read current router rules successfully.
- `/api/analyze` returned expected normalized domains for Figma and NotebookLM URLs.
