# Shenlan Topology VLAN/NAS Update

Updated: 2026-06-19 19:30 Asia/Shanghai

## User-Supplied Facts Recorded

- Huawei S5735/S5735S access switch carries four office/department VLANs:
  - VLAN10: 办公设备
  - VLAN16: 市场部
  - VLAN17: 教培部
  - VLAN18: AI 开发部
- H3C is the core switch.
- Business VLAN gateways and DHCP pools are on H3C.
- H3C optical port 27 is believed to be VLAN30, using a 10G optical-to-electrical module, connected to a 威联通 NAS.
- `192.168.50.254` should be 飞牛 NAS.

## Read-Only H3C Verification

Commands were read-only `display` checks through the existing `ssh h3c` wrapper.

### H3C `Ten-GigabitEthernet1/0/27`

Verified:

- Interface state: `UP` / line protocol `UP`.
- Port link type: access.
- PVID: `30`.
- Untagged VLAN: `30`.
- Media type: optical fiber.
- Port hardware type: `10G_BASE_LR_SFP`.
- Speed/duplex: 10Gbps full-duplex.
- `display vlan 30` shows `Ten-GigabitEthernet1/0/27` as an untagged port.
- Learned MAC on the port: `245e-be7d-49fd` in VLAN30.
- LLDP neighbor: none reported.

Conclusion: H3C port 27 is confirmed as the VLAN30 10G NAS access port. The “威联通 NAS” device identity comes from user/site knowledge because LLDP does not advertise a neighbor.

### H3C `Ten-GigabitEthernet1/0/28`

Verified:

- Interface state: `UP` / line protocol `UP`.
- Description: `TO-Huawei5130`.
- Port link type: trunk.
- Permitted/pass VLANs: `1,10,16-18,99`.
- Media type: optical fiber.
- Port hardware type: `1000_BASE_LX_SFP`.
- `display vlan 10/16/17/18` shows VLAN10/16/17/18 tagged on this port.

Conclusion: H3C port 28 is the S5735/S5735S trunk carrying the department VLANs and management VLAN.

## Documentation Updated

- `references/shenlan-network-topology.md`
  - Added H3C core/VLAN/DHCP authority note.
  - Added S5735 department VLAN mapping.
  - Added verified H3C port 27 NAS details.
  - Added `192.168.50.254` as 飞牛 NAS in VLAN50.
- `diagrams/shenlan-network-ops-tree.svg`
  - Updated S5735 node with VLAN10/16/17/18.
  - Added NAS/storage node for VLAN30 威联通 NAS and VLAN50 飞牛 NAS.
  - Updated bottom VLAN ledger for handoff use.

## Remaining Checks

- Confirm the physical access port for `192.168.50.254` 飞牛 NAS through ARP/MAC/Scanopy/NetBox or NAS Web UI.
- Confirm whether the VLAN30 NAS should be named 威联通 NAS or another formal asset name in NetBox.
- Continue resolving LLDP duplicate/multi-port neighbors for H3C `Gi1/0/18`, `Gi1/0/19`, `Gi1/0/24`, and related S5735/FutureMatrix entries.
