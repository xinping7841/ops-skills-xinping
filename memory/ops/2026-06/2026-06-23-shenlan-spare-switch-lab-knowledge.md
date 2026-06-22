# 2026-06-23 Shenlan spare switch lab knowledge

## Background

The user clarified that many listed switches are idle/spare and that the immediate goal is to accumulate vendor knowledge and debugging documentation before hands-on deployment. The Shenlan ops repo needed a separate path for spare-device lab work so future agents do not confuse production readonly troubleshooting with isolated practice, initialization, and preflight validation.

## Changes

- Added `D:\shenlan-network-ops\runbooks\spare-switch-lab-preflight.md` for isolated spare switch practice, initial discovery, vendor CLI habits, Web/SNMP checks, PoE/10G validation, and a sanitized information capture template.
- Added `D:\shenlan-network-ops\docs\switch-knowledge-index.md` as the switch knowledge map, with per-vendor reference priorities and real-device validation points for H3C, Huawei VRP/CloudEngine, Huawei S1730S Web-managed switches, TP-LINK managed switches, and TP-LINK TL-ST1008 unmanaged switches.
- Linked the new documents from `D:\shenlan-network-ops\README.md`, `inventory/devices/switches/switch-catalog.md`, and `runbooks/switch-cli-readonly-diagnostics.md`.
- Updated `D:\shenlan-network-ops\docs\open-questions.md` to explicitly ask which switches are online, spare inventory, planned devices, or unknown, and whether idle units may be factory reset or isolated for lab work.
- Committed and pushed `xinping7841/shenlan-network-ops` commit `d90ddc5` on `main`.

## Why This Way

Production devices and spare devices need different safety rules. The existing CLI runbook remains readonly-first for live or unknown devices; the new spare-device lab runbook allows deeper discovery only after a device is confirmed not to carry production traffic. The knowledge index keeps vendor documentation and validation gaps easy to find before onsite work starts.

## Alternatives Not Taken

- Did not mark any specific unknown switch as idle inventory; the user said many are idle, but exact per-device status still needs onsite confirmation.
- Did not add raw vendor PDFs or downloaded manuals to Git; the repo stores curated links and operational notes instead.
- Did not run live device commands or perform factory resets.

## Validation

- `git -C D:\shenlan-network-ops diff --check` passed apart from Windows LF-to-CRLF warnings.
- Sensitive-pattern scan over `README.md`, `docs`, `runbooks`, and `inventory` found only safety guidance and secret-reference placeholders, not actual credentials.
- `git -C D:\shenlan-network-ops push` succeeded: `00122bf..d90ddc5 main -> main`.
- Final `git -C D:\shenlan-network-ops status --short --branch` returned clean `## main...origin/main`.

## Risks

- The actual spare/online/planned status is still unknown for several models. Do not factory reset or reconfigure a device until its idle status and approval are confirmed.
- TP-LINK CLI support varies by firmware; the knowledge base intentionally treats TP-LINK commands as candidates to validate on each real device.
- Vendor official links may change; the curated knowledge index should be refreshed when exact submodel manuals are collected.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: `D:\shenlan-network-ops\runbooks\spare-switch-lab-preflight.md`.

## Handoff Notes

For Shenlan switch work, read `docs/switch-knowledge-index.md` first, then choose `runbooks/spare-switch-lab-preflight.md` for confirmed idle devices or `runbooks/switch-cli-readonly-diagnostics.md` for online/unknown devices. Before any write operation, factory reset, firmware upgrade, or production cabling change, run the pre-change safety process.

## Related Files

- `D:\shenlan-network-ops\docs\switch-knowledge-index.md`
- `D:\shenlan-network-ops\runbooks\spare-switch-lab-preflight.md`
- `D:\shenlan-network-ops\runbooks\switch-cli-readonly-diagnostics.md`
- `D:\shenlan-network-ops\inventory\devices\switches\switch-catalog.md`
- `D:\shenlan-network-ops\docs\open-questions.md`
