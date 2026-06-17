#!/bin/bash
# Audit local Codex skills against the Deepseek repository source of truth.

set -u

REPO_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "ERROR: not a git repository: $REPO_DIR" >&2
  exit 1
fi

cd "$REPO_DIR" || exit 1

repo_names="$(mktemp)"
local_names="$(mktemp)"
missing_local="$(mktemp)"
orphan_local="$(mktemp)"
trap 'rm -f "$repo_names" "$local_names" "$missing_local" "$orphan_local"' EXIT

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

comm -23 "$repo_names" "$local_names" > "$missing_local"
comm -13 "$repo_names" "$local_names" > "$orphan_local"

echo "Repository skills: $(wc -l < "$repo_names" | tr -d ' ')"
echo "Local Codex skills: $(wc -l < "$local_names" | tr -d ' ')"
echo ""

if [ -s "$missing_local" ]; then
  echo "Repo skills missing locally:"
  sed 's/^/  - /' "$missing_local"
else
  echo "Repo skills missing locally: none"
fi

echo ""

if [ -s "$orphan_local" ]; then
  echo "Local skills not in repo:"
  sed 's/^/  - /' "$orphan_local"
else
  echo "Local skills not in repo: none"
fi
