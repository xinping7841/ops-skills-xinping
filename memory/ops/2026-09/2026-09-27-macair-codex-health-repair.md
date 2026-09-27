# 2026-09-27 macair Codex health and archive repair

## Background

The macair Codex installation had an unarchivable-session symptom, a duplicate rollout filename for the active thread, a stale Context7 MCP entry path, and a Node/npm PATH mismatch. The workspace also contained generated Playwright output.

## Changes

- Backed up Codex config, shell startup files, state databases, and the duplicate rollout under `~/.codex/backups_state/health-repair-20260927_223541/`.
- Moved the unindexed duplicate active-thread rollout into the backup directory. The active thread's indexed rollout and writer lock were preserved.
- Changed Context7 and restored filesystem MCP to direct Node 22 paths. Filesystem access is limited to `/Users/xinping/Documents/Deepseek`.
- Reordered mise shims before `~/.local/bin` in `.zshenv`, `.zprofile`, and `.zshrc`, and set `TERM=xterm-256color` when a shell inherits `TERM=dumb`.
- Removed the plaintext `OPENAI_API_KEY` export from `.zprofile`; Codex continues using its local auth file/provider configuration.
- Archived the historical failed-MCP session `019f0dee-2380-7260-9554-a9bf42368c06` successfully.
- Moved generated `.playwright-mcp` output and `.DS_Store` out of the workspace into the repair backup; removed empty generated directories.

## Why This Way

The indexed large rollout was the active session record, while the smaller duplicate had the same thread id but was not referenced by the state database. Moving the duplicate preserves recovery while restoring one-to-one rollout/index agreement. Direct Node paths avoid GUI PATH inheritance drift, and mise-first shell ordering makes Codex and npm resolve to the same Node installation.

## Alternatives Not Taken

- Did not delete SQLite databases or force-stop the active Codex process because the current conversation holds the writer lock.
- Did not archive the current active session; it remains in use and can be archived after this conversation ends.
- Did not update Codex immediately even though `0.157.1` is available; the current `0.142.4` installation is healthy and the update is a separate change.

## Validation

- `codex doctor`: `17 ok`, `0 warn`, `0 fail`; state, rollout, auth, MCP, provider reachability, and install consistency passed.
- `codex mcp list`: six configured stdio servers, with Context7 and filesystem using existing absolute paths.
- Filesystem MCP stdio initialize handshake returned `secure-filesystem-server 0.2.0` successfully.
- `codex archive 019f0dee-2380-7260-9554-a9bf42368c06`: succeeded and moved the rollout to `archived_sessions`.
- State database `pragma integrity_check`: `ok`; active rollout files and state DB inventory agree.
- Fresh login shell resolves Node `24.17.0`, npm `11.13.0`, and Codex `0.142.4` through the same mise installation.
- `python3 scripts/memory-audit.py`: required after this record is committed/working-tree checked.

## Risks

- The running desktop Codex process may need a restart before it reloads changed MCP configuration.
- `codex doctor` reports a newer CLI `0.157.1`; upgrading should be handled separately and only after confirming the Hirender provider compatibility.
- The current conversation's writer lock is expected until the session ends.

## Machine / Sync Impact

- [x] Updated `memory/machines/macair.md`.
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

After the current conversation ends, restart the Codex desktop app once so all MCP clients reload the repaired config. Keep the repair backup until the restart and archive workflow have been exercised.

## Related Files

- `/Users/xinping/.codex/config.toml`
- `/Users/xinping/.zshenv`
- `/Users/xinping/.zprofile`
- `/Users/xinping/.zshrc`
- `/Users/xinping/Documents/Deepseek/memory/machines/macair.md`
- `/Users/xinping/.codex/backups_state/health-repair-20260927_223541/`
