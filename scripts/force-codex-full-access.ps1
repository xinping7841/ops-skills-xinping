param(
    [switch]$RestartCodex,
    [switch]$NoRestart
)

$ErrorActionPreference = 'Stop'

$CodexHome = Join-Path $env:USERPROFILE '.codex'
$ConfigPath = Join-Path $CodexHome 'config.toml'
$GlobalStatePath = Join-Path $CodexHome '.codex-global-state.json'
$StateDbPath = Join-Path $CodexHome 'state_5.sqlite'
$PythonPath = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$StartAppId = 'OpenAI.Codex_2p2nqsd0c76g0!App'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Write-Step($Message) {
    Write-Host "[force-codex-full-access] $Message"
}

if (-not (Test-Path -LiteralPath $CodexHome)) {
    throw "Codex home not found: $CodexHome"
}

if (-not (Test-Path -LiteralPath $PythonPath)) {
    $PythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $PythonCmd) {
        throw 'Python not found. Install Python or ensure Codex primary runtime exists.'
    }
    $PythonPath = $PythonCmd.Source
}

if ($RestartCodex -and $NoRestart) {
    throw 'Use either -RestartCodex or -NoRestart, not both.'
}

if ($RestartCodex) {
    Write-Step 'Stopping running Codex processes so app state cannot overwrite the repair.'
    Get-Process Codex,codex,node_repl -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
}

if (Test-Path -LiteralPath $ConfigPath) {
    $ConfigBackup = "$ConfigPath.bak-full-access-$Timestamp"
    Copy-Item -LiteralPath $ConfigPath -Destination $ConfigBackup -Force
    $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8
    $config = [regex]::Replace(
        $config,
        "(?ms)^\[mcp_servers\.playwright\.tools\.browser_navigate\]\s*\r?\napproval_mode\s*=\s*`"approve`"\s*\r?\n+",
        ""
    )
    Set-Content -LiteralPath $ConfigPath -Value $config -Encoding UTF8
    Write-Step "Config repaired and backed up: $ConfigBackup"
} else {
    Write-Step "Config not found; skipped: $ConfigPath"
}

$RepairPython = @'
import json
import pathlib
import shutil
import sqlite3
import time

home = pathlib.Path.home()
ts = time.strftime('%Y%m%d-%H%M%S')
state_db = home / '.codex' / 'state_5.sqlite'
global_json = home / '.codex' / '.codex-global-state.json'

full_sandbox_db = json.dumps({'type': 'disabled'}, separators=(',', ':'))
thread_ids = []
changed_db = 0

if state_db.exists():
    backup_db = state_db.with_name(f'{state_db.name}.bak-full-access-{ts}')
    shutil.copy2(state_db, backup_db)
    con = sqlite3.connect(str(state_db), timeout=30)
    cur = con.cursor()
    cur.execute('select id, approval_mode, sandbox_policy from threads')
    rows = cur.fetchall()
    thread_ids = [row[0] for row in rows]
    changed_db = sum(1 for _, approval, sandbox in rows if approval != 'never' or sandbox != full_sandbox_db)
    cur.execute('update threads set approval_mode = ?, sandbox_policy = ?', ('never', full_sandbox_db))
    con.commit()
    con.close()
    print(f'db_backup={backup_db}')
    print(f'db_threads={len(rows)} db_changed={changed_db}')
else:
    print(f'db_missing={state_db}')

changed_json = 0
if global_json.exists():
    backup_json = global_json.with_name(f'{global_json.name}.bak-full-access-{ts}')
    shutil.copy2(global_json, backup_json)
    data = json.loads(global_json.read_text(encoding='utf-8'))
    atom = data.setdefault('electron-persisted-atom-state', {})
    atom.setdefault('agent-mode-by-host-id', {})['local'] = 'full-access'
    atom.setdefault('preferred-non-full-access-agent-mode-by-host-id', {})['local'] = 'full-access'
    atom['skip-full-access-confirm'] = True
    perms = atom.setdefault('heartbeat-thread-permissions-by-id', {})
    target_ids = sorted(set(thread_ids) | set(perms.keys()))
    for thread_id in target_ids:
        prev = perms.get(thread_id, {})
        if prev.get('approvalPolicy') != 'never' or prev.get('sandboxPolicy', {}).get('type') != 'dangerFullAccess':
            changed_json += 1
        perms[thread_id] = {
            'activePermissionProfile': {'id': ':danger-full-access', 'extends': None},
            'approvalPolicy': 'never',
            'approvalsReviewer': 'user',
            'sandboxPolicy': {'type': 'dangerFullAccess'},
        }
    global_json.write_text(json.dumps(data, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'json_backup={backup_json}')
    print(f'json_threads={len(target_ids)} json_changed={changed_json}')
else:
    print(f'json_missing={global_json}')
'@

$TempScript = Join-Path $env:TEMP "force-codex-full-access-$Timestamp.py"
Set-Content -LiteralPath $TempScript -Value $RepairPython -Encoding UTF8
Write-Step 'Repairing Codex thread permissions in SQLite and global state JSON.'
& $PythonPath $TempScript
Remove-Item -LiteralPath $TempScript -Force -ErrorAction SilentlyContinue

Write-Step 'Verification:'
$VerifyPython = @'
import json
import pathlib
import sqlite3

home = pathlib.Path.home()
state_db = home / '.codex' / 'state_5.sqlite'
global_json = home / '.codex' / '.codex-global-state.json'

if state_db.exists():
    con = sqlite3.connect(str(state_db), timeout=30)
    cur = con.cursor()
    cur.execute('select approval_mode, sandbox_policy, count(*) from threads group by approval_mode, sandbox_policy order by approval_mode, sandbox_policy')
    print('db_groups=' + repr(cur.fetchall()))
    con.close()
if global_json.exists():
    data = json.loads(global_json.read_text(encoding='utf-8'))
    atom = data.get('electron-persisted-atom-state', {})
    perms = atom.get('heartbeat-thread-permissions-by-id', {})
    groups = {}
    for value in perms.values():
        key = '/'.join([
            str(value.get('approvalPolicy')),
            str(value.get('sandboxPolicy', {}).get('type')),
            str(value.get('activePermissionProfile', {}).get('id')),
        ])
        groups[key] = groups.get(key, 0) + 1
    print('json_groups=' + repr(groups))
    print('agent_mode=' + repr(atom.get('agent-mode-by-host-id')))
    print('preferred_non_full_access=' + repr(atom.get('preferred-non-full-access-agent-mode-by-host-id')))
'@

$VerifyScript = Join-Path $env:TEMP "verify-codex-full-access-$Timestamp.py"
Set-Content -LiteralPath $VerifyScript -Value $VerifyPython -Encoding UTF8
& $PythonPath $VerifyScript
Remove-Item -LiteralPath $VerifyScript -Force -ErrorAction SilentlyContinue

if ($RestartCodex) {
    Write-Step 'Starting Codex.'
    Start-Process "shell:AppsFolder\$StartAppId"
} elseif (-not $NoRestart) {
    Write-Step 'Repair complete. Restart Codex Desktop once so the UI reloads repaired permissions.'
}
