# Shenlan WAN1 Domain Manager 121 Deployment - 2026-06-18 20:15

## Summary

The WAN1 domain manager has been migrated from the operator PC to the long-term service host `192.168.50.121` (`node-121`). The service is now managed by systemd and listens on the internal LAN only:

```text
http://192.168.50.121:8765/
```

It remains a conservative domain-policy tool for the existing dnsmasq-full + nftset + fwmark WAN1 policy. It does not enable OpenClash, does not enable broad non-China routing, and does not change existing domain policy during deployment.

## 121 Runtime

```text
Host:        192.168.50.121 / node-121
OS:          Ubuntu 24.04, Python 3.12
Service:     shenlan-wan1-domain-manager.service
App path:    /opt/shenlan-network-ops/tools/wan1-domain-manager
Config:      /opt/shenlan-network-ops/config.json
Env/auth:    /etc/shenlan-wan1-domain-manager.env
Bind:        192.168.50.121:8765
User:        lingke01
```

The service is enabled and active:

```text
systemctl is-enabled shenlan-wan1-domain-manager.service -> enabled
systemctl is-active shenlan-wan1-domain-manager.service  -> active
```

Basic auth is enabled because the service binds to a non-local address. The password is stored only on 121 in the private environment file and must not be committed or printed.

## OpenWrt Access Model

A dedicated OpenSSH key was generated on 121 for this service:

```text
/home/lingke01/.ssh/shenlan_openwrt_domain_manager
```

Its public key was added to OpenWrt dropbear authorized keys. 121 can now run key-based commands as `root@192.168.99.3`; verification returned:

```text
openwrt-key-ok
dnsmasq status: running
```

The app was updated to support both execution modes:

- Windows/operator-PC mode: PuTTY plink with password from private local config.
- Linux/121 mode: OpenSSH with a private key and known_hosts from the private 121 config.

Current deployed app server header is `ShenlanDomainManager/1.2`.

## Verification

From 121 using authenticated local API calls:

```text
/api/domains:
dnsmasqRunning: true
domainCount: 68
missingDns: 27

/api/verify figma.com:
wan1SetOk: true
httpStatus: 200
curlRc: 0
ok: true
summary: 可达 HTTP 200
```

From 12700K/admin network:

```text
Test-NetConnection 192.168.50.121 -Port 8765 -> TcpTestSucceeded True
Unauthenticated GET http://192.168.50.121:8765/ -> 401 Unauthorized
```

The previous 27 `Missing DNS` domains were not batch-fixed during migration. Continue using per-row or confirmed batch repair in the UI after human review, because broad Apple/Microsoft/cloud domains are included.

## Operations

Common commands on 121:

```bash
sudo systemctl status shenlan-wan1-domain-manager.service
sudo systemctl restart shenlan-wan1-domain-manager.service
journalctl -u shenlan-wan1-domain-manager.service --no-pager -n 80
```

Update flow from 12700K source:

```powershell
scp D:\IDE\AI\network-ops\tools\wan1-domain-manager\app.py D:\IDE\AI\network-ops\tools\wan1-domain-manager\README.md lingke01@192.168.50.121:/opt/shenlan-network-ops/tools/wan1-domain-manager/
ssh lingke01@192.168.50.121 "sudo systemctl restart shenlan-wan1-domain-manager.service"
```

Keep `/opt/shenlan-network-ops/config.json`, `/etc/shenlan-wan1-domain-manager.env`, and the private SSH key only on 121. Do not copy them to shared Git.

## Current User-Facing Entry

Use:

```text
http://192.168.50.121:8765/
```

The browser will prompt for Basic auth. The username is configured in `/etc/shenlan-wan1-domain-manager.env`; the password is stored on 121 only.
