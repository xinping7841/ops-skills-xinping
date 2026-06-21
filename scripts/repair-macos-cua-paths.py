#!/usr/bin/env python3
"""修复 macOS 上 config.toml 和 cc-switch 数据库中被 Windows 路径污染的 CUA 配置。"""

import re
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

HOME = Path.home()
CODEX_HOME = HOME / ".codex"
CONFIG_TOML = CODEX_HOME / "config.toml"
CC_SWITCH_DB = HOME / ".cc-switch" / "cc-switch.db"

CODEX_APP = Path("/Applications/Codex.app/Contents/Resources")
NODE_BIN = CODEX_APP / "cua_node/bin"
NODE_REPL = NODE_BIN / "node_repl"
NODE = NODE_BIN / "node"
NODE_MODULES = CODEX_APP / "cua_node/lib/node_modules"
CODEX_CLI_PATH = CODEX_HOME / "plugins/.plugin-appserver/codex"


def backup(path: Path) -> Path:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    bak = path.with_suffix(f"{path.suffix}.bak-cua-repair-{stamp}")
    if path.exists():
        bak.write_bytes(path.read_bytes())
        print(f"  ✅ 已备份: {bak}")
    return bak


def fix_config_toml():
    if not CONFIG_TOML.exists():
        print(f"  ⚠️  未找到 config.toml: {CONFIG_TOML}")
        return

    backup(CONFIG_TOML)
    text = CONFIG_TOML.read_text(encoding="utf-8")

    # 1. 修复 notify
    text = re.sub(
        r'notify = \[ "[^"]*codex-computer-use\.exe"[^\]]*\]',
        'notify = [ "turn-ended" ]',
        text
    )

    # 2. 修复 mcp_servers.node_repl.command
    text = re.sub(
        r"command = 'C:\\\\Users\\\\gaoxi[^']*node_repl\.exe'",
        f'command = "{NODE_REPL}"',
        text
    )

    # 3. NODE_REPL_NODE_PATH
    text = re.sub(
        r"NODE_REPL_NODE_PATH = 'C:\\\\Users\\\\gaoxi[^']*node\.exe'",
        f'NODE_REPL_NODE_PATH = "{NODE}"',
        text
    )

    # 4. NODE_REPL_NODE_MODULE_DIRS
    text = re.sub(
        r"NODE_REPL_NODE_MODULE_DIRS = 'C:\\\\Users\\\\gaoxi[^']*node_modules'",
        f'NODE_REPL_NODE_MODULE_DIRS = "{NODE_MODULES}"',
        text
    )

    # 5. NODE_REPL_TRUSTED_CODE_PATHS
    text = re.sub(
        r"NODE_REPL_TRUSTED_CODE_PATHS = 'C:\\\\Users\\\\gaoxi\\\\.codex'",
        f'NODE_REPL_TRUSTED_CODE_PATHS = "{CODEX_HOME}"',
        text
    )

    # 6. CODEX_HOME (在 node_repl.env 中)
    text = re.sub(
        r"CODEX_HOME = 'C:\\\\Users\\\\gaoxi\\\\.codex'",
        f'CODEX_HOME = "{CODEX_HOME}"',
        text
    )

    # 7. CODEX_CLI_PATH
    text = re.sub(
        r"CODEX_CLI_PATH = 'C:\\\\Users\\\\gaoxi[^']*codex\.exe'",
        f'CODEX_CLI_PATH = "{CODEX_CLI_PATH}"',
        text
    )

    # 8. 删除 Windows-only 设置
    text = re.sub(r'\nSKY_CUA_NATIVE_PIPE = "1"\n', '\n', text)
    text = re.sub(r"\nSKY_CUA_NATIVE_PIPE_DIRECTORY = '[^']*'\n", '\n', text)
    text = re.sub(r'\nNODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS = "[^"]*"\n', '\n', text)
    text = re.sub(r'\n\[windows\]\nsandbox = "elevated"\n', '\n', text)

    # 9. 修复 marketplace 和 skills 路径
    text = text.replace(
        r"'\\?\C:\Users\gaoxi\.codex\.tmp\bundled-marketplaces\openai-bundled'",
        f'"{CODEX_HOME}/.tmp/bundled-marketplaces/openai-bundled"'
    )
    text = text.replace(
        r"'\\?\C:\Users\gaoxi\.cache\codex-runtimes\codex-primary-runtime\plugins\openai-primary-runtime'",
        f'"{HOME}/.cache/codex-runtimes/codex-primary-runtime/plugins/openai-primary-runtime"'
    )

    # 10. 修复 skills 路径
    text = text.replace("C:\\Users\\gaoxi\\.codex\\skills\\", f"{CODEX_HOME}/skills/")

    # 11. 修复 projects 路径
    text = text.replace("'d:\\deepseek'", f"'{CODEX_HOME.parent}/Documents/Deepseek'")
    text = text.replace("'d:\\ai工作集合\\日常'", f"'{CODEX_HOME.parent}/Documents/Deepseek'")

    # 12. 修复 mcp_servers.filesystem
    text = text.replace('"D:\\Deepseek"', f'"{CODEX_HOME.parent}/Documents/Deepseek"')
    text = text.replace("'D:\\\\Deepseek'", f'"{CODEX_HOME.parent}/Documents/Deepseek"')

    # 13. 修复 mcp_servers.context7
    text = text.replace(
        '"C:/Users/gaoxi/AppData/Roaming/npm/node_modules/@upstash/context7-mcp/dist/index.js"',
        '"/usr/local/lib/node_modules/@upstash/context7-mcp/dist/index.js"'
    )

    CONFIG_TOML.write_text(text, encoding="utf-8")
    print(f"  ✅ config.toml 已修复并保存")


