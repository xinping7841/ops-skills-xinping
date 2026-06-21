#!/usr/bin/env python3
"""
Cross-platform CUA path repair for Codex Desktop + cc-switch.

Problem: cc-switch syncs config across machines with different OS (Windows/macOS).
Platform-specific paths (node_repl, node, CUA pipes) get written for the wrong OS,
breaking Computer Use Agent and remote phone control.

This script detects the current platform and repairs all affected locations:
  - ~/.codex/config.toml
  - ~/.cc-switch/cc-switch.db (common_config, providers, mcp_servers)

Usage:
  python3 scripts/repair-cua-platform-paths.py          # auto-detect + repair + verify
  python3 scripts/repair-cua-platform-paths.py --verify  # verify only
"""

import json
import os
import platform
import re
import sqlite3
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

HOME = Path.home()
CODEX_HOME = HOME / ".codex"
CC_SWITCH_DB = HOME / ".cc-switch" / "cc-switch.db"


# ── platform detection ──────────────────────────────────────────

def detect_platform() -> Dict[str, str]:
    """Return platform-specific paths."""
    system = platform.system()

    if system == "Darwin":
        # macOS — Codex.app bundle
        app = Path("/Applications/Codex.app/Contents/Resources")
        return {
            "os": "macos",
            "node_repl": str(app / "cua_node/bin/node_repl"),
            "node": str(app / "cua_node/bin/node"),
            "node_modules": str(app / "cua_node/lib/node_modules"),
            "codex_cli": str(CODEX_HOME / "plugins/.plugin-appserver/codex"),
            "trusted_paths": str(CODEX_HOME),
            "has_native_pipe": False,
            "native_pipe_settings": [],  # macOS doesn't need SKY_CUA_NATIVE_PIPE
        }
    elif system == "Windows":
        # Windows — User's AppData
        local_appdata = os.environ.get("LOCALAPPDATA", str(HOME / "AppData/Local"))
        codex_runtime = Path(local_appdata) / "OpenAI/Codex/runtimes"
        # Find the cua_node runtime dir (hash varies per install)
        cua_dir = None
        if codex_runtime.exists():
            for child in codex_runtime.iterdir():
                if child.is_dir() and (child / "bin/node_repl.exe").exists():
                    cua_dir = child
                    break
        if not cua_dir:
            cua_dir = codex_runtime / "cua_node/PLACEHOLDER"

        cua_bin = cua_dir / "bin"
        return {
            "os": "windows",
            "node_repl": str(cua_bin / "node_repl.exe"),
            "node": str(cua_bin / "node.exe"),
            "node_modules": str(cua_bin / "node_modules"),
            "codex_cli": str(CODEX_HOME / "plugins/.plugin-appserver/codex.exe"),
            "trusted_paths": str(CODEX_HOME),
            "has_native_pipe": True,
            "native_pipe_settings": [
                ("SKY_CUA_NATIVE_PIPE", "1"),
                # Native pipe dir — keep existing or generate new
            ],
        }
    else:
        raise SystemExit(f"Unsupported platform: {system}")


PLAT = detect_platform()

# ── helpers ─────────────────────────────────────────────────────

def backup(path: Path) -> Path:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    bak = path.with_suffix(f"{path.suffix}.bak-cua-repair-{stamp}")
    if path.exists():
        bak.write_bytes(path.read_bytes())
        print(f"  📦 已备份: {bak}")
    return bak

def find_windows_paths(text: str) -> List[str]:
    """Find all Windows paths in text (C:\\Users\\... patterns)."""
    return re.findall(r'[A-Z]:\\[^\s\'"]+', text)

def find_macos_paths(text: str) -> List[str]:
    """Find all macOS paths in text (/Applications/Codex.app... patterns)."""
    return re.findall(r'/Applications/Codex\.app[^\s\'"]*', text)


# ── config.toml repair ──────────────────────────────────────────

