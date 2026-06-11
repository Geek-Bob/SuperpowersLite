# Superpowers Lite

> 基于官方 [Superpowers](https://github.com/obra/superpowers) v5.1.0 的轻量化深度定制。

## 为什么选 Lite？

官方 Superpowers 诞生于早期模型能力较弱时——计划文件必须包含完整代码，子代理拿到后直接抄。但如今模型能力大幅提升，这套"代码副本"模式反而成了负担：

| 官方问题 | Lite 解法 |
|---------|----------|
| **计划是代码副本**（500-2000 行），子代理抄代码不走 TDD，模型输出截断风险 | **计划只有验收契约**（100-300 行），子代理自己走 Red→Green→Refactor |
| **上下文浪费**：Controller 把整个 Spec 读入内存再转发给审查员，Token 开销巨大 | **Spec Reference 按需读取**：审查员只读锚点指向的那个章节 |
| **只标记会话 TodoWrite**，会话结束进度丢失 | **实时回写计划文件** checkbox（`- [ ]` → `- [x]`），持久化进度 |
| **Controller 自我审查**，毫无意义 | **强制派发独立子代理审查**：task-reviewer + code-quality-reviewer 两级门控 |
| **修复用新子代理**，上下文丢失 | **SendMessage 原实现者修复**，保留实现上下文 |
| **两套执行路径**（executing-plans + subagent），维护成本翻倍 | **单一执行路径**，统一流程 |

**一句话：干掉计划中的代码，让子代理真正 TDD。**

## 目录

- [为什么改造](#为什么改造)
- [原始 vs 改造：逐文件对比](#原始-vs-改造逐文件对比)
- [完整工作流](#完整工作流)
- [技能文件索引](#技能文件索引)
- [使用方式](#使用方式)

---

## 为什么改造

### 核心矛盾

官方 Superpowers 的设计假设是"一次性生成完整计划然后机械执行"，但实际开发中：

1. **需求是迭代打磨出来的**，不是一次性写死的
2. **计划是任务分解 + 验收标准**，不是实现代码的预演
3. **审查必须由独立子代理完成**，不能自我审查
4. **Spec 是按需引用的**，不是全文预加载的

### 官方原版的具体问题

| # | 问题 | 原始行为 | 实际后果 |
|---|------|---------|---------|
| 1 | **计划文件是"完整代码副本"** | `writing-plans` 要求 "Complete code in every step — if a step changes code, show the code"，每个步骤包含完整代码块 | 计划 500-2000 行，Token 量巨大；子代理拿到计划后只是抄代码，不走 TDD 思考过程；代码改一行，计划就过时 |
| 2 | **writing-plans 无用户确认门控** | `writing-plans` 的 "Execution Handoff" 直接让用户选执行方式，没有"请确认计划"的阻断 | 计划写完直接执行，用户没有机会审阅任务拆分是否合理 |
| 3 | **brainstorming 门控太弱** | 原始有 "User Review Gate" 但措辞是建议性的 "Wait for the user's response"，没有 "HARD STOP" 强制语义 | Controller 可能跳过等待，直接进入 writing-plans |
| 4 | **无 Spec Reference 机制** | 原始 `spec-reviewer-prompt.md` 要求审查员对照 "spec" 检查，但任务模板里根本没有 Spec Reference 字段；Controller 需要手动把 Spec 内容粘贴到 prompt 里 | Controller 要把整个 Spec 读入上下文再转发，Token 浪费；审查员拿到的是二手摘要，不是原文 |
| 5 | **Controller 自我审查** | 原始 `subagent-driven-development` 说 "Proceed to spec compliance review"，但没有明确说"必须派发子代理"；Controller 把这个理解为"自己审查" | 自我审查毫无意义——Controller 有完整会话上下文，已被实现决策偏见化 |
| 6 | **spec-reviewer 定位模糊** | 原始 `spec-reviewer-prompt.md` 标题是 "Spec Compliance Reviewer"，审查依据是 "spec"（整个设计文档），但实际子代理拿到的是任务文本 | 审查员不知道该对照 Spec 还是对照任务要求；名字暗示审查 Spec，但实际做的是任务合规检查 |
| 7 | **验收标准与步骤混用 checkbox** | 原始任务模板所有步骤都用 `- [ ]` checkbox，没有区分"验收标准"和"TDD 步骤" | 标记完成时不知勾哪个；审查员验证依据不明确 |
| 8 | **修复方式不明确** | 原始只说 "Implementer subagent fixes spec gaps"，没说用 SendMessage 还是新子代理 | Controller 可能派发新子代理修复，丢失实现上下文 |
| 9 | **两套执行路径** | 原始有 `executing-plans`（串行）和 `subagent-driven-development`（并行）两套技能，writing-plans 让用户二选一 | 维护成本翻倍，流程不统一，`executing-plans` 没有审查机制 |

---

## 原始 vs 改造：逐文件对比

### 1. brainstorming/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 用户确认门控 | "Wait for the user's response. If they request changes, make them..."（建议性） | "**MANDATORY hard stop**. Do NOT invoke writing-plans until the user explicitly confirms the spec."（强制性） |
| 语言 | 全英文 | 全中文 |

> **改动程度：** 小。原始已有门控雏形，我们将其强化为强制阻断。

---

### 2. writing-plans/SKILL.md（改动最大）

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| **核心理念** | "Write comprehensive implementation plans... assume engineer has zero context... questionable taste... document everything: which files, code, testing" | "计划定义构建什么和如何验证。子代理决定如何实现。不要在计划中写实现代码——写验收标准。" |
| **计划内容** | 每个步骤包含完整代码块（"Complete code in every step"） | 只含 Goal + Spec Reference + 验收标准 + 测试用例 + 步骤（有序列表，无代码） |
| **任务模板** | 步骤用 `- [ ]` checkbox + Python 代码块 | 验收标准用 `- [ ]` checkbox；步骤用 `1. 2. 3.` 有序列表；新增 Spec Reference 字段（精确章节锚点） |
| **Spec Reference** | 不存在 | 每个任务必须有精确锚点（如 `spec.md#agent-管理`），含转换规则和正确/错误示例 |
| **执行交接** | "Two execution options: Subagent-Driven or Inline Execution (executing-plans)" | 只有 `subagent-driven-development`，且**必须经过用户确认门控**才能调用 |
| **用户确认门控** | 不存在 | **新增** "User Confirmation Gate (MANDATORY hard stop)"——保存计划后强制停止，等用户确认 |
| **禁止占位符** | 6 条 | 新增第 7 条：Spec Reference 不能用占位符或只指向整个文件 |
| **自审清单** | 3 项 | 第 2 项新增 Spec Reference 精确性检查 |
| **语言** | 全英文 | 全中文 |

> **改动程度：** 极大。从"代码副本生成器"重构为"任务分解 + 验收契约"。

---

### 3. subagent-driven-development/SKILL.md（改动第二大）

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| **审查员名称** | spec-reviewer（Spec 合规审查） | task-reviewer（任务合规审查） |
| **审查依据** | "spec"（整个设计文档） | 验收标准 + Spec Reference（按需读取精确章节） |
| **Controller 角色** | 未明确禁止 Controller 自己审查（导致实际运行中 Controller 自我审查） | **明确禁止**："Controller 是纯协调者——不读代码、不审查、不修复"。新增 "Two-Stage Review (MANDATORY subagent dispatch)" 章节 |
| **修复方式** | "Implementer subagent fixes spec gaps"（模糊） | **SendMessage** 原实现者修复（保留上下文）；审查员重新审查用**新子代理** |
| **计划文件跟踪** | 不存在 | **新增**：标记完成后 Edit 计划文件，`- [ ]` → `- [x]` |
| **最终审查** | "Dispatch final code reviewer subagent"（通用描述） | 明确调用 `superpowers:requesting-code-review` 技能 |
| **前置条件** | 无 | **新增** Precondition：Plan 必须已被用户确认 |
| **流程图** | 仅 Per Task 流程 | **新增** "Full Workflow" 图，展示从 brainstorming 到 finishing 的完整 5 阶段链路，含两个 🛑 用户确认门控 |
| **When to Use** | 三岔口（含 executing-plans 分支） | 二叉（只有 subagent-driven-development） |
| **vs. Executing Plans** | 有专门对比章节 | 已删除 |
| **替代工作流** | executing-plans | 无（"subagent-driven-development 是唯一的执行技能"） |
| **红线** | 10 条 | 新增 3 条：禁止 Controller 自我审查、禁止跳过审查员派发、禁止在未获审查员 ✅ 前继续 |
| **语言** | 全英文 | 全中文 |

> **改动程度：** 极大。修复了 Controller 自我审查的架构缺陷，新增了计划跟踪、前置条件、完整流程图。

---

### 4. spec-reviewer-prompt.md → task-reviewer-prompt.md

| 对比项 | 原始（spec-reviewer） | 改造后（task-reviewer） |
|--------|----------------------|------------------------|
| **名称** | "Spec Compliance Reviewer Prompt Template" | "任务合规审查员 Prompt 模板" |
| **审查对象** | "whether an implementation matches its specification" | "实现是否匹配其任务要求" |
| **Spec 关联** | 无——只拿到 "FULL TEXT of task requirements"，不知道 Spec 在哪 | **新增** "设计文档索引（按需读取）"——精确章节锚点，只读需要的章节 |
| **审查范围** | "Did they fully implement everything in the spec?" / "over-engineer" / "nice to haves that weren't in spec" | "验收标准中的所有内容" / "过度设计" / "任务中没有要求的东西" |
| **遗漏检查** | 无 | **新增** "设计文档中是否有该任务遗漏的需求（从设计文档索引中读取）" |
| **语言** | 全英文 | 全中文 |

> **改动程度：** 中。从"对照 Spec"改为"对照任务要求"，新增 Spec Reference 按需读取机制。

---

### 5. code-quality-reviewer-prompt.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 前置条件 | "Only dispatch after spec compliance review passes" | "仅在任务合规审查通过后才派发" |
| 语言 | 全英文 | 全中文 |

> **改动程度：** 极小。仅翻译 + 术语对齐（spec compliance → 任务合规）。

---

### 6. implementer-prompt.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 自审依据 | "Did I fully implement everything in the spec?" | "我是否完整实现了任务要求中的所有内容？" |
| 语言 | 全英文 | 全中文 |

> **改动程度：** 极小。仅翻译 + 术语对齐（spec → 任务要求）。

---

### 7. requesting-code-review/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 集成章节 | 三个：Subagent-Driven Development / Executing Plans / Ad-Hoc Development | 两个：子代理驱动开发 / 临时开发（删除 Executing Plans） |
| 语言 | 全英文 | 全中文 |

> **改动程度：** 小。删除 Executing Plans 引用 + 翻译。

---

### 8. requesting-code-review/code-reviewer.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 语言 | 全英文 | 全中文 |

> **改动程度：** 极小。纯翻译，内容未变。

---

### 9. executing-plans/（整个目录）

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 状态 | 存在（78 行，串行执行 + 无审查机制） | **已删除** |

> **删除理由：** 两套执行技能的核心流程相同，区别仅在于并行/串行。`executing-plans` 没有审查机制，维护两套导致规则不一致。

---

## 改造总览

```
原始 9 个文件                          改造后 8 个文件（删除 1 个）
─────────────────────────────────      ─────────────────────────
brainstorming/SKILL.md          →      brainstorming/SKILL.md          (强化门控 + 翻译)
writing-plans/SKILL.md          →      writing-plans/SKILL.md          (完全重写：轻量化 + Spec Reference + 门控)
subagent-driven-dev/SKILL.md    →      subagent-driven-dev/SKILL.md    (大幅重写：两阶段审查 + 计划跟踪 + 前置条件)
  spec-reviewer-prompt.md       →        task-reviewer-prompt.md       (重命名 + 新增 Spec Reference)
  code-quality-reviewer-prompt  →        code-quality-reviewer-prompt  (翻译)
  implementer-prompt.md         →        implementer-prompt.md         (翻译)
requesting-code-review/SKILL.md →      requesting-code-review/SKILL.md (删除 Executing Plans 引用 + 翻译)
  code-reviewer.md              →        code-reviewer.md              (翻译)
executing-plans/SKILL.md        →      ❌ 已删除
```

---

## 完整工作流

```
┌──────────────────────────────────────────────────────────────┐
│                  1. brainstorming（需求梳理）                  │
│                                                              │
│  探索上下文 → 逐个提问澄清 → 提出 2-3 种方案                    │
│      → 分段呈现设计 → 用户逐段确认                              │
│      → 写入 docs/superpowers/specs/xxx-design.md               │
│      → 自审（占位符/一致性/歧义）                               │
│                                                              │
│  🛑 用户确认门控（强制阻断）                                   │
│  "请审阅这份设计文档，是否有需要修改的地方？"                    │
│      → 用户修改 → 循环                                         │
│      → 用户确认 ✅                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                  2. writing-plans（任务分解）                   │
│                                                              │
│  Spec → 拆解为独立可 TDD 的任务                                │
│      → 每个任务：Goal + Spec Reference(精确锚点)                │
│        + 验收标准(checkbox) + 测试用例 + 步骤(有序列表)          │
│      → 写入 docs/superpowers/plans/xxx.md                      │
│      → 自审（覆盖/占位符/类型一致性/Spec Reference 精确性）      │
│                                                              │
│  🛑 用户确认门控（强制阻断）                                   │
│  "请审阅这份实施计划。任务拆分是否合理？"                        │
│      → 用户修改 → 循环                                         │
│      → 用户确认 ✅                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│          3. subagent-driven-development（子代理执行）           │
│                                                              │
│  Precondition: Plan 已被用户确认 ✅                            │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Per Task:                                              │  │
│  │                                                        │  │
│  │ 派发实现者子代理（TDD: Red→Green→Refactor）              │  │
│  │   → 自审 → 提交 → 报告 DONE                             │  │
│  │                                                        │  │
│  │ 第一阶段：派发 task-reviewer 子代理                      │  │
│  │   → 对照验收标准 + Spec Reference（按需读取）验证         │  │
│  │   → 有问题 → SendMessage 原实现者修复 → 新子代理重新审查  │  │
│  │   → 合规 ✅                                             │  │
│  │                                                        │  │
│  │ 第二阶段：派发 code-quality-reviewer 子代理              │  │
│  │   → 检查代码质量/架构/测试                               │  │
│  │   → 有问题 → SendMessage 原实现者修复 → 新子代理重新审查  │  │
│  │   → 通过 ✅                                             │  │
│  │                                                        │  │
│  │ TodoWrite 完成 + Edit 计划 checkbox（- [ ] → - [x]）    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  Controller 角色：纯协调者，只派发子代理/读报告/决定下一步       │
└──────────────────────────┬───────────────────────────────────┘
                           │ 所有任务完成
                           ▼
┌──────────────────────────────────────────────────────────────┐
│             4. requesting-code-review（整体审查）              │
│                                                              │
│  派发 code-reviewer 子代理 → BASE_SHA ~ HEAD_SHA 全量审查     │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│          5. finishing-a-development-branch（分支收尾）         │
└──────────────────────────────────────────────────────────────┘
```

---

## 技能文件索引

| 文件 | 原始 | 改造后 | 改动程度 |
|------|------|--------|---------|
| `brainstorming/SKILL.md` | 英文，建议性门控 | 中文，强制阻断门控 | 小 |
| `writing-plans/SKILL.md` | 英文，含完整代码的"代码副本生成器" | 中文，轻量级任务分解 + Spec Reference + 用户门控 | **极大** |
| `subagent-driven-development/SKILL.md` | 英文，spec-reviewer，Controller 可自我审查 | 中文，task-reviewer，强制派发子代理，计划跟踪，前置条件 | **极大** |
| `subagent-driven-development/spec-reviewer-prompt.md` | 英文，对照 Spec，无 Spec 关联 | → `task-reviewer-prompt.md` 中文，对照任务，Spec Reference 按需读取 | 中 |
| `subagent-driven-development/code-quality-reviewer-prompt.md` | 英文 | 中文 | 极小 |
| `subagent-driven-development/implementer-prompt.md` | 英文 | 中文 | 极小 |
| `requesting-code-review/SKILL.md` | 英文，含 Executing Plans 引用 | 中文，删除 Executing Plans | 小 |
| `requesting-code-review/code-reviewer.md` | 英文 | 中文 | 极小 |
| `executing-plans/SKILL.md` | 英文，78 行 | ❌ 已删除 | — |

---

## 使用方式

### 安装

```bash
# 在 Claude Code 中注册插件
claude plugins install superpowers@obra
```

然后将本仓库中 `skills/` 下的改造文件覆盖到插件目录：

```
~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
```

### 启动开发

在 Claude Code 会话中描述你的需求，Claude 会自动调用 `brainstorming` 技能开始需求梳理：

1. **需求梳理** → 输出 Spec → 🛑 等你确认
2. **任务分解** → 输出 Plan → 🛑 等你确认
3. **子代理执行** → 全自动（任务间不暂停）
4. **整体审查** → requesting-code-review
5. **分支收尾** → finishing-a-development-branch

### 注意事项

- **Spec 和 Plan 阶段需要你主动审阅**，仔细看完再确认，不要直接说"继续"
- **执行阶段是全自动的**，Controller 不会在任务之间停下来问你
- **如果对某个任务结果有疑虑**，随时打断，Controller 会停下来让你检查

---

## 许可

基于 [Superpowers](https://github.com/obra/superpowers) 修改，遵循原项目 MIT 许可协议。
