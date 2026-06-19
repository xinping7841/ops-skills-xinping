Latest topology/model/image handoff: 2026-06-19 22:25 Asia/Shanghai. Completed the Shenlan topology device-model supplement and diagram handoff. Confirmed model list now includes B866-S2 optical modem, OSDWAN, OpenWrt hardware 倍控 H30S, H3C S5130V2-28S-LI, Huawei S5735S-L24T4S-QA2, ERG3/ER5200G3, 7 x H3C A61-1500 APs, QNAP TS-h973AX-8G, 飞牛OS, Xiaomi ZSWG01CM, Hikvision DS-7932N-R4(C), and node-121 AZW SER / AMD 零刻. Resolved the previous layered SVG conflict, regenerated the latest horizontal tree SVG, fixed text overflow/cropping by moving to a 2600 x 2600 safe square canvas, exported `codex-skills/shenlan-ops/diagrams/shenlan-network-latest-tree.svg.png`, and pushed commit `15287f2 优化深澜拓扑图图片布局`. Remaining work is physical placement and management details: 飞牛OS NAS port, Xiaomi MAC/IP, Hikvision NVR port, AP locations/uplinks, B866-S2/OSDWAN management addresses, OpenWrt physical port map/version, and VLAN50 downstream switch locations/models/uplinks. See `codex-skills/shenlan-ops/handoff/shenlan-topology-model-image-status-2026-06-19-2225.md`.

Latest topology image layout fix: 2026-06-19 21:25 Asia/Shanghai. Reworked codex-skills/shenlan-ops/diagrams/shenlan-network-latest-tree.svg to a larger 3200x2200 canvas with shorter wrapped lines to avoid text overflow in preview.

Latest rendered topology image: 2026-06-19 21:15 Asia/Shanghai. Generated latest horizontal tree SVG topology at codex-skills/shenlan-ops/diagrams/shenlan-network-latest-tree.svg using the completed model supplements: B866-S2, OSDWAN, Beelink/倍控 H30S, H3C S5130V2-28S-LI, S5735S-L24T4S-QA2, ER5200G3/ERG3, 7 x A61-1500 APs, QNAP TS-h973AX-8G, 飞牛OS, Xiaomi ZSWG01CM, and Hikvision DS-7932N-R4(C).

Latest endpoint model supplement: 2026-06-19 21:05 Asia/Shanghai. User confirmed 飞牛 NAS is an assembled NAS and should be recorded as 飞牛OS, Xiaomi central gateway model ZSWG01CM, and Hikvision NVR model DS-7932N-R4(C). Updated topology and device-model enrichment handoff. Remaining details are mostly physical access ports/locations and management addresses. Rebase conflict on codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg remains unresolved.

Latest QNAP model supplement: 2026-06-19 21:00 Asia/Shanghai. User confirmed the 威联通/QNAP NAS model as TS-h973AX-8G. Updated topology and device-model enrichment handoff. Remaining model gaps are mainly 飞牛 NAS hardware, 小米中枢网关 model/MAC/IP, 海康 NVR model/access port, AP physical locations/uplink ports, and management addresses/port maps for B866-S2/OSDWAN. Rebase conflict on codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg remains unresolved.

Latest field model supplement: 2026-06-19 20:55 Asia/Shanghai. User supplied additional model data: telecom optical modem B866-S2, SDWAN OSDWAN, OpenWrt hardware Beelink/倍控 H30S, and ER5200G3 AP screenshot showing 7 x A61-1500 APs with AP version SWBA1A1V100R005 and IPs 172.17.1.2-172.17.1.8. Updated codex-skills/shenlan-ops/references/shenlan-network-topology.md and codex-skills/shenlan-ops/handoff/shenlan-device-model-enrichment-2026-06-19.md. Repository is still in a pull --rebase add/add conflict on codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg, so do not push until the conflict is manually resolved.

Latest device model enrichment: 2026-06-19 20:45 Asia/Shanghai. Pulled non-sensitive model fields from node-121 LibreNMS, NetBox, Scanopy, and local read-only DMI. Confirmed H3C core as H3C S5130V2-28S-LI, Huawei access as S5735S-L24T4S-QA2, ER5200G3 AC as H3C ERG3/ER5200G3 software ERG3-MINIWAREV2-R0174P03, and node-121 as AZW SER / AMD Beelink service platform. OpenWrt hardware, SDWAN, optical modem, APs, NAS/NVR exact models, and VLAN50 downstream switch physical placement still need field supplement. Updated codex-skills/shenlan-ops/references/shenlan-network-topology.md. See codex-skills/shenlan-ops/handoff/shenlan-device-model-enrichment-2026-06-19.md.

Latest layered topology diagram: 2026-06-19 19:45 Asia/Shanghai. Added `codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg`, a three-layer handoff topology based on the actual Shenlan network: WAN/Internet with WAN1 SDWAN and WAN2 optical modem, OpenWrt as the egress/NAT/DNS/QoS/policy-routing node, H3C as the L3 core with VLAN/DHCP, and access/business branches for S5735S, ER5200G3, node-121, NAS, and downstream candidates. The diagram intentionally does not copy the example-only dual-core/firewall/finance-VLAN structure. See `codex-skills/shenlan-ops/handoff/shenlan-layered-structure-topology-2026-06-19.md`.

Latest VLAN/NAS topology update: 2026-06-19 19:30 Asia/Shanghai. Recorded user-supplied S5735 department VLAN mapping: VLAN10 office devices, VLAN16 marketing, VLAN17 training, VLAN18 AI development. Read-only H3C checks confirmed H3C remains the VLAN/DHCP core; Ten-GigabitEthernet1/0/28 is the S5735 trunk permitting VLAN 1/10/16-18/99, and Ten-GigabitEthernet1/0/27 is an UP 10G optical access port in VLAN30 for the site-reported 威联通 NAS. Also recorded `192.168.50.254` as 飞牛 NAS in VLAN50, with its exact access port still to be confirmed. Updated `codex-skills/shenlan-ops/references/shenlan-network-topology.md` and `codex-skills/shenlan-ops/diagrams/shenlan-network-ops-tree.svg`. No live network configuration or credentials changed. See `codex-skills/shenlan-ops/handoff/shenlan-topology-vlan-nas-update-2026-06-19.md`.

Latest ops tree topology: 2026-06-19 Asia/Shanghai. Added an operations handoff tree SVG at `codex-skills/shenlan-ops/diagrams/shenlan-network-ops-tree.svg` because the original dense draw.io preview was not readable enough for troubleshooting. The tree is organized by fault-isolation order: Internet/WAN, OpenWrt, H3C core, then S5735S/ER5200G3/node-121/downstream candidates. No live network configuration or credentials changed. See `codex-skills/shenlan-ops/handoff/shenlan-network-ops-tree-2026-06-19.md`.

Latest topology draw.io: 2026-06-19 19:03 Asia/Shanghai. After Codex restart, `mcp-diagram-generator` was available and generated the editable draw.io topology file `codex-skills/shenlan-ops/diagrams/shenlan-network-topology.drawio` from the Shenlan Scanopy/LibreNMS/NetBox topology draft. The reference document now points to the draw.io file. No live network configuration or credentials changed. See `codex-skills/shenlan-ops/handoff/shenlan-network-topology-drawio-2026-06-19-1903.md`.

