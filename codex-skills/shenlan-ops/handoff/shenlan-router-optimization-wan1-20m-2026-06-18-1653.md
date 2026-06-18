# Shenlan Router Optimization - WAN1 20M SQM And Service Cleanup

Updated: 2026-06-18 16:53 Asia/Shanghai

## Summary

WAN1/SDWAN was limited symmetrically to 20Mbit/s with SQM CAKE. WAN2/direct optical modem remains the global default route. OpenClash takeover was not enabled; current selected-domain WAN1 steering remains dnsmasq-full + nftset + fwmark only.

## Changes Applied

WAN1 SQM:

```text
sqm.eth1.enabled='1'
sqm.eth1.interface='eth1'
sqm.eth1.download='20000'
sqm.eth1.upload='20000'
sqm.eth1.qdisc='cake'
sqm.eth1.script='piece_of_cake.qos'
sqm.eth1.iqdisc_opts='nat dual-dsthost ingress'
sqm.eth1.eqdisc_opts='nat dual-srchost'
```

Verified by `tc qdisc`:

```text
eth1: cake bandwidth 20Mbit dual-srchost nat
ifb4eth1: cake bandwidth 20Mbit dual-dsthost nat ingress
```

WAN2 SQM unchanged:

```text
sqm.eth2.download='950000'
sqm.eth2.upload='46000'
```

Routing unchanged:

```text
default via 192.168.201.1 dev eth2 metric 10
default via 192.168.77.1 dev eth1 metric 30
fwmark 0x1 -> table 100 -> default via 192.168.77.1 dev eth1
```

Disabled or confirmed inactive:

```text
nlbwmon
openclash
pbr
mwan3
```

Kept enabled/running:

```text
sqm
cron
log
```

Logging tuned:

```text
system.@system[0].log_size='512'
system.@system[0].cronloglevel='9'
```

Remote syslog to `192.168.50.121:514/udp` was tested but reverted because no receiver was deployed and OpenWrt logged send failures. Deploy receiver on `192.168.50.121` before re-enabling remote syslog.

## Rationale

- WAN1/SDWAN had been the unstable/congested path for selected foreign/AI traffic; symmetric CAKE 20M/20M is a conservative stability-first cap.
- `nlbwmon` previously correlated with log/netlink/conntrack pressure during flash-disconnect observation.
- `openclash` is not suitable for the current no-subscription, LAN domestic/foreign WAN split requirement.
- `pbr` and `mwan3` are not active in the current conservative policy path and were disabled to reduce variables.

## Observations

- WAN1 and WAN2 gateways were reachable in quick tests after the change.
- Domestic DNS/public probe quick tests were clean.
- `192.168.50.121` is reachable from OpenWrt.
- H3C core management ping had intermittent latency spikes in earlier checks but later samples were clean; continue correlating with user-visible stalls.
- `eth2` RX dropped still increments slowly without CRC/errors; observe trend before changing driver/offload/queue settings.

## DNS/Rebind Decision

Do not disable DNS rebind protection and do not blanket-whitelist noisy domains yet. Current warnings appear to be from domestic public DNS answers containing private/special addresses. Attribute to clients before whitelisting, especially suspicious names such as `nal.fqoqehwib.com`.

## Pending Follow-Up

1. Observe WAN1 CAKE counters and user experience under 20M/20M.
2. Keep WAN2 as global default; do not activate broad China/non-China split until explicitly approved.
3. Deploy syslog receiver on `192.168.50.121` before enabling OpenWrt remote syslog.
4. Continue watching `eth2` RX dropped deltas, H3C core ping spikes, and public HTTP/DNS probes.
5. Run H3C read-only audit once the active credentials/tooling are confirmed.
6. Attribute DNS rebind warnings to clients before adding whitelist rules.

## Rollback

WAN1 SQM rollback if needed:

```sh
uci set sqm.eth1.download='950000'
uci set sqm.eth1.upload='46000'
uci commit sqm
/etc/init.d/sqm restart
```
