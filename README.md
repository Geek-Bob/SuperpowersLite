<div align="center">

# ⚡ Superpowers Lite

> **Superpowers 的轻量化深度定制版 — 去冗余、强审查、真 TDD**

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Based on](https://img.shields.io/badge/based%20on-Superpowers%20v5.1.0-8A2BE2?style=flat-square)](https://github.com/obra/superpowers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/Geek-Bob/SuperpowersLite/pulls)

<br>

[🇬🇧 **English**](./README.en.md)

</div>

---

> 🎯 **干掉计划中的代码，让子代理真正 TDD · 契约优先 · 动态分层并行 · 强制审查门控**

---

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
| 5️⃣ | **修复用新子代理**，上下文丢失 | **附带原始上下文 + 问题清单派新实现者修复**，不丢上下文 |
| 6️⃣ | **两套执行路径**，维护成本翻倍 | **单一执行路径**，统一流程 |
| 7️⃣ | 设计纯文本，缺乏可视化 | **图表驱动设计**：ASCII 框图 + Mermaid 流程图/时序图/状态图强制产出 |
| 8️⃣ | TDD 可选，子代理经常跳过 | **强制加载 TDD 技能**：实现者子代理启动即调用 `Skill("superpowers:test-driven-development")` |
| 9️⃣ | 设计/计划文档审查无上下文，无效审查 | **双审查分工**：子代理审结构质量（完整性/一致性），Controller 审需求一致性（遗漏/曲解） |
| 🔟 | **所有任务串行执行**，效率低 | **契约优先 + 动态分层并行**：接口先于实现定义 → 依赖自动分析 → 同层并行、跨层串行 |

### 📋 原始 vs 改造：逐文件对比

<details>
<summary><b>🖱️ 点击展开逐文件对比详情</b></summary>

#### 1️⃣ brainstorming/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 🚪 用户确认门控 | 建议性："Wait for the user's response…" | **强制性**："MANDATORY hard stop" |
| 🎨 图表驱动设计 | ❌ 不存在 | ✅ ASCII 框图 + Mermaid 强制产出 |
| 🔍 双审查机制 | 自审 + 孤儿审查文件 | ✅ 子代理审结构（完整性/一致性/清晰度）→ Controller 审需求一致性（遗漏/曲解） |
| 🌐 语言 | 全英文 | 全中文 |
| 📊 改动程度 | 🟡 中 — 图表驱动设计 + 双审查 + 中文化 |

#### 2️⃣ writing-plans/SKILL.md（改动最大）

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 🧠 核心理念 | 代码副本生成器 | 任务分解 + 验收契约 |
| 📄 计划内容 | 完整代码块 | Goal + Spec Reference + 验收标准 |
| 🔗 Spec Reference | ❌ 不存在 | ✅ 精确章节锚点 |
| 🚪 用户确认门控 | ❌ 不存在 | ✅ 强制阻断 |
| 🐛 BUG 修复 | `plan-document-reviewer-prompt.md` 是孤儿文件 | ✅ 计划写完后子代理对照设计文档全面审查（需求一致性 + 结构质量） |
| 📊 改动程度 | 🔴 **极大** — 完全重写 |

#### 3️⃣ subagent-driven-development/SKILL.md

| 对比项 | 原始 | 改造后 |
|--------|------|--------|
| 👤 审查员 | spec-reviewer | spec-reviewer（对照原始规格验证） |
| 🚫 Controller 角色 | 可自我审查 | **纯协调者，禁止审查** |
| ⚡ 执行策略 | 串行逐个执行 | **动态分层并行**：契约优先 → DAG 分层 → 同层并行、跨层串行 |
| 📊 改动程度 | 🔴 **极大** — 修复架构缺陷 + 分层并行 |

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
│      → 🎨 图表驱动设计：ASCII 布局原型 + Mermaid 流程图/时序图/状态图 │
│      → 写入 docs/superpowers/specs/xxx-design.md               │
│      → 🔍 阶段一：子代理审查（结构质量：完整性/一致性/清晰度）   │
│      → 🧠 阶段二：Controller 自审（需求一致性：遗漏/曲解检查）   │
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
│        + 验收标准(checkbox) + 步骤(有序列表)          │
│      → 写入 docs/superpowers/plans/xxx.md                      │
│      → 🔍 子代理审查（对照设计文档：需求一致性 + 结构质量）     │
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
│  │ 阶段 0：读「执行分层」表（writing-plans 已自动计算）     │  │
│  │                                                        │  │
│  │ 阶段 1：逐层并行执行                                    │  │
│  │                                                        │  │
│  │   Layer 0 ──→ 全部通过                                  │  │
│  │     │                                                  │  │
│  │     ▼                                                  │  │
│  │   Layer 1: Task A ─┐                                   │  │
│  │   Layer 1: Task B ─┤ 同时派发（不同文件 + 共享契约）     │  │
│  │   Layer 1: Task C ─┘                                   │  │
│  │     │                                                  │  │
│  │     ▼ 全部通过                                          │  │
│  │   Layer 2: Task D ─┐                                   │  │
│  │   Layer 2: Task E ─┤ 同时派发                           │  │
│  │     │                                                  │  │
│  │     ▼ ...直到所有层完成                                  │  │
│  │                                                        │  │
│  │ Per Task 流程不变：                                     │  │
│  │   实现 → spec-review → code-review → 标记完成           │  │
│  │   失败 → 派新实现者修复 → 重新审查（不影响同层其他任务）  │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬───────────────────────────────────┘
                           │ 所有任务完成
                           ▼
┌──────────────────────────────────────────────────────────────┐
│           ④ requesting-code-review 👀（整体审查）              │
│                                                              │
│  所有任务完成后，再次调用 requesting-code-review               │
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
| `brainstorming/SKILL.md` | 🌐 英文，建议性门控 | 🇨🇳 中文，强制阻断 + 图表驱动 + 契约与接口 + 双审查 | 🟡 中 |
| `brainstorming/diagram-driven-design.md` | — | 🆕 **新增**：ASCII 框图 + Mermaid 图表规范（含 classDiagram） | 🟡 中 |
| `brainstorming/spec-document-reviewer-prompt.md` | — | 🇨🇳 中文，结构质量审查子代理模板（完整性/一致性/清晰度） | 🟡 中 |
| `writing-plans/SKILL.md` | 🌐 英文，代码副本生成器 | 🇨🇳 中文，任务分解 + Produces/Consumes + 自动 DAG 分层 + 子代理全面审查 | 🔴 **极大** |
| `writing-plans/plan-document-reviewer-prompt.md` | — | 🇨🇳 中文，审查子代理模板（含 Produces/Consumes 引用完整性检查） | 🟡 中 |
| `subagent-driven-dev/SKILL.md` | 🌐 英文，可自我审查 | 🇨🇳 中文，强制派发审查 + 分层并行执行 | 🔴 **极大** |
| `spec-reviewer-prompt.md` | 🌐 `spec-reviewer` | 🇨🇳 `spec-reviewer` + Spec Reference | 🟡 中 |
| `implementer-prompt.md` | 🌐 英文，TDD 可选 | 🇨🇳 中文，强制加载 TDD 技能 | 🟡 中 |
| `requesting-code-review/SKILL.md` | 🌐 英文 | 🇨🇳 中文，Per Task 内第二阶段触发 | 🔵 小 |
| `code-reviewer.md` | 🌐 英文 | 🇨🇳 中文，新增架构/文件职责检查点 | 🟡 中 |
| ~~`executing-plans/SKILL.md`~~ | 🌐 英文（78 行） | ❌ **已删除** | ⚫ 删除 |

---

## 🚀 使用方式

### 📦 安装

```bash
# 克隆 Lite 仓库
git clone https://github.com/Geek-Bob/SuperpowersLite.git

# 注册官方插件（获取非技能文件：hooks、配置等）
claude plugins install superpowers@obra

# 用 Lite 技能覆盖官方技能
cp -r SuperpowersLite/skills/* ~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
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

[⬆ 返回顶部](#-superpowers-lite) · [🇬🇧 English](./README.en.md)

<br>

</div>
