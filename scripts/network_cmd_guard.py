#!/usr/bin/env python3
"""网络设备命令风险检查器。

检查模型输出中是否包含高风险命令。
当模型输出中含有禁止命令时，自动标记并返回风险报告。

用法：
    from network_cmd_guard import check_commands, CommandRisk

    risks = check_commands(model_output)
    if risks:
        for r in risks:
            print(f"[{r.level}] {r.command} - {r.reason}")
"""

import re
from dataclasses import dataclass, field
from typing import List


@dataclass
class CommandRisk:
    level: str        # "HIGH" | "MEDIUM" | "LOW"
    command: str      # 匹配到的命令原文
    reason: str       # 风险说明
    suggestion: str   # 安全替代或人审要求


# 高风险命令 — 禁止自动执行，必须人工审核
HIGH_RISK_COMMANDS = [
    ("reboot",
     "重启设备将导致全网断网",
     "如确需重启，请先确认维护窗口、备份配置、告知受影响用户"),
    ("reset saved-configuration",
     "清除启动配置将导致下次重启配置丢失",
     "请先备份当前配置到 TFTP/FTP 服务器"),
    ("format flash:",
     "格式化 Flash 将永久删除所有文件",
     "绝对禁止；如需清理空间请用 delete /unreserved 逐个确认"),
    ("delete /unreserved",
     "永久删除文件不可恢复",
     "请先确认文件用途，用 dir 列出文件后再操作"),
    ("erase startup-config",
     "清除启动配置不可逆",
     "如需重置设备，请先备份 running-config"),
]

# 中风险命令 — 允许提及但需标注风险
MEDIUM_RISK_COMMANDS = [
    ("undo dhcp snooping",
     "关闭 DHCP Snooping 会暴露 DHCP 欺骗风险",
     "仅限临时排查，确认问题后应立即恢复启用"),
    ("undo dhcp snooping vlan",
     "关闭特定 VLAN 的 DHCP Snooping 保护",
     "需确认该 VLAN 无 DHCP 服务器欺骗风险"),
    ("shutdown",
     "关闭接口将中断该端口所有连接",
     "确认端口连接设备，评估中断影响"),
    ("undo shutdown",
     "开启接口前需确认端口安全状态",
     "先用 display interface 确认端口状态和连接设备"),
    ("save force",
     "强制保存将覆盖启动配置，可能固化错误配置",
     "先用 display current-configuration 对比 running-config 与 startup-config"),
    ("system-view",
     "进入系统视图后即可执行写操作",
     "提醒用户 system-view 之后进入写配置模式，注意勿误操作"),
]

# 低风险提醒 — 安全但需注意
LOW_RISK_PATTERNS = [
    ("display current-configuration",
     "显示运行配置，可能包含敏感信息（如 SNMP community、密码）",
     "分享输出时注意脱敏"),
    ("terminal monitor",
     "开启终端监控可能产生大量输出",
     "不需要时用 undo terminal monitor 关闭"),
]


def check_commands(output: str) -> List[CommandRisk]:
    """检查模型输出中是否包含风险命令。

    Args:
        output: 模型输出的完整文本

    Returns:
        CommandRisk 列表，按风险等级排序（HIGH > MEDIUM > LOW）
    """
    risks = []
    output_lower = output.lower()

    for cmd, reason, suggestion in HIGH_RISK_COMMANDS:
        if cmd.lower() in output_lower:
            # 排除被标注为回滚方案中的命令
            # 简单启发：如果命令上下文有 "回滚" 或 "rollback" 则降级
            context = _get_context(output, cmd)
            if _is_in_rollback_context(context):
                risks.append(CommandRisk(
                    level="MEDIUM",
                    command=cmd,
                    reason=f"{reason}（出现在回滚方案中，风险降级）",
                    suggestion=suggestion
                ))
            else:
                risks.append(CommandRisk(
                    level="HIGH",
                    command=cmd,
                    reason=reason,
                    suggestion=suggestion
                ))

    for cmd, reason, suggestion in MEDIUM_RISK_COMMANDS:
        if cmd.lower() in output_lower:
            context = _get_context(output, cmd)
            if _is_in_rollback_context(context):
                continue  # 回滚方案中的中风险命令可接受
            risks.append(CommandRisk(
                level="MEDIUM",
                command=cmd,
                reason=reason,
                suggestion=suggestion
            ))

    for cmd, reason, suggestion in LOW_RISK_PATTERNS:
        if cmd.lower() in output_lower:
            risks.append(CommandRisk(
                level="LOW",
                command=cmd,
                reason=reason,
                suggestion=suggestion
            ))

    return sorted(risks, key=lambda r: {"HIGH": 0, "MEDIUM": 1, "LOW": 2}.get(r.level, 99))


def _get_context(output: str, match: str, window: int = 40) -> str:
    """获取匹配命令附近的上下文文本。"""
    idx = output.lower().find(match.lower())
    if idx == -1:
        return ""
    start = max(0, idx - window)
    end = min(len(output), idx + len(match) + window)
    return output[start:end]


def _is_in_rollback_context(context: str) -> bool:
    """判断命令是否在回滚方案的上下文中。"""
    rollback_keywords = ["回滚", "rollback", "恢复", "revert", "备份", "回退"]
    return any(kw in context.lower() for kw in rollback_keywords)


def format_risk_report(risks: List[CommandRisk]) -> str:
    """格式化输出风险报告。"""
    if not risks:
        return "OK: 未检测到风险命令"

    lines = ["⚠️  检测到风险命令：", ""]
    for r in risks:
        lines.append(f"  [{r.level}] {r.command}")
        lines.append(f"         原因: {r.reason}")
        lines.append(f"         建议: {r.suggestion}")
        lines.append("")
    return "\n".join(lines)


# ========== CLI 入口 ==========
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python network_cmd_guard.py '<model_output>'")
        print("   or: echo 'model output' | python network_cmd_guard.py --stdin")
        sys.exit(1)

    if sys.argv[1] == "--stdin":
        text = sys.stdin.read()
    else:
        text = sys.argv[1]

    risks = check_commands(text)
    print(format_risk_report(risks))

    # 退出码：有 HIGH 风险返回 1
    if any(r.level == "HIGH" for r in risks):
        sys.exit(1)