Latest topology draft: 2026-06-19 18:55 Asia/Shanghai. Generated the first Shenlan network topology draft from node-121 Scanopy/LibreNMS/NetBox data. Added `codex-skills/shenlan-ops/references/shenlan-network-topology.md` with a Mermaid high-level topology, LibreNMS device/link evidence, NetBox VLAN/IPAM table, system responsibilities, and confirmation checklist. Installed local `mcp-diagram-generator` and configured Codex MCP for future draw.io generation after restart. No live network configuration or credentials changed. See `codex-skills/shenlan-ops/handoff/shenlan-network-topology-draft-2026-06-19-1855.md`.

Latest NetBox CSRF trusted origins fix: 2026-06-19 18:35 Asia/Shanghai. NetBox on `node-121` returned Django `Forbidden (403)` / `CSRF verification failed` from `http://100.122.235.56:60801/login/` because runtime `CSRF_TRUSTED_ORIGINS` was empty. Added `http://100.122.235.56:60801` and `http://192.168.50.121:60801` to `/opt/netbox/netbox-docker/env/netbox.env`, rebuilt the NetBox container, and verified container health, loaded Django settings, `GET /login/` 200 OK, and a token-bearing login form POST from the Tailscale origin no longer fails origin CSRF validation. No plaintext credentials were added to the repository. See `codex-skills/shenlan-ops/handoff/shenlan-netbox-csrf-trusted-origins-2026-06-19-1835.md`.

Latest node-121 Web credential unification: 2026-06-19 18:26 Asia/Shanghai. Scanopy (`60072`), LibreNMS (`60800`), and NetBox (`60801`) now use a unified administrator password while retaining product-specific usernames: Scanopy `admin@shenlan.local`, LibreNMS `admin`, NetBox `admin`. Passwords remain only in local secret files on `node-121`: `/opt/scanopy/.shenlan-credentials`, `/opt/librenms/docker-src/examples/compose/.shenlan-credentials`, and `/opt/netbox/netbox-docker/.shenlan-credentials`; no plaintext credential was added to this repository. HTTP reachability and backend password hash checks passed. No OpenWrt/H3C/S5735S/ER5200G3/VLAN/DNS/routing/firewall/SQM/PBR/MWAN/AP changes. See `codex-skills/shenlan-ops/handoff/shenlan-node121-web-credentials-unified-2026-06-19-1826.md`.

Latest node-121 service catalog update: 2026-06-19 18:05 Asia/Shanghai. Added a consolidated service catalog at `codex-skills/shenlan-ops/references/node121-services.md` so other terminals can identify the current `node-121` services: Scanopy (`60072`), LibreNMS (`60800`), NetBox (`60801`), WAN1 Domain Manager (`8765`), local SNMPv3 `snmpd`, LibreNMS trap/syslog receivers (`162`/`514`), and Smart Center SNMP Agent. The catalog records URLs, directories, Docker/systemd management commands, and secret-handling rules without exposing credentials.

Latest OpenWrt SNMPv3 / LibreNMS update: 2026-06-19 17:35 Asia/Shanghai. OpenWrt main router `192.168.99.3` now verifies by SNMPv3 authPriv from `node-121` as `OpenWrt-Main-Router`; SNMPv2c `public` no longer responds. LibreNMS removed the old ping-only/incomplete placeholder and re-added `192.168.99.3` as SNMPv3, discovery/poll succeeded as OS `linux`, type `server`, 9 ports. Key monitored devices are now all SNMPv3 in LibreNMS: node-121 `192.168.50.121`, H3C `192.168.99.1`, S5735S `192.168.99.2`, OpenWrt `192.168.99.3`, ER5200G3 `192.168.99.4`. See `codex-skills/shenlan-ops/handoff/shenlan-openwrt-snmpv3-librenms-2026-06-19-1735.md`.

Latest ER5200G3 SNMPv3/LibreNMS update: 2026-06-19 15:05 Asia/Shanghai. ER5200G3 `192.168.99.4` now verifies by SNMPv3 from `node-121` using user `shenlan_ro` with the ER UI-supported `MD5` auth and `DES/Des56` privacy mode; SNMPv2c remains non-responsive. LibreNMS replaced the ping-only ER placeholder with SNMPv3, discovery/poll succeeded as `ER5200G3-AC`, OS `comware`, type `network`, 11 ports. H3C and S5735S remain SNMPv3 in LibreNMS. See `codex-skills/shenlan-ops/handoff/shenlan-er5200g3-snmpv3-librenms-2026-06-19-1505.md`.

Latest SNMPv3 switch/ER5200G3 progress: 2026-06-19 14:45 Asia/Shanghai. H3C `192.168.99.1` and S5735S `192.168.99.2` now verify with SNMPv3 authPriv from `node-121`; SNMPv2c polling no longer responds for H3C/S5735S/ER5200G3 from `node-121`. LibreNMS re-added H3C as SNMPv3 (`comware`, network, 48 ports) and S5735S as SNMPv3 (`vrp`, network, 33 ports). ER5200G3 screenshots show SNMPv3-only and trusted host `192.168.50.121`; probe reaches the device but returns `Unknown user name`, so the ER SNMPv3 user must be changed from the built-in `admin` MD5/DES user to the shared read-only monitoring user in `/opt/shenlan-ops/secrets/snmpv3-switches.env`, then re-add `192.168.99.4` to LibreNMS as SNMPv3. See `codex-skills/shenlan-ops/handoff/shenlan-snmpv3-switches-er5200g3-2026-06-19-1445.md`.

# Shenlan Network Ops Latest Handoff

Latest node-121 SNMPv3 / LibreNMS upgrade: 2026-06-19 13:45 Asia/Shanghai. Installed and configured `snmpd`/`snmp` on `node-121`, created a local-only SNMPv3 read-only authPriv user stored at `/opt/shenlan-ops/secrets/snmpv3-node121.env`, bound SNMP to `127.0.0.1`, `192.168.50.121`, and Tailscale `100.122.235.56`, and upgraded LibreNMS device `192.168.50.121` from ping-only to SNMPv3 polling. LibreNMS discovery/poll succeeded for `node-121` with sysName `node-121`, OS `linux`, type `server`, 26 ports, 16 processors, and 2 storage entries. SNMPv2c probes with `public`/`shenlan` still failed for H3C `192.168.99.1`, S5735S `192.168.99.2`, OpenWrt `192.168.99.3`, and ER5200G3 `192.168.99.4`; those remain ping-only until read-only SNMP or confirmed credentials are provided. No OpenWrt/H3C/S5735S/ER5200G3/VLAN/DNS/routing/firewall/SQM/PBR/MWAN/DHCP/AP changes. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-node121-snmpv3-librenms-upgrade-2026-06-19-1345.md`.

Latest node-121 LibreNMS and NetBox deployment: 2026-06-19 01:45 Asia/Shanghai. Deployed LibreNMS on `node-121` at `http://100.122.235.56:60800/` for long-running monitoring and NetBox at `http://100.122.235.56:60801/` for professional handoff/IPAM/source-of-truth. Existing Scanopy remains at `http://100.122.235.56:60072/` for discovery/topology annotation. LibreNMS was bootstrapped with local admin credentials stored only on `node-121` and initial ping-only devices for `192.168.99.1`, `192.168.99.2`, `192.168.99.3`, `192.168.99.4`, and `192.168.50.121`. NetBox was bootstrapped with site `深澜空间`, 5 devices, 17 VLANs, 17 prefixes, and 21 IP addresses imported from sanitized inventory. No OpenWrt/H3C/ER5200G3/VLAN/DNS/routing/firewall/SQM/PBR/MWAN/AP changes. Chinese UI status: no complete built-in Chinese UI confirmed for Scanopy/LibreNMS/NetBox; use Chinese names/descriptions/Markdown handoff for now. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-node121-librenms-netbox-deployment-2026-06-19-0145.md`.

