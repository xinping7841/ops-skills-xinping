#!/bin/bash
# setup-mac.sh — macair/Linux 新机一键部署
# 用法: git clone git@github.com:xinping7841/ops-skills-xinping.git ~/Documents/Deepseek
#        cd ~/Documents/Deepseek && bash setup-mac.sh

set -e
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "=== Kun 生态部署 ==="

link_codex_skill_for_ui() {
  local skill_name="$1"
  local src="$HOME/.codex/skills/$skill_name"
  local dst="$HOME/.agents/skills/$skill_name"
  local config="$HOME/.codex/config.toml"

  [ -d "$src" ] || return 0
  mkdir -p "$HOME/.agents/skills"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    :
  elif [ -e "$dst" ]; then
    echo "⚠️  ~/.agents/skills 已有同名技能，跳过: $skill_name"
  else
    ln -s "$src" "$dst"
    echo "✅ Codex UI skill $skill_name 已链接"
  fi

  if [ -f "$config" ] && ! grep -q "^\[skills\.$skill_name\]" "$config"; then
    {
      echo ""
      echo "[skills.$skill_name]"
      echo "path = \"$src\""
    } >> "$config"
    echo "✅ Codex UI skill $skill_name 已注册"
  fi
}

# 1. Codex 全局指令
if [ -d "$HOME/.codex" ]; then
  cp "$REPO_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
  echo "✅ Codex AGENTS.md 已部署"
else
  echo "⚠️  未找到 Codex (~/.codex)，跳过"
fi

# 1.5 Codex 技能
if [ -d "$HOME/.codex" ] && [ -d "$REPO_DIR/codex-skills" ]; then
  mkdir -p "$HOME/.codex/skills"
  SKILLS_ROOT_REAL="$(cd "$HOME/.codex/skills" && pwd -P)"
  for SKILL_SRC in "$REPO_DIR"/codex-skills/*; do
    [ -d "$SKILL_SRC" ] || continue
    SKILL_NAME="$(basename "$SKILL_SRC")"
    DEST="$HOME/.codex/skills/$SKILL_NAME"
    if [ -e "$DEST" ]; then
      DEST_REAL="$(cd "$(dirname "$DEST")" && pwd -P)/$(basename "$DEST")"
      case "$DEST_REAL" in
        "$SKILLS_ROOT_REAL"/*) rm -rf "$DEST" ;;
        *) echo "⚠️  技能目录异常，拒绝覆盖: $DEST_REAL"; exit 1 ;;
      esac
    fi
    cp -R "$SKILL_SRC" "$DEST"
    link_codex_skill_for_ui "$SKILL_NAME"
    echo "✅ Codex skill $SKILL_NAME 已部署"
  done
fi

if [ -d "$HOME/.codex/skills" ]; then
  for SKILL_DEST in "$HOME/.codex/skills"/*; do
    [ -d "$SKILL_DEST" ] && [ -f "$SKILL_DEST/SKILL.md" ] || continue
    link_codex_skill_for_ui "$(basename "$SKILL_DEST")"
  done
fi

# 2. SSH config 追加（不覆盖已有）
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "### ops-skills ###" "$SSH_CONFIG" 2>/dev/null; then
  cat >> "$SSH_CONFIG" << 'SSHEOF'

### ops-skills ###
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_nodes
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
SSHEOF
  echo "✅ SSH github config 已追加"
else
  echo "⏭️  SSH config 已有 ops-skills 标记，跳过"
fi

# 3. 定时同步 (launchd)
PLIST="$HOME/Library/LaunchAgents/com.ops-skills.sync.plist"
cat > "$PLIST" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ops-skills.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$REPO_DIR/auto-sync.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLISTEOF
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST" 2>/dev/null
echo "✅ 定时同步已启用（每5分钟）"

# 4. 提醒
echo ""
echo "=== 部署完成 ==="
echo "还需手动操作："
echo "  1. 确保 ~/.ssh/id_ed25519_nodes 密钥已生成并添加到 GitHub"
echo "  2. Kun GUI → 设置 → MCP 参考 skill-mcp-servers.md 配置"
echo "  3. Kun GUI → 设置 → 技能 extraDirs 添加: $REPO_DIR"
echo ""
echo "技能文件已就位："
ls "$REPO_DIR"/skill-*.md
