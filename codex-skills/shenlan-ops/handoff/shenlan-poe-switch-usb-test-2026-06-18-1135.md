# Shenlan PoE Switch USB Test - 2026-06-18 11:35

## Summary

12700K connected a Windows USB Ethernet adapter to the local unmanaged PoE/AP switch to isolate the wireless/AP access-layer issue. The adapter received VLAN20/AP-management address `192.168.20.2/24`, proving that the local PoE/AP switch path lands on H3C core `GE1/0/3`.

Current confirmed AP/PoE topology:

```text
H3C GE1/0/3
  -> local unmanaged PoE switch port 8
      -> local PoE optical port
          -> remote machine-room PoE optical port
              -> another group of APs
```

Both local and remote AP groups are downstream of H3C `GE1/0/3`. H3C `XGE1/0/28` is separate and currently permits VLAN `1/10/16/17/18/99`, not AP VLAN20/60.

## Test Point

USB Ethernet adapter on 12700K:

```text
Interface: Windows "以太网 4"
MAC: 00-E0-4C-68-00-8E
IP: 192.168.20.2/24
Gateway: 192.168.20.1
DNS: 192.168.99.3
Link: 1 Gbps
H3C learned MAC/IP on GE1/0/3
```

H3C `GE1/0/3` during checks:

```text
UP, 1G full-duplex
Trunk, PVID 20, permits VLAN20/60
0 input errors, 0 CRC, 0 output errors
```

## Findings Before Cable/Port Change

With USB on the local PoE switch and the remote optical link connected, parallel pings from `192.168.20.2` showed synchronized short loss to:

```text
192.168.20.1
192.168.99.3
223.5.5.5
```

After disconnecting the remote PoE optical link, synchronized loss still appeared, about `54/60` received to all three targets. This means the remote fiber/remote PoE segment was not the sole cause.

Local USB adapter and H3C `GE1/0/3` counters remained clean. The issue looked like an intermittent access-layer path problem behind or around the local PoE switch/uplink arrangement, not WAN/DNS.

## Physical Change

User changed the local access setup:

```text
H3C-to-local-PoE copper patch cable replaced with a new finished cable.
USB test point moved from local PoE port 6 to local PoE port 7.
```

H3C `GE1/0/3` had one expected down/up around 12:01 during the cable replacement, then stayed UP at 1G full-duplex.

## Results After Cable/Port Change

After the new cable / local PoE port arrangement:

```text
80-packet parallel test: 0% loss to 192.168.20.1, 192.168.99.3, 223.5.5.5
120-packet follow-up:    0% loss to all three targets
```

Before reconnecting the remote PoE optical link:

```text
120/120 to all three targets, 0% loss
```

After reconnecting the remote PoE optical link:

```text
120/120 to all three targets, 0% loss
H3C GE1/0/3 stayed UP, 1G full-duplex, 0 CRC/input/output errors
No new GE1/0/3 flap after the expected 12:01 cable-change event
```

## Current Interpretation

The strongest current suspect is the old H3C-to-PoE patch cable, previous local PoE port, or previous cable/port combination.

The remote fiber/remote PoE segment did not immediately reintroduce loss after reconnect, but should still be observed under normal AP/client load.

H3C gateway ICMP spikes to `192.168.20.1` continued during otherwise clean tests. Treat H3C gateway ping latency spikes carefully; they may be control-plane ICMP scheduling. Forwarded targets such as `192.168.99.3`, public IP, HTTP, and DNS are more meaningful for user-impact correlation.

## Separate Items To Check Later

- VLAN60 duplicate IP conflict logs appeared on H3C `GE1/0/3` around 09:08-09:28 for several `192.168.60.x` addresses.
- H3C `GE1/0/21` / `TO-SKS3200-Room` had real physical flaps today, but appears separate from the AP trunk.
- H3C logs include an older STP dispute event on `GigabitEthernet1/0/6` around 10:20. Check against the physical patch map later. Do not confuse H3C `GE1/0/6` with local unmanaged PoE port 6.

## Guidance For Mac Office Access Test

When mac goes to the office access switch/AP area, continue from this state:

1. Keep the new H3C-to-PoE cable and current local PoE port arrangement unchanged.
2. Test from the office-side access point as a client of the access layer, not by changing OpenWrt DNS/routing.
3. Run simultaneous tests to at least:
   - local VLAN gateway
   - OpenWrt `192.168.99.3`
   - a public IP such as `223.5.5.5`
   - HTTP/DNS if possible
4. If a stall/loss happens, record exact time and whether gateway, OpenWrt, public IP, HTTP, and DNS failed together.
5. Compare with OpenWrt 1-minute health files and H3C logs/counters after the event.

Current priority remains wireless/AP/access-layer jitter isolation. Do not restart `nlbwmon` and do not change OpenWrt DNS/routing unless the user explicitly resumes that work.
