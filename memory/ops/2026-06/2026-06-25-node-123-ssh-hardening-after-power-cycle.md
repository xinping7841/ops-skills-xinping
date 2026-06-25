# 2026-06-25 node-123 SSH hardening after power-cycle

## Background

After node-123 was power-cycled during Hunyuan3D repair work, SSH briefly appeared unavailable from 12700K. Once the host finished booting, both LAN and Tailscale SSH recovered. The task was to harden the access path so future agents can reliably regain access after reboot or power loss.

## Changes

- Verified `ssh.service` and `ssh.socket` on node-123 are both `enabled` and `active` after boot.
- Verified Tailscale is online for node-123 at `100.119.214.90`.
- Tightened `/home/sl123/.ssh` permissions to `700`, `/home/sl123/.ssh/authorized_keys` to `600`, and `/home/sl123/.ssh/backups` to `700`.
- Backed up `authorized_keys` under `/home/sl123/.ssh/backups/` and removed CR characters from the live file.
- Added local 12700K SSH alias `node-123-lan` alongside `node-123` in `C:\Users\gaoxi\.ssh\config` so LAN access no longer falls back to the wrong default user.
- After sudo access was provided, added root-owned OpenSSH hardening drop-in `/etc/ssh/sshd_config.d/99-codex-hardening.conf` with `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `PermitRootLogin no`, `MaxAuthTries 3`, `X11Forwarding no`, `PubkeyAuthentication yes`, and `UsePAM yes`; validated with `sshd -t` before reloading `ssh`.
- Backed up root SSH config under `/etc/ssh/backups-codex-20260625/` before applying the drop-in.
- Restored RDP by disabling both system and user `gnome-remote-desktop.service`, then enabling and starting `xrdp-sesman.service` and `xrdp.service` so `xrdp` owns TCP/3389.

## Why This Way

The server-side OpenSSH unit and socket were already correctly enabled, so the first pass preserved the working daemon state, fixed user key-file hygiene, and made client aliases explicit. Once sudo was available, the system policy was moved to a dedicated drop-in so it is easy to audit and roll back without rewriting the distro `sshd_config`.

RDP failed because GNOME Remote Desktop was listening on 3389 without configured RDP credentials, while `xrdp` failed to bind the same port and then stopped `xrdp-sesman`. The stable path for this host is now `xrdp` on 3389.

## Alternatives Not Taken

- Did not edit the base `/etc/ssh/sshd_config`; used `/etc/ssh/sshd_config.d/99-codex-hardening.conf` instead.
- Did not keep GNOME Remote Desktop enabled because it conflicts with `xrdp` on 3389 and was denying clients with `Credentials are not set`.
- Did not enable a system-level monitor because existing `ssh.service`, `ssh.socket`, and Tailscale all recovered after boot.

## Validation

- Commands run:
  - `systemctl is-enabled ssh ssh.socket` and `systemctl is-active ssh ssh.socket` on node-123.
  - `tailscale status --self` on node-123.
  - `ssh-keygen -lf ~/.ssh/authorized_keys` after permission and CR cleanup.
  - `ssh node-123-lan 'hostname; whoami; systemctl is-enabled ssh; systemctl is-active ssh'` from 12700K.
  - `ssh node-123-ts 'hostname; whoami; uptime'` from 12700K.
- Result: LAN and Tailscale SSH both succeed as `sl123`; `ssh` and `ssh.socket` are enabled and active; `authorized_keys` has no CR characters and retains four ED25519 authorized key fingerprints.
- Post-sudo validation:
  - `sshd -T` shows `passwordauthentication no`, `kbdinteractiveauthentication no`, `permitrootlogin no`, `maxauthtries 3`, `x11forwarding no`, and `pubkeyauthentication yes`.
  - `ssh -o BatchMode=yes -o PasswordAuthentication=no node-123-lan 'hostname; whoami'` succeeds from 12700K.
  - `systemctl is-active xrdp xrdp-sesman ssh ssh.socket` returns `active` for all four services.
  - `systemctl is-enabled xrdp xrdp-sesman ssh ssh.socket` returns `enabled` for all four services.
  - `gnome-remote-desktop.service` is disabled/inactive at both system and user levels.
  - TCP checks from 12700K: LAN and Tailscale ports 22 and 3389 all return reachable.

## Risks

- SSH password login is now disabled. Future access requires an authorized SSH key or console access.
- RDP should use username `sl123`; earlier `LK123` / `lk123` attempts failed because that user does not exist.
- GNOME Remote Desktop is intentionally disabled. Re-enabling it may steal TCP/3389 from `xrdp` again unless moved to another port and configured with credentials.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [x] Updated `memory/machines/123.md`.
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

For future node-123 access, prefer `ssh node-123-lan` on the Shenlan LAN and `ssh node-123-ts` over Tailscale. If SSH appears down immediately after a power-cycle, allow boot time first, then check both port 22 paths before changing server config.

## Related Files

- Remote user files: `/home/sl123/.ssh/authorized_keys`, `/home/sl123/.ssh/backups/`.
- Remote system SSH drop-in: `/etc/ssh/sshd_config.d/99-codex-hardening.conf`.
- Remote SSH backups: `/etc/ssh/backups-codex-20260625/`.
- Remote RDP services: `xrdp.service`, `xrdp-sesman.service`, `gnome-remote-desktop.service`.
- Local client config: `C:\Users\gaoxi\.ssh\config`.
- Machine memory: `memory/machines/123.md`.
