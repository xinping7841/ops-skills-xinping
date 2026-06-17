#!/bin/bash
# Configure Codex MCP and plugin blocks on macOS.
# Usage: cd ~/Documents/Deepseek && bash setup-codex-macos.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$REPO_DIR/codex-config-macos-mcp.toml"
CODEX_DIR="$HOME/.codex"
CODEX_CONFIG="$CODEX_DIR/config.toml"
CODEX_SNIPPET="$CODEX_DIR/mcp-macos.generated.toml"

if [ ! -f "$TEMPLATE" ]; then
  echo "Missing template: $TEMPLATE" >&2
  exit 1
fi

for BIN in node npm npx; do
  if ! command -v "$BIN" >/dev/null 2>&1; then
    echo "Missing $BIN. Install Node.js first, for example: brew install node" >&2
    exit 1
  fi
done

mkdir -p "$CODEX_DIR"

echo "Installing MCP packages..."
npm install -g @upstash/context7-mcp @modelcontextprotocol/server-filesystem@0.6.2
npx playwright install chromium >/dev/null 2>&1 || true

NODE_BIN="$(command -v node)"
NPX_BIN="$(command -v npx)"
NPM_ROOT="$(npm root -g | sed 's#/$##')"

sed \
  -e "s#__NODE_BIN__#$NODE_BIN#g" \
  -e "s#__NPX_BIN__#$NPX_BIN#g" \
  -e "s#__NPM_ROOT__#$NPM_ROOT#g" \
  -e "s#__HOME__#$HOME#g" \
  "$TEMPLATE" > "$CODEX_SNIPPET"

echo "Generated: $CODEX_SNIPPET"

if [ ! -f "$CODEX_CONFIG" ]; then
  cp "$CODEX_SNIPPET" "$CODEX_CONFIG"
  echo "Created: $CODEX_CONFIG"
else
  cp "$CODEX_CONFIG" "$CODEX_CONFIG.bak.$(date +%Y%m%d%H%M%S)"

  for SECTION in filesystem context7 playwright github; do
    if grep -q "^\[mcp_servers\.$SECTION\]" "$CODEX_CONFIG"; then
      echo "MCP already exists, skipped: $SECTION"
      continue
    fi

    awk -v section="$SECTION" '
      $0 == "[mcp_servers." section "]" { keep=1 }
      keep { print }
      keep && /^startup_timeout_sec = / { print ""; exit }
    ' "$CODEX_SNIPPET" >> "$CODEX_CONFIG"
    echo "Added MCP: $SECTION"
  done

  for PLUGIN in \
    'computer-use@openai-bundled' \
    'browser@openai-bundled' \
    'chrome@openai-bundled' \
    'documents@openai-primary-runtime' \
    'spreadsheets@openai-primary-runtime' \
    'presentations@openai-primary-runtime' \
    'pdf@openai-primary-runtime'; do
    if grep -q "^\[plugins\.\"$PLUGIN\"\]" "$CODEX_CONFIG"; then
      echo "Plugin already exists, skipped: $PLUGIN"
      continue
    fi

    cat >> "$CODEX_CONFIG" <<EOF_PLUGIN

[plugins."$PLUGIN"]
enabled = true
EOF_PLUGIN
    echo "Added plugin: $PLUGIN"
  done
fi

cat <<'NEXT_STEPS'

Next steps:
1. Set secrets locally, never commit them:
   launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "your_token"
   launchctl setenv CONTEXT7_API_KEY "your_key"
2. Fully quit and reopen Codex.
3. Check Codex Settings -> Tools & Plugins for filesystem/context7/playwright/github.
NEXT_STEPS
