# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目定位

Superpowers Lite 是官方 [Superpowers](https://github.com/obra/superpowers) 的轻量化深度定制版。

**Fork 点：** v5.1.0（2026-04-30）· **当前上游：** v6.4.1（2026-09-18）· 裁决台账见 [`UPSTREAM.md`](UPSTREAM.md)

**核心差异：** 计划不再包含实现代码，只包含验收契约。实现者自行 TDD，不走抄代码捷径。**持续跟踪官方上游**——只做优化与简化，每项采纳/拒绝都记入 `UPSTREAM.md`，便于下次增量合并。

## 仓库结构

```
skills/                          # 所有技能文件（核心产出）
├── brainstorming/               # 🔴 重度改造：需求 → 设计文档
│   ├── SKILL.md                 #   全中文 + 三路径分类 + 强制阻断 + 意图回述 + ASCII/Mermaid 双阶段图表 + 契约与接口 + 自审
│   ├── diagram-driven-design.md # 🆕 ASCII 框图 + Mermaid 规范（flowchart/sequenceDiagram/stateDiagram/classDiagram）
│   ├── spec-document-reviewer-prompt.md  # 结构质量审查模板（仅用户明确要求独立审查时用）
│   └── visual-companion.md      # 浏览器可视化伴侣（来自官方，未改造）
├── writing-plans/               # 🔴 重度改造：设计文档 → 实施计划
│   ├── SKILL.md                 #   全中文 + 任务分解 + Produces/Consumes + 自动 DAG 分层 + 自审
│   └── plan-document-reviewer-prompt.md  # 计划审查模板（仅用户明确要求独立审查时用）
├── subagent-driven-development/ # 🔴 重度改造：执行计划
│   ├── SKILL.md                 #   全中文 + 审查门控分流 + 指针化派发 + 分层并行 + 进度持久化（Edit checkbox → TaskUpdate）
│   ├── implementer-prompt.md    #   全中文 + 强制加载 TDD 技能 + 契约约束 + 自审提示
│   └── spec-reviewer-prompt.md  #   全中文 + 整体审查模板（按需读取全量代码，自主定位）
├── executing-plans/             # 🆕 Native 内联执行：本会话亲自逐任务实现 + 末尾整体审查
│   └── SKILL.md                 #   全中文 + 0 脚本 + 计划 checkbox 作进度真相源
├── test-driven-development/     # 🟡 TDD 技能（来自官方，部分中文化）
│   ├── SKILL.md                 #   强制 TDD 循环 + 调试集成
│   └── writing-good-tests.md    #   🆕 写好测试规则（两条原则 + 写前自检 + 变异检查 + 三条反模式）
├── requesting-code-review/      # 🟡 代码审查技能（全中文）
├── finishing-a-development-branch/  # 分支收尾（来自官方）
├── systematic-debugging/        # 系统化调试（来自官方）
├── dispatching-parallel-agents/ # 并行代理调度（来自官方）
├── verification-before-completion/  # 完成前验证（来自官方）
├── using-superpowers/           # 技能入口 + 平台适配（全中文）
├── using-git-worktrees/         # Git worktree 管理（来自官方）
├── writing-skills/              # 编写技能指南（来自官方）
└── receiving-code-review/       # 接收代码审查（来自官方）

README.md / README.en.md          # 中英文 README
UPSTREAM.md                       # 🆕 上游跟踪台账（fork 点、当前上游、逐项裁决 + 原因）
```

## 核心工作流（三路径分档）

所有创造性工作先经 `brainstorming` 分类，路径名固定为 **Spike** / **Bounded** / **Architectural**。

```
                      ┌─ Spike ──────────→ 汇报结论（一次性产物：不写文档、不留要保留的代码）
brainstorming 分类 ───┼─ Bounded ────────→ TDD 直接实现 + requesting-code-review（不写 spec、不调用 writing-plans）
                      └─ Architectural ──→ writing-plans ──→ 执行交接二选一
                                                             ├─ subagent-driven-development（每任务派子代理）
                                                             └─ executing-plans（Native 内联，最省）
```

| 路径 | 判定条件 | 产出 | 终点 |
|------|---------|------|------|
| **Spike** | 可行性问题（"能不能…"、"糙一点没关系"），产出是**答案**而非要保留的代码 | 问题 + 试探方案（2-3 句话） | 汇报结论（不写文档、不留要保留的代码） |
| **Bounded** | 本仓库**已有流程**的小改动（加 flag、小端点、单文件修复）。判断依据是仓库里已有可直接读的流程——光知道应用类型不算 | 聊天内短设计 | TDD 直接实现 + requesting-code-review |
| **Architectural** | 新项目、新子系统、重构组件如何拼装、改动他人依赖的接口 | 书面 spec + 书面实施计划 | writing-plans → SDD 或 Native 内联（用户二选一） |

**三条硬规则：** 分类必须说出口 / 怀疑时走重的那条 / 中途发现复杂度只升不降。

**每条链的交接规则（Architectural 路径）：**
- brainstorming 终态（书面 spec 已获用户批准）→ 调用 writing-plans（禁止调用其他技能）
- writing-plans 终态（书面计划已获用户批准）→ 执行交接二选一：`subagent-driven-development`（要每任务审查门，或计划长到后续任务会在压缩后的上下文里跑）或 `executing-plans`（任务基本独立、不需要每任务审查，**最省**）
- 所有阶段都有强制用户确认门控（Hard Stop），用户未明确批准不得进入下一阶段

**门控是阶段级授权（全路径适用）：**
- 对话层批准 → 只允许写 spec 文件
- 书面 spec 批准 → 才允许调用 writing-plans
- 一次回复只批准**当前正在呈现的那个阶段**，不允许把一个批准变成跳过所选路径其余步骤的许可
- Spike 以「批准问题与试探方案」为前置条件；Bounded 以「批准聊天内短设计」为前置条件

## 关键设计决策

### 1. 契约优先（Contract-First）
设计文档必须包含「契约与接口」章节：共享类型、模块接口、跨端契约。没有契约，writing-plans 无法判断哪些任务可以并行。

### 2. Produces/Consumes → 动态 DAG 分层
每个任务声明 Produces（产出）和 Consumes（消费），writing-plans 自动拓扑排序计算执行分层。同层任务修改不同文件、无相互依赖 → 安全并行。

### 3. ASCII → Mermaid 双阶段图表策略
- 交互阶段（展示设计）：ASCII 框图，快速迭代
- 文档阶段（写设计文档）：Mermaid 正式图表，嵌入 markdown

### 4. 文档自审（brainstorming / writing-plans）

设计文档与实施计划**都由 Controller 自己跑清单自审**，不派子代理——官方 `Self-Review` 明写 "not a subagent dispatch"，两个 `*-document-reviewer-prompt.md` 在官方已成刻意孤儿（Lite 曾误判为「孤儿引用」并接回工作流，2026-09-23 二次复核纠正）。

- **结构质量**（完整性 / 一致性 / 清晰度）—— 文档的客观属性，作者视角就能验
- **需求一致性**（遗漏 / 曲解 / 假设）—— 只有全程在场的人能验
- **独立视角留给用户门控**（设计文档批准 / 计划批准）—— 那是最后一道，也是最有效的一道

两个 `*-document-reviewer-prompt.md` **保留在仓库中**，供用户明确要求独立审查时使用，默认不派发。

### 5. 进度持久化 + 审查门控分流（subagent-driven-development）
每个任务完成后，**先** Edit 计划文件 checkbox（`- [ ]` → `- [x]`），**再** TaskUpdate 标记完成。文件是唯一持久化真相源。**所有任务完成后**进入**审查门控**：需求侧 `spec-review` **永远跑**；质量侧 `code-review` **仅当交付物含可执行代码时跑**，且**只审代码部分**。**纯文档 / 技能任务跳过 code-review**——code-review 的检查项（错误处理、类型安全、Schema 迁移、安全隐患）对技能 Markdown 是无效项。**例外（防一刀切）**：技能 / 文档任务夹带可执行代码（内嵌 bash / node 片段）时，code-review 只审那些代码片段，文档部分仍走 spec-review。

### 6. 两条执行路径（executing-plans 恢复为 Native 内联）

**Fork 时删除、2026-09-23 恢复。** 官方 v6.4.1 把 `executing-plans` 从 64 行 stub 重建为 **Native 内联执行**——「最便宜的执行计划方式」。Lite 采纳并极简化（~100 行、0 脚本）。

| | `subagent-driven-development` | `executing-plans`（Native） |
|---|---|---|
| 执行者 | 每任务一个新子代理 | 本会话亲自 |
| 适用 | 要每任务审查门；或计划长到后续任务会在压缩后的上下文里跑 | 任务基本独立、不需要每任务审查；计划够细 |
| 成本 | 每任务一次子代理启动 + 从零读库 | 一次会话语境 + 末尾一个审查员 |
| 审查 | 末尾整体审查门控 | 末尾整体审查门控，**用最强模型**（整轮唯一一次买独立视角）|

**两者的前提相同：任务基本独立。** 分界不是耦合紧不紧——紧耦合时两条路都不适用，该手工执行或先重新 brainstorming。

**恢复理由（三条）：**（1）成本阶梯有断层——Bounded 无计划、SDD 最贵，缺「有计划但不派子代理」这一档；（2）官方明说**紧耦合任务不该走 SDD**，而 Native 与 SDD 共享前提，故分界落在「要不要每任务审查门」与「计划长不长」上；（3）**无子代理工具的平台**（Codex / Copilot / Gemini 不保证有）在 Lite 里原本无路可走。

Bounded / Spike 仍不写计划，不经任何执行器。

### 7. 计划文件 Rulings 一行裁决
writing-plans 在计划文档中固定 `## Rulings` 区，每条裁决一行：`> **Ruling:** <决定了什么> — <为什么> — <错了代价是什么>`。只记录裁决——计划文件的 checkbox 追踪状态，Rulings 只记录裁决，**不引入**完整 Ledger / progress.md / 逐任务流水账。空区即无裁决（不写「无」）。执行完成后最终报告汇总全部 Rulings 供用户复核。

### 8. 上下文物理阻断＝规则，不是脚本
上下文阻断靠**规则**实现，仓库里**没有任何辅助脚本**：

- **指针化派发**：控制器只传「计划文件路径 + `offset`/`limit` 行号窗口 + 本任务额外约束 + 报告路径」，不粘贴任务全文、会话历史、前序任务摘要、整份计划正文
- **子代理自行 `git diff`**：审查员与修复者自跑 `git diff --stat BASE..HEAD` 与 `git diff -- <path>`，控制器不代取、不把 diff 正文粘进任何 prompt。BASE 必须是派发前记录的 SHA，禁用 `HEAD~1`；整体审查用 `git merge-base origin/main HEAD`，禁用裸 `origin/main`（会把 main 的新文件显示成幻影删除）
- **报告契约**：详细内容落 `.superpowers/sdd/<plan-slug>/task-N-report.md`，返回控制器只有「状态 / commit / 一行测试摘要 / 顾虑」四项
- **行号解析**：派发前 `grep -n "^### Task N:"` 现场解析，不硬编码（进度只翻 checkbox、不增删行，防止行号漂移）

规则优于脚本：不新增维护面，也不引入脚本自身的缺陷（参数解析、行尾 CRLF）。产出路径约定不变——固定落在仓库根 `.superpowers/sdd/<plan-slug>/`。

## 改造范围

| 技能 | 改动程度 | 语言 | 核心变化 |
|------|:--------:|------|---------|
| brainstorming | 🟡 中 | 🇨🇳 | 强制阻断 + **三路径分类（Spike / Bounded / Architectural）** + 意图回述 + 图表驱动 + 契约与接口 + 自审 |
| writing-plans | 🔴 极大 | 🇨🇳 | 完全重写：代码副本 → 任务分解 + Produces/Consumes + DAG 分层 + Rulings 一行裁决 |
| subagent-driven-development | 🔴 极大 | 🇨🇳 | 审查门控分流（spec-review 必跑 / code-review 按交付物）+ 指针化派发 + 分层并行执行 |
| requesting-code-review | 🔵 小 | 🇨🇳 | 中文化 |
| executing-plans | 🆕 新增 | 🇨🇳 | 借鉴官方 v6.4.1 的 Native 内联执行，极简重写（0 脚本）|

其余技能（test-driven-development、systematic-debugging 等）基本保持官方原样或仅中文化。

## 安装方式

```bash
git clone https://github.com/Geek-Bob/SuperpowersLite.git
claude plugins install superpowers@obra
cp -r SuperpowersLite/skills/* ~/.claude/plugins/cache/claude-plugins-official/superpowers/6.4.1/skills/
```

## 语言约定

- 所有技能文件和文档使用简体中文
- 技术术语保留英文（如 TDD、DAG、Produces/Consumes、checkbox）
- README 提供中英双语版本

