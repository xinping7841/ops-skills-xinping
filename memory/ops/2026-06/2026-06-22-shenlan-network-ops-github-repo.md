# 2026-06-22 Shenlan Network Ops GitHub Repo

## Background

The user asked to understand the EnlightV v0.6 distributed AI-Ops / DR architecture and turn the currently known Shenlan network environment and services into a GitHub-based network operations knowledge base. The intent is to make future information supplements and staged configuration work easier to coordinate without losing design context or mixing secrets into chat/local scripts.

## Changes

- Created a new private GitHub repository: `xinping7841/shenlan-network-ops`.
- Created local working copy: `/Users/xinping/Documents/shenlan-network-ops`.
- Initial commit: `8746aeb Initialize Shenlan network ops knowledge base`.
- Added sanitized architecture, inventory, plan, runbook, template, decision, and security files.
- The new repository records the current Shenlan roles for OpenWrt, H3C, S5735S, ER5200G3, node-121, QNAP, Feiniu OS, VLANs, and node-121 services, plus the EnlightV v0.6 AI-Ops / DR control-plane direction.
- No live Shenlan network device, `node-121` service, Tailscale route, DNS, VLAN, firewall, UPS, or NAS configuration was changed.

## Why This Way

The new repo is a durable, private, sanitized handoff layer: it is easier to update than a one-off document, safer than copying raw local `network-ops` state, and narrower than the general Deepseek skills repository. It lets future agents and humans add information to stable locations (`inventory/`, `plans/`, `runbooks/`, `templates/`) before implementing Oxidized, node-122 hot standby, UPS/NUT, backups, and AI-Ops Gateway work.

## Alternatives Not Taken

- Did not store the new operating knowledge only in `ops-skills-xinping`; that repo remains the multi-machine skill/config source, while this new repo is a dedicated Shenlan operations knowledge base.
- Did not copy raw backups, `config.json`, logs, reports, Scanopy/LibreNMS/NetBox data exports, or secrets into GitHub.
- Did not create a public repository because the content includes internal topology, service ports, private IPs, and operational plans.
- Did not start configuring production items yet; the requested outcome was to establish the GitHub operations base so staged configuration can follow safely.

## Validation

- Commands run:
  - `git pull --rebase` in `/Users/xinping/Documents/Deepseek` -> already up to date.
  - Extracted text from `/Users/xinping/Downloads/enlightv_aiops_dr_plan_v0_6_optimized.docx` with bundled Python OOXML parsing.
  - Read Shenlan skill references: latest handoff, sanitized inventory, topology, node-121 services, backup/monitoring, DNS/VLAN baseline.
  - Ran sensitive-term scan in `/Users/xinping/Documents/shenlan-network-ops`; hits were policy wording, SNMPv3 labels, and local secret path references only, not actual credentials.
  - `git init -b main`, `git add .`, `git commit -m "Initialize Shenlan network ops knowledge base"`.
  - Created private GitHub repository through GitHub MCP and pushed `main` over SSH.
- Result: private repo exists at `git@github.com:xinping7841/shenlan-network-ops.git` and local `main` tracks `origin/main`.

## Risks

- The new repo contains sanitized private IPs, device roles, service ports, and topology. Keep it private.
- It is not a password vault. Secrets remain in node-local secret files or the chosen password/secret system.
- The first version is documentation and planning only; NetBox, LibreNMS, Scanopy, and live devices remain the operational facts that must be checked before changes.
- If old local scripts or Git history elsewhere contained plaintext device credentials, rotate affected credentials separately.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

For follow-up Shenlan network operations, read the new repo first:

1. `/Users/xinping/Documents/shenlan-network-ops/README.md`
2. `/Users/xinping/Documents/shenlan-network-ops/docs/current-state.md`
3. `/Users/xinping/Documents/shenlan-network-ops/plans/configuration-backlog.md`
4. `/Users/xinping/Documents/shenlan-network-ops/SECURITY.md`

Then cross-check live/source systems as needed: NetBox, LibreNMS, Scanopy on `node-121`, and the Deepseek Shenlan skill references.

## Related Files

- `/Users/xinping/Documents/shenlan-network-ops/README.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/architecture/control-plane.md`
- `/Users/xinping/Documents/shenlan-network-ops/docs/architecture/enlightv-aiops-dr-plan-v0.6-digest.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/devices/core-devices.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/vlans/shenlan-vlans.md`
- `/Users/xinping/Documents/shenlan-network-ops/inventory/services/node-121.md`
- `/Users/xinping/Documents/shenlan-network-ops/plans/configuration-backlog.md`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/pre-change-safety-check.md`
- `/Users/xinping/Documents/shenlan-network-ops/runbooks/update-ops-knowledge.md`
- GitHub: `https://github.com/xinping7841/shenlan-network-ops`
