#!/usr/bin/env bash
# Force Codex Desktop into full-access / never-approval mode on macOS.
# Usage:
#   bash scripts/force-codex-full-access.sh --repair --verify
#   bash scripts/force-codex-full-access.sh --install-launch-agent

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG_PATH="$CODEX_HOME/config.toml"
GLOBAL_JSON="$CODEX_HOME/.codex-global-state.json"
LAUNCH_AGENT_LABEL="com.codex.force-full-access"
LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_LABEL.plist"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
QUIET=0
DO_REPAIR=0
DO_VERIFY=0
DO_INSTALL_AGENT=0
DO_UNINSTALL_AGENT=0
AGENT_MODE=0

log() {
  if [[ "$QUIET" != "1" ]]; then
    printf '[force-codex-full-access] %s\n' "$*"
  fi
}

usage() {
  cat <<'EOF'
Usage: force-codex-full-access.sh [options]

Options:
  --repair                 Repair Codex config, JSON state, and SQLite state.
  --verify                 Verify current permissions and exit non-zero if dirty.
  --install-launch-agent   Install a user LaunchAgent that repairs at login and when Codex rewrites global state.
  --uninstall-launch-agent Remove the LaunchAgent.
  --agent-mode             Internal: run from the installed LaunchAgent copy.
  --quiet                  Reduce output.
  -h, --help               Show this help.

If no action is provided, --repair --verify is used.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repair) DO_REPAIR=1 ;;
    --verify) DO_VERIFY=1 ;;
    --install-launch-agent) DO_INSTALL_AGENT=1 ;;
    --uninstall-launch-agent) DO_UNINSTALL_AGENT=1 ;;
    --agent-mode) AGENT_MODE=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 64 ;;
  esac
  shift
done

if [[ "$DO_REPAIR$DO_VERIFY$DO_INSTALL_AGENT$DO_UNINSTALL_AGENT" == "0000" ]]; then
  DO_REPAIR=1
  DO_VERIFY=1
fi

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required tool: %s\n' "$1" >&2
    exit 69
  fi
}

backup_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  cp -p "$file" "$file.bak-full-access-$TIMESTAMP"
}

repair_config() {
  [[ -f "$CONFIG_PATH" ]] || { log "Config missing, skipped: $CONFIG_PATH"; return 0; }

  require_tool python3
  local tmp
  tmp="$(mktemp)"
  set +e
  python3 - "$CONFIG_PATH" > "$tmp" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding='utf-8')
original = text

pairs = {
    'approval_policy': 'never',
    'sandbox_mode': 'danger-full-access',
}
for key, value in pairs.items():
    pattern = re.compile(rf'(?m)^{re.escape(key)}\s*=\s*"[^"]*"\s*$')
    replacement = f'{key} = "{value}"'
    if pattern.search(text):
        text = pattern.sub(replacement, text, count=1)
    else:
        text = replacement + '\n' + text

# Old per-tool approval overrides can still produce prompts even when global approval is never.
text = re.sub(
    r'(?ms)^\[mcp_servers\.playwright\.tools\.browser_navigate\]\s*\r?\napproval_mode\s*=\s*"approve"\s*\r?\n+',
    '',
    text,
)

sys.stdout.write(text)
sys.exit(0 if text == original else 2)
PY
  local status=$?
  set -e
  if [[ "$status" != "0" && "$status" != "2" ]]; then
    rm -f "$tmp"
    return "$status"
  fi
  if [[ "$status" == "2" ]]; then
    backup_file "$CONFIG_PATH"
    mv "$tmp" "$CONFIG_PATH"
    log "Config repaired: $CONFIG_PATH"
  else
    rm -f "$tmp"
    log "Config already clean."
  fi
}

repair_json() {
  [[ -f "$GLOBAL_JSON" ]] || { log "Global JSON missing, skipped: $GLOBAL_JSON"; return 0; }
  require_tool python3
  local tmp
  tmp="$(mktemp)"
  set +e
  python3 - "$GLOBAL_JSON" > "$tmp" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text(encoding='utf-8'))
