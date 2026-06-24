# 2026-06-24 Slim Codex Context Injection

## Background

Codex Desktop usage for 2026-06-24 showed about 13.5M real tokens across 215 requests, with input tokens dominating and prompt/cache hit rate reported as 0%. The Deepseek workspace was contributing recurring context through a long project `AGENTS.md`, many registered local Codex skills, and default-enabled heavy plugins/MCP blocks.

## Changes

- Rewrote `AGENTS.md` as a short read-on-demand entry instead of a full topology and duplicated skill index.
- Backed up local Codex config before edits: `C:\Users\gaoxi\.codex\config.toml.before-context-slim-20260624-095241.bak`.
- Slimmed `C:\Users\gaoxi\.codex\config.toml` locally:
  - disabled browser/computer-use/document/spreadsheet/presentation plugins by default;
  - removed always-on MCP server blocks from the default config;
  - kept only high-frequency Deepseek/code/ops skills registered by default.
- Updated `sync.ps1`, `auto-sync.sh`, and `setup-mac.sh` so repo sync/setup still installs and registers repo-managed skills, but no longer scans every local `~/.codex/skills/*` directory and re-registers orphan skills into every thread.

## Why This Way

The large cost pattern was multiplicative: many requests times a large repeated system/project/tool context. The safest fix is to keep durable knowledge in files and skills, but make it load only when the task needs it. Local skills remain on disk and can be re-registered later; this change reduces default prompt size without deleting source material.

## Alternatives Not Taken

- Deleting local orphan skill directories: skipped because some may be useful user-installed skills and deletion is unnecessary for context reduction.
- Removing all skills: skipped because Deepseek operations rely on a small core set for handoff, sync, SSH, MCP, code review, web work, and table/PDF tasks.
- Disabling the sync task: skipped because three-machine sync is still the desired operating model.

## Validation

- Commands run:
  - `git pull --rebase`
  - `python -c "import tomllib; tomllib.load(open(r'C:\Users\gaoxi\.codex\config.toml','rb')); print('toml ok')"`
  - `Select-String -LiteralPath C:\Users\gaoxi\.codex\config.toml -Pattern '^\[skills\.|^\[plugins\.|^\[mcp_servers\.' | Measure-Object`
- Result:
  - Repo was already up to date before edits.
  - Local Codex TOML parsed successfully.
  - Local default registrations were reduced from 62 plugin/skill/MCP blocks to 23 blocks before this memory record, with 17 default skill blocks and no default MCP server blocks.

## Risks

- Some browser, document, spreadsheet, presentation, Figma, Notion, Lark, deploy, or security skills/plugins will not appear by default in new Codex threads. Re-enable the specific skill/plugin when a task needs it.
- Codex Desktop may require restart or new thread creation before the slimmed config fully affects injected context.
- Future setup/sync changes should preserve the rule that orphan local skills are audited but not auto-registered.

## Machine / Sync Impact

- [x] Updated sync/setup behavior: `sync.ps1`, `auto-sync.sh`, `setup-mac.sh`.
- [x] Updated project instruction entry: `AGENTS.md`.
- [ ] Updated `memory/machines/...`.
- [ ] Updated `memory/sync/...`.
- [ ] Updated relevant runbook.

## Handoff Notes

If a missing capability is needed, first re-enable only that specific plugin or `[skills.<name>]` block in `C:\Users\gaoxi\.codex\config.toml`, or restore from the backup path above. Avoid bulk-registering all local skills again unless the user accepts higher per-thread token cost.

## Related Files

- `AGENTS.md`
- `sync.ps1`
- `auto-sync.sh`
- `setup-mac.sh`
- `C:\Users\gaoxi\.codex\config.toml`
