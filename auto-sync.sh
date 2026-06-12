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

# 1. 拉取远端更新（总是安全）
echo "[$(date '+%H:%M:%S')] 🔄 pull..." | tee -a sync.log
git pull --no-edit 2>&1 | tee -a sync.log

# 2. 如果有本地改动，自动提交 + 推送
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  echo "[$(date '+%H:%M:%S')] 📝 检测到改动，自动提交..." | tee -a sync.log
  git add -A
  git commit -m "auto: sync $(date '+%m-%d %H:%M')" 2>&1 | tee -a sync.log
  git push 2>&1 | tee -a sync.log
  echo "[$(date '+%H:%M:%S')] ✅ 已推送" | tee -a sync.log
else
  echo "[$(date '+%H:%M:%S')] ✔ 无需同步" | tee -a sync.log
fi
