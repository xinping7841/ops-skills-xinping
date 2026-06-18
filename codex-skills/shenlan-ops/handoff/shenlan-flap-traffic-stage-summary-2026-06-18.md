# Shenlan Flash Disconnect And Traffic Observation Summary - 2026-06-18

## Scope

This record summarizes the recent Shenlan Space network operations work around short user-visible disconnects, temporary upload limiting, traffic observation, and the added probes for the next analysis window.

## Operating Baseline

- OpenWrt x86 N150 is the main egress/NAT/DNS/QoS/policy-routing device.
- H3C core switch remains internal L3 gateway and DHCP server.
- ER5200G3 remains in router mode but is used only as AC/MiniAP controller; ordinary DHCP is disabled.
- Client DNS standard is `192.168.99.3`.
- OpenWrt upstream DNS is `192.168.77.1`.
- WAN1 is the preferred SDWAN uplink via `eth1`.
- WAN2 is direct optical modem uplink via `eth2` and is currently mostly idle.

## Work Completed

1. Temporary host upload limits were applied on OpenWrt for `192.168.10.16` and `192.168.10.60` at about 8 Mbit/s each.
2. A 1-minute OpenWrt health collector was installed to record gateway/public ICMP probes, interface counters, selected logs, and rate-limit counters.
3. A user-reported short disconnect around 2026-06-17 18:48 was correlated with a 2026-06-17 18:45 probe event.
4. During that event, H3C core, WAN1 gateway, and WAN2 gateway stayed reachable, but both public ICMP targets had 100% loss for that minute.
5. OpenWrt simultaneously logged a large `nlbwmon` MAC lookup storm: `Too many pending MAC address lookups`.
6. `nlbwmon` was stopped at about 2026-06-17 18:52 and kept inactive for observation.
7. Overnight public ICMP loss events still appeared occasionally, but H3C/WAN gateways stayed reachable and there were no new `nlbwmon` errors, link flaps, or WAN DHCP failures.
8. HTTP/HTTPS and DNS probes were added to the 1-minute collector on 2026-06-18 so ICMP-only loss can be separated from real web/DNS reachability failure.

## Current Evidence

The strongest concrete incident is the 2026-06-17 18:45 event:

```text
2026-06-17T18:45:00+08:00,h3c_core,192.168.99.1,0,23.201,67.306
2026-06-17T18:45:00+08:00,wan1_gateway,192.168.77.1,0,0.435,0.491
2026-06-17T18:45:00+08:00,wan2_gateway,192.168.201.1,0,0.688,0.780
2026-06-17T18:45:00+08:00,public_aliyun,223.5.5.5,100,,
2026-06-17T18:45:00+08:00,public_dnspod,119.29.29.29,100,,
```

Related OpenWrt log:

```text
Wed Jun 17 18:45:42 2026 daemon.err nlbwmon[717]: Too many pending MAC address lookups
```

Interpretation so far:

- Internal routing and directly connected WAN gateways did not fail during the captured event.
- The first user-visible short disconnect aligned with public reachability loss and `nlbwmon` telemetry pressure.
- After `nlbwmon` was stopped, remaining overnight events looked more like public ICMP/path behavior or a periodic upstream effect, but this still needs HTTP/DNS correlation.
- WAN1 upload remains the main optimization area because SQM CAKE upload counters show heavy drops/overlimits on a roughly 50 Mbit/s upload link.

## Added Probe Files

OpenWrt now writes:

```text
/root/shenlan-usage/health/health-probes-YYYY-MM-DD.csv
/root/shenlan-usage/health/interface-health-YYYY-MM-DD.csv
/root/shenlan-usage/health/http-health-YYYY-MM-DD.csv
/root/shenlan-usage/health/dns-health-YYYY-MM-DD.csv
```

Latest copies are also placed under:

```text
/root/shenlan-usage/latest/
```

HTTP targets:

- `baidu_http`: `http://www.baidu.com/`
- `aliyun_https`: `https://www.aliyun.com/`

DNS targets:

- `local_baidu`: `127.0.0.1`, `www.baidu.com`
- `upstream_baidu`: `192.168.77.1`, `www.baidu.com`
- `local_aliyun`: `127.0.0.1`, `www.aliyun.com`
- `upstream_aliyun`: `192.168.77.1`, `www.aliyun.com`

## Next Analysis Method

For each minute where public ICMP targets show loss, compare the same timestamp in HTTP and DNS probe CSVs.

- Public ICMP loss plus HTTP/DNS success means likely ICMP/path behavior with low user impact.
- Public ICMP loss plus HTTP failure means real Internet reachability interruption.
- DNS failure only means DNS path or resolver issue.
- Local DNS failure while upstream DNS works means OpenWrt dnsmasq/local resolver issue.
- Local and upstream DNS both fail while gateways stay reachable means upstream DNS/WAN1 path issue beyond the directly connected gateway.

## Current Decisions

- Keep `nlbwmon` stopped during this observation window unless traffic accounting is explicitly needed.
- Keep the temporary host upload limits installed for `192.168.10.16` and `192.168.10.60`; counters should be checked before drawing conclusions.
- Do not change H3C Chinese-named DHCP pools through raw UTF-8 SSH/console.
- Do not implement WAN1/WAN2 VLAN policy routing until VLAN/host policy is confirmed.

## Follow-Up Work

1. Pull another full day of OpenWrt health data.
2. Correlate ICMP, HTTP, DNS, interface counters, logs, and user reports by exact minute.
3. Decide whether short disconnects were caused by `nlbwmon`, upstream path behavior, DNS, or actual WAN reachability loss.
4. Continue upload optimization: identify business owner of heavy upload hosts, tune SQM/qosify, and consider WAN2 offload for selected VLANs/hosts.
5. Move scheduled backup, monitoring, report generation, and optional WPS/Feishu sync to the service host `192.168.50.121`.
