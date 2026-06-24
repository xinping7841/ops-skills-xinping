#!/bin/bash
# auto-sync.sh — multi-machine ops workspace sync
# GitHub is the source of truth. Local Codex/Kun directories are derived.

set -u

REPO_DIR="${1:-}"
if [ -z "$REPO_DIR" ]; then
  for d in "$HOME/Documents/Deepseek" "/mnt/d/Deepseek" "D:/Deepseek" "C:/Users/gaoxi/Documents/Deepseek"; do
    if [ -d "$d/.git" ]; then
      REPO_DIR="$d"
      break
    fi
  done
fi

if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
  echo "[$(date '+%H:%M:%S')] ERROR: not a git repository: ${REPO_DIR:-<empty>}"
  exit 1
fi

cd "$REPO_DIR" || exit 1

LOCK_DIR="$REPO_DIR/.sync.lock"
REPORT_DIR="$REPO_DIR/.sync-reports"
LOG_FILE="$REPORT_DIR/sync.log"

mkdir -p "$REPORT_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "SKIP: sync lock already exists: $LOCK_DIR"
  exit 0
fi

cleanup() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

remote="$(git remote get-url origin 2>/dev/null || true)"
case "$remote" in
  *xinping7841/ops-skills-xinping*) ;;
  *)
    log "ERROR: unexpected origin remote: ${remote:-<missing>}"
    exit 1
    ;;
esac

append_skill_config() {
  skill_name="$1"
  src="$2"
  config="$HOME/.codex/config.toml"

  [ -f "$config" ] || return 0
  if ! grep -q "^\[skills\.$skill_name\]" "$config"; then
    {
      echo ""
      echo "[skills.$skill_name]"
      printf "path = '%s'\n" "$src"
    } >> "$config"
    log "Codex skill registered: $skill_name"
  fi
}

install_codex_global_agents() {
  [ -d "$HOME/.codex" ] || return 0
  cat > "$HOME/.codex/AGENTS.md" << 'AGENTSEOF'
# Codex Global Instructions

Project-specific AGENTS.md files are the source of truth.

For the Deepseek workspace, read and follow:
- ~/Documents/Deepseek/AGENTS.md on macOS/Linux
- D:\Deepseek\AGENTS.md on Windows

Keep this global file short. Do not copy full project instructions here; doing so duplicates context in every Codex thread and can cause context bloat or stalled conversations.
AGENTSEOF
}

link_codex_skill_for_ui() {
  skill_name="$1"
  src="$HOME/.codex/skills/$skill_name"
  dst="$HOME/.agents/skills/$skill_name"

  [ -d "$src" ] || return 0
  mkdir -p "$HOME/.agents/skills"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    :
  elif [ -e "$dst" ]; then
    log "WARN: ~/.agents/skills already has skill, skipped link: $skill_name"
  else
    ln -s "$src" "$dst"
    log "Codex UI skill linked: $skill_name"
  fi

  append_skill_config "$skill_name" "$src"
}

sync_markdown_skill() {
  skill_md="$1"
  [ -f "$skill_md" ] || return 0
  [ -d "$HOME/.codex" ] || return 0

  skill_name="${skill_md#skill-}"
  skill_name="${skill_name%.md}"
  skill_dir="$HOME/.codex/skills/$skill_name"
  mkdir -p "$skill_dir"
  {
    echo "---"
    echo "name: $skill_name"
    echo "description: $(head -1 "$skill_md" | sed 's/^# //')"
    echo "---"
    echo ""
    cat "$skill_md"
  } > "$skill_dir/SKILL.md"
  link_codex_skill_for_ui "$skill_name"
}