def fix_config_toml():
    config = CODEX_HOME / "config.toml"
    if not config.exists():
        print("  ⚠️  config.toml 未找到")
        return False

    backup(config)
    text = config.read_text(encoding="utf-8")

    changes = 0

    # 1. Fix mcp_servers.node_repl.command
    for old_pattern in [
        r"command\s*=\s*'C:\\Users\\[^']*node_repl(\.exe)?'",
        r'command\s*=\s*"/Applications/Codex\.app[^"]*node_repl"',
    ]:
        new_text = re.sub(old_pattern, f'command = "{PLAT["node_repl"]}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 2. Fix NODE_REPL_NODE_PATH
    for old_pattern in [
        r"NODE_REPL_NODE_PATH\s*=\s*'C:\\Users\\[^']*node(\.exe)?'",
        r'NODE_REPL_NODE_PATH\s*=\s*"/Applications/Codex\.app[^"]*node"',
    ]:
        new_text = re.sub(old_pattern, f'NODE_REPL_NODE_PATH = "{PLAT["node"]}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 3. Fix NODE_REPL_NODE_MODULE_DIRS
    for old_pattern in [
        r"NODE_REPL_NODE_MODULE_DIRS\s*=\s*'C:\\Users\\[^']*node_modules'",
        r'NODE_REPL_NODE_MODULE_DIRS\s*=\s*"/Applications/Codex\.app[^"]*node_modules"',
    ]:
        new_text = re.sub(old_pattern, f'NODE_REPL_NODE_MODULE_DIRS = "{PLAT["node_modules"]}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 4. Fix NODE_REPL_TRUSTED_CODE_PATHS
    for old_pattern in [
        r"NODE_REPL_TRUSTED_CODE_PATHS\s*=\s*'C:\\Users\\[^']*\.codex'",
        r'NODE_REPL_TRUSTED_CODE_PATHS\s*=\s*"/Users/[^"]*/.codex"',
    ]:
        new_text = re.sub(old_pattern, f'NODE_REPL_TRUSTED_CODE_PATHS = "{PLAT["trusted_paths"]}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 5. Fix CODEX_HOME in node_repl.env
    for old_pattern in [
        r"CODEX_HOME\s*=\s*'C:\\Users\\[^']*\.codex'",
        r'CODEX_HOME\s*=\s*"/Users/[^"]*/.codex"',
    ]:
        new_text = re.sub(old_pattern, f'CODEX_HOME = "{CODEX_HOME}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 6. Fix CODEX_CLI_PATH
    for old_pattern in [
        r"CODEX_CLI_PATH\s*=\s*'C:\\Users\\[^']*codex(\.exe)?'",
        r'CODEX_CLI_PATH\s*=\s*"/Users/[^"]*codex"',
    ]:
        new_text = re.sub(old_pattern, f'CODEX_CLI_PATH = "{PLAT["codex_cli"]}"', text)
        if new_text != text:
            changes += 1
            text = new_text

    # 7. Handle SKY_CUA_NATIVE_PIPE (Windows-only)
    if PLAT["os"] == "windows":
        if 'SKY_CUA_NATIVE_PIPE' not in text:
            text = re.sub(
                r'CODEX_CLI_PATH[^\n]*\n',
                f'CODEX_CLI_PATH = "{PLAT["codex_cli"]}"\nSKY_CUA_NATIVE_PIPE = "1"\n',
                text, count=1
            )
            changes += 1
    else:  # macOS — remove SKY_CUA_NATIVE_PIPE
        if 'SKY_CUA_NATIVE_PIPE' in text:
            text = re.sub(r'\nSKY_CUA_NATIVE_PIPE = "1"\n', '\n', text)
            text = re.sub(r"\nSKY_CUA_NATIVE_PIPE_DIRECTORY = '[^']*'\n", '\n', text)
            text = re.sub(r'\nNODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS = "[^"]*"\n', '\n', text)
            changes += 1

    # 8. Windows sandbox section (Windows-only)
    if PLAT["os"] != "windows":
        if re.search(r'\[windows\]\nsandbox\s*=', text):
            text = re.sub(r'\n\[windows\]\nsandbox = "elevated"\n', '\n', text)
            changes += 1

    if changes > 0:
        config.write_text(text, encoding="utf-8")
        print(f"  ✅ config.toml 已修复 ({changes} 处变更)")
    else:
        print(f"  ✅ config.toml 无需修复")

    return True


# ── cc-switch database repair ───────────────────────────────────

def fix_cc_switch_db():
    if not CC_SWITCH_DB.exists():
        print("  ⚠️  cc-switch.db 未找到")
        return

    backup(CC_SWITCH_DB)
    con = sqlite3.connect(str(CC_SWITCH_DB))
    con.row_factory = sqlite3.Row
    cursor = con.cursor()

    # ── Fix common_config_codex ──
    row = cursor.execute(
        "SELECT value FROM settings WHERE key = 'common_config_codex'"
    ).fetchone()
    if row:
        text = row["value"]
        original = text

        # Replace wrong-platform paths
        wrong_paths = find_windows_paths(text) if PLAT["os"] == "macos" else find_macos_paths(text)

        if wrong_paths:
            text = _localize_config_text(text)
            if text != original:
                cursor.execute(
                    "UPDATE settings SET value = ? WHERE key = 'common_config_codex'",
                    (text,)
                )
                con.commit()
                print("  ✅ cc-switch common_config_codex 已本地化")
        else:
            print("  ✅ cc-switch common_config_codex 路径正确")

    # ── Fix all codex providers ──
    rows = cursor.execute(
        "SELECT id, name, settings_config FROM providers WHERE app_type = 'codex'"
    ).fetchall()
    for row in rows:
        try:
            cfg = json.loads(row["settings_config"])
        except json.JSONDecodeError:
            continue

        config_text = cfg.get("config", "")
        if not config_text:
            continue

        wrong_paths = find_windows_paths(config_text) if PLAT["os"] == "macos" else find_macos_paths(config_text)
        if wrong_paths:
            cfg["config"] = _localize_config_text(config_text)
            cursor.execute(
                "UPDATE providers SET settings_config = ? WHERE id = ? AND app_type = 'codex'",
                (json.dumps(cfg, ensure_ascii=False), row["id"])
            )
            con.commit()
            print(f"  ✅ provider '{row['name']}' 配置已本地化")

    # ── Fix mcp_servers ──
    rows = cursor.execute(
        "SELECT id, name, server_config FROM mcp_servers WHERE enabled_codex = 1"
    ).fetchall()
    for row in rows:
        cfg_text = row["server_config"]
        wrong_paths = find_windows_paths(cfg_text) if PLAT["os"] == "macos" else find_macos_paths(cfg_text)
        if wrong_paths:
            cfg_text = _localize_server_config(cfg_text)
            cursor.execute(
                "UPDATE mcp_servers SET server_config = ? WHERE id = ?",
                (cfg_text, row["id"])
            )
            con.commit()
            print(f"  ✅ mcp_server '{row['name']}' 已本地化")

    con.close()


def _localize_config_text(text: str) -> str:
    """Replace all foreign-platform paths in a TOML config block."""
    if PLAT["os"] == "macos":
        # Windows → macOS
        text = re.sub(r"C:\\Users\\[^'\"\s]*\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\[^'\"\s]*\\\\bin\\\\node_repl\.exe",
                      PLAT["node_repl"].replace("\\", "\\\\"), text)
        text = re.sub(r"C:\\Users\\[^'\"\s]*\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\[^'\"\s]*\\\\bin\\\\node\.exe",
                      PLAT["node"].replace("\\", "\\\\"), text)
        text = re.sub(r"C:\\Users\\[^'\"\s]*\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\[^'\"\s]*\\\\bin\\\\node_modules",
                      str(PLAT["node_modules"]).replace("\\", "\\\\"), text)
        # Generic Windows paths
        text = text.replace("C:\\Users\\gaoxi\\.codex", str(CODEX_HOME))
        text = re.sub(r"C:\\Users\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\bin\\\\[^'\"\s]*\\\\codex\.exe",
                      str(PLAT["codex_cli"]).replace("\\", "\\\\"), text)
        # Remove Windows-only
        text = re.sub(r'SKY_CUA_NATIVE_PIPE = "1"\n', '', text)
        text = re.sub(r"SKY_CUA_NATIVE_PIPE_DIRECTORY = '[^']*'\n", '', text)
        text = re.sub(r"NODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS = \"[^\"]*\"\n", '', text)
        text = re.sub(r'\[windows\]\nsandbox = "elevated"\n\n?', '', text)
        # Fix skills paths
        text = text.replace("C:\\Users\\gaoxi\\.codex\\skills\\", f"{CODEX_HOME}/skills/")
        # Fix projects
        text = text.replace("d:\\deepseek", f"{HOME}/Documents/Deepseek")
        text = text.replace("d:\\ai工作集合\\日常", f"{HOME}/Documents/Deepseek")
        # Fix filesystem MCP
        text = text.replace("D:\\Deepseek", f"{HOME}/Documents/Deepseek")
        # Fix marketplace
        text = re.sub(r"\\\\\?\\C:\\Users\\gaoxi\\\.codex\\\.tmp\\bundled-marketplaces\\openai-bundled",
                      f"{CODEX_HOME}/.tmp/bundled-marketplaces/openai-bundled", text)
    else:
        # macOS → Windows
        text = text.replace(
            "/Applications/Codex.app/Contents/Resources/cua_node/bin/node_repl",
            PLAT["node_repl"]
        )
        text = text.replace(
            "/Applications/Codex.app/Contents/Resources/cua_node/bin/node",
            PLAT["node"]
        )
        text = text.replace(
            "/Applications/Codex.app/Contents/Resources/cua_node/lib/node_modules",
            PLAT["node_modules"]
        )
        # Add Windows CUA settings
        if 'SKY_CUA_NATIVE_PIPE' not in text:
            text += '\nSKY_CUA_NATIVE_PIPE = "1"\n'
        text = text.replace(str(CODEX_HOME / "plugins/.plugin-appserver/codex"),
                          PLAT["codex_cli"])

    return text


def _localize_server_config(cfg_text: str) -> str:
    """Replace foreign-platform paths in a JSON MCP server config."""
    if PLAT["os"] == "macos":
        cfg_text = cfg_text.replace(
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\",
            "/Applications/Codex.app/Contents/Resources/cua_node/"
        )
        cfg_text = re.sub(r'\\\\a89897d3d9baa117\\\\', '/', cfg_text)
        cfg_text = cfg_text.replace("node_repl.exe", "node_repl")
        cfg_text = cfg_text.replace("node.exe", "node")
        cfg_text = re.sub(r'"SKY_CUA_NATIVE_PIPE":"1",?', '', cfg_text)
    else:
        cfg_text = cfg_text.replace(
            "/Applications/Codex.app/Contents/Resources/cua_node/",
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\SPECIFY_HASH\\\\"
        )
    return cfg_text


# ── verify ──────────────────────────────────────────────────────

def verify():
    print("\n── 验证 ──")
    issues = 0

    # Check config.toml
    config = CODEX_HOME / "config.toml"
    if config.exists():
        text = config.read_text(encoding="utf-8")
        wrong = find_windows_paths(text) if PLAT["os"] == "macos" else find_macos_paths(text)
        if wrong:
            print(f"  ❌ config.toml 含 {len(wrong)} 个外来平台路径")
            issues += 1
        else:
            print("  ✅ config.toml 路径正确")

        if PLAT["node_repl"] in text:
            print(f"  ✅ 包含正确的 node_repl 路径")

    # Check cc-switch
    if CC_SWITCH_DB.exists():
        con = sqlite3.connect(str(CC_SWITCH_DB))
        row = con.execute(
            "SELECT value FROM settings WHERE key = 'common_config_codex'"
        ).fetchone()
        if row:
            wrong = find_windows_paths(row[0]) if PLAT["os"] == "macos" else find_macos_paths(row[0])
            if wrong:
                print(f"  ❌ cc-switch common_config 含 {len(wrong)} 个外来平台路径")
                issues += 1
            else:
                print("  ✅ cc-switch common_config 路径正确")
        con.close()

    if issues == 0:
        print("\n🎉 全部通过！")
    else:
        print(f"\n⚠️  {issues} 项检查未通过，请运行修复模式")
    return issues == 0


# ── main ────────────────────────────────────────────────────────

def main():
    import argparse
    parser = argparse.ArgumentParser(description="跨平台 CUA 路径修复")
    parser.add_argument("--verify", action="store_true", help="仅验证不修复")
    args = parser.parse_args()

    print(f"🖥️  平台: {PLAT['os']} ({platform.system()})")
    print(f"   node_repl: {PLAT['node_repl']}")
    print(f"   codex_home: {CODEX_HOME}")
    print()

    if args.verify:
        verify()
        return

    fix_config_toml()
    fix_cc_switch_db()
    verify()

    print("\n💡 下一步: 重启 Codex Desktop 和 CC Switch 使配置生效")


if __name__ == "__main__":
    main()