Latest Scanopy onboarding and VLAN discovery: 2026-06-18 23:10 Asia/Shanghai. Completed Scanopy first-run onboarding on `node-121`, created the local admin account with user-provided credentials (password not recorded), added 16 manual Shenlan VLAN subnets to network `Shenlan LAN`, and updated the scheduled Discovery to include 17 intended Shenlan subnets including the original `192.168.50.0/24`. First onboarding scan completed with 48 hosts, 76 services, and 9 subnets. Manual multi-subnet runs were cancelled because Scanopy marks manual Run as full 65k-port scans, estimating over an hour. Before cancellation, it discovered routed-VLAN host `192.168.30.2` under VLAN30 NAS Storage. Topology was rebuilt; current counts are 50 hosts, 78 services, and 25 subnets. Scheduled Discovery cron was restored to weekly `0 0 0 * * 0`. No OpenWrt/H3C/ER5200G3/VLAN/DNS/routing/firewall/SQM changes. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-scanopy-onboarding-and-vlan-discovery-2026-06-18-2310.md`.

Latest health collector timeout hardening: 2026-06-18 22:35 Asia/Shanghai. Follow-up monitoring optimization after CSV dedupe found stale `collect-health.sh`/`logread | grep` processes and a held `/root/shenlan-usage/run/collect-health.lock` even though `crond=1`, `nlbwmon=0`, and CSV rows were clean.

Updated `/root/shenlan-usage/bin/collect-health.sh` from local source `D:\IDE\AI\network-ops\router-scripts\collect-health.sh` to add PID/start-time lock metadata, stale-lock recovery after 240 seconds, and 8-second hard timeouts around `nslookup` and `logread` using temporary files instead of live pipelines. Remote backup: `/root/shenlan-usage/backups/collect-health-pre-timeout-20260618-222813.sh`.

Cleared stale collector/logread/grep processes and lock; manual run returned `manual_rc=0` in about 12 seconds; natural cron samples at 22:29, 22:30, and 22:31 wrote one clean set per minute; post-check duplicate keys remained 0 for health, HTTP, DNS, and interface CSVs. No routing/DNS/firewall/SQM/H3C/OpenClash/PBR/MWAN/VLAN/DHCP changes. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-health-collector-timeout-hardening-2026-06-18-2235.md`.

Latest node-121 Tailscale/Scanopy remote fix: 2026-06-18 22:16 Asia/Shanghai. User reported remote Scanopy URL would not open. From macair, `100.122.235.56:60072` and SSH timed out because `node-121` was offline in Tailscale, while 12700K LAN checks to `192.168.50.121` showed ping, SSH `22`, Scanopy `60072`, and domain manager `8765` all reachable. `tailscaled` was active but stale; control endpoint HTTPS and `tailscale netcheck` worked. Restarted `tailscaled` on `node-121`; it re-registered with `machineAuthorized=true`, Tailscale status became `active; direct 219.142.184.185:10171`, and macair `curl http://100.122.235.56:60072/api/health` returned Scanopy Server `0.16.2`. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-node121-tailscale-scanopy-remote-fix-2026-06-18-2216.md`.

Latest node-121 DNS standardization: 2026-06-18 22:00 Asia/Shanghai. Standardized `node-121` ordinary DNS to OpenWrt `192.168.99.3` by updating `/etc/systemd/resolved.conf.d/codex-public-dns.conf`, NetworkManager connection `lan-enp1s0`, and matching netplan source `/etc/netplan/90-NM-23ed7651-c4f5-4380-bb4d-7481065923cf.yaml`. Backups use timestamp `20260618-215725`. `resolvectl dns enp1s0` now shows `192.168.99.3`; `docker.io`, `github.com`, and `ghcr.io` resolve via `-- link: enp1s0`; `docker pull alpine:3.20` succeeded. Tailscale split DNS and NodeBabyLink `~link` split DNS were preserved. No OpenWrt/H3C/VLAN/routing/firewall/SQM/OpenClash/PBR/MWAN changes were made. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-node121-dns-standardization-2026-06-18-2200.md`.

Latest health CSV dedupe: 2026-06-18 21:57 Asia/Shanghai. Cleaned historical duplicate OpenWrt health CSV rows after the monitoring runtime cleanup; no routing/DNS/firewall/SQM/H3C/OpenClash/PBR/MWAN changes. Original CSVs were backed up on OpenWrt at `/root/shenlan-usage/backups/health-csv-pre-dedupe-20260618-215504`. Deduped by file-specific key while preserving the first row: health `timestamp+label`, HTTP `timestamp+label+url`, DNS `timestamp+label+server+name`, interface `timestamp+iface`. Removed duplicate rows: `health-probes-2026-06-18.csv` 1175, `http-health-2026-06-18.csv` 470, `dns-health-2026-06-18.csv` 940, `interface-health-2026-06-18.csv` 940; 2026-06-17 files had 0 duplicates. Post-check all health CSVs report `duplicate_data_rows=0`, and natural sample at 21:56 appended cleanly. See `D:\IDE\AI\network-ops\handoff\shenlan-health-csv-dedupe-2026-06-18-2157.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-health-csv-dedupe-2026-06-18-2157.md`.

Latest container registry WAN1 policy: 2026-06-18 21:55 Asia/Shanghai. Added container image registry domains to the existing conservative WAN1 domain policy via the 121 WAN1 domain manager: `docker.io`, `docker.com`, `ghcr.io`, `pkg-containers.githubusercontent.com`, `github.com`, `githubusercontent.com`, `githubassets.com`, `public.ecr.aws`, `ecr.aws`, and `quay.io`. All report `dns=True`, `nftset=True`, `complete=True`; OpenWrt dnsmasq resolved sample registry domains locally, and sample `docker.io` IPs were present in `inet fw4 shenlan_foreign_wan1_v4`. `docker pull hello-world:latest` succeeded on `node-121` after the change. No broad non-China routing, OpenClash, PBR, MWAN, H3C, VLAN, DHCP, or SQM changes were made. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-container-registry-wan1-policy-2026-06-18-2155.md`.

Latest Scanopy deployment: 2026-06-18 21:45 Asia/Shanghai. Scanopy Community was deployed on the long-term ops host `192.168.50.121` / `node-121` under `/opt/scanopy` using Docker Compose. It runs `scanopy-server-1`, `scanopy-daemon`, and `scanopy-postgres-1`; health checks report Scanopy Server/Daemon `0.16.2`. Web UI is `http://192.168.50.121:60072/` from the admin LAN and `http://100.122.235.56:60072/` over Tailscale. The UI is currently at first-run onboarding; Codex did not create an admin account. No OpenWrt/H3C/ER5200G3/DNS/routing/firewall/SQM settings were changed. Docker image pulls required disabling a stale Docker daemon proxy drop-in pointing at dead `127.0.0.1:3128`; the disabled file is `/etc/systemd/system/docker.service.d/proxy.conf.disabled-20260618-scanopy-pull`. The local compose file uses `public.ecr.aws/docker/library/postgres:17-alpine` instead of Docker Hub `postgres:17-alpine` because Docker Hub auth reset from 121. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-scanopy-121-deployment-2026-06-18-2145.md`.

