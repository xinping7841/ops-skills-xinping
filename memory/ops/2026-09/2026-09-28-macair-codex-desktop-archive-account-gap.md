# 2026-09-28 macair Codex desktop archive account gap

## Background

After the 2026-09-27 rollout/index repair, the user still could not archive previous chats from the Codex desktop interface. The earlier successful `codex archive` check covered the CLI path only.

## Changes

- Reproduced the desktop archive failure on the idle chat `01a0dd70-c3a1-7bf1-8881-da720d2d1b04`: `Could not determine the account for worktree cleanup.`
- Confirmed local Codex authentication is API key mode. The desktop archive flow requires an authenticated account principal before its worktree cleanup preparation, including for ordinary chats with no worktree attachments.
- Archived the five previous chats shown in the current Codex project using `codex archive <thread-id>`. Their database rows and rollout files now point to `archived_sessions`, and the desktop list shows only the active chat.
- Kept the active chat and its writer lock untouched.

## Why This Way

The CLI archive path is supported and works under API key authentication. The desktop path fails before the backend archive call, so editing rollout/index data or fabricating an account identifier would not repair the UI safely. All five archived chats had zero worktree attachments.

## Alternatives Not Taken

- Did not change the user's API key login to a ChatGPT account because this would alter authentication for the custom Hirender provider and requires the user's account sign-in.
- Did not patch the signed desktop application bundle or insert synthetic account fields into Codex state.
- Did not archive the active chat while this task is running.

## Validation

- Desktop `set_thread_archived` returned the account/worktree cleanup error before any archive state change.
- Five `codex archive <thread-id>` calls succeeded.
- `list_threads` returned only the active current chat; `list_archived_threads` showed the five moved chats.
- SQLite `pragma integrity_check` returned `ok`; each archived row's file exists under `~/.codex/archived_sessions/`.

## Risks

- Desktop archive button still fails while Codex is signed in only with an API key. Use `codex archive <thread-id>` or ask Codex to archive a named idle chat until the desktop app supports this auth mode or the user signs in with an account.
- A ChatGPT account sign-in may change provider authentication behavior and should be evaluated before switching.

## Machine / Sync Impact

- [x] Updated `memory/machines/macair.md`.
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

Do not repeat rollout/index repair for this UI error. Check the exact desktop error and current auth mode first. Use the CLI for API key mode archives, and verify through the desktop archived list and state DB.

## Related Files

- `/Users/xinping/.codex/auth.json` (auth mode only; never copy the credential)
- `/Users/xinping/.codex/state_5.sqlite`
- `/Users/xinping/.codex/archived_sessions/`
- `memory/ops/2026-09/2026-09-27-macair-codex-health-repair.md`