original = json.dumps(data, ensure_ascii=False, sort_keys=True, separators=(',', ':'))
atom = data.setdefault('electron-persisted-atom-state', {})
atom.setdefault('agent-mode-by-host-id', {})['local'] = 'full-access'
atom.setdefault('preferred-non-full-access-agent-mode-by-host-id', {})['local'] = 'full-access'
atom['skip-full-access-confirm'] = True
perms = atom.get('heartbeat-thread-permissions-by-id')
if isinstance(perms, dict):
    clean = {
        'activePermissionProfile': {'id': ':danger-full-access', 'extends': None},
        'approvalPolicy': 'never',
        'approvalsReviewer': 'user',
        'sandboxPolicy': {'type': 'dangerFullAccess'},
    }
    for thread_id in list(perms.keys()):
        perms[thread_id] = clean
new = json.dumps(data, ensure_ascii=False, sort_keys=True, separators=(',', ':'))
sys.stdout.write(json.dumps(data, ensure_ascii=False, separators=(',', ':')))
sys.exit(0 if new == original else 2)
PY
  local status=$?
  set -e
  if [[ "$status" != "0" && "$status" != "2" ]]; then
    rm -f "$tmp"
    return "$status"
  fi
  if [[ "$status" == "2" ]]; then
    backup_file "$GLOBAL_JSON"
    mv "$tmp" "$GLOBAL_JSON"
    log "Global JSON repaired: $GLOBAL_JSON"
  else
    rm -f "$tmp"
    log "Global JSON already clean."
  fi
}

repair_sqlite_db() {
  local db="$1"
  [[ -f "$db" ]] || return 0
  require_tool sqlite3
  if ! sqlite3 "$db" "SELECT 1 FROM sqlite_master WHERE type='table' AND name='threads';" | grep -q 1; then
    return 0
  fi

  local count
  count="$(sqlite3 "$db" "SELECT COUNT(*) FROM threads WHERE approval_mode!='never' OR sandbox_policy NOT IN ('{\"type\":\"danger-full-access\"}','{\"type\":\"disabled\"}');")"
  if [[ "$count" == "0" ]]; then
    log "SQLite already clean: $db"
    return 0
  fi

  backup_file "$db"
  cp -p "$db-wal" "$db-wal.bak-full-access-$TIMESTAMP" 2>/dev/null || true
  cp -p "$db-shm" "$db-shm.bak-full-access-$TIMESTAMP" 2>/dev/null || true
  sqlite3 "$db" "UPDATE threads SET approval_mode='never', sandbox_policy='{\"type\":\"danger-full-access\"}' WHERE approval_mode!='never' OR sandbox_policy NOT IN ('{\"type\":\"danger-full-access\"}','{\"type\":\"disabled\"}');"
  log "SQLite repaired: $db ($count records)"
}

repair_all() {
  [[ -d "$CODEX_HOME" ]] || { printf 'Codex home not found: %s\n' "$CODEX_HOME" >&2; exit 66; }
  repair_config
  repair_json
  repair_sqlite_db "$CODEX_HOME/state_5.sqlite"
  repair_sqlite_db "$CODEX_HOME/sqlite/state_5.sqlite"
}

