# 2026-06-23 Shenlan switch asset catalog and CLI diagnostics

## Background

The user provided a switch model list screenshot and then asked to review Kun's整理结果, check related documentation, identify missing information, and especially add per-brand command-line troubleshooting rules. This needed to be captured in the private Shenlan operations knowledge base so switch asset facts and readonly diagnostics are reusable across machines and agents.

## Changes

- Reviewed Kun-created switch model documents under `D:\shenlan-network-ops\inventory\devices\switches\`.
- Added individual pages for live devices `h3c-s5130v2-28s-li.md` and `huawei-s5735s-l24t4s-qa2.md`.
- Updated `switch-catalog.md` with a CLI diagnostics reference, safer wording around unverified specs, and a fixed `core-devices.md` link.
- Added `runbooks/switch-cli-readonly-diagnostics.md` covering H3C Comware, Huawei VRP/CloudEngine, Huawei S1730S Web-managed switches, TP-LINK managed switches, and TP-LINK TL-ST1008 unmanaged behavior.
- Updated `docs/open-questions.md` with missing field prompts for deployment status, physical location, management IP/VLAN, uplink/downlink ports, CLI support, PoE budget, and 10G link details.
- Committed and pushed `xinping7841/shenlan-network-ops` commit `00122bf` on `main`.

## Why This Way

The switch model catalog belongs in `shenlan-network-ops` because it is sanitized long-lived network asset knowledge, while raw configs and credentials remain out of Git. A separate CLI runbook avoids mixing vendor command habits into model spec pages and gives future agents a readonly troubleshooting boundary before any live change work.

## Alternatives Not Taken

- Did not SSH to live switches or run commands in this turn; the task was documentation review/enrichment, and credentials/raw output are sensitive.
- Did not commit raw configs, logs, packet captures, SNMP credentials, or password material.
- Did not rewrite README encoding/wording even though PowerShell displayed some Chinese as mojibake; that would be unrelated churn.

## Validation

- `git -C D:\shenlan-network-ops diff --cached --check` passed with only Windows LF-to-CRLF warnings before commit.
- `rg` sensitive-pattern scan over the switch inventory/runbook/open-questions files found only secret-reference guidance and no actual credentials.
- `git -C D:\shenlan-network-ops push` succeeded: `75c200f..00122bf main -> main`.
- Final `git -C D:\shenlan-network-ops status --short --branch` returned clean `## main...origin/main`.

## Risks

- Several Kun-created model pages still contain planning/spec values that should be verified against exact official submodel docs or physical labels before being treated as procurement-grade facts.
- Most listed switches except H3C core and S5735S office access remain deployment-state unknown: physical location, management IP, upstream/downstream ports, NetBox/LibreNMS onboarding, and CLI support still need onsite confirmation.
- TP-LINK CLI command support varies by firmware; the runbook intentionally marks those commands as candidates to verify with `?`/Web/SNMP on the actual device.

## Machine / Sync Impact

- [x] Does not affect long-lived machine or sync documentation.
- [ ] Updated `memory/machines/...`:
- [ ] Updated `memory/sync/...`:
- [x] Updated relevant runbook: `D:\shenlan-network-ops\runbooks\switch-cli-readonly-diagnostics.md`.

## Handoff Notes

For future Shenlan switch work, read `D:\shenlan-network-ops\inventory\devices\switches\switch-catalog.md` and `D:\shenlan-network-ops\runbooks\switch-cli-readonly-diagnostics.md` first. For live changes, still start with `runbooks/pre-change-safety-check.md`, current NetBox/LibreNMS state on `node-121`, and a confirmed recent backup.

## Related Files

- `D:\shenlan-network-ops\inventory\devices\switches\switch-catalog.md`
- `D:\shenlan-network-ops\inventory\devices\switches\h3c-s5130v2-28s-li.md`
- `D:\shenlan-network-ops\inventory\devices\switches\huawei-s5735s-l24t4s-qa2.md`
- `D:\shenlan-network-ops\runbooks\switch-cli-readonly-diagnostics.md`
- `D:\shenlan-network-ops\docs\open-questions.md`
