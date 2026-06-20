# Web 应用现场开发规范

本规范用于让 Codex/Kun 搭建和维护网页服务时，代码更规矩、结构更清楚、UI 更稳。它适合小白用户主导需求、Agent 负责实现的场景：用户只需要描述要做什么，Agent 必须按这里的工程护栏执行。

## 何时使用

当任务涉及以下内容时，先读本文件：

- 搭建网站、后台、管理台、数据看板、表单系统、登录页、工具页。
- 修改 React、Next.js、Vite、Tailwind、shadcn/ui 项目。
- 要求“代码规范一点”“以后 Agent 好维护”“UI 漂亮一点”。
- 从 GitHub 模板、公开项目、Cursor rules、AGENTS.md 方案中整理本地开发规范。

## 推荐公开方案

这些仓库适合作为参考，不建议整包照搬。我们取它们的思路，落成本地轻量规范。

| 仓库 | 用途 | 采用方式 |
|------|------|----------|
| `ciembor/agent-rules-books` | 从 Clean Code、Refactoring、A Philosophy of Software Design 等书提炼 Agent 规则 | 采用“mini rules”思路：短规则、强约束、减少认知负担 |
| `PatrickJS/awesome-cursorrules` | 大量 Cursor/AI 编程规则样例 | 用作灵感库，不整包复制，避免规则互相打架 |
| `PanisHandsome/ai-rules-sync` | AGENTS.md、CLAUDE.md、Cursor、Copilot 等规则同步 | 采用“一份规则，多 Agent 可读”的源头模型 |
| `ixartz/SaaS-Boilerplate` | Next.js + TypeScript + Tailwind + shadcn/ui 生产级模板 | 借鉴脚本、检查命令、目录和工具链，不默认引入复杂 SaaS 全家桶 |

参考链接：

- https://github.com/ciembor/agent-rules-books
- https://github.com/PatrickJS/awesome-cursorrules
- https://github.com/PanisHandsome/ai-rules-sync
- https://github.com/ixartz/SaaS-Boilerplate

## 默认技术栈

新项目默认选择：

- 前端框架：Next.js + React + TypeScript；纯静态小工具可用 Vite + React + TypeScript。
- 样式：Tailwind CSS + shadcn/ui + lucide-react。
- 表单：React Hook Form + Zod，除非项目已有别的方案。
- 数据请求：先用框架内置能力；复杂缓存再引入 TanStack Query。
- 后端：优先用 Next.js Route Handlers 或项目既有后端，不为小功能额外上复杂服务。
- 数据库：小项目先 SQLite/Postgres 二选一；需要类型安全时用 Drizzle 或 Prisma，跟随现有项目。
- 测试：Vitest 做单元测试，Playwright 做关键页面冒烟测试。

已有项目优先跟随项目现状，不为了“更先进”强行换栈。

## 项目结构

推荐结构如下。项目已有结构时，保持一致，只补齐缺失边界。

```text
src/
  app/ or pages/        # 路由入口，只放页面编排和服务端入口
  components/
    ui/                 # shadcn/ui 原子组件
    layout/             # 导航、侧栏、页框
    features/           # 按业务功能拆分的组件
  features/
    <feature>/
      components/       # 功能内 UI
      actions.ts        # 服务端动作或接口调用
      schema.ts         # Zod schema 和类型
      queries.ts        # 数据读取
      mutations.ts      # 数据写入
      utils.ts          # 仅限本功能的小工具
  lib/                  # 跨功能基础工具
  styles/               # 全局样式和设计 token
  tests/                # 跨页面测试或测试工具
```

边界规则：

- 页面文件只负责“拿数据、排版、连接组件”，不要塞一堆业务逻辑。
- `components/ui` 只放通用 UI，不放业务文案、接口请求、权限逻辑。
- 业务功能优先按 `features/<feature>` 聚合，方便 Agent 一次读懂上下文。
- 跨功能复用超过两处再提升到 `lib`，不要提前抽象。

## 编码规则

- TypeScript 必须开严格模式；避免 `any`，除非隔离在边界并写明原因。
- 变量和函数用清楚名字，不用 `data2`、`handleClick1`、`temp` 这类含糊名。
- 一个函数只做一件事；超过约 60 行时先考虑拆分。
- 复杂条件先命名成布尔变量，比如 `canPublish`、`isOverQuota`。
- 不复制粘贴大段代码；相同逻辑出现第三次时提取函数或组件。
- 远离“聪明代码”：优先让下一个 Agent 10 秒内看懂。
- 注释只解释“为什么”，不要解释代码肉眼可见的“做了什么”。
- 错误处理要给用户可执行反馈，不要只 `console.error`。
- 环境变量集中校验，禁止把 token、密码、私钥写进仓库。

## UI 规范

目标不是“花”，而是专业、稳定、可读。

- 后台、CRM、运维、看板类页面：信息密度适中，导航清楚，避免大营销 Hero。
- 工具类页面：首屏就是可用工具，不做空洞介绍页。
- 按钮使用动词：`保存`、`发布`、`导出`，不要写 `提交` 这种模糊词。
- 图标按钮优先用 lucide-react，必须有可访问标签或 tooltip。
- 卡片半径默认 8px 或更小，不做卡片套卡片。
- 文本不能溢出按钮、表格、卡片；移动端必须检查。
- 避免一眼 AI 味：少用紫蓝渐变、巨大居中标题、漂浮光斑、同色系铺满。
- 颜色用 4-6 个命名 token 管理：背景、文字、边框、主色、危险色、强调色。
- 每个页面至少考虑空状态、加载状态、错误状态、成功反馈。
- 可交互元素必须有 hover、focus-visible、disabled 状态。

## Agent 开工流程

Agent 接手网页服务任务时按这个顺序来：

1. 读项目根目录的 `AGENTS.md`、`package.json`、路由目录、主要组件目录。
2. 判断现有技术栈和目录风格，优先跟随。
3. 如果是新项目，按“默认技术栈”和“项目结构”搭建。
4. 先实现可运行的纵向小闭环，再扩展细节。
5. 修改前说明要动哪些文件；修改时保持范围小。
6. 改完运行项目已有检查命令。
7. UI 改动要启动本地服务，并用浏览器或截图做一次桌面/移动端检查。
8. 最终说明改了什么、如何验证、还有哪些风险。

## 默认检查命令

按项目实际脚本选择，不存在就说明未运行原因。

```bash
npm run lint
npm run check:types
npm test
npm run build
npm run test:e2e
```

如果是 pnpm/yarn/bun 项目，使用对应包管理器。

## 新手提需求模板

你可以直接这样对 Codex 说：

```text
请按 Deepseek 的 Web 应用现场开发规范做。我要一个[网站/后台/工具]，用户是[谁]，核心功能是[一句话]，需要包含[页面/表单/表格/登录/导出等]。UI 希望[简洁专业/科技感/中文后台/移动端优先]。做好后请启动本地服务并告诉我地址。
```

如果你什么都不确定，就只说：

```text
按 Web 应用现场开发规范，帮我从零搭一个可维护、好看的版本。你先替我定一个保守技术方案，然后直接实现。
```

## 交付标准

一次合格交付至少包含：

- 项目能启动，核心页面能打开。
- 关键功能有真实交互，不只是静态假图。
- 目录、命名、组件边界清楚。
- UI 有桌面和移动端适配。
- 运行过可用的 lint/typecheck/test/build 中至少一项；能跑的都应跑。
- 最终回复给出本地访问地址、验证结果和未完成风险。

