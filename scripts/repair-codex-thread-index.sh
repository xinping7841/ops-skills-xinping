#!/bin/bash
# Reconcile Codex Desktop thread indexes when app versions write different DB paths.

set -u

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
ROOT_DB="$CODEX_HOME/state_5.sqlite"
NESTED_DB="$CODEX_HOME/sqlite/state_5.sqlite"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

if ! command -v sqlite3 >/dev/null 2>&1; then
  log "WARN: sqlite3 not found; skipped Codex thread index repair."
  exit 0
fi

if [ ! -f "$ROOT_DB" ] && [ ! -f "$NESTED_DB" ]; then
  exit 0
fi

backup_db() {
  db="$1"
  dst="$2"
  [ -f "$db" ] || return 0
  sqlite3 "$db" ".backup '$dst'" 2>/dev/null || cp "$db" "$dst"
}

ensure_copy() {
  src="$1"
  dst="$2"
  [ -f "$src" ] || return 0
  [ ! -f "$dst" ] || return 0
  mkdir -p "$(dirname "$dst")"
  backup_db "$src" "$dst"
  log "Codex thread index created: $dst"
}

ensure_copy "$ROOT_DB" "$NESTED_DB"
ensure_copy "$NESTED_DB" "$ROOT_DB"

if [ ! -f "$ROOT_DB" ] || [ ! -f "$NESTED_DB" ]; then
  exit 0
fi

stamp="$(date '+%Y%m%d%H%M%S')"
backup_dir="$CODEX_HOME/backups_state/thread-index-repair/$stamp"
mkdir -p "$backup_dir"
backup_db "$ROOT_DB" "$backup_dir/root-state_5.sqlite"
backup_db "$NESTED_DB" "$backup_dir/sqlite-state_5.sqlite"

sql_quote() {
  printf "%s" "$1" | sed "s/'/''/g"
}

merge_threads() {
  src="$1"
  dst="$2"
  src_sql="$(sql_quote "$src")"

  cols="$(sqlite3 "$dst" "PRAGMA table_info(threads);" | awk -F'|' '{print $2}' | paste -sd, -)"
  updates="$(sqlite3 "$dst" "PRAGMA table_info(threads);" | awk -F'|' '$2 != "id" {printf "%s%s=(SELECT %s FROM srcdb.threads s WHERE s.id=threads.id)", sep, $2, $2; sep=", "}')"

  [ -n "$cols" ] || return 0
  [ -n "$updates" ] || return 0

  sqlite3 "$dst" >/dev/null <<SQL
PRAGMA busy_timeout=5000;
ATTACH DATABASE '$src_sql' AS srcdb;
BEGIN IMMEDIATE;
INSERT OR IGNORE INTO threads ($cols)
SELECT $cols FROM srcdb.threads;
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
SQL
}

merge_threads "$ROOT_DB" "$NESTED_DB"
merge_threads "$NESTED_DB" "$ROOT_DB"

root_count="$(sqlite3 "$ROOT_DB" "SELECT count(*) FROM threads;" 2>/dev/null || echo 0)"
nested_count="$(sqlite3 "$NESTED_DB" "SELECT count(*) FROM threads;" 2>/dev/null || echo 0)"
log "Codex thread index repaired: root=$root_count sqlite=$nested_count backup=$backup_dir"
