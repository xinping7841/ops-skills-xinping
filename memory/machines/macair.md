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
- Codex MCP block was cleaned on 2026-06-22 to use macOS direct-node paths for filesystem, GitHub, Playwright, and Context7.
- Tokens should stay in local environment or app config, not Git memory.

## Known Risks

- Local Codex app config may contain runtime/cache paths managed by the app. Do not rewrite those unless they are proven to affect MCP or skills.
- Ignored local sync artifacts such as `sync.log` and `.sync-reports/` should remain untracked and can be deleted when auditing workspace noise.

## Last Verified

- Date: 2026-06-22
- Repo HEAD before cleanup commit: `45870e63bac99de2ccdc46a6634f1ffae7f8cfd3`
- Verified SSH to `12700K` and `lk402`; local ignored sync artifacts were removed.
