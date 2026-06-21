# 2026-06-22 Engineering Memory Tooling

## Background

The first version of `engineering-handoff-memory` created the memory structure, templates, and audit script. The remaining gap was operational friction: agents still had to remember paths and templates manually, and there was no single handoff command to verify memory discipline or derive a commit message from memory context.

## Changes

- Added `scripts/memory-new.py` to create ops, code, ADR, module, and runbook records from templates.
- Added `scripts/commit-and-handoff.py` to run the memory audit, enforce memory updates for non-memory changes by default, show whitelisted paths, and optionally commit or push with a memory-derived message.
- Extended `scripts/memory-audit.py` with `--require-memory-change` so handoff tooling can turn the existing warning into a blocking check.
- Added `memory/templates/runbook.md` and `memory/runbooks/use-engineering-handoff-memory.md`.
- Ignored Python bytecode output and taught the handoff script to skip generated Python cache files.
- Updated the engineering handoff skill and the top-level Kun skill file to describe the new scripts.

## Why This Way

Small deterministic scripts reduce the chance that future agents create memory files in inconsistent places or skip the handoff gate. The scripts stay dependency-free so they work on macair, 12700K, and lk402 without extra package installation. `commit-and-handoff.py` defaults to a dry, reviewable mode unless `--commit` or `--push` is explicitly passed.

## Alternatives Not Taken

- A Git hook was skipped because hooks are local, easy to bypass, and can create surprising behavior on the Windows machines.
- A full documentation portal was skipped because the immediate need is reliable Markdown generation and handoff checks.
- Fully automatic `LATEST.md` rewriting was skipped because summarizing active risks and next steps still benefits from agent judgment.

## Validation

- Passed `python3 -m py_compile scripts/memory-audit.py scripts/memory-new.py scripts/commit-and-handoff.py`.
- Passed `python3 scripts/memory-audit.py`.
- Passed `python3 scripts/memory-new.py code "Example Change" --dry-run` and `python3 scripts/memory-new.py runbook "Example Runbook" --dry-run`.
- Passed `python3 scripts/commit-and-handoff.py --dry-run`.
- Passed the system skill validator against `codex-skills/engineering-handoff-memory`.
- Passed `git diff --check`.

## Risks

- `commit-and-handoff.py --commit` only stages the same broad whitelist as the sync scripts. Agents should still inspect changed paths before committing.
- The suggested commit message is best-effort and should be reviewed for clarity.
- `LATEST.md` still requires intentional rewriting; the tooling does not infer priorities automatically.

## Module Notes Impact

- [x] Does not affect long-lived module documentation.
- [ ] Updated `memory/modules/...`:

## Handoff Notes

Future agents should use `scripts/memory-new.py` instead of manually copying templates. Use `scripts/commit-and-handoff.py --dry-run` before final response or commit to catch missing memory updates early.

## Related Files

- `scripts/memory-new.py`
- `scripts/commit-and-handoff.py`
- `scripts/memory-audit.py`
- `.gitignore`
- `memory/runbooks/use-engineering-handoff-memory.md`
- `codex-skills/engineering-handoff-memory/SKILL.md`
