# macair / xinpingmacbook-air

## Role

Mobile office and current primary coordination machine for the Deepseek ops workspace.

## Main Paths

- Deepseek repo: `/Users/xinping/Documents/Deepseek`
- Codex derived skills: `/Users/xinping/.codex/skills`
- Kun config: `/Users/xinping/.kun/mcp.json`, `/Users/xinping/.kun/data/config.json`

## SSH

- Tailscale IP: `100.112.77.115`
- User: `xinping`
- Preferred alias: `macair`, `xinpingmacbook-air`
- Cluster key: `~/.ssh/id_ed25519_nodes`

## Sync

- launchd label: `com.ops-skills.sync`
- Interval: 300 seconds
- Source of truth remote: `git@github.com:xinping7841/ops-skills-xinping.git`

## MCP Notes

- Kun MCP uses direct node path from mise: `/Users/xinping/.local/share/mise/installs/node/22.23.0/bin/node`.
- Kun filesystem root: `/Users/xinping/Documents/Deepseek`.
- Codex MCP block was cleaned on 2026-06-22 and repaired on 2026-09-27 to use macOS direct-node paths. Context7 and filesystem now point to the installed mise Node 22 packages; filesystem is scoped to `/Users/xinping/Documents/Deepseek`.
- Tokens should stay in local environment or app config, not Git memory.

## Known Risks

- Local Codex app config may contain runtime/cache paths managed by the app. Do not rewrite those unless they are proven to affect MCP or skills. The 2026-09-27 repair backup is under `~/.codex/backups_state/health-repair-20260927_223541/`.
- Codex desktop archive currently fails in API key authentication mode with `Could not determine the account for worktree cleanup.` Ordinary chats can be archived with `codex archive <thread-id>`; the CLI path was verified on 2026-09-28. Do not alter auth files or app bundles to fake an account.
- Ignored local sync artifacts such as `sync.log` and `.sync-reports/` should remain untracked and can be deleted when auditing workspace noise.

## Last Verified

- Date: 2026-09-28
- Deepseek repo was up to date with `origin/main` before the memory update.
- Five previous chats in the Codex project were archived through the CLI; the desktop list shows only the active chat. The desktop archive button still has the API key account gap.
