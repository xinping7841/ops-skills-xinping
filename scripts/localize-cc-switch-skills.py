#!/usr/bin/env python3
"""Repair and export the 12700K CC Switch skill profile.

The CC Switch SQLite database and auth/config files stay local because they may
contain account data or provider secrets. This script only exports a sanitized
manifest and can re-apply names/descriptions from that manifest.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import shutil
import sqlite3
from pathlib import Path


HOME = Path.home()
CC_SWITCH = HOME / ".cc-switch"
DB_PATH = CC_SWITCH / "cc-switch.db"
CODEX_SKILLS = HOME / ".codex" / "skills"
AGENTS_SKILLS = HOME / ".agents" / "skills"
REPO = Path(__file__).resolve().parents[1]
MANIFEST = REPO / "machine-profiles" / "12700k-cc-switch-skills.json"


def user_path(path: Path) -> str:
    try:
        return "~/" + path.relative_to(HOME).as_posix()
    except ValueError:
        return str(path)


def connect_db() -> sqlite3.Connection:
    if not DB_PATH.exists():
        raise SystemExit(f"CC Switch database not found: {DB_PATH}")
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    return con


def backup_db() -> Path:
    stamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = CC_SWITCH / "backups" / f"profile_repair_{stamp}"
    backup_dir.mkdir(parents=True, exist_ok=True)
    target = backup_dir / "cc-switch.db"
    shutil.copy2(DB_PATH, target)
    return target


def db_rows() -> list[sqlite3.Row]:
    with connect_db() as con:
        return list(
            con.execute(
                """
                select
                  name, description, directory,
                  repo_owner, repo_name, repo_branch, readme_url,
                  enabled_claude, enabled_codex, enabled_gemini,
                  enabled_opencode, enabled_hermes
                from skills
                order by directory
                """
            )
        )


def manifest_skills() -> dict[str, dict]:
    if not MANIFEST.exists():
        return {}
    data = json.loads(MANIFEST.read_text(encoding="utf-8-sig"))
    return {item["directory"]: item for item in data.get("skills", [])}


def export_manifest() -> None:
    skills = []
    for row in db_rows():
        directory = row["directory"]
        skills.append(
            {
                "directory": directory,
                "displayNameZh": row["name"],
                "descriptionZh": row["description"],
                "source": {
                    "owner": row["repo_owner"],
                    "repo": row["repo_name"],
                    "branch": row["repo_branch"],
                    "readmeUrl": row["readme_url"],
                },
                "enabled": {
                    "claude": bool(row["enabled_claude"]),
                    "codex": bool(row["enabled_codex"]),
                    "gemini": bool(row["enabled_gemini"]),
                    "opencode": bool(row["enabled_opencode"]),
                    "hermes": bool(row["enabled_hermes"]),
                },
                "localPaths": {
                    "ccSwitch": user_path(CC_SWITCH / "skills" / directory),
                    "codex": user_path(CODEX_SKILLS / directory),
                    "agents": user_path(AGENTS_SKILLS / directory),
                },
            }
        )

    payload = {
        "schema": "cc-switch-skills-profile/v1",
        "machine": "12700k",
        "windowsUser": "gaoxi",
        "generatedAt": dt.datetime.now(dt.timezone.utc).isoformat(),
        "note": (
            "Sanitized CC Switch skills profile. Credentials, OAuth data, "
            "local databases, provider secrets, and private logs are excluded."
        ),
        "counts": {
            "installed": len(skills),
            "enabledCodex": sum(1 for item in skills if item["enabled"]["codex"]),
            "enabledClaude": sum(1 for item in skills if item["enabled"]["claude"]),
        },
        "storage": {
            "ccSwitchSkillsDir": "~/.cc-switch/skills",
            "codexSkillsDir": "~/.codex/skills",
            "agentsSkillsDir": "~/.agents/skills",
            "backupPolicy": (
                "Use this manifest as a restore checklist; do not commit "
                "~/.cc-switch/cc-switch.db because it may contain account data."
            ),
        },
        "skills": skills,
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8-sig",
    )


def apply_manifest() -> None:
    skills = manifest_skills()
    if not skills:
        raise SystemExit(f"No skills found in manifest: {MANIFEST}")

    backup = backup_db()
    with connect_db() as con:
        for directory, item in skills.items():
            con.execute(
                """
                update skills
                set name = ?, description = ?
                where directory = ?
                """,
                (item["displayNameZh"], item["descriptionZh"], directory),
            )
        con.commit()
    print(f"Backed up CC Switch database to {backup}")


def audit() -> None:
    roots = {
        "ccSwitch": CC_SWITCH / "skills",
        "codex": CODEX_SKILLS,
        "agents": AGENTS_SKILLS,
    }
    rows = db_rows()
    print(f"databaseInstalled={len(rows)}")
    print(f"databaseEnabledCodex={sum(1 for r in rows if r['enabled_codex'])}")
    for name, root in roots.items():
        skill_dirs = [p for p in root.iterdir() if p.is_dir()] if root.exists() else []
        skill_md = [p for p in skill_dirs if (p / "SKILL.md").exists()]
        print(f"{name}Dirs={len(skill_dirs)}")
        print(f"{name}SkillMd={len(skill_md)}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply-manifest", action="store_true")
    parser.add_argument("--audit", action="store_true")
    parser.add_argument("--fix-cua-paths", action="store_true",
                        help="Detect and fix cross-platform CUA path pollution (delegates to repair-cua-platform-paths.py)")
    args = parser.parse_args()

    if args.fix_cua_paths:
        from pathlib import Path
        repair_script = REPO / "scripts" / "repair-cua-platform-paths.py"
        if not repair_script.exists():
            raise SystemExit(f"Repair script not found: {repair_script}")
        import subprocess
        subprocess.run([sys.executable, str(repair_script)], check=True)
        return
    if args.apply_manifest:
        apply_manifest()
    if args.audit:
        audit()
        return
    export_manifest()


if __name__ == "__main__":
    main()
