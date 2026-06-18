# Shenlan Office Access VLAN16/17/18 OpenWrt Route Fix - 2026-06-18 13:30

Updated: 2026-06-18 13:35 Asia/Shanghai

## Trigger

During office access troubleshooting, the user connected a laptop directly to office access switch port 12. The laptop received `192.168.17.15` but had no Internet. The user then reported that other access points below the office access switch also had no network.

## Devices / Scope

- OpenWrt main router: `192.168.99.3`
- H3C core switch: `192.168.99.1`
- Office access switch: `S5735S-Office-Access`, management `192.168.99.2`
- Office access uplink: S5735S `GE0/0/25` -> H3C `XGE1/0/28`
- Affected VLANs: `16`, `17`, `18`
- Test laptop: `192.168.17.15`, MAC `a82b-dd5d-de2b`, learned on S5735S `GE0/0/12`

## Findings

This was not a single access port failure.

S5735S/H3C evidence:

- S5735S `GE0/0/12` was up/up, 1G full duplex, 0 CRC/input/output errors.
- S5735S learned laptop MAC `a82b-dd5d-de2b` on VLAN17 via `GE0/0/12`.
- H3C ARP learned `192.168.17.15` on VLAN17 via office access uplink `XGE1/0/28`.
- H3C could ping `192.168.17.15`.
- H3C could ping OpenWrt `192.168.99.3` and public `223.5.5.5` from its default source.
- Before the fix, H3C could not ping OpenWrt/public when sourcing from VLAN17 gateway `192.168.17.1`.

OpenWrt evidence before fix:

```text
192.168.16.0/24 dev eth3.99 proto static scope link
192.168.17.0/24 dev eth3.99 proto static scope link
192.168.18.0/24 dev eth3.99 proto static scope link
```

OpenWrt had route objects for VLAN16/17/18 without `gateway 192.168.99.1`, so it treated those subnets as directly connected on `eth3.99`. Return packets ARPed on VLAN99 instead of routing back through H3C, causing VLAN16/17/18 clients to lose Internet even though H3C and the access switch were healthy.

## Fix Applied

A live route repair was applied first:

```sh
ip route replace 192.168.16.0/24 via 192.168.99.1 dev eth3.99
ip route replace 192.168.17.0/24 via 192.168.99.1 dev eth3.99
ip route replace 192.168.18.0/24 via 192.168.99.1 dev eth3.99
```

After confirming recovery, the OpenWrt network config was persisted:

```sh
uci set network.@route[16].gateway='192.168.99.1'
uci set network.@route[17].gateway='192.168.99.1'
uci set network.@route[18].gateway='192.168.99.1'
uci commit network
```

Backup left on OpenWrt:

```text
/root/network-before-vlan16-18-routefix-20260618-133214.conf
```

## Verification

After the live route fix:

- OpenWrt could ping `192.168.17.15`: 5/5, 0% loss.
- H3C sourced from `192.168.17.1` could ping OpenWrt `192.168.99.3`: 5/5, 0% loss.
- H3C sourced from `192.168.17.1` could ping public `223.5.5.5`: 5/5, 0% loss.

Final cross-VLAN verification:

- OpenWrt routes now resolve VLAN16/17/18 via `192.168.99.1`.
- OpenWrt could ping VLAN gateways `192.168.16.1`, `192.168.17.1`, `192.168.18.1`: all 0% loss in quick tests.
- H3C sourced from `192.168.16.1`, `192.168.17.1`, `192.168.18.1` could ping public `223.5.5.5`: all 0% loss.

## Interpretation

The office access outage for clients in VLAN16/17/18 was caused by incorrect OpenWrt return routes, not by S5735S access ports or H3C gateway health. The earlier GE0/0/2 physical flap remains a separate access-layer event for the VLAN16 downstream segment, but this direct-connect/no-Internet incident was a routing issue on OpenWrt.

## Follow-Up

- Ask onsite user to retest the laptop on port 12 and other office access clients.
- If clients still show no Internet, check client-side gateway/DNS and whether they renewed DHCP after the outage.
- Audit OpenWrt `/etc/config/network` route objects later and normalize named route sections for VLAN16/17/18 so future edits are less index-dependent.
- Keep observing access switch logs for real physical flaps, especially S5735S `GE0/0/2` and `GE0/0/12`, but do not conflate those with the resolved return-route fault.
