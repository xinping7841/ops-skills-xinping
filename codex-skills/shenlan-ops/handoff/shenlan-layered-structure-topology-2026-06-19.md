# Shenlan Layered Structure Topology

Updated: 2026-06-19 19:45 Asia/Shanghai

## Purpose

User wanted a topology diagram in the style of a clear three-layer operations handoff chart, but based on the actual Shenlan network instead of the example dual-core/firewall architecture.

## Generated Diagram

- `codex-skills/shenlan-ops/diagrams/shenlan-network-layered-structure.svg`

The diagram uses these actual layers:

1. 广域网出口层
   - Upstream Internet / operator links.
   - WAN1 SDWAN.
   - WAN2 optical modem direct link.
   - OpenWrt main router `192.168.99.3` as the real egress/NAT/DNS/QoS/policy-routing node.
2. 核心交换层
   - H3C core switch `192.168.99.1` as the actual L3 core.
   - VLAN gateways and DHCP are recorded as living on H3C.
3. 接入与业务层
   - S5735S office access switch `192.168.99.2` with VLAN10/16/17/18 department access.
   - ER5200G3 AC `192.168.99.4`.
   - node-121 ops services `192.168.50.121`.
   - NAS storage: 威联通 NAS on H3C `Te1/0/27` / VLAN30, and 飞牛 NAS `192.168.50.254` / VLAN50.
   - Downstream candidates such as PoE/small switches/APs remain marked for NetBox cable/interface confirmation.

## Notes

- The diagram intentionally does not include example-only items such as dual core stack, generic next-generation firewall, or VLAN20 finance from the user’s reference block.
- It reuses verified facts from the H3C read-only checks: `Te1/0/27` is VLAN30 10G NAS access, and `Te1/0/28` is the S5735S trunk permitting VLAN `1,10,16-18,99`.
