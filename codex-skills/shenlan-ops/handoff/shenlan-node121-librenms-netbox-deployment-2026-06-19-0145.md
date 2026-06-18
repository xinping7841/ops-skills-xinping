# Shenlan node-121 LibreNMS and NetBox deployment — 2026-06-19 01:45

## Summary

Deployed the second and third Shenlan network operations services on `node-121` (`192.168.50.121` / Tailscale `100.122.235.56`) to complement the existing Scanopy topology/annotation service.

No OpenWrt, H3C, ER5200G3, VLAN, routing, DNS, firewall, SQM, PBR, MWAN, or AP configuration was changed.

## Services

| Service | Purpose | URL | Local path | Notes |
|---|---|---|---|---|
| Scanopy | Progressive discovery, topology view, manual annotation, information sedimentation | `http://100.122.235.56:60072/` | `/opt/scanopy` | Existing service from previous handoff |
| LibreNMS | Long-running monitoring, device health, ping/SNMP polling, syslog/trap receiver | `http://100.122.235.56:60800/` | `/opt/librenms/docker-src/examples/compose` | New deployment |
| NetBox | Professional handoff source-of-truth / IPAM / VLAN / device inventory | `http://100.122.235.56:60801/` | `/opt/netbox/netbox-docker` | New deployment |

Credentials were generated/stored only on `node-121` in restricted local files:

- LibreNMS: `/opt/librenms/docker-src/examples/compose/.shenlan-credentials`
- NetBox: `/opt/netbox/netbox-docker/.shenlan-credentials`

Do not sync those files into the ops-skills repository.

## Current Validation

Validated at deployment time:

- `scanopy-server-1`, `scanopy-postgres-1`, and `scanopy-daemon` are healthy/running.
- LibreNMS containers are running: `librenms`, `librenms_db`, `librenms_redis`, `librenms_dispatcher`, `librenms_syslogng`, `librenms_snmptrapd`, `librenms_msmtpd`.
- NetBox containers are healthy: `netbox-docker-netbox-1`, `netbox-docker-postgres-1`, `netbox-docker-redis-1`, `netbox-docker-redis-cache-1`.
- HTTP checks:
  - Scanopy health: `http://127.0.0.1:60072/api/health` returned `200 OK`.
  - LibreNMS login: `http://127.0.0.1:60800/login` returned redirect to login.
  - NetBox login: `http://127.0.0.1:60801/login/` returned `200 OK`.
- Node resources after deployment: root disk about `20%` used, memory about `8.9 GiB` used of `28 GiB`, no meaningful swap use.

## LibreNMS bootstrap

LibreNMS was deployed from the official `librenms/docker` compose example.

Deployment details:

- External Web port changed from default `8000` to `60800` to avoid conflicts.
- Time zone set to `Asia/Shanghai`.
- Local admin user `admin` created; password is stored only in the restricted local credentials file.
- Added initial ping-only devices for safe baseline monitoring:
  - `192.168.99.1` — H3C core switch
  - `192.168.99.2` — Office access S5735S
  - `192.168.99.3` — OpenWrt main router
  - `192.168.99.4` — ER5200G3 AC
  - `192.168.50.121` — node-121 service host

These are ping-only until real read-only SNMP credentials are added. Do not assume port/interface metrics are available yet.

## NetBox bootstrap

NetBox was deployed from `netbox-community/netbox-docker` release branch.

Deployment details:

- External Web port set to `60801`.
- Time zone set to `Asia/Shanghai`.
- Initial admin user `admin` created; password is stored only in the restricted local credentials file.
- Imported baseline handoff inventory into NetBox:
  - Site: `深澜空间`
  - Devices: 5
  - VLANs: 17
  - Prefixes: 17
  - IP addresses: 21

Imported device baseline:

- `OpenWrt-Main-Router` — `192.168.99.3/24`
- `H3C-Core-Switch` — `192.168.99.1/24`
- `Office-Access-S5735S` — `192.168.99.2/24`
- `ER5200G3-AC` — `192.168.99.4/24`
- `node-121-service-host` — `192.168.50.121/23`

Imported VLAN/prefix baseline came from `codex-skills/shenlan-ops/references/network-inventory.sanitized.json`.

## Chinese localization answer

As of this deployment:

- Scanopy does not appear to provide a complete built-in Chinese UI switch in the deployed UI.
- LibreNMS and NetBox are primarily English upstream UIs; NetBox responses currently show `content-language: en`.
- Practical Chinese workflow for now:
  - Use Chinese site/device names, descriptions, comments, VLAN names, and handoff documents.
  - Use NetBox as the professional structured source of truth, with Chinese labels where supported.
  - Use LibreNMS for health/alerts, with Chinese display names/descriptions where supported.
  - Keep Git handoff Markdown in Chinese for maintenance transfer.

A full Chinese UI would require either upstream locale support, a maintained translation package, or a reverse-proxy/browser-side translation layer. Do not patch container source casually; it will be fragile across upgrades.

## Next steps

1. Add real read-only SNMP credentials for H3C core / S5735S / OpenWrt where supported, then convert LibreNMS devices from ping-only to SNMP polling.
2. Enable LLDP/CDP/SNMP on switches where safe, then let LibreNMS/Scanopy build more accurate topology and interface relationships.
3. Gradually enrich NetBox with racks/locations, switch ports, uplinks, APs, servers, and critical services.
4. Decide whether to put a reverse proxy route in front of `60800`/`60801`; current direct Tailscale URLs are sufficient for admin use.
5. If a fully Chinese operator UI is required, evaluate supported localization/plugin options before modifying containers.
