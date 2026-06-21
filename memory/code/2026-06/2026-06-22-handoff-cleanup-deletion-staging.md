# 2026-06-22 Handoff Cleanup Deletion Staging

## Background

During the Deepseek cleanup pass, `scripts/commit-and-handoff.py --dry-run` correctly listed deleted root-level one-off scripts, but marked them as `skip` because the whitelist logic only allowed known shared paths. That was too conservative for cleanup tasks: deleting already-tracked legacy files is different from adding new non-whitelisted files.

## Changes

- Updated `scripts/commit-and-handoff.py` so deleted files that are already tracked by Git are treated as stageable/whitelisted.
- Kept the existing restriction for new or modified non-whitelisted files.
- Updated dry-run display and staging behavior to use the same repository-aware whitelist decision.

## Why This Way

Cleanup work needs to remove historical clutter safely without broadening what new files can enter the repo. Allowing tracked deletions lets the handoff tool commit cleanup diffs while preserving the guardrail against adding machine-private or ad hoc files.

## Alternatives Not Taken

- Manually staging deleted files was skipped because it weakens the value of `commit-and-handoff.py` as the standard gate.
- Adding every removed filename pattern to the positive whitelist was skipped because the whitelist should describe durable assets, not historical clutter.

## Validation

- Run `python3 scripts/commit-and-handoff.py --dry-run` and confirm deleted tracked root files show as `[whitelist]` while new non-whitelisted files would still be skipped.
- Run `python3 scripts/memory-audit.py`.
- Run `git diff --check`.

## Risks

- A deletion of any tracked file can now be staged by the handoff tool. Agents must still inspect the dry-run path list before using `--commit` or `--push`.

## Module Notes Impact

- [x] Does not affect long-lived module documentation.
- [ ] Updated `memory/modules/...`:

## Handoff Notes

Use `scripts/commit-and-handoff.py --dry-run` before cleanup commits. Deleted tracked files are allowed so repo cleanup can be committed, but additions outside the shared asset whitelist should still be treated as suspicious.

## Related Files

- `scripts/commit-and-handoff.py`
- `memory/ops/2026-06/2026-06-22-clean-deepseek-root-temporary-configs.md`
