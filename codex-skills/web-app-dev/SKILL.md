---
name: web-app-dev
description: Build and maintain web apps with clean code, readable project structure, Agent-friendly conventions, and polished UI. Use whenever the user asks to create a website, web service, dashboard, admin panel, React/Next/Vite frontend, Tailwind/shadcn UI, or says code should be more standard, maintainable, readable, or visually nicer. Triggers include 网页服务, 网站, 后台, 管理台, 看板, UI 漂亮, 代码规范, Agent 好维护, React, Next.js, Vite, Tailwind, shadcn/ui.
---

# Web App Dev

Use this skill for web application work where the user wants a usable product, clean structure, and a UI that does not look hastily generated.

中文说明：当用户要搭建、修改或优化网页服务时使用本技能。目标不是只把页面“做出来”，而是让项目结构清楚、代码容易被下一个 Agent 接手、UI 看起来像认真设计过的产品。

## 中文速记

- 新项目默认用 Next.js/React/TypeScript/Tailwind/shadcn/ui，除非需求明显更适合 Vite 或已有项目已有技术栈。
- 先做能跑通的最小闭环，再扩展细节；不要一上来堆复杂架构。
- 页面负责编排，业务逻辑放进 feature 模块，通用 UI 放 `components/ui`。
- UI 改动必须考虑加载、空状态、错误、成功、禁用、移动端和键盘焦点。
- 完工前尽量跑 lint、typecheck、test、build；网页要启动本地服务并给访问地址。

## Source Standard

Read `D:\Deepseek\skill-web-app-dev-standards.md` on Windows or `~/Documents/Deepseek/skill-web-app-dev-standards.md` on macOS/Linux when available. That file is the human-readable operating standard; this skill is the compact execution guide for Codex.

中文注解：优先读取仓库里的 `skill-web-app-dev-standards.md`，那里是给人看的完整规范；本文件是给 Codex 执行时快速加载的简版。

If the file is unavailable, continue with the rules below.

## Default Stack

中文注解：默认栈只是“新项目的保守选择”。如果项目已经存在，必须先尊重现有框架、包管理器、目录结构和组件库。

- Existing project wins. Match the repo's framework, package manager, styling system, and component conventions.
- New app default: Next.js + React + TypeScript + Tailwind CSS + shadcn/ui + lucide-react.
- Smaller static tools may use Vite + React + TypeScript.
- Use React Hook Form + Zod for nontrivial forms unless the project already uses another form system.
- Use Vitest for unit tests and Playwright for user-flow or visual checks when available.

Avoid adding a large SaaS/auth/database stack unless the request actually needs it.

## Project Shape

Keep code easy for future agents to scan:

中文注解：目录的目的不是形式好看，而是让 Agent 很快知道“页面在哪里、业务逻辑在哪里、通用组件在哪里、跨功能工具在哪里”。已有项目不要为了套模板而大搬家。

```text
src/
  app/ or pages/
  components/
    ui/
    layout/
    features/
  features/
    <feature>/
      components/
      actions.ts
      schema.ts
      queries.ts
      mutations.ts
      utils.ts
  lib/
  styles/
  tests/
```

Use the existing shape if one already exists. Do not reorganize unrelated files just to match this tree.

## Workflow

中文注解：执行时先读项目，再动手；先小步实现，再验证。UI 相关任务不要只靠想象，能开浏览器就开浏览器看一眼。

1. Inspect `AGENTS.md`, `package.json`, app routes, global styles, UI components, and existing scripts.
2. Identify the package manager from lockfiles.
3. For new projects, create the smallest complete vertical slice: one running page, real state, real controls, and clear layout.
4. Keep edits scoped. Before editing, tell the user what files or areas you are about to change.
5. Prefer local helpers and existing components over new abstractions.
6. Run the best available checks before finishing: lint, typecheck, tests, build.
7. For UI work, start the dev server when the app needs one and provide the local URL. Use Playwright/browser screenshots when visual quality, responsiveness, or canvas/3D correctness matters.

## Code Rules

中文注解：代码优先靠命名、拆分和边界自解释。注释只解释“为什么这样做”，不要写“这行代码在做什么”的废话注释。

- Strict TypeScript mindset: avoid `any`; validate external data at boundaries.
- Use descriptive names and small functions.
- Put business logic in feature modules or services, not directly inside page markup.
- Keep `components/ui` generic and business-free.
- Extract shared code only after it has real reuse or reduces obvious complexity.
- Do not hide errors. Show actionable UI feedback and log useful developer context.
- Keep secrets out of committed files. Use env examples without real credentials.
- Comments should explain non-obvious reasons, not restate syntax.

## UI Rules

中文注解：UI 要专业、稳定、可用。后台和工具类页面尤其要避免大标题、大渐变、装饰光斑和卡片套卡片；用户打开第一屏就应该能开始做事。

- Build the actual usable screen first; do not default to a marketing landing page.
- For admin/SaaS/ops tools, prefer calm, dense, scannable interfaces over oversized hero sections.
- Use shadcn/ui and lucide-react icons where appropriate.
- Buttons use clear verbs. Icon-only buttons need accessible labels/tooltips.
- Include loading, empty, error, disabled, and success states for normal workflows.
- Avoid obvious AI defaults: purple-blue gradients everywhere, giant centered text, decorative blobs, and card nesting.
- Keep cards at 8px radius or less unless the project already differs.
- Ensure text does not overflow containers on mobile or desktop.
- Use stable dimensions for boards, toolbars, tables, tiles, and counters to avoid layout shift.
- Respect keyboard focus and reduced motion.

## Verification

中文注解：验证不是走形式。能跑的检查都尽量跑；缺脚本时说明原因，并运行项目里最接近的检查命令。

Prefer this order, adapted to the repo:

```bash
npm run lint
npm run check:types
npm test
npm run build
npm run test:e2e
```

Use `pnpm`, `yarn`, or `bun` when the lockfile indicates it. If a command is missing, say so and run the closest available check.

For UI deliverables, verify at least one desktop viewport and one mobile viewport when tooling is available.

## Final Response

中文注解：最后回复要短而有用，告诉用户改了什么、在哪里打开、跑了哪些检查、还有什么风险。

Keep the final answer concise and useful:

- What changed.
- Where to open the app or which file was created.
- Which checks ran and their result.
- Any unresolved risks or follow-up work.

## Public References

Use these as research sources when needed, not as files to copy wholesale:

- `ciembor/agent-rules-books` for compact software design and clean-code agent rules.
- `PatrickJS/awesome-cursorrules` for AI coding rule examples.
- `PanisHandsome/ai-rules-sync` for one-source multi-agent rule management.
- `ixartz/SaaS-Boilerplate` for production Next.js/Tailwind/shadcn tooling patterns.
