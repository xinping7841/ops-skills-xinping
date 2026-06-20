#!/usr/bin/env python3
"""Localize and export the 12700K CC Switch skill profile.

This script intentionally writes only local CC Switch/Codex skill metadata and a
sanitized repo manifest. It does not copy provider configs, tokens, OAuth files,
logs, or the CC Switch SQLite database into Git.
"""

from __future__ import annotations

import datetime as _dt
import json
import re
import shutil
import sqlite3
import time
from pathlib import Path


HOME = Path.home()
CC_SWITCH = HOME / ".cc-switch"
DB_PATH = CC_SWITCH / "cc-switch.db"
REPO = Path(__file__).resolve().parents[1]
MANIFEST = REPO / "machine-profiles" / "12700k-cc-switch-skills.json"


ZH = {
    "baoyu-compress-image": ("宝玉-图片压缩", "压缩图片并转换为 WebP 或 PNG，适合优化图片体积、批量压缩、转 WebP、减小图片文件大小。"),
    "baoyu-diagram": ("宝玉-图表绘制", "创建专业 SVG 图表，适合架构图、流程图、时序图、脑图、网络拓扑、系统结构和各种“画个图”需求。"),
    "baoyu-format-markdown": ("宝玉-Markdown 排版", "为普通文本或 Markdown 添加标题、摘要、层级、加粗、列表和代码块，适合文章排版和 Markdown 美化。"),
    "baoyu-infographic": ("宝玉-信息图生成", "生成专业信息图和高密度视觉总结，适合信息图、可视化摘要、长文提炼和社交媒体大图。"),
    "baoyu-markdown-to-html": ("宝玉-Markdown 转 HTML", "将 Markdown 转为带样式 HTML，支持微信兼容主题、代码高亮、数学公式、Mermaid 和外链引用。"),
    "baoyu-translate": ("宝玉-翻译", "翻译文本或文档内容，适合中英互译、润色译文、多语言内容转换和保持 Markdown 结构的翻译任务。"),
    "baoyu-url-to-markdown": ("宝玉-网页转 Markdown", "抓取 URL 并转换为 Markdown，支持网页、X/Twitter、YouTube 字幕、Hacker News 等内容保存。"),
    "baoyu-youtube-transcript": ("宝玉-YouTube 字幕提取", "下载 YouTube 视频字幕、封面和章节信息，适合提取视频文字稿、字幕、封面图和多语言转写。"),
    "brand-guidelines": ("品牌规范应用", "将品牌颜色、字体和视觉规范应用到文档、页面、报告或视觉稿中，适合需要统一品牌风格的输出。"),
    "canvas-design": ("画布视觉设计", "创建海报、静态视觉稿、艺术图和 PDF/PNG 设计稿，适合需要原创视觉设计的任务。"),
    "changelog-generator": ("更新日志生成", "根据 Git 提交历史生成面向用户的更新日志，把技术提交整理成清晰的版本说明。"),
    "codex-sandbox-repair": ("Codex 沙箱修复", "修复 Windows 上 Codex sandbox helper、ACL、.sandbox 目录和 shell_command 启动失败等问题。"),
    "content-research-writer": ("内容研究写作", "辅助资料研究、引用整理、文章大纲、开头优化和段落迭代，适合高质量内容写作。"),
    "doc-coauthoring": ("文档协作写作", "通过结构化流程协作撰写文档、提案、技术方案、决策记录和规范说明。"),
    "docx": ("Word 文档处理", "创建、读取、编辑和整理 .docx Word 文档，支持目录、标题、页码、图片、查找替换、批注和专业格式。"),
    "domain-name-brainstormer": ("域名头脑风暴", "为项目生成创意域名并检查常见后缀可用性，适合产品命名和域名筛选。"),
    "file-organizer": ("文件整理", "根据内容理解文件和文件夹，识别重复文件，建议目录结构并辅助清理本地文件。"),
    "frontend-design": ("前端视觉设计", "为新 UI 或现有界面提供更有辨识度的视觉设计、字体、布局和审美方向。"),
    "internal-comms": ("内部沟通写作", "撰写状态报告、领导更新、项目同步、FAQ、事故报告、公司通讯等内部沟通材料。"),
    "invoice-organizer": ("发票收据整理", "读取并整理发票、收据和报销文件，提取关键信息、规范命名并分类归档。"),
    "kun-skills-sync": ("Kun 技能同步", "维护 Kun / .agents 技能多机同步、GitHub 推送、首次拉取和本机技能目录对齐。"),
    "mcp-builder": ("MCP 服务构建", "指导创建高质量 MCP 服务器，适合用 Python FastMCP 或 Node/TypeScript MCP SDK 集成外部 API。"),
    "mcp-servers": ("MCP 服务器配置", "管理和排查 GitHub、filesystem、context7、playwright 等 MCP 服务器配置。"),
    "meeting-insights-analyzer": ("会议洞察分析", "分析会议记录或转写内容，提炼沟通模式、行为反馈、行动项和领导力改进建议。"),
    "ops-terminal-sync": ("终端技能同步运维", "同步和维护 Deepseek ops skills 多机工作区、Codex/Kun AGENTS、计划任务和 GitHub 分发。"),
    "pdf": ("PDF 处理", "读取、拆分、合并、旋转、加水印、OCR、提取表格/图片、填写表单和生成 PDF。"),
    "pptx": ("PPT 演示处理", "创建、读取、编辑和整理 .pptx 幻灯片，支持模板、版式、备注、合并拆分和内容提取。"),
    "product-requirements": ("产品需求文档", "通过交互式需求收集、分析和质量检查生成 PRD、功能规格和产品需求说明。"),
    "shenlan-ops": ("深蓝现场网络运维", "深蓝现场网络、OpenWrt、H3C、ER5200G3、AC/AP、NAS、VLAN、DNS、路由和带宽优化知识库。"),
    "skill-creator": ("技能创建器", "创建、修改、优化和评估技能，适合从零编写 SKILL.md 或改进已有技能触发描述。"),
    "ssh-tailscale": ("SSH 与 Tailscale", "SSH 免密连接、Tailscale 组网、新机器上线和 12700K/lk402/macair 节点连接速查。"),
    "table-data": ("表格数据整理", "清洗、合并、去重、校验、透视和汇总 Excel、CSV、TSV、Google Sheets 等表格数据。"),
    "tailored-resume-generator": ("定制简历生成", "根据职位描述生成定制简历，突出匹配经验、技能和成果，提高面试机会。"),
    "tailscale-derp": ("Tailscale DERP 中继", "自建 DERP 中继配置、验证、回滚和 Tailscale netcheck/derp-map 排查。"),
    "test-cases": ("测试用例生成", "根据 PRD 或用户需求生成结构化测试用例，覆盖功能、边界、异常和状态转换场景。"),
    "theme-factory": ("主题工厂", "为文档、幻灯片、报告和网页生成或应用视觉主题，包含颜色、字体和样式方案。"),
    "video-downloader": ("视频下载", "下载 YouTube 视频或音频，支持清晰度、格式和 MP3 音频提取选项。"),
    "web-artifacts-builder": ("Web 交互制品构建", "使用 React、Tailwind、shadcn/ui 构建复杂 HTML/Web 制品，适合需要状态管理和多组件的交互页面。"),
    "webapp-testing": ("Web 应用测试", "使用 Playwright 测试本地 Web 应用，验证前端功能、调试 UI、截图和查看浏览器日志。"),
    "xlsx": ("电子表格处理", "读取、编辑、清洗、格式化、制图和创建 .xlsx/.xlsm/.csv/.tsv 表格文件。"),
}