Latest monitoring cleanup: 2026-06-18 21:10 Asia/Shanghai. Optimized OpenWrt monitoring runtime only; no routing/DNS/firewall/SQM/H3C/OpenClash/PBR/MWAN changes. Stopped stale `nlbwmon` runtime and killed residual `nlbwmon` processes; restarted cron and killed the duplicate bare `crond`, leaving one managed `/usr/sbin/crond -f -c /etc/crontabs -l 9`. Added a lightweight overlap lock to `/root/shenlan-usage/bin/collect-health.sh` using `/root/shenlan-usage/run/collect-health.lock`, so overlapping health probes skip instead of writing duplicate rows. Installed missing helper packages `openssh-sftp-server` and `coreutils-base64`; verified PuTTY `pscp` upload now succeeds. Final verification: `crond_count=1`, `nlbwmon_count=0`, collector syntax OK, manual run OK, and natural cron samples from 21:06-21:09 wrote one clean set per minute. Historical CSV files before about 21:06 still contain duplicate rows, so deduplicate by `timestamp + label` when doing full-day analysis. See `D:\IDE\AI\network-ops\handoff\shenlan-monitoring-cleanup-2026-06-18-2110.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-monitoring-cleanup-2026-06-18-2110.md`.

Latest post-WAN1-20M network analysis: 2026-06-18 20:45 Asia/Shanghai. Checked OpenWrt router and H3C core after the 16:53 WAN1 symmetric CAKE `20000/20000` kbit/s change. No evidence that the WAN1 limit caused a core-switch, interface, WAN1 gateway, or WAN2 gateway outage. WAN1 and WAN2 gateways had 0 loss; OpenWrt `eth1`, `eth2`, `eth3`, and `eth3.99` stayed up with no error/CRC delta; H3C key ports `GE1/0/3`, `GE1/0/12`, and `XGE1/0/28` were up/up with 0 errors/CRC. The strongest post-change user-visible candidate was 19:00: public ICMP plus HTTP plus local dnsmasq query timeout while WAN gateways stayed clean, pointing to WAN2/upstream/public-path or dnsmasq transient rather than a physical link flap. WAN1 shaping is active but not continuously saturated; WAN2 remains the main/default exit. Runtime hygiene issue found: stale `nlbwmon` processes and duplicate `crond` caused duplicate one-minute health rows; clean these without changing routing/DNS. Also note one `logd` segfault at 18:34 and a VLAN60 duplicate IP `192.168.60.156` on H3C `GE1/0/3`. Raw local evidence is in `D:\IDE\AI\network-ops\state\post-wan1-20m-audit-20260618-202753`; sanitized report is `D:\IDE\AI\network-ops\handoff\shenlan-post-wan1-20m-network-analysis-2026-06-18-2045.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-post-wan1-20m-network-analysis-2026-06-18-2045.md`.

Latest WAN1 domain manager deployment: 2026-06-18 20:15 Asia/Shanghai. The WAN1 domain manager has been migrated from the operator PC to the long-term service host `192.168.50.121` (`node-121`). It is now a systemd service `shenlan-wan1-domain-manager.service`, enabled and active, listening internally at `http://192.168.50.121:8765/` with Basic auth. Runtime paths on 121: app `/opt/shenlan-network-ops/tools/wan1-domain-manager`, private config `/opt/shenlan-network-ops/config.json`, auth env `/etc/shenlan-wan1-domain-manager.env`, service SSH key `/home/lingke01/.ssh/shenlan_openwrt_domain_manager`. The app is now `ShenlanDomainManager/1.2` and supports both Windows/plink and Linux/OpenSSH-key modes. Verified from 121: `/api/domains` shows dnsmasq running, 68 domains, 27 missing DNS; `/api/verify figma.com` returns `wan1SetOk=true`, HTTP 200. Unauthenticated browser/API access returns 401. Do not commit or print 121 private config, auth env, or private key. See `D:\IDE\AI\network-ops\handoff\shenlan-wan1-domain-manager-121-deployment-2026-06-18-2015.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-wan1-domain-manager-121-deployment-2026-06-18-2015.md`.

