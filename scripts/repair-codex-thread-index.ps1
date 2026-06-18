# Reconcile Codex Desktop thread indexes when app versions write different DB paths.

$ErrorActionPreference = 'Continue'

$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$rootDb = Join-Path $codexHome 'state_5.sqlite'
$nestedDb = Join-Path $codexHome 'sqlite\state_5.sqlite'

function Write-RepairLog {
    param([string]$Message)
    Write-Host ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
}

$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) {
    Write-RepairLog 'WARN: sqlite3 not found; skipped Codex thread index repair.'
    exit 0
}

if ((-not (Test-Path -LiteralPath $rootDb)) -and (-not (Test-Path -LiteralPath $nestedDb))) {
    exit 0
}

function Backup-Db {
    param([string]$Db, [string]$Destination)
    if (-not (Test-Path -LiteralPath $Db)) { return }
    & sqlite3 $Db ".backup '$Destination'" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Copy-Item -LiteralPath $Db -Destination $Destination -Force
    }
}

function Ensure-Copy {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path -LiteralPath $Source)) { return }
    if (Test-Path -LiteralPath $Destination) { return }
    New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
    Backup-Db -Db $Source -Destination $Destination
    Write-RepairLog "Codex thread index created: $Destination"
}

Ensure-Copy -Source $rootDb -Destination $nestedDb
Ensure-Copy -Source $nestedDb -Destination $rootDb

if ((-not (Test-Path -LiteralPath $rootDb)) -or (-not (Test-Path -LiteralPath $nestedDb))) {
    exit 0
}

$stamp = Get-Date -Format 'yyyyMMddHHmmss'
$backupDir = Join-Path $codexHome "backups_state\thread-index-repair\$stamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Backup-Db -Db $rootDb -Destination (Join-Path $backupDir 'root-state_5.sqlite')
Backup-Db -Db $nestedDb -Destination (Join-Path $backupDir 'sqlite-state_5.sqlite')

function Sql-Quote {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

function Merge-Threads {
    param([string]$Source, [string]$Destination)

    $columns = (& sqlite3 $Destination 'PRAGMA table_info(threads);') |
        ForEach-Object { ($_ -split '\|')[1] } |
        Where-Object { $_ }
    if (-not $columns) { return }

    $columnList = ($columns -join ',')
    $updates = ($columns | Where-Object { $_ -ne 'id' } | ForEach-Object {
        "$_=(SELECT $_ FROM srcdb.threads s WHERE s.id=threads.id)"
    }) -join ', '
    if (-not $updates) { return }

    $sourceSql = Sql-Quote $Source
    $sql = @"
PRAGMA busy_timeout=5000;
ATTACH DATABASE '$sourceSql' AS srcdb;
BEGIN IMMEDIATE;
INSERT OR IGNORE INTO threads ($columnList)
SELECT $columnList FROM srcdb.threads;
UPDATE threads
SET $updates
WHERE EXISTS (
  SELECT 1 FROM srcdb.threads s
  WHERE s.id = threads.id
    AND coalesce(s.updated_at_ms, s.updated_at * 1000, 0) > coalesce(threads.updated_at_ms, threads.updated_at * 1000, 0)
);
COMMIT;
DETACH DATABASE srcdb;
PRAGMA wal_checkpoint(TRUNCATE);
"@
    $sql | & sqlite3 $Destination | Out-Null
}

Merge-Threads -Source $rootDb -Destination $nestedDb
Merge-Threads -Source $nestedDb -Destination $rootDb

$rootCount = (& sqlite3 $rootDb 'SELECT count(*) FROM threads;' 2>$null)
$nestedCount = (& sqlite3 $nestedDb 'SELECT count(*) FROM threads;' 2>$null)
Write-RepairLog "Codex thread index repaired: root=$rootCount sqlite=$nestedCount backup=$backupDir"