def backup_local_state() -> Path:
    backup = CC_SWITCH / "backups" / ("manual_chinese_skill_labels_" + time.strftime("%Y%m%d_%H%M%S"))
    backup.mkdir(parents=True, exist_ok=True)
    if DB_PATH.exists():
        shutil.copy2(DB_PATH, backup / "cc-switch.db")
    skills = CC_SWITCH / "skills"
    if skills.exists():
        shutil.copytree(skills, backup / "skills", dirs_exist_ok=True, symlinks=True)
    return backup


def update_frontmatter(path: Path, name: str, desc: str) -> bool:
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    body = text
    if text.startswith("---"):
        match = re.search(r"\n---\s*\n?", text[3:])
        if match:
            body = text[3 + match.end():].lstrip("\r\n")
    new_text = f"---\nname: {name}\ndescription: {desc}\n---\n\n{body}"
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")
        return True
    return False


def localize() -> dict[str, object]:
    backup = backup_local_state()
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    changed: list[str] = []
    for directory, (name, desc) in ZH.items():
        cur.execute("UPDATE skills SET name = ?, description = ? WHERE directory = ?", (name, desc, directory))
        if cur.rowcount:
            changed.append(directory)
            for root in (CC_SWITCH / "skills", HOME / ".codex" / "skills", HOME / ".agents" / "skills"):
                update_frontmatter(root / directory / "SKILL.md", name, desc)
    con.commit()
    con.close()
    return {"backup": str(backup), "updated": len(changed), "directories": changed}


def export_manifest() -> Path:
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    rows = con.execute(
        """
        SELECT directory, name, description, repo_owner, repo_name, repo_branch, readme_url,
               enabled_claude, enabled_codex, enabled_gemini, enabled_opencode, enabled_hermes
        FROM skills
        ORDER BY directory
        """
    ).fetchall()
    con.close()

    skills = []
    for row in rows:
        skills.append(
            {
                "directory": row["directory"],
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
            }
        )

    data = {
        "schema": "cc-switch-skills-profile/v1",
        "machine": "12700k",
        "windowsUser": "gaoxi",
        "generatedAt": _dt.datetime.now(_dt.timezone.utc).isoformat(),
        "note": "Sanitized CC Switch skills profile. Credentials, account auth data, local database files, provider secrets, and private logs are excluded.",
        "storage": {
            "ccSwitchSkillsDir": "~/.cc-switch/skills",
            "codexSkillsDir": "~/.codex/skills",
            "backupPolicy": "Use this manifest as a restore checklist; do not commit ~/.cc-switch/cc-switch.db because it may contain account/provider data.",
        },
        "skills": skills,
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return MANIFEST


def main() -> None:
    result = localize()
    manifest = export_manifest()
    print(json.dumps({**result, "manifest": str(manifest)}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