Latest WAN1 domain manager enhancement: 2026-06-18 18:25 Asia/Shanghai. The local web console at `D:\IDE\AI\network-ops\tools\wan1-domain-manager` is now `ShenlanDomainManager/1.1` and is running on `http://127.0.0.1:8765/` when the local Python process is active. Added a table connectivity column, automatic/visible-row verification, per-row DNS repair for `Missing DNS`, confirmed batch repair, and a non-local-bind guard requiring `WAN1_MANAGER_PASSWORD`. Verification from OpenWrt checks local dnsmasq resolution, `inet fw4 shenlan_foreign_wan1_v4` membership, and basic HTTPS HEAD reachability. Current observed counts: 68 policy domains, 27 missing DNS, dnsmasq running; `figma.com` verified `wan1SetOk=true`, HTTP 200. Do not silently batch-fix the 27 missing-DNS domains because broad Apple/Microsoft/cloud domains are included. Long-term service target is still `192.168.50.121`, but migration is not done; quick ping/SSH probe to 121 timed out during this update, so verify reachability and SSH before deploying there. See `D:\IDE\AI\network-ops\handoff\shenlan-wan1-domain-manager-web-console-2026-06-18-1716.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-wan1-domain-manager-web-console-2026-06-18-1716.md`.
Updated: 2026-06-18 17:16 Asia/Shanghai
Latest WAN1 domain manager: 2026-06-18 17:16 Asia/Shanghai. Created a local web console on 12700K at `D:\IDE\AI\network-ops\tools\wan1-domain-manager`, currently served on `http://127.0.0.1:8765/` when running. It manages the existing conservative WAN1 overseas/AI domain policy by keeping `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf` and `dhcp.shenlan_foreign_wan1_nftset.domain` in sync, then restarting dnsmasq. It accepts full URLs or plain domains and automatically normalizes examples like `https://www.figma.com/file/abc` to `figma.com` and `https://notebooklm.google/?location=unsupported` to `notebooklm.google`. It does not enable OpenClash or broad non-China routing. See `D:\IDE\AI\network-ops\handoff\shenlan-wan1-domain-manager-web-console-2026-06-18-1716.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-wan1-domain-manager-web-console-2026-06-18-1716.md`.
Latest WAN1 domain additions: 2026-06-18 17:04 Asia/Shanghai. Added `notebooklm.google` and `figma.com` to the existing conservative WAN1 overseas/AI policy. Added `server=/notebooklm.google/192.168.77.1` and `server=/figma.com/192.168.77.1` under `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf`, and added both domains to `dhcp.shenlan_foreign_wan1_nftset.domain` so resolved IPv4 answers populate `inet fw4 shenlan_foreign_wan1_v4`. Verified `notebooklm.google` and `www.figma.com` resolve locally and all returned IPv4 addresses are present in the WAN1 nftset. OpenClash remains disabled and broad non-China routing remains inactive. See `D:\IDE\AI\network-ops\handoff\shenlan-wan1-domain-add-notebooklm-figma-2026-06-18-1704.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-wan1-domain-add-notebooklm-figma-2026-06-18-1704.md`.
Latest router optimization: 2026-06-18 16:53 Asia/Shanghai. User requested WAN1 upstream/downstream limiting and router optimization. WAN1/SDWAN SQM is now enabled as symmetric CAKE `20000/20000` kbit/s (`eth1` and `ifb4eth1` both verified by `tc qdisc` as 20Mbit). WAN2/direct optical modem remains the global default route (`eth2`, metric 10); marked foreign/AI policy traffic still uses table 100 to WAN1 (`fwmark 0x1`, metric 30). Disabled or confirmed inactive: `nlbwmon`, `openclash`, `pbr`, and `mwan3`. Kept enabled/running: `sqm`, `cron`, and `log`. Logging was tuned to `log_size=512` and `cronloglevel=9`; remote syslog to `192.168.50.121:514/udp` was tested but reverted because no receiver was deployed. Do not enable OpenClash takeover, do not activate broad non-China split yet, and do not whitelist DNS rebind noise until client attribution is available. See `D:\IDE\AI\network-ops\handoff\shenlan-router-optimization-wan1-20m-2026-06-18-1653.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-router-optimization-wan1-20m-2026-06-18-1653.md`.
Latest WAN split correction/staging: 2026-06-18 15:55 Asia/Shanghai. User clarified the goal is LAN-side domestic/foreign split across different WAN links, not proxy/OpenClash takeover, and there is no subscription URL. OpenClash remains disabled/inactive and should not be used as the primary tool for this no-subscription requirement. Router already has `pbr`, `luci-app-pbr`, `mwan3`, and `luci-app-mwan3`, but both `pbr` and `mwan3` are currently inactive. Current production path remains the conservative dnsmasq-full+nftset domain policy for selected overseas/AI/social domains to WAN1 while WAN2 remains global default. Added disabled staging file `/etc/nftables.d/21-shenlan-nonchina-wan1.nft.disabled` to implement broad China/non-China IPv4 split later: private/internal and China IPv4 stay unmarked on main/WAN2, non-China IPv4 from LAN/H3C side gets mark `0x1` and uses table 100 to WAN1. It is not active; traffic path was not changed. Backup before staging: `/root/shenlan-usage/backups/pre-nonchina-wan1-staging-20260618-155359`. See `D:\IDE\AI\network-ops\handoff\shenlan-lan-domestic-foreign-wan-split-staging-2026-06-18-1555.md`.
Latest VLAN16 AI-site fix: 2026-06-18 15:30 Asia/Shanghai. VLAN16 Marketing clients under the office access switch reported intermittent overseas AI site access. Office access switch `192.168.99.2` was checked: VLAN16 ports `GE0/0/1` and `GE0/0/2` and uplink `GE0/0/25` are up/up, 1G full duplex, 0 CRC/input/output errors, and VLAN16 MACs are present. The fault was isolated to DNS/egress policy after the 10:55 domestic-priority DNS change: domestic upstream DNS returned abnormal IPs for several AI domains, while WAN1/SDWAN DNS `192.168.77.1` returned expected Cloudflare/Google addresses and WAN1 path completed TLS/HTTP. Added AI-domain dnsmasq exceptions to `192.168.77.1`, enabled `/etc/dnsmasq.d/shenlan-ai-domain-wan1.conf`, restarted dnsmasq, and flushed `inet fw4 shenlan_foreign_wan1_v4`; default route, VLANs, H3C, and S5735 config were not changed. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-vlan16-ai-sites-dns-policy-fix-2026-06-18-1530.md`.

Kun/Codex cross-machine resume path: on any machine, first `git pull --rebase` in the shared ops skills repository (`~/Documents/Deepseek` on macair, `C:\Users\gaoxi\Documents\Deepseek` or `D:\Deepseek` on Windows if present). Then read `AGENTS.md`, `codex-skills/shenlan-ops/SKILL.md`, and this file `codex-skills/shenlan-ops/handoff/LATEST-HANDOFF.md`. Prefer synced relative files under `codex-skills/shenlan-ops/handoff/` and `codex-skills/shenlan-ops/references/`; only use local full-fidelity paths like `D:\IDE\AI\network-ops` when running on 12700K and when sensitive local state is required.

Latest office access status snapshot: 2026-06-18 13:40 Asia/Shanghai. After the VLAN16/17/18 OpenWrt return-route repair, the office access switch was checked for traffic and endpoint state. S5735S `GE0/0/25` and H3C `XGE1/0/28` uplink were up, lightly utilized, and had 0 CRC/input/output errors. VLAN16 online ports were `GE0/0/1` and `GE0/0/2`; VLAN17 online ports were `GE0/0/9`, `GE0/0/10`, and `GE0/0/12`; VLAN18 online ports were `GE0/0/18`, `GE0/0/19`, and `GE0/0/24`. H3C sourced pings from VLAN16/17/18 gateways to `223.5.5.5` all passed with 0% loss. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-office-access-status-snapshot-2026-06-18-1335.md`.

Latest office access fix: 2026-06-18 13:35 Asia/Shanghai. Office access clients under VLAN16/17/18 had no Internet even though S5735S access ports, H3C VLAN gateways, and the office uplink were healthy. Root cause was OpenWrt return routes for `192.168.16.0/24`, `192.168.17.0/24`, and `192.168.18.0/24` missing gateway `192.168.99.1`, causing OpenWrt to treat those subnets as directly connected on `eth3.99`. Live routes were repaired and persisted with `gateway 192.168.99.1`; H3C sourced pings from VLAN16/17/18 gateways to public IP now pass with 0% loss. See synced handoff `codex-skills/shenlan-ops/handoff/shenlan-office-access-vlan16-18-openwrt-routefix-2026-06-18-1330.md`.

Latest access-layer handoff: 2026-06-18 12:50 Asia/Shanghai. 12700K finished a USB Ethernet isolation test on the local unmanaged PoE/AP switch. The USB test point received VLAN20 address `192.168.20.2`, and H3C learned it on `GE1/0/3`, confirming both local and remote AP/PoE groups are downstream of H3C `GE1/0/3` through the local PoE switch and its optical uplink. Before changing cabling, synchronized loss appeared from the PoE switch test point and persisted even after disconnecting the remote PoE optical link, so the remote segment was not the sole cause. After replacing the H3C-to-local-PoE copper patch with a new finished cable and moving the USB test point from local PoE port 6 to port 7, repeated 80/120/120-packet parallel tests to VLAN20 gateway, OpenWrt, and public IP were clean. Reconnecting the remote PoE optical link did not reintroduce loss. Current strongest suspect is the old H3C-to-PoE patch cable, previous local PoE port, or previous cable/port combination. Keep the new arrangement unchanged while mac tests the office-side access point. See `D:\IDE\AI\network-ops\handoff\shenlan-poe-switch-usb-test-2026-06-18-1135.md` and synced handoff `codex-skills/shenlan-ops/handoff/shenlan-poe-switch-usb-test-2026-06-18-1135.md`.

Latest DNS log-noise finding: 2026-06-18 12:45 Asia/Shanghai. `dnsmasq` rebind warnings after the 10:55 domestic-priority DNS change are caused by the current public domestic upstreams returning private/special addresses for some public names, not by WAN2 optical modem DNS being used by dnsmasq. Live config has `noresolv=1`, `server=223.5.5.5 119.29.29.29 114.114.114.114`, `allservers=1`, `filter_aaaa=1`, and rebind protection enabled. Examples: `cn.ntp.org.cn` includes `10.48.49.44`, `dns.msftncsi.com` AAAA includes `fd3e:4f5a:5b81::1`, Sogou quality check returns `10.10.10.10`, and `offline.specialcdnstatus.com` returns `169.254.254.254`. Do not disable rebind protection or whitelist these domains casually. Treat this as log noise, not disconnect evidence, and keep OpenWrt DNS/routing unchanged unless explicitly resumed.

Latest decision: 2026-06-18 11:05 Asia/Shanghai. Keep the current OpenWrt/DNS/routing state unchanged while 12700K continues troubleshooting the wireless AP access/jitter issue. Do not make further OpenWrt DNS or routing changes unless the user explicitly resumes this work. Current priority remains stable domestic access; WAN1/SDWAN foreign access remains best-effort pending later upgrade.

