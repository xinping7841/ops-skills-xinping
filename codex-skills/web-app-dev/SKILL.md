---
name: web-app-dev
description: Build and maintain web apps with clean code, readable project structure, Agent-friendly conventions, and polished UI. Use whenever the user asks to create a website, web service, dashboard, admin panel, React/Next/Vite frontend, Tailwind/shadcn UI, or says code should be more standard, maintainable, readable, or visually nicer. Triggers include 网页服务, 网站, 后台, 管理台, 看板, UI 漂亮, 代码规范, Agent 好维护, React, Next.js, Vite, Tailwind, shadcn/ui.
---

# Web App Dev

Use this skill for web application work where the user wants a usable product, clean structure, and a UI that does not look hastily generated.

## Source Standard

Read `D:\Deepseek\skill-web-app-dev-standards.md` on Windows or `~/Documents/Deepseek/skill-web-app-dev-standards.md` on macOS/Linux when available. That file is the human-readable operating standard; this skill is the compact execution guide for Codex.

If the file is unavailable, continue with the rules below.

## Default Stack

- Existing project wins. Match the repo's framework, package manager, styling system, and component conventions.
- New app default: Next.js + React + TypeScript + Tailwind CSS + shadcn/ui + lucide-react.
- Smaller static tools may use Vite + React + TypeScript.
- Use React Hook Form + Zod for nontrivial forms unless the project already uses another form system.
- Use Vitest for unit tests and Playwright for user-flow or visual checks when available.

Avoid adding a large SaaS/auth/database stack unless the request actually needs it.

## Project Shape

Keep code easy for future agents to scan:

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

1. Inspect `AGENTS.md`, `package.json`, app routes, global styles, UI components, and existing scripts.
2. Identify the package manager from lockfiles.
3. For new projects, create the smallest complete vertical slice: one running page, real state, real controls, and clear layout.
4. Keep edits scoped. Before editing, tell the user what files or areas you are about to change.
5. Prefer local helpers and existing components over new abstractions.
6. Run the best available checks before finishing: lint, typecheck, tests, build.
7. For UI work, start the dev server when the app needs one and provide the local URL. Use Playwright/browser screenshots when visual quality, responsiveness, or canvas/3D correctness matters.

## Code Rules

- Strict TypeScript mindset: avoid `any`; validate external data at boundaries.
- Use descriptive names and small functions.
- Put business logic in feature modules or services, not directly inside page markup.
- Keep `components/ui` generic and business-free.
- Extract shared code only after it has real reuse or reduces obvious complexity.
- Do not hide errors. Show actionable UI feedback and log useful developer context.
- Keep secrets out of committed files. Use env examples without real credentials.
- Comments should explain non-obvious reasons, not restate syntax.

## UI Rules

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

