#!/usr/bin/env python3
"""
12700k / lk402 — CC Switch 代理守护 + 会话统一脚本

用途：在 Windows 上，cc-switch 切换到 OpenAI Official 后会自动关闭本地代理，
导致 Codex 会话身份分裂（API 登录的会话在官方登录下不可见）。

此脚本：
  1. 强制启用 cc-switch Codex 代理
  2. 确保官方 provider 内嵌 config 包含 model_provider="custom"
  3. 确保 config.toml 包含 model_provider="custom" 和代理 base_url
  4. 迁移 state_5.sqlite 中所有会话到 "custom" provider

用法：
  python guard-cc-switch-session-unity.py          # 修复一次
  python guard-cc-switch-session-unity.py --watch  # 持续守护（每30秒检查）
"""

import json
import os
import sqlite3
import sys
import time
from pathlib import Path

HOME = Path.home()
CODEX_HOME = HOME / ".codex"
CC_SWITCH_DB = HOME / ".cc-switch" / "cc-switch.db"
SETTINGS_JSON = HOME / ".cc-switch" / "settings.json"
CONFIG_TOML = CODEX_HOME / "config.toml"
STATE_DB = CODEX_HOME / "state_5.sqlite"

CONFIG_HEADER = """model_provider = "custom"
model = "gpt-5.5"
disable_response_storage = true
model_reasoning_effort = "high"

[model_providers]
[model_providers.custom]
name = "custom"
wire_api = "responses"
requires_openai_auth = true
base_url = "http://127.0.0.1:15721/v1"

"""

def enable_proxy():
    """强制启用 Codex 代理"""
    if not CC_SWITCH_DB.exists():
        return False
    con = sqlite3.connect(str(CC_SWITCH_DB))
    row = con.execute(
        "SELECT proxy_enabled, enabled FROM proxy_config WHERE app_type='codex'"
    ).fetchone()
    if not row or row[0] != 1 or row[1] != 1:
        con.execute(
            "UPDATE proxy_config SET proxy_enabled=1, enabled=1 WHERE app_type='codex'"
        )
        con.commit()
        con.close()
        return True
    con.close()
    return False

def fix_official_provider():
    """确保官方 provider 内嵌 config 包含 model_provider=custom"""
    if not CC_SWITCH_DB.exists():
        return False
    con = sqlite3.connect(str(CC_SWITCH_DB))
    row = con.execute(
        "SELECT settings_config FROM providers WHERE id='codex-official'"
    ).fetchone()
    if not row:
        con.close()
        return False
    try:
        cfg = json.loads(row[0])
    except json.JSONDecodeError:
        con.close()
        return False
    old_config = cfg.get("config", "")
    if "model_provider" not in old_config:
        cfg["config"] = CONFIG_HEADER + old_config
        con.execute(
            "UPDATE providers SET settings_config=? WHERE id='codex-official'",
            (json.dumps(cfg, ensure_ascii=False),)
        )
        con.commit()
        con.close()
        return True
    con.close()
    return False

def fix_config_toml():
    """确保 config.toml 包含 model_provider=custom + proxy base_url"""
    if not CONFIG_TOML.exists():
        return False
    text = CONFIG_TOML.read_text(encoding="utf-8")
    if 'model_provider = "custom"' not in text:
        CONFIG_TOML.write_text(CONFIG_HEADER + text, encoding="utf-8")
        return True
    if 'base_url = "http://127.0.0.1:15721/v1"' not in text:
        CONFIG_TOML.write_text(CONFIG_HEADER + text, encoding="utf-8")
        return True
    return False

def unify_sessions():
    """迁移所有会话到 custom provider"""
    if not STATE_DB.exists():
        return False
    con = sqlite3.connect(str(STATE_DB))
    n = con.execute(
        "UPDATE threads SET model_provider='custom' WHERE model_provider!='custom'"
    ).rowcount
    con.commit()
    con.close()
    return n > 0

def main():
    watch = "--watch" in sys.argv

    while True:
        changes = []

        if enable_proxy():
            changes.append("proxy enabled")
        if fix_official_provider():
            changes.append("official provider fixed")
        if fix_config_toml():
            changes.append("config.toml fixed")
        if unify_sessions():
            changes.append("sessions unified")

        if changes:
            print(f"[{time.strftime('%H:%M:%S')}] " + ", ".join(changes))
        elif not watch:
            print("All good — no changes needed")

        if not watch:
            break
        time.sleep(30)


if __name__ == "__main__":
    main()