Latest change: 2026-06-18 10:55 Asia/Shanghai. Domestic stability was made the priority because WAN1/SDWAN is currently not reliable enough to handle foreign access. OpenWrt client-facing DNS remains `192.168.99.3`, but dnsmasq upstreams were changed to domestic-only DNS `223.5.5.5`, `119.29.29.29`, and `114.114.114.114` with `allservers=1`; WAN1 DNS `192.168.77.1`, Beijing Telecom `219.141.136.10`, and domain-specific foreign upstream rules were removed from dnsmasq's `server` list. WAN2 remains the default route. Wired domestic tests were stable; wireless domestic tests still showed periodic 2.5-5s TCP connect stalls while pings to the wireless gateway had 100-240ms spikes, pointing to wireless/AP/AC/H3C-side jitter rather than OpenWrt DNS/WAN2. See `D:\IDE\AI\network-ops\handoff\shenlan-dnsmasq-full-wan1-split-2026-06-18-1015.md`.

Latest change: 2026-06-18 10:15 Asia/Shanghai. OpenWrt DNS was repaired and upgraded to `dnsmasq-full 2.93` after an interrupted `apk` install left the old `dnsmasq` package half-removed. DNS is now centralized on OpenWrt again: clients keep using `192.168.99.3`, LAN TCP/UDP 53 interception is active, Beijing Telecom `219.141.136.10` is retained with `192.168.77.1` fallback, and foreign domains resolve through `192.168.77.1` while their IPv4 answers are inserted into `inet fw4 shenlan_foreign_wan1_v4` for WAN1 policy routing. See `D:\IDE\AI\network-ops\handoff\shenlan-dnsmasq-full-wan1-split-2026-06-18-1015.md`.

Latest change: 2026-06-18 09:50 Asia/Shanghai. Morning disconnect diagnosis found that OpenWrt itself had intermittent public HTTP failures, so the issue was not isolated to the Mac/VLAN16 client. OpenWrt was changed so WAN2/direct optical modem is the global default route, WAN1/SDWAN is retained for marked policy traffic, and dnsmasq upstream DNS was changed to Beijing Telecom `219.141.136.10` with AAAA filtering. A starter foreign-domain nft mark set was created, but its cron refresh is currently disabled because the installed dnsmasq has `no-ipset no-nftset` and the helper resolver may add DNS pressure. See `D:\IDE\AI\network-ops\handoff\shenlan-wan2-default-dns-adjustment-2026-06-18-0950.md`.

Latest probe expansion: 2026-06-18 08:20 Asia/Shanghai. Added HTTP/HTTPS and DNS health probes to OpenWrt 1-minute collector so future public ICMP loss can be distinguished from real web/DNS reachability failure. New files: `/root/shenlan-usage/health/http-health-YYYY-MM-DD.csv` and `/root/shenlan-usage/health/dns-health-YYYY-MM-DD.csv`. See `D:\IDE\AI\network-ops\handoff\shenlan-http-dns-health-probes-2026-06-18-0820.md`.

Stage summary: 2026-06-18. The recent upload limiting, flash-disconnect diagnosis, `nlbwmon` stop, overnight findings, and HTTP/DNS probe expansion are summarized in `D:\IDE\AI\network-ops\handoff\shenlan-flap-traffic-stage-summary-2026-06-18.md`.

Latest live event: 2026-06-17 19:00 Asia/Shanghai. User reported another short disconnect around 18:48. The 1-minute OpenWrt health probe captured a matching 18:45 event: H3C core, WAN1 gateway, and WAN2 gateway were reachable, while both public targets had 100% loss for that minute. OpenWrt simultaneously logged a large `nlbwmon` MAC lookup storm. `nlbwmon` was temporarily stopped at about 18:52 and stayed inactive; public probes from 18:53 onward were healthy. See `D:\IDE\AI\network-ops\handoff\shenlan-flap-event-nlbwmon-stop-2026-06-17-1900.md`.

Latest continuation: 2026-06-17 17:35 Asia/Shanghai. See `D:\IDE\AI\network-ops\handoff\shenlan-traffic-dns-observation-2026-06-17-1730.md`.
Latest change: 2026-06-17 17:58 Asia/Shanghai. Temporary host upload limits were applied on OpenWrt for `192.168.10.16` and `192.168.10.60`; see `D:\IDE\AI\network-ops\handoff\openwrt-host-upload-rate-limit-2026-06-17-1758.md`.
Latest troubleshooting: 2026-06-17 18:20 Asia/Shanghai. User reported frequent short disconnects. No router reboot, WAN1 link flap, or internal management packet loss was found during the check window. OpenWrt `nlbwmon` was flooding logs with netlink/conntrack buffer errors, so its buffer/refresh settings and kernel receive buffer limit were tuned; see `D:\IDE\AI\network-ops\handoff\shenlan-flap-diagnosis-nlbwmon-tuning-2026-06-17-1820.md`.
Latest observation setup: 2026-06-17 18:35 Asia/Shanghai. Added a 1-minute OpenWrt health probe to observe for one day. Main purpose: analyze short disconnects and the overall traffic situation, identify concrete problem sources, and decide handling/optimization direction; see `D:\IDE\AI\network-ops\handoff\shenlan-24h-health-observation-setup-2026-06-17-1835.md`.

Use this file when a new Codex/Kun conversation needs to continue Shenlan network operations without the full chat history.

## How To Resume

Read these first:

```text
D:\IDE\AI\AGENTS.md
C:\Users\gaoxi\.codex\skills\shenlan-ops\SKILL.md
D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md
```

Then load referenced files only as needed.

## Current Objective

The Shenlan site network is online. OpenWrt x86 N150 replaced ER5200G3 as the main router. H3C core remains the internal L3 gateway and DHCP server. ER5200G3 remains router-mode but is only used as AC/MiniAP controller with ordinary DHCP disabled.

Near-term work:

1. Hold the current OpenWrt DNS/routing state while 12700K investigates wireless AP access/jitter. Do not change OpenWrt DNS/routing again unless explicitly requested.
2. Observe the 2026-06-18 10:55 domestic-priority DNS change: WAN2 is still the global default route, client DNS remains centralized on OpenWrt `192.168.99.3`, dnsmasq now uses domestic-only upstreams `223.5.5.5`, `119.29.29.29`, and `114.114.114.114` with `allservers=1`, and WAN1/SDWAN is no longer used as a DNS dependency. Watch whether wired domestic browsing remains stable.
3. Continue wireless/AP access-layer isolation from the office-side test point. The 12700K PoE-switch USB test became clean only after replacing the H3C-to-local-PoE cable and moving the test point from local PoE port 6 to port 7; remote PoE optical reconnect stayed clean. Mac should now test at the office access point without changing OpenWrt DNS/routing: record exact time, wired/wireless test point, source IP/VLAN, and simultaneous results to local gateway, OpenWrt `192.168.99.3`, public IP, HTTP, and DNS. If stalls recur, correlate that minute with OpenWrt health files and H3C logs/counters.
4. Continue observing whether reported short disconnects stop while OpenWrt `nlbwmon` is temporarily inactive. The 18:45 event strongly implicated `nlbwmon` telemetry pressure: WAN gateways stayed reachable, both public probes failed for one minute, and an `nlbwmon` MAC lookup storm occurred at the same time. If reports continue while `nlbwmon` remains inactive, inspect the exact probe minute and collect longer probes from an affected client/VLAN to gateway, OpenWrt, WAN1 gateway, public IP, and DNS.
5. After one day of observation, analyze both flash-disconnect evidence and overall traffic/optimization direction: loss/latency by layer, interface error deltas, nlbwmon health, rate-limit hits, heavy clients/VLANs, WAN utilization, and SQM drops/overlimits.
6. Continue observing DHCP/DNS stability after the H3C DNS fix.
7. Observe the OpenWrt host upload limits. `192.168.10.16` and `192.168.10.60` are each limited to about `8Mbit/s` WAN upload using nftables `limit rate over 1000 kbytes/second drop`; counters remained `0` during the 18:20 flash-disconnect diagnosis.
8. Fix backup/report sync to QNAP. Latest reporting run synced WPS and fnOS, but QNAP failed with an SMB username/password error.
9. Deploy scheduled backups, monitoring, reports, and optional WPS/Feishu sync on `192.168.50.121`.
10. Later, optionally rebuild H3C DHCP pools with English names during a maintenance window.

