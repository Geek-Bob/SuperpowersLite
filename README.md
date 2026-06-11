<div align="center">

# ⚡ Superpowers Lite

> **Superpowers 的轻量化深度定制版 — 去冗余、强审查、真 TDD**

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Based on](https://img.shields.io/badge/based%20on-Superpowers%20v5.1.0-8A2BE2?style=flat-square)](https://github.com/obra/superpowers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/Geek-Bob/SuperpowersLite/pulls)

<br>

[🇨🇳 中文](#-中文) · [🇬🇧 English](#-english)

</div>

---

<a name="中文"></a>

# 🇨🇳 中文

<div align="center">

<br>

> 🎯 **干掉计划中的代码，让子代理真正 TDD**

<br>

</div>

## 📖 目录

- [💡 为什么选 Lite？](#-为什么选-lite)
- [🔄 完整工作流](#-完整工作流)
- [📂 技能文件索引](#-技能文件索引)
- [🚀 使用方式](#-使用方式)
- [📜 许可](#-许可)

---

## 💡 为什么选 Lite？

官方 Superpowers 诞生于早期模型能力较弱时——计划文件必须包含完整代码，子代理拿到后直接抄。但如今模型能力大幅提升，这套 **"代码副本"模式**反而成了负担：

### 🔍 核心矛盾

| # | 官方问题 | Lite 解法 |
|:---:|----------|-----------|
| 1️⃣ | **计划是代码副本**（500-2000 行），子代理抄代码不走 TDD | **计划只有验收契约**（100-300 行），子代理自己走 Red→Green→Refactor |
| 2️⃣ | **上下文浪费**：Controller 把整个 Spec 读入内存再转发 | **Spec Reference 按需读取**：审查员只读锚点指向的章节 |
| 3️⃣ | **只标记会话 TodoWrite**，会话结束进度丢失 | **实时回写计划文件** checkbox，进度持久化 |
| 4️⃣ | **Controller 自我审查**，毫无意义 | **强制派发独立子代理审查**：两级门控把关 |
| 5️⃣ | **修复用新子代理**，上下文丢失 | **SendMessage 原实现者修复**，保留上下文 |
| 6️⃣ | **两套执行路径**，维护成本翻倍 | **单一执行路径**，统一流程 |

### 📋 原始 vs 改造：逐文件对比

<details>
<summary><b>🖱️ 点击展开逐文件对比详情</b></summary>

#### 1️⃣ brainstorming/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 🚪 用户确认门控 | 建议性："Wait for the user's response…" | **强制性**："MANDATORY hard stop" |
| 🌐 语言 | 全英文 | 全中文 |
| 📊 改动程度 | 🔵 小 — 强化门控 + 翻译 |

#### 2️⃣ writing-plans/SKILL.md（改动最大）

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 🧠 核心理念 | 代码副本生成器 | 任务分解 + 验收契约 |
| 📄 计划内容 | 完整代码块 | Goal + Spec Reference + 验收标准 |
| 🔗 Spec Reference | ❌ 不存在 | ✅ 精确章节锚点 |
| 🚪 用户确认门控 | ❌ 不存在 | ✅ 强制阻断 |
| 📊 改动程度 | 🔴 **极大** — 完全重写 |

#### 3️⃣ subagent-driven-development/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 👤 审查员 | spec-reviewer | task-reviewer |
| 🚫 Controller 角色 | 可自我审查 | **纯协调者，禁止审查** |
| 📊 改动程度 | 🔴 **极大** — 修复架构缺陷 |

#### 4️⃣ executing-plans/

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 📂 状态 | 存在（78 行） | ❌ **已删除** |
| 📊 改动程度 | ⚫ 删除 — 统一执行路径 |

</details>

---

## 🔄 完整工作流

```
┌──────────────────────────────────────────────────────────────┐
│           ① brainstorming 📝（需求梳理）                       │
│                                                              │
│  探索上下文 → 逐个提问澄清 → 提出 2-3 种方案                    │
│      → 分段呈现设计 → 用户逐段确认                              │
│      → 写入 docs/superpowers/specs/xxx-design.md               │
│                                                              │
│  🛑 用户确认门控（强制阻断）                                   │
│  "请审阅这份设计文档，是否有需要修改的地方？"                    │
│      → 用户修改 → 循环                                         │
│      → 用户确认 ✅                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ② writing-plans 📋（任务分解）                       │
│                                                              │
│  Spec → 拆解为独立可 TDD 的任务                                │
│      → 每个任务：Goal + Spec Reference(精确锚点)                │
│        + 验收标准(checkbox) + 测试用例 + 步骤(有序列表)          │
│      → 写入 docs/superpowers/plans/xxx.md                      │
│                                                              │
│  🛑 用户确认门控（强制阻断）                                   │
│  "请审阅这份实施计划。任务拆分是否合理？"                        │
│      → 用户修改 → 循环                                         │
│      → 用户确认 ✅                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ③ subagent-driven-development 🤖（子代理执行）       │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Per Task:                                              │  │
│  │                                                        │  │
│  │ 🔴🔴🔴 派发实现者子代理（TDD: Red→Green→Refactor）      │  │
│  │   → 自审 → 提交 → 报告 DONE                             │  │
│  │                                                        │  │
│  │ 🔍 第一阶段：派发 task-reviewer 子代理                   │  │
│  │   → 对照验收标准 + Spec Reference（按需读取）验证         │  │
│  │   → 有问题 → SendMessage 原实现者修复 → 重新审查         │  │
│  │   → 合规 ✅                                             │  │
│  │                                                        │  │
│  │ 🧪 第二阶段：派发 code-quality-reviewer 子代理           │  │
│  │   → 检查代码质量/架构/测试                               │  │
│  │   → 有问题 → SendMessage 原实现者修复 → 重新审查         │  │
│  │   → 通过 ✅                                             │  │
│  │                                                        │  │
│  │ ✅ TodoWrite 完成 + Edit 计划 checkbox（- [ ] → - [x]）  │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬───────────────────────────────────┘
                           │ 所有任务完成
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ④ requesting-code-review 👀（整体审查）              │
│                                                              │
│  派发 code-reviewer 子代理 → BASE_SHA ~ HEAD_SHA 全量审查     │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ⑤ finishing-a-development-branch 🏁（分支收尾）      │
└──────────────────────────────────────────────────────────────┘
```

---

## 📂 技能文件索引

| 文件 | 原始 | 改造后 | 改动程度 |
|------|------|--------|:--------:|
| `brainstorming/SKILL.md` | 🌐 英文，建议性门控 | 🇨🇳 中文，强制阻断 | 🔵 小 |
| `writing-plans/SKILL.md` | 🌐 英文，代码副本生成器 | 🇨🇳 中文，轻量任务分解 | 🔴 **极大** |
| `subagent-driven-dev/SKILL.md` | 🌐 英文，可自我审查 | 🇨🇳 中文，强制派发审查 | 🔴 **极大** |
| `task-reviewer-prompt.md` | 🌐 `spec-reviewer` | 🇨🇳 `task-reviewer` + Spec Reference | 🟡 中 |
| `code-quality-reviewer-prompt.md` | 🌐 英文 | 🇨🇳 中文 | ⚪ 极小 |
| `implementer-prompt.md` | 🌐 英文 | 🇨🇳 中文 | ⚪ 极小 |
| `requesting-code-review/SKILL.md` | 🌐 英文 | 🇨🇳 中文 | 🔵 小 |
| `code-reviewer.md` | 🌐 英文 | 🇨🇳 中文 | ⚪ 极小 |
| ~~`executing-plans/SKILL.md`~~ | 🌐 英文（78 行） | ❌ **已删除** | ⚫ 删除 |

---

## 🚀 使用方式

### 📦 安装

```bash
# 在 Claude Code 中注册插件
claude plugins install superpowers@obra
```

然后将本仓库中 `skills/` 下的改造文件覆盖到插件目录：

```bash
~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
```

### 🎬 启动开发

在 Claude Code 会话中描述你的需求，Claude 会自动调用 `brainstorming` 技能开始需求梳理：

| 阶段 | 步骤 | 说明 |
|:----:|------|------|
| ① | 📝 **需求梳理** → 输出 Spec | 🛑 等你确认 |
| ② | 📋 **任务分解** → 输出 Plan | 🛑 等你确认 |
| ③ | 🤖 **子代理执行** | 全自动（任务间不暂停） |
| ④ | 👀 **整体审查** | requesting-code-review |
| ⑤ | 🏁 **分支收尾** | finishing-a-development-branch |

### ⚠️ 注意事项

> 🟡 **Spec 和 Plan 阶段**需要你**主动审阅**，仔细看完再确认，不要直接说"继续"

> 🟢 **执行阶段是全自动的**，Controller 不会在任务之间停下来问你

> 🔴 **如果对某个任务结果有疑虑**，随时打断，Controller 会停下来让你检查

---

## 📜 许可

基于 [Superpowers](https://github.com/obra/superpowers) 修改，遵循原项目 [MIT](LICENSE) 许可协议。

---

<div align="center">

<br>

[⬆ 返回顶部](#-superpowers-lite)

<br>

</div>

---

<a name="english"></a>

# 🇬🇧 English

<div align="center">

<br>

> 🎯 **Remove code from plans. Let subagents truly TDD.**

<br>

</div>

## 📖 Table of Contents

- [💡 Why Lite?](#-why-lite)
- [🔄 Full Workflow](#-full-workflow)
- [📂 Skill File Index](#-skill-file-index)
- [🚀 Getting Started](#-getting-started)
- [📜 License](#-license-1)

---

## 💡 Why Lite?

The original Superpowers was born when models were weaker — plan files had to contain complete code for subagents to copy-paste. Today, models are far more capable, and that **"code-copy" pattern** has become a liability:

### 🔍 Core Problems

| # | Original Issue | Lite Solution |
|:---:|---------------|---------------|
| 1️⃣ | **Plans are code clones** (500-2000 lines), subagents skip TDD | **Plans are acceptance contracts** (100-300 lines), subagents do real Red→Green→Refactor |
| 2️⃣ | **Context waste**: Controller loads entire Spec into memory | **Spec Reference on-demand**: reviewers read only the anchored section |
| 3️⃣ | **Session-only TodoWrite**, progress lost when session ends | **Persistent plan checkbox updates** (`- [ ]` → `- [x]`) |
| 4️⃣ | **Controller self-review**, meaningless | **Mandatory independent subagent review**: two-stage gating |
| 5️⃣ | **New subagent for fixes**, losing context | **SendMessage original implementer**, preserving context |
| 6️⃣ | **Two execution paths**, double maintenance | **Single execution path**, unified flow |

### 📋 Original vs Lite: File-by-File

<details>
<summary><b>🖱️ Click to expand file comparison details</b></summary>

#### 1️⃣ brainstorming/SKILL.md

| Aspect | Original | Lite |
|--------|----------|------|
| 🚪 User Gate | Suggestive: "Wait for the user's response…" | **Mandatory**: "HARD STOP" |
| 🌐 Language | English | Chinese |
| 📊 Impact | 🔵 Small — hardened gate + translation |

#### 2️⃣ writing-plans/SKILL.md (Biggest Change)

| Aspect | Original | Lite |
|--------|----------|------|
| 🧠 Philosophy | Code-clone generator | Task decomposition + acceptance contract |
| 📄 Content | Full code blocks | Goal + Spec Reference + acceptance criteria |
| 🔗 Spec Reference | ❌ None | ✅ Precise section anchors |
| 🚪 User Gate | ❌ None | ✅ Mandatory hard stop |
| 📊 Impact | 🔴 **Massive** — complete rewrite |

#### 3️⃣ subagent-driven-development/SKILL.md

| Aspect | Original | Lite |
|--------|----------|------|
| 👤 Reviewer | spec-reviewer | task-reviewer |
| 🚫 Controller Role | Could self-review | **Pure coordinator, no review** |
| 📊 Impact | 🔴 **Massive** — architecture fix |

#### 4️⃣ executing-plans/

| Aspect | Original | Lite |
|--------|----------|------|
| 📂 Status | Existed (78 lines) | ❌ **Deleted** |
| 📊 Impact | ⚫ Removed — unified execution path |

</details>

---

## 🔄 Full Workflow

```
┌──────────────────────────────────────────────────────────────┐
│           ① brainstorming 📝 (Requirements)                   │
│                                                              │
│  Explore context → Ask clarifying questions → Propose 2-3    │
│  solutions → Section-by-section design → User confirms       │
│      → Write to docs/superpowers/specs/xxx-design.md         │
│                                                              │
│  🛑 USER CONFIRMATION GATE (HARD STOP)                       │
│  "Please review this design document. Any changes needed?"   │
│      → User revises → Loop                                   │
│      → User confirms ✅                                      │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ② writing-plans 📋 (Task Decomposition)             │
│                                                              │
│  Spec → Break into independently TDD-able tasks              │
│      → Each task: Goal + Spec Reference + Acceptance Criteria│
│        + Test Cases + Steps (ordered list)                   │
│      → Write to docs/superpowers/plans/xxx.md                │
│                                                              │
│  🛑 USER CONFIRMATION GATE (HARD STOP)                       │
│  "Please review this plan. Is the decomposition reasonable?" │
│      → User revises → Loop                                   │
│      → User confirms ✅                                      │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ③ subagent-driven-development 🤖 (Execution)       │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Per Task:                                              │  │
│  │                                                        │  │
│  │ 🔴🔴🔴 Dispatch implementer (TDD: Red→Green→Refactor)  │  │
│  │   → Self-review → Commit → Report DONE                 │  │
│  │                                                        │  │
│  │ 🔍 Stage 1: Dispatch task-reviewer subagent            │  │
│  │   → Verify against acceptance criteria + Spec Ref      │  │
│  │   → Issues? SendMessage original implementer → Re-check│  │
│  │   → Compliant ✅                                       │  │
│  │                                                        │  │
│  │ 🧪 Stage 2: Dispatch code-quality-reviewer subagent    │  │
│  │   → Check code quality / architecture / tests          │  │
│  │   → Issues? SendMessage original implementer → Re-check│  │
│  │   → Pass ✅                                            │  │
│  │                                                        │  │
│  │ ✅ TodoWrite done + Edit plan checkbox (- [ ] → - [x]) │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬───────────────────────────────────┘
                           │ All tasks complete
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ④ requesting-code-review 👀 (Final Review)         │
│                                                              │
│  Dispatch code-reviewer subagent → BASE_SHA ~ HEAD_SHA       │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ⑤ finishing-a-development-branch 🏁 (Wrap-up)      │
└──────────────────────────────────────────────────────────────┘
```

---

## 📂 Skill File Index

| File | Original | Lite | Impact |
|------|----------|------|:------:|
| `brainstorming/SKILL.md` | 🌐 English, suggestive gate | 🇨🇳 Chinese, mandatory gate | 🔵 Small |
| `writing-plans/SKILL.md` | 🌐 English, code-clone gen. | 🇨🇳 Chinese, light task decomp. | 🔴 **Massive** |
| `subagent-driven-dev/SKILL.md` | 🌐 English, self-review OK | 🇨🇳 Chinese, mandatory review | 🔴 **Massive** |
| `task-reviewer-prompt.md` | 🌐 `spec-reviewer` | 🇨🇳 `task-reviewer` + Spec Ref | 🟡 Medium |
| `code-quality-reviewer-prompt.md` | 🌐 English | 🇨🇳 Chinese | ⚪ Minimal |
| `implementer-prompt.md` | 🌐 English | 🇨🇳 Chinese | ⚪ Minimal |
| `requesting-code-review/SKILL.md` | 🌐 English | 🇨🇳 Chinese | 🔵 Small |
| `code-reviewer.md` | 🌐 English | 🇨🇳 Chinese | ⚪ Minimal |
| ~~`executing-plans/SKILL.md`~~ | 🌐 English (78 lines) | ❌ **Deleted** | ⚫ Removed |

---

## 🚀 Getting Started

### 📦 Installation

```bash
# Register the plugin in Claude Code
claude plugins install superpowers@obra
```

Then copy the `skills/` files from this repo to the plugin directory:

```bash
~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
```

### 🎬 Start Developing

Describe your requirements in a Claude Code session, and Claude will automatically invoke the `brainstorming` skill:

| Phase | Step | Note |
|:-----:|------|------|
| ① | 📝 **Requirements** → Spec output | 🛑 Wait for your confirmation |
| ② | 📋 **Task decomposition** → Plan output | 🛑 Wait for your confirmation |
| ③ | 🤖 **Subagent execution** | Fully automatic |
| ④ | 👀 **Final review** | requesting-code-review |
| ⑤ | 🏁 **Branch wrap-up** | finishing-a-development-branch |

### ⚠️ Notes

> 🟡 **Spec & Plan phases require your review** — read carefully before confirming

> 🟢 **Execution is fully automatic** — Controller won't pause between tasks

> 🔴 **If unsure about any task result** — interrupt anytime, Controller will stop for inspection

---

## 📜 License

Modified from [Superpowers](https://github.com/obra/superpowers). Licensed under the original project's [MIT](LICENSE) license.

---

<div align="center">

<br>

[⬆ Back to top](#-superpowers-lite)

<br>

</div>