def fix_cc_switch_db():
    if not CC_SWITCH_DB.exists():
        print(f"  ⚠️  未找到 cc-switch 数据库: {CC_SWITCH_DB}")
        return

    backup(CC_SWITCH_DB)
    con = sqlite3.connect(str(CC_SWITCH_DB))
    con.row_factory = sqlite3.Row
    cursor = con.cursor()

    # 修复 common_config_codex
    row = cursor.execute("SELECT value FROM settings WHERE key = 'common_config_codex'").fetchone()
    if row:
        text = row[0]
        original = text
        text = text.replace(
            "C:\\Users\\gaoxi\\AppData\\Local\\OpenAI\\Codex\\runtimes\\cua_node\\a89897d3d9baa117\\bin\\node_repl.exe",
            str(NODE_REPL)
        )
        text = text.replace(
            "C:\\Users\\gaoxi\\AppData\\Local\\OpenAI\\Codex\\runtimes\\cua_node\\a89897d3d9baa117\\bin\\node.exe",
            str(NODE)
        )
        text = text.replace(
            "C:\\Users\\gaoxi\\AppData\\Local\\OpenAI\\Codex\\runtimes\\cua_node\\a89897d3d9baa117\\bin\\node_modules",
            str(NODE_MODULES)
        )
        text = text.replace("C:\\Users\\gaoxi\\.codex", str(CODEX_HOME))
        text = text.replace(
            "C:\\Users\\gaoxi\\AppData\\Local\\OpenAI\\Codex\\bin\\5d35d2790d1d3d7b\\codex.exe",
            str(CODEX_CLI_PATH)
        )
        # Remove Windows-only settings
        text = re.sub(r'\nSKY_CUA_NATIVE_PIPE = "1"\n', '\n', text)
        text = re.sub(r"\nSKY_CUA_NATIVE_PIPE_DIRECTORY = '[^']*'\n", '\n', text)
        text = re.sub(r'\nNODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS = "[^"]*"\n', '\n', text)
        text = re.sub(r'\n\[windows\]\nsandbox = "elevated"\n', '\n', text)
        # Fix marketplace paths
        text = text.replace(
            r"\\?\C:\Users\gaoxi\.codex\.tmp\bundled-marketplaces\openai-bundled",
            f"{CODEX_HOME}/.tmp/bundled-marketplaces/openai-bundled"
        )
        text = text.replace(
            r"\\?\C:\Users\gaoxi\.cache\codex-runtimes\codex-primary-runtime\plugins\openai-primary-runtime",
            f"{HOME}/.cache/codex-runtimes/codex-primary-runtime/plugins/openai-primary-runtime"
        )
        # Fix skills paths
        text = text.replace("C:\\Users\\gaoxi\\.codex\\skills\\", f"{CODEX_HOME}/skills/")
        # Fix filesystem
        text = text.replace("D:\\Deepseek", f"{HOME}/Documents/Deepseek")
        # Fix context7
        text = text.replace(
            "C:/Users/gaoxi/AppData/Roaming/npm/node_modules/@upstash/context7-mcp/dist/index.js",
            "/usr/local/lib/node_modules/@upstash/context7-mcp/dist/index.js"
        )
        # Fix projects
        text = text.replace("d:\\deepseek", f"{HOME}/Documents/Deepseek")
        text = text.replace("d:\\ai工作集合\\日常", f"{HOME}/Documents/Deepseek")

        if text != original:
            cursor.execute("UPDATE settings SET value = ? WHERE key = 'common_config_codex'", (text,))
            con.commit()
            print(f"  ✅ cc-switch common_config_codex 已修复")
        else:
            print(f"  ℹ️  cc-switch common_config_codex 无需修改")

    # 修复 mcp_servers 表中的 node_repl
    row = cursor.execute("SELECT id, server_config FROM mcp_servers WHERE id = 'node_repl'").fetchone()
    if row:
        config = row["server_config"]
        original_cfg = config
        config = config.replace(
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\a89897d3d9baa117\\\\bin\\\\node_repl.exe",
            str(NODE_REPL)
        )
        config = config.replace(
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\a89897d3d9baa117\\\\bin\\\\node.exe",
            str(NODE)
        )
        config = config.replace(
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\runtimes\\\\cua_node\\\\a89897d3d9baa117\\\\bin\\\\node_modules",
            str(NODE_MODULES)
        )
        config = config.replace("C:\\\\Users\\\\gaoxi\\\\.codex", str(CODEX_HOME))
        config = config.replace(
            "C:\\\\Users\\\\gaoxi\\\\AppData\\\\Local\\\\OpenAI\\\\Codex\\\\bin\\\\5d35d2790d1d3d7b\\\\codex.exe",
            str(CODEX_CLI_PATH)
        )
        config = re.sub(r'"SKY_CUA_NATIVE_PIPE":"1",?', '', config)
        config = re.sub(r'"SKY_CUA_NATIVE_PIPE_DIRECTORY":"[^"]*",?', '', config)

        if config != original_cfg:
            cursor.execute(
                "UPDATE mcp_servers SET server_config = ? WHERE id = 'node_repl'",
                (config,)
            )
            con.commit()
            print(f"  ✅ cc-switch mcp_servers.node_repl 已修复")
        else:
            print(f"  ℹ️  cc-switch mcp_servers.node_repl 无需修改")

    # 修复 mcp_servers.filesystem
    row = cursor.execute(
        "SELECT id, server_config FROM mcp_servers WHERE id = 'filesystem'"
    ).fetchone()
    if row:
        config = row["server_config"]
        if "D:\\Deepseek" in config:
            config = config.replace(
                "D:\\Deepseek", f"{HOME}/Documents/Deepseek"
            )
            cursor.execute(
                "UPDATE mcp_servers SET server_config = ? WHERE id = 'filesystem'",
                (config,)
            )
            con.commit()
            print(f"  ✅ cc-switch mcp_servers.filesystem 已修复")

    # 修复 mcp_servers.context7
    row = cursor.execute(
        "SELECT id, server_config FROM mcp_servers WHERE id = 'context7'"
    ).fetchone()
    if row:
        config = row["server_config"]
        if "C:/Users/gaoxi" in config:
            config = config.replace(
                "C:/Users/gaoxi/AppData/Roaming/npm/node_modules/@upstash/context7-mcp/dist/index.js",
                "/usr/local/lib/node_modules/@upstash/context7-mcp/dist/index.js"
            )
            cursor.execute(
                "UPDATE mcp_servers SET server_config = ? WHERE id = 'context7'",
                (config,)
            )
            con.commit()
            print(f"  ✅ cc-switch mcp_servers.context7 已修复")

    con.close()