## Device Roles

| Device | Address | Role |
|---|---:|---|
| OpenWrt main router | `192.168.99.3` | Egress/NAT/DNS/QoS/policy routing |
| OpenWrt local rescue LAN | `192.168.7.1` | Local management/rescue |
| H3C core switch | `192.168.99.1` | L3 gateway/VLAN/DHCP |
| ER5200G3 | `192.168.99.4` | AC/MiniAP controller, ordinary DHCP disabled |
| ER5200G3 rescue | `192.168.9.254` | VLAN1/LAN4 rescue management |
| Central control/NTP/SNMP trap | `192.168.50.120` | NTP, SNMP trap, central control |
| Ops service target | `192.168.50.121` | Future backup/monitoring/report service host |
| QNAP NAS | `192.168.30.145` | Primary backup target |
| fnOS NAS | `192.168.50.254:5666` | Secondary backup target |

Credentials exist in local skill/reference files and prior environment. Treat them as sensitive; do not print passwords unless explicitly required.

## Current DNS Standard

Client DHCP DNS must be:

```text
192.168.99.3
```

OpenWrt upstream DNS currently standardized to:

```text
223.5.5.5
119.29.29.29
114.114.114.114
```

Reason: 2026-06-18 domestic stability priority. WAN1/SDWAN DNS `192.168.77.1` and Beijing Telecom `219.141.136.10` were removed from the client DNS upstream path. dnsmasq uses these three domestic upstreams with `allservers=1`; OpenWrt DNS interception for TCP/UDP 53 from LAN side remains active.

## H3C DHCP DNS Fix Completed

Status: completed and verified.

Actions completed:

- All active H3C DHCP pools now hand out DNS `192.168.99.3`.
- Old DNS removed from H3C DHCP config:
  - `223.5.5.5`
  - `119.29.29.29`
- Bad duplicate/empty mojibake DHCP pool removed.
- Empty unused DHCP pools `80` and `110` removed.
- H3C `save force` completed.
- H3C Web DHCP pool page recovered and now displays pools.

Latest H3C backup:

```text
D:\IDE\AI\network-ops\backups\h3c-after-dhcp-dns-web-fix-20260617-160613.txt
```

Detailed fix record:

```text
D:\IDE\AI\network-ops\handoff\h3c-dhcp-dns-web-fix-2026-06-17-1600.md
```

## Active H3C DHCP Pools

| Pool | Network | Gateway | DNS |
|---|---|---|---|
| `有线办公` | `192.168.10.0/24` | `192.168.10.1` | `192.168.99.3` |
| `接待厅` | `192.168.19.0/24` | `192.168.19.1` | `192.168.99.3` |
| `无线管理` | `192.168.20.0/24` | `192.168.20.1` | `192.168.99.3` |
| `NAS存储` | `192.168.30.0/24` | `192.168.30.1` | `192.168.99.3` |
| `监控网络` | `192.168.40.0/24` | `192.168.40.1` | `192.168.99.3` |
| `无线业务` | `192.168.60.0/23` | `192.168.60.1` | `192.168.99.3` |
| `工作坊` | `192.168.70.0/24` | `192.168.70.1` | `192.168.99.3` |
| `2号厅` | `192.168.80.0/24` | `192.168.80.1` | `192.168.99.3` |
| `XR影棚` | `192.168.90.0/24` | `192.168.90.1` | `192.168.99.3` |
| `120` | `192.168.120.0/24` | `192.168.120.1` | `192.168.99.3` |
| `vlan16` | `192.168.16.0/24` | `192.168.16.1` | `192.168.99.3` |
| `vlan17` | `192.168.17.0/24` | `192.168.17.1` | `192.168.99.3` |
| `vlan18` | `192.168.18.0/24` | `192.168.18.1` | `192.168.99.3` |

Important H3C encoding warning:

- H3C CLI stores/displays Chinese object names in GBK/CP936.
- Do not send normal UTF-8 Chinese commands through raw SSH/plink to modify Chinese-named objects.
- If Chinese object modification is unavoidable, use a GBK/CP936 encoded command file.
- Better long-term option: rebuild DHCP pools as English names during a maintenance window.

Suggested future English DHCP pool names:

| Current | Suggested |
|---|---|
| `有线办公` | `vlan10-office` |
| `接待厅` | `vlan19-reception` |
| `无线管理` | `vlan20-wifi-mgmt` |
| `NAS存储` | `vlan30-nas` |
| `监控网络` | `vlan40-surveillance` |
| `无线业务` | `vlan60-wifi-client` |
| `工作坊` | `vlan70-workshop` |
| `2号厅` | `vlan80-hall2` |
| `XR影棚` | `vlan90-xr-studio` |
| `120` | `vlan120-temp` |

## H3C VLAN Baseline

VLAN cleanup already completed:

- VLAN11/12/13 deleted.
- Vlan-interface11/12/13 deleted.
- DHCP pools `vlan11/vlan12/vlan13` deleted.
- VLAN16 description `Marketing`.
- VLAN17 description `Training`.
- VLAN18 description `AI-Innovation`.
- VLAN201 description `Optical-Modem`.

Key VLANs:

| VLAN | Purpose | Gateway |
|---:|---|---|
| 10 | Wired office | `192.168.10.1/24` |
| 16 | Marketing | `192.168.16.1/24` |
| 17 | Training | `192.168.17.1/24` |
| 18 | AI-Innovation | `192.168.18.1/24` |
| 19 | Reception | `192.168.19.1/24` |
| 20 | Wi-Fi/AP management | `192.168.20.1/24` |
| 30 | NAS storage | `192.168.30.1/24` |
| 40 | Surveillance | `192.168.40.1/24` |
| 50 | Showroom/server/central control | `192.168.50.1/23` |
| 60 | Wi-Fi clients | `192.168.60.1/23` |
| 70 | Workshop | `192.168.70.1/24` |
| 80 | Hall 2 | `192.168.80.1/24` |
| 90 | XR studio | `192.168.90.1/24` |
| 99 | Core/router/AC management | `192.168.99.1/24` |
| 120 | Temporary/free DHCP | `192.168.120.1/24` |
| 201 | Optical modem | `172.16.201.254/24` |

H3C default route:

```text
0.0.0.0/0 -> 192.168.99.3
```

## OpenWrt Baseline

| Interface | Role |
|---|---|
| `eth0 / br-lan` | Local management LAN, `192.168.7.1/24` |
| `eth1` | WAN1, SDWAN uplink |
| `eth2` | WAN2, direct optical modem |
| `eth3.99` | H3C core VLAN99, `192.168.99.3/24` |

OpenWrt static routes to internal VLANs use next hop:

```text
192.168.99.1
```

Internal routes include:

