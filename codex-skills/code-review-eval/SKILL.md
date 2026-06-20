---
name: code-review-eval
description: Evaluate code quality, review risks, and produce prioritized findings before changing code. Use whenever the user asks for code review, project audit, code quality assessment, refactoring assessment, bug-risk scan, maintainability review, test gap analysis, PR review, UI quality review, or asks whether existing code is standard, readable, safe, or easy for agents to modify. Triggers include 代码评估, 代码审查, code review, review, 体检, 风险, 重构前, 可维护性, 可读性, 代码质量, 测试覆盖, UI 评估.
---

# Code Review Eval

Use this skill to inspect an existing codebase and report actionable findings. The default stance is review first, do not modify code unless the user explicitly asks for fixes.

## Source Standard

Read `D:\Deepseek\skill-code-review-eval.md` on Windows or `~/Documents/Deepseek/skill-code-review-eval.md` on macOS/Linux when available. That file is the human-readable standard; this skill is the compact execution guide.

If the file is unavailable, continue with the rules below.

## Review Stance

- Lead with bugs, risks, regressions, missing tests, and maintainability hazards.
- Do not inflate style preferences into high-severity findings.
- Prefer evidence: file path, line number, command output, code path, or reproducible scenario.
- If the user did not ask for edits, do not edit files.
- If asked to fix issues, address P0/P1 first and keep changes small.

## Severity

- P0: production outage, data loss/corruption, severe security issue, core feature unusable.
- P1: likely user-visible bug, key workflow failure, serious stability/performance/security risk.
- P2: maintainability, testability, structure, type safety, or medium-risk issue worth fixing soon.
- P3: low-risk cleanup, clarity, consistency, or minor UX issue.

Do not assign severity without explaining impact.

## Dimensions

Evaluate the relevant dimensions for the repo:

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