def verify():
    """验证修复结果"""
    print("\n--- 验证修复结果 ---")
    if CONFIG_TOML.exists():
        text = CONFIG_TOML.read_text(encoding="utf-8")
        issues = []
        if "gaoxi" in text:
            issues.append("⚠️  config.toml 仍包含 'gaoxi' Windows 路径")
        if "SKY_CUA_NATIVE_PIPE" in text:
            issues.append("⚠️  config.toml 仍包含 SKY_CUA_NATIVE_PIPE")
        if "node_repl.exe" in text:
            issues.append("⚠️  config.toml 仍包含 node_repl.exe")
        if str(NODE_REPL) in text:
            print(f"  ✅ config.toml 包含正确的 node_repl 路径: {NODE_REPL}")
        if str(NODE) in text:
            print(f"  ✅ config.toml 包含正确的 node 路径: {NODE}")
        if not issues:
            print(f"  ✅ config.toml 无 Windows 路径残留")
        else:
            for i in issues:
                print(f"  {i}")

    if CC_SWITCH_DB.exists():
        con = sqlite3.connect(str(CC_SWITCH_DB))
        row = con.execute(
            "SELECT value FROM settings WHERE key = 'common_config_codex'"
        ).fetchone()
        if row and "gaoxi" in row[0]:
            print(f"  ⚠️  cc-switch common_config 仍包含 Windows 路径")
        else:
            print(f"  ✅ cc-switch common_config 已清理")

        row = con.execute(
            "SELECT server_config FROM mcp_servers WHERE id = 'node_repl'"
        ).fetchone()
        if row and "gaoxi" in row[0]:
            print(f"  ⚠️  cc-switch mcp_servers.node_repl 仍包含 Windows 路径")
        else:
            print(f"  ✅ cc-switch mcp_servers.node_repl 已清理")
        con.close()


def main():
    print("🔧 开始修复 macOS CUA 路径...")
    print(f"   Codex Home: {CODEX_HOME}")
    print(f"   Node Repl:  {NODE_REPL}")
    print(f"   Node:       {NODE}")

    fix_config_toml()
    fix_cc_switch_db()
    verify()

    print("\n💡 下一步:")
    print("   1. 完全退出 Codex Desktop (Cmd+Q)")
    print("   2. 重新启动 Codex Desktop")
    print("   3. 如需手机控制，运行: codex remote-control start")


if __name__ == "__main__":
    main()