```text
172.16.201.0/24
192.168.10.0/24
192.168.16.0/24
192.168.17.0/24
192.168.18.0/24
192.168.19.0/24
192.168.20.0/24
192.168.30.0/24
192.168.40.0/24
192.168.50.0/23
192.168.60.0/23
192.168.70.0/24
192.168.80.0/24
192.168.90.0/24
192.168.110.0/24
192.168.120.0/24
```

OpenWrt IPv6 was disabled earlier. DNS interception is active. SQM/QoS optimization is pending after traffic data collection.

## ER5200G3 / AC Baseline

ER5200G3 cannot be changed to pure AC mode per vendor. It remains in router mode but is used only as AC/MiniAP controller. Ordinary DHCP is disabled.

Formal management:

```text
http://192.168.99.4/router_index.html
```

Rescue management:

```text
http://192.168.9.254
```

Core switch port to ER5200G3:

```text
H3C GE1/0/12
trunk permit VLAN 20 60 99
PVID 99
```

Wi-Fi service bridges to VLAN60. H3C core provides VLAN60 gateway/DHCP.

SSIDs:

| Band | SSID | VLAN |
|---|---|---:|
| 2.4G | `shenlan2.4g` | 60 |
| 5G | `shenlan_5G` | 60 |

Passwords are recorded in local sensitive references/history; do not print unless needed.

## H3C Access Notes

SSH works to:

```text
admin@192.168.99.1
```

Use PuTTY plink on this Windows host:

```powershell
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' admin@192.168.99.1 "display version"
```

Reliable read pattern:

```powershell
$cmd='D:\IDE\AI\network-ops\state\h3c-display.cmds'
Set-Content -Path $cmd -Value "screen-length disable`ndisplay current-configuration`nquit`n" -Encoding ascii
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' -m $cmd admin@192.168.99.1
```

GBK command-file pattern for Chinese object changes:

```powershell
$path='D:\IDE\AI\network-ops\state\h3c-gbk-change.cmds'
$enc=[Text.Encoding]::GetEncoding(936)
[IO.File]::WriteAllBytes($path, $enc.GetBytes(($lines -join "`r`n") + "`r`n"))
& 'C:\Program Files\PuTTY\plink.exe' -ssh -batch -pw '<password>' -m $path admin@192.168.99.1
```

## Backup And Monitoring Plan

User requirements:

1. Scheduled config backup to NAS at 03:00.
2. Config changes should update a table view; WPS remote view is desired.
3. Monitor OpenWrt and H3C core status, traffic, temperature, and services.
4. Later integrate with central control system or independent dashboard/tool.
5. Services should run on `192.168.50.121`, not the current PC.

NAS targets:

| NAS | Address | Role |
|---|---|---|
| QNAP | `192.168.30.145` | Primary backup target |
| fnOS | `192.168.50.254:5666` | Secondary backup target |

Feishu Base/WPS discussion:

- Feishu Base is suitable for device inventory, VLAN/IP records, backup logs, alerts, and operations history.
- Alert target might be the existing central-control ops group, or a new group.
- Account/IP/backup path visibility should be limited to group owner/admins.
- This was noted for later; not implemented yet.

## Traffic/QoS Plan

Current stability test: OpenWrt `nlbwmon` is stopped as of about 2026-06-17 18:52. Do not restart it during the overnight observation unless explicitly needed. The health script now records `nlbwmon_error_latest`; treat repeated old 18:45 log lines as historical unless the latest timestamp advances.

Current temporary limiter:

- OpenWrt file: `/etc/nftables.d/30-shenlan-rate-limit.nft`.
- Hosts: `192.168.10.16`, `192.168.10.60`.
- Match: forwarded traffic from those source IPs going out WAN interfaces `eth1` or `eth2`.
- Limit: each host about `1000 kbytes/second`, around `8Mbit/s`; excess packets dropped.
- Rollback: `rm -f /etc/nftables.d/30-shenlan-rate-limit.nft && fw4 reload`.
- During the 2026-06-17 18:20 flash-disconnect diagnosis, both limiter rules still had `0 packets / 0 bytes`, so the limiter had not triggered and was not implicated by observed counters.

Bandwidth: around 1000M down / 50M up.

User wants automatic throttling of large uploads/downloads, not crude static limits. WAN1 goes through SDWAN and speed test being lower was considered reasonable. WAN2 is direct optical modem.

Pending approach:

Latest observation:

- OpenWrt usage collection is active every 5 minutes under `/root/shenlan-usage`.
- Local analysis files were pulled to `D:\IDE\AI\network-ops\state\openwrt-usage-20260617`.
- VLAN10 is the main upload pressure: `192.168.10.16` uploaded about 177.62 GB in nlbwmon data; `192.168.10.60` uploaded about 39.45 GB.
- VLAN60 is the main download volume but upload is moderate.
- WAN1 carries almost all traffic. WAN2 is up but nearly idle.
- `tc -s qdisc` shows WAN1 upload CAKE at 46Mbit with millions of drops/overlimits, while WAN1 download at 950Mbit has minimal drops. Upload is the real congestion point.

Pending approach:

- Identify owner/business role of heavy upload IPs before applying host/VLAN restrictions.
- Keep CAKE near `950M/46M` until latency-under-load is tested.
- Consider host/VLAN throttling, qosify marking, or WAN2 offload only after user confirms policy goals.

## VLAN-Based WAN Policy Routing Plan

User asked whether VLANs can be steered to WAN1 or WAN2. Yes.

Possible future design:

- Default office/Wi-Fi through WAN1/SDWAN.
- Selected VLANs or test/high-bandwidth VLANs through WAN2/direct optical modem.
- Optionally combine with domain/IP-set routing for domestic/overseas split.

Do not implement until user confirms which VLANs should use which WAN.

## Important Files

```text
D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md
D:\IDE\AI\network-ops\handoff\shenlan-wan2-default-dns-adjustment-2026-06-18-0950.md
D:\IDE\AI\network-ops\handoff\shenlan-flap-traffic-stage-summary-2026-06-18.md
D:\IDE\AI\network-ops\handoff\shenlan-24h-health-observation-setup-2026-06-17-1835.md
D:\IDE\AI\network-ops\handoff\shenlan-flap-diagnosis-nlbwmon-tuning-2026-06-17-1820.md
D:\IDE\AI\network-ops\handoff\shenlan-traffic-dns-observation-2026-06-17-1730.md
D:\IDE\AI\network-ops\handoff\openwrt-host-upload-rate-limit-2026-06-17-1758.md
D:\IDE\AI\network-ops\handoff\h3c-dhcp-dns-web-fix-2026-06-17-1600.md
D:\IDE\AI\network-ops\handoff\h3c-vlan-cleanup-2026-06-17-1530.md
D:\IDE\AI\network-ops\handoff\shenlan-dns-vlan-standard-2026-06-17.md
D:\IDE\AI\network-ops\inventory\shenlan-network-standard.json
D:\IDE\AI\network-ops\backups\h3c-after-dhcp-dns-web-fix-20260617-160613.txt
D:\IDE\AI\network-ops\backups\openwrt\openwrt-config-20260617-172825.tar.gz
D:\IDE\AI\network-ops\backups\openwrt\openwrt-before-rate-limit-20260617-175328.tar.gz
D:\IDE\AI\network-ops\backups\openwrt\openwrt-dns-standard-20260617-150738.tar.gz
```

## One-Line User Prompt For New Conversation

```text
继续深澜网络运维，请先读取 D:\IDE\AI\AGENTS.md、shenlan-ops 技能和 D:\IDE\AI\network-ops\handoff\LATEST-HANDOFF.md，然后按接力文件继续，不要从头猜。
```
