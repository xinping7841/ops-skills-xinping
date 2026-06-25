# 2026-06-25 node-123 SSH hardening after power-cycle

## Background

After node-123 was power-cycled during Hunyuan3D repair work, SSH briefly appeared unavailable from 12700K. Once the host finished booting, both LAN and Tailscale SSH recovered. The task was to harden the access path so future agents can reliably regain access after reboot or power loss.

## Changes

- Verified `ssh.service` and `ssh.socket` on node-123 are both `enabled` and `active` after boot.
- Verified Tailscale is online for node-123 at `100.119.214.90`.
- Tightened `/home/sl123/.ssh` permissions to `700`, `/home/sl123/.ssh/authorized_keys` to `600`, and `/home/sl123/.ssh/backups` to `700`.
- Backed up `authorized_keys` under `/home/sl123/.ssh/backups/` and removed CR characters from the live file.
- Added local 12700K SSH alias `node-123-lan` alongside `node-123` in `C:\Users\gaoxi\.ssh\config` so LAN access no longer falls back to the wrong default user.

## Why This Way

The server-side OpenSSH unit and socket were already correctly enabled, so the safest hardening was to preserve the working daemon state, fix user key-file hygiene, and make client aliases explicit. This avoids changing root-owned `sshd_config` without sudo while still addressing the likely recurring failure modes: key parsing, file permissions, and ambiguous local aliases.

## Alternatives Not Taken

- Did not edit `/etc/ssh/sshd_config` because `sl123` does not have passwordless sudo and the current daemon/socket boot state is healthy.
- Did not disable password authentication remotely because that system-level change needs an interactive sudo path and a deliberate rollback window.
- Did not enable a system-level monitor because existing `ssh.service`, `ssh.socket`, and Tailscale all recovered after boot.

## Validation

- Commands run:
  - `systemctl is-enabled ssh ssh.socket` and `systemctl is-active ssh ssh.socket` on node-123.
  - `tailscale status --self` on node-123.
  - `ssh-keygen -lf ~/.ssh/authorized_keys` after permission and CR cleanup.
  - `ssh node-123-lan 'hostname; whoami; systemctl is-enabled ssh; systemctl is-active ssh'` from 12700K.
  - `ssh node-123-ts 'hostname; whoami; uptime'` from 12700K.
- Result: LAN and Tailscale SSH both succeed as `sl123`; `ssh` and `ssh.socket` are enabled and active; `authorized_keys` has no CR characters and retains four ED25519 authorized key fingerprints.

## Risks

- Root-owned SSH policy is still default-ish: `/etc/ssh/sshd_config` has `KbdInteractiveAuthentication no` and `UsePAM yes`, but password-auth policy is not hardened in a drop-in because sudo requires a password.
- `/usr/sbin/sshd -T` as non-root returned `sshd: no hostkeys available -- exiting`; use `sudo sshd -T` from the console if system-level effective config needs auditing.
- If stricter SSH policy is desired, apply a root-owned drop-in from a console session after confirming both LAN and Tailscale sessions remain open.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [x] Updated `memory/machines/123.md`.
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

For future node-123 access, prefer `ssh node-123-lan` on the Shenlan LAN and `ssh node-123-ts` over Tailscale. If SSH appears down immediately after a power-cycle, allow boot time first, then check both port 22 paths before changing server config.

## Related Files

- Remote user files: `/home/sl123/.ssh/authorized_keys`, `/home/sl123/.ssh/backups/`.
- Local client config: `C:\Users\gaoxi\.ssh\config`.
- Machine memory: `memory/machines/123.md`.
