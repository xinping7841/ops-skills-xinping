---
name: code-review-eval
description: Evaluate code quality, review risks, and produce prioritized findings before changing code. Use whenever the user asks for code review, project audit, code quality assessment, refactoring assessment, bug-risk scan, maintainability review, test gap analysis, PR review, UI quality review, or asks whether existing code is standard, readable, safe, or easy for agents to modify. Triggers include 代码评估, 代码审查, code review, review, 体检, 风险, 重构前, 可维护性, 可读性, 代码质量, 测试覆盖, UI 评估.
---

# Code Review Eval

Use this skill to inspect an existing codebase and report actionable findings. The default stance is review first, do not modify code unless the user explicitly asks for fixes.

中文说明：当用户要“检查代码、评估质量、做 code review、重构前体检、找风险”时使用本技能。默认只审查不改代码，除非用户明确说“修复/优化/直接改”。

## 中文速记

- 先找真实风险，再谈风格偏好。
- 输出按 P0/P1/P2/P3 排序，问题必须有文件位置、风险说明和最小修法。
- 没证据不要升严重级别；不要把个人审美写成高优先级问题。
- 网页项目审查时，同时结合 `web-app-dev` 看目录边界、组件拆分和 UI 状态。
- 用户没有要求修复时，不要动文件；用户要求修复时，先修 P0/P1。

## Source Standard

Read `D:\Deepseek\skill-code-review-eval.md` on Windows or `~/Documents/Deepseek/skill-code-review-eval.md` on macOS/Linux when available. That file is the human-readable standard; this skill is the compact execution guide.

中文注解：优先读取仓库里的 `skill-code-review-eval.md`，那里是给人看的完整审查规范；本文件是 Codex 执行审查时的简版。

If the file is unavailable, continue with the rules below.

## Review Stance

中文注解：审查报告要像真正的工程 review，不要泛泛而谈。先列会出 bug、会影响用户、会阻碍维护的问题，再补充低风险建议。

- Lead with bugs, risks, regressions, missing tests, and maintainability hazards.
- Do not inflate style preferences into high-severity findings.
- Prefer evidence: file path, line number, command output, code path, or reproducible scenario.
- If the user did not ask for edits, do not edit files.
- If asked to fix issues, address P0/P1 first and keep changes small.

## Severity

中文注解：严重级别表示“影响和紧急程度”，不是“看着不顺眼的程度”。如果只是命名或风格问题，通常是 P3，除非它真的导致误用或维护风险。

- P0: production outage, data loss/corruption, severe security issue, core feature unusable.
- P1: likely user-visible bug, key workflow failure, serious stability/performance/security risk.
- P2: maintainability, testability, structure, type safety, or medium-risk issue worth fixing soon.
- P3: low-risk cleanup, clarity, consistency, or minor UX issue.

Do not assign severity without explaining impact.

## Dimensions

Evaluate the relevant dimensions for the repo:

中文注解：不要机械地每项都写一遍。根据项目类型选择相关维度；没有发现问题就不硬凑问题，但要说明剩余风险或测试缺口。

1. Correctness: logic, edge cases, state transitions, race conditions.
2. Structure: route/component/business/data boundaries, module responsibilities, coupling.
3. Readability: naming, function size, nesting, comments that explain why.
4. Complexity: duplication, over-abstraction, giant components/hooks/services.
5. Types and data boundaries: `any`, unsafe casts, schema validation, date/money/id modeling.
6. Error handling: loading, empty, error, success states; actionable user feedback.
7. Tests: lint/typecheck/unit/e2e/build coverage and meaningful assertions.
8. Security/privacy: secrets, authz, XSS, injection, sensitive logs, unsafe uploads.
9. Performance/reliability: repeated requests, bundle size, pagination, cleanup, timeouts.
10. UI/UX for web apps: responsive layout, focus states, contrast, overflow, layout stability.

When reviewing a web app, also use the `web-app-dev` standard if available.

## Workflow

中文注解：先理解项目和高风险路径，再搜索风险信号。审查不是只跑 lint，也不是只看格式，而是把可能影响功能、用户、安全和后续维护的地方找出来。

1. Inspect `AGENTS.md`, `package.json`, lockfiles, source tree, test config, and existing scripts.
2. Determine whether the user wants review-only or review-and-fix. Default to review-only.
3. Search for risk signals with `rg` where useful:
   - `TODO|FIXME|HACK`
   - `any|as unknown|as any|eslint-disable`
   - `dangerouslySetInnerHTML|localStorage|sessionStorage`
   - `console.error|throw new Error|fetch|useEffect`
4. Read high-risk flows: auth, permissions, payments/money, destructive actions, forms, imports/exports, external APIs.
5. Run available checks if safe and relevant: lint, typecheck, tests, build, e2e.
6. Report findings sorted by severity. Include file/line references whenever possible.
7. If no issues are found, say that clearly and list remaining test gaps or residual risk.

## Output Format

中文注解：输出要把“发现”放在最前面，并按严重程度排序。每条问题都要让用户知道在哪里、为什么重要、怎么最小修。

Use this shape by default:

```text
Findings
1. [P1] Short title
   File: path/to/file.ts:123
   Issue: What is wrong.
   Risk: Why it matters.
   Recommendation: Smallest useful fix.

Open Questions
- ...

Verification
- npm run lint: passed/failed/not run, with reason
- npm run build: passed/failed/not run, with reason
```

Keep summaries brief and after findings. If reviewing only a diff, focus on changed behavior and changed files.

## Fix Mode

中文注解：只有用户明确要求修复时才进入修复模式。修复时保持小步、可验证，不要顺手重构无关模块。

Only enter fix mode when the user explicitly asks to fix or optimize.

In fix mode:

- Preserve behavior unless the finding is a behavior bug.
- Avoid unrelated refactors.
- Add or update focused tests when risk justifies it.
- Re-run the checks that are most relevant to the changed files.
- Final response should say which findings were fixed and which remain.

## Public References

Use these as research sources when helpful, not as files to copy wholesale:

- `ciembor/agent-rules-books` for Clean Code, Refactoring, and software design criteria.
- `KbWen/agentic-os` for evidence-based review gates.
- `joho/awesome-code-review` for code review practice references.
- `baz-scm/awesome-reviewers` for agentic review prompt patterns.
- `sshahzaiib/senior-designer-skill` for UI/UX and accessibility review criteria.