sync_codex_skill_dir() {
  skill_src="$1"
  [ -d "$skill_src" ] || return 0
  [ -d "$HOME/.codex" ] || return 0

  mkdir -p "$HOME/.codex/skills"
  skills_root_real="$(cd "$HOME/.codex/skills" && pwd -P)"
  skill_name="$(basename "$skill_src")"
  dest="$HOME/.codex/skills/$skill_name"

  if [ -e "$dest" ]; then
    dest_real="$(cd "$(dirname "$dest")" && pwd -P)/$(basename "$dest")"
    case "$dest_real" in
      "$skills_root_real"/*) rm -rf "$dest" ;;
      *)
        log "ERROR: refusing to replace unexpected skill path: $dest_real"
        exit 1
        ;;
    esac
  fi

  cp -R "$skill_src" "$dest"
  link_codex_skill_for_ui "$skill_name"
}

deploy_repo_to_local() {
  if [ -d "$HOME/.codex" ]; then
    install_codex_global_agents

    for skill_md in skill-*.md; do
      [ -f "$skill_md" ] || continue
      sync_markdown_skill "$skill_md"
    done

    if [ -d "codex-skills" ]; then
      for skill_src in codex-skills/*; do
        [ -d "$skill_src" ] || continue
        sync_codex_skill_dir "$skill_src"
      done
    fi

    # Only repo-managed skills are registered in Codex config. Local orphan
    # skills are audited below, but not auto-registered into every thread.
  fi
}

audit_orphan_skills() {
  mkdir -p "$REPORT_DIR"
  report="$REPORT_DIR/skills-orphans-$(hostname)-$(date '+%Y%m%d-%H%M%S').txt"
  repo_names="$(mktemp)"
  local_names="$(mktemp)"

  {
    for f in skill-*.md; do
      [ -f "$f" ] || continue
      n="${f#skill-}"
      echo "${n%.md}"
    done
    if [ -d codex-skills ]; then
      find codex-skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
    fi
  } | sort -u > "$repo_names"

  if [ -d "$HOME/.codex/skills" ]; then
    find "$HOME/.codex/skills" -mindepth 1 -maxdepth 1 -type d -exec sh -c '[ -f "$1/SKILL.md" ] && basename "$1"' sh {} \; | sort -u > "$local_names"
  else
    : > "$local_names"
  fi

  orphan_count="$(comm -13 "$repo_names" "$local_names" | tee "$report" | wc -l | tr -d ' ')"
  if [ "$orphan_count" != "0" ]; then
    log "WARN: found $orphan_count local Codex skills not in repo; report: $report"
  else
    rm -f "$report"
  fi

  rm -f "$repo_names" "$local_names"
}

repair_codex_thread_index() {
  repair_script="$REPO_DIR/scripts/repair-codex-thread-index.sh"
  [ -f "$repair_script" ] || return 0
  if ! bash "$repair_script" 2>&1 | tee -a "$LOG_FILE"; then
    log "WARN: Codex thread index repair failed; continuing sync."
  fi
}

stage_whitelisted_changes() {
  git add -- AGENTS.md .gitattributes .gitignore 2>/dev/null || true

  for f in skill-*.md codex-config-*.toml setup-*.sh setup-*.ps1 auto-sync.sh sync.ps1 sync-hidden.vbs; do
    [ -e "$f" ] && git add -- "$f"
  done

  for d in codex-skills memory scripts machine-profiles mcp-templates; do
    [ -e "$d" ] && git add -- "$d"
  done
}

deploy_repo_to_local
audit_orphan_skills
repair_codex_thread_index

stage_whitelisted_changes
if ! git diff --cached --quiet 2>/dev/null; then
  machine="$(hostname)"
  log "Committing whitelisted sync changes."
  git commit -m "auto: sync from $machine $(date '+%m-%d %H:%M')" 2>&1 | tee -a "$LOG_FILE"
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    log "ERROR: git commit failed."
    exit 1
  fi
else
  log "No whitelisted local changes to commit."
fi

untracked="$(git status --porcelain --untracked-files=all | grep '^??' || true)"
if [ -n "$untracked" ]; then
  log "INFO: untracked or non-whitelisted files left untouched:"
  echo "$untracked" | tee -a "$LOG_FILE"
fi

log "Pulling remote updates with rebase."
if ! git pull --rebase 2>&1 | tee -a "$LOG_FILE"; then
  log "ERROR: pull --rebase failed; manual conflict resolution required."
  exit 1
fi

deploy_repo_to_local
audit_orphan_skills
repair_codex_thread_index

if [ -n "$(git log --branches --not --remotes --oneline)" ]; then
  log "Pushing local commits."
  if ! git push 2>&1 | tee -a "$LOG_FILE"; then
    log "ERROR: git push failed."
    exit 1
  fi
  log "Push complete."
else
  log "No commits to push."
fi