verify_all() {
  require_tool python3
  python3 - "$CODEX_HOME" <<'PY'
import json
import pathlib
import sqlite3
import sys

home = pathlib.Path(sys.argv[1])
config = home / 'config.toml'
global_json = home / '.codex-global-state.json'
dbs = [home / 'state_5.sqlite', home / 'sqlite' / 'state_5.sqlite']
errors = []

try:
    import tomllib
    cfg = tomllib.loads(config.read_text(encoding='utf-8'))
    approval = cfg.get('approval_policy')
    sandbox = cfg.get('sandbox_mode')
    print(f'config approval_policy={approval!r} sandbox_mode={sandbox!r}')
    if approval != 'never':
        errors.append(f'config approval_policy is {approval!r}')
    if sandbox != 'danger-full-access':
        errors.append(f'config sandbox_mode is {sandbox!r}')
except Exception as exc:
    errors.append(f'config read failed: {exc}')

try:
    data = json.loads(global_json.read_text(encoding='utf-8'))
    atom = data.get('electron-persisted-atom-state', {})
    agent = (atom.get('agent-mode-by-host-id') or {}).get('local')
    preferred = (atom.get('preferred-non-full-access-agent-mode-by-host-id') or {}).get('local')
    skip = atom.get('skip-full-access-confirm')
    perms = atom.get('heartbeat-thread-permissions-by-id') or {}
    guarded = 0
    for value in perms.values():
        value = value or {}
        if (
            value.get('approvalPolicy') == 'on-request'
            or (value.get('sandboxPolicy') or {}).get('type') in {'workspaceWrite', 'readOnly'}
            or (value.get('activePermissionProfile') or {}).get('id') in {':workspace', ':read-only'}
        ):
            guarded += 1
    print(f'json agent_mode.local={agent!r} preferred.local={preferred!r} skip={skip!r} heartbeat_count={len(perms)} guarded_count={guarded}')
    if agent != 'full-access':
        errors.append(f'json agent_mode.local is {agent!r}')
    if preferred not in (None, 'full-access'):
        errors.append(f'json preferred.local is {preferred!r}')
    if skip is not True:
        errors.append(f'json skip-full-access-confirm is {skip!r}')
    if guarded:
        errors.append(f'json has {guarded} guarded heartbeat records')
except Exception as exc:
    errors.append(f'json read failed: {exc}')

for db in dbs:
    if not db.exists():
        print(f'sqlite missing={db}')
        continue
    try:
        con = sqlite3.connect(str(db), timeout=30)
        cur = con.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='threads'")
        if not cur.fetchone():
            con.close()
            print(f'sqlite no_threads_table={db}')
            continue
        cur.execute("SELECT approval_mode, sandbox_policy, COUNT(*) FROM threads GROUP BY approval_mode, sandbox_policy ORDER BY approval_mode, sandbox_policy")
        groups = cur.fetchall()
        cur.execute("SELECT COUNT(*) FROM threads WHERE approval_mode!='never' OR sandbox_policy NOT IN ('{\"type\":\"danger-full-access\"}','{\"type\":\"disabled\"}')")
        guarded = cur.fetchone()[0]
        con.close()
        print(f'sqlite {db} groups={groups!r} guarded_count={guarded}')
        if guarded:
            errors.append(f'sqlite {db} has {guarded} guarded records')
    except Exception as exc:
        errors.append(f'sqlite {db} read failed: {exc}')

if errors:
    print('VERIFY=dirty')
    for error in errors:
        print('error=' + error)
    sys.exit(2)
print('VERIFY=clean')
PY
}

install_launch_agent() {
  mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
  local installed_script="$CODEX_HOME/bin/force-codex-full-access.sh"
  mkdir -p "$CODEX_HOME/bin"
  cp -p "$SCRIPT_PATH" "$installed_script"
  chmod +x "$installed_script"
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LAUNCH_AGENT_LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$installed_script</string>
    <string>--repair</string>
    <string>--agent-mode</string>
    <string>--quiet</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>WatchPaths</key>
  <array>
    <string>$GLOBAL_JSON</string>
  </array>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/$LAUNCH_AGENT_LABEL.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/$LAUNCH_AGENT_LABEL.err</string>
</dict>
</plist>
EOF
  if [[ -f "$LAUNCH_AGENT_PATH" ]] && cmp -s "$tmp" "$LAUNCH_AGENT_PATH"; then
    rm -f "$tmp"
  else
    mv "$tmp" "$LAUNCH_AGENT_PATH"
  fi

  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT_PATH" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PATH"
  launchctl kickstart -k "gui/$(id -u)/$LAUNCH_AGENT_LABEL" >/dev/null 2>&1 || true
  log "LaunchAgent installed: $LAUNCH_AGENT_PATH"
}

uninstall_launch_agent() {
  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT_PATH" >/dev/null 2>&1 || true
  rm -f "$LAUNCH_AGENT_PATH"
  rm -f "$CODEX_HOME/bin/force-codex-full-access.sh"
  log "LaunchAgent removed: $LAUNCH_AGENT_PATH"
}

if [[ "$DO_UNINSTALL_AGENT" == "1" ]]; then
  uninstall_launch_agent
fi
if [[ "$DO_REPAIR" == "1" ]]; then
  repair_all
fi
if [[ "$DO_INSTALL_AGENT" == "1" ]]; then
  install_launch_agent
fi
if [[ "$DO_VERIFY" == "1" ]]; then
  verify_all
fi
