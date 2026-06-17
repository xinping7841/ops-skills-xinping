#!/bin/bash
# auto-sync.sh — 三机 workspace 自动同步
# 用法：放到 crontab / 计划任务里，每5分钟跑一次

REPO_DIR="$1"
if [ -z "$REPO_DIR" ]; then
  # 默认搜索常见路径
  for d in "$HOME/Documents/Deepseek" "/mnt/d/Deepseek" "D:/Deepseek" "C:/Users/gaoxi/Documents/Deepseek"; do
    if [ -d "$d/.git" ]; then
      REPO_DIR="$d"
      break
    fi
  done
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[$(date '+%H:%M:%S')] ❌ 不是 git 仓库: $REPO_DIR" | tee -a "$REPO_DIR/../sync.log"
  exit 1
fi

cd "$REPO_DIR" || exit 1

# 1. 同步到 Codex 全局目录（Codex 每次启动自动加载）
if [ -d "$HOME/.codex" ]; then
  # AGENTS.md
  [ -f "AGENTS.md" ] && cp AGENTS.md "$HOME/.codex/AGENTS.md"
  # skill-*.md → Codex skills/
  for skill_md in skill-*.md; do
    [ -f "$skill_md" ] || continue
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
  done
fi

# 1.5. 同步 Codex skill（codex-skills/ 目录下的专用 skill）
if [ -d "codex-skills/ops-terminal-sync" ] && [ -d "$HOME/.codex" ]; then
  mkdir -p "$HOME/.codex/skills"
  DEST="$HOME/.codex/skills/ops-terminal-sync"
  SKILLS_ROOT_REAL="$(cd "$HOME/.codex/skills" && pwd -P)"
  if [ -e "$DEST" ]; then
    DEST_REAL="$(cd "$(dirname "$DEST")" && pwd -P)/$(basename "$DEST")"
    case "$DEST_REAL" in
      "$SKILLS_ROOT_REAL"/*) rm -rf "$DEST" ;;
      *) echo "[$(date '+%H:%M:%S')] ❌ 技能目录异常，拒绝覆盖: $DEST_REAL" | tee -a sync.log; exit 1 ;;
    esac
  fi
  cp -R "codex-skills/ops-terminal-sync" "$DEST"
fi

# 2. 如果有本地改动，先自动提交
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  echo "[$(date '+%H:%M:%S')] 📝 检测到改动，先自动提交..." | tee -a sync.log
  git add -A
  git commit -m "auto: sync $(date '+%m-%d %H:%M')" 2>&1 | tee -a sync.log
else
  echo "[$(date '+%H:%M:%S')] ✔ 无需同步" | tee -a sync.log
fi

# 3. 拉取远端更新并推送本地提交
echo "[$(date '+%H:%M:%S')] 🔄 pull --rebase..." | tee -a sync.log
if ! git pull --rebase 2>&1 | tee -a sync.log; then
  echo "[$(date '+%H:%M:%S')] ❌ pull --rebase 失败，需要人工处理冲突" | tee -a sync.log
  exit 1
fi

if [ -n "$(git log --branches --not --remotes --oneline)" ]; then
  git push 2>&1 | tee -a sync.log
  echo "[$(date '+%H:%M:%S')] ✅ 已推送" | tee -a sync.log
else
  echo "[$(date '+%H:%M:%S')] ✔ 没有待推送提交" | tee -a sync.log
fi
