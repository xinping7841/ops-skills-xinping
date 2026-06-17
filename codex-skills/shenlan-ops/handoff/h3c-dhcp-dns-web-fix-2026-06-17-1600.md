# H3C DHCP DNS and Web Pool Cleanup

Updated: 2026-06-17 16:00 Asia/Shanghai

## Summary

The H3C core switch DHCP pools were corrected so all active IPv4 client pools now hand out DNS `192.168.99.3`.

The old external DNS values were removed from DHCP pool configuration:

```text
223.5.5.5
119.29.29.29
```

A bad duplicate DHCP pool created by previous encoding mismatch was removed. Two empty unused pools `80` and `110` were also removed.

## Device

```text
H3C core switch: 192.168.99.1
Role: internal L3 gateway and DHCP server
OpenWrt DNS/router: 192.168.99.3
```

## Active DHCP Pools After Cleanup

| Pool | Network | Gateway | DNS |
|---|---|---|---|
| 120 | 192.168.120.0/24 | 192.168.120.1 | 192.168.99.3 |
| 2号厅 | 192.168.80.0/24 | 192.168.80.1 | 192.168.99.3 |
| NAS存储 | 192.168.30.0/24 | 192.168.30.1 | 192.168.99.3 |
| vlan16 | 192.168.16.0/24 | 192.168.16.1 | 192.168.99.3 |
| vlan17 | 192.168.17.0/24 | 192.168.17.1 | 192.168.99.3 |
| vlan18 | 192.168.18.0/24 | 192.168.18.1 | 192.168.99.3 |
| XR影棚 | 192.168.90.0/24 | 192.168.90.1 | 192.168.99.3 |
| 工作坊 | 192.168.70.0/24 | 192.168.70.1 | 192.168.99.3 |
| 监控网络 | 192.168.40.0/24 | 192.168.40.1 | 192.168.99.3 |
| 接待厅 | 192.168.19.0/24 | 192.168.19.1 | 192.168.99.3 |
| 无线管理 | 192.168.20.0/24 | 192.168.20.1 | 192.168.99.3 |
| 无线业务 | 192.168.60.0/23 | 192.168.60.1 | 192.168.99.3 |
| 有线办公 | 192.168.10.0/24 | 192.168.10.1 | 192.168.99.3 |

## Removed Pools

```text
Bad duplicate/empty UTF-8-mojibake 接待厅 pool
80 empty pool
110 empty pool
```

## Verification Files

```text
D:\IDE\AI\network-ops\backups\h3c-before-dhcp-dns-gbk-fix-20260617-155512.txt
D:\IDE\AI\network-ops\state\h3c-final-after-empty-pool-clean-20260617-155917.txt
```

Final verification showed no remaining `223.5.5.5` or `119.29.29.29` in the H3C current configuration output.

## Operational Note

Chinese DHCP pool names on this H3C CLI require GBK/CP936 encoded command files. Do not send normal UTF-8 Chinese commands over plink/SSH unless intentionally targeting a UTF-8-mojibake object for cleanup.
