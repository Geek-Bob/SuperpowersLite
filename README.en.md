<div align="center">

# ⚡ Superpowers Lite

> **A lightweight, deeply customized Superpowers — leaner reviews, real TDD.**

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Based on](https://img.shields.io/badge/based%20on-Superpowers%20v5.1.0-8A2BE2?style=flat-square)](https://github.com/obra/superpowers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/Geek-Bob/SuperpowersLite/pulls)

<br>

[🇨🇳 **中文**](./README.md)

</div>

---

> 🎯 **Remove code from plans. Let subagents truly TDD. · Diagram-Driven Design · Mandatory Review Gates**

---

## 📖 Table of Contents

- [💡 Why Lite?](#-why-lite)
- [🔄 Full Workflow](#-full-workflow)
- [📂 Skill File Index](#-skill-file-index)
- [🚀 Getting Started](#-getting-started)
- [📜 License](#-license)

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
| 7️⃣ | Text-only design, no visualization | **Diagram-Driven Design**: ASCII box drawings + Mermaid flowcharts/sequence/state diagrams mandatory |
| 8️⃣ | TDD is optional, subagents often skip | **Enforced TDD loading**: implementer subagent invokes `Skill("superpowers:test-driven-development")` on startup |

### 📋 Original vs Lite: File-by-File

<details>
<summary><b>🖱️ Click to expand file comparison details</b></summary>

#### 1️⃣ brainstorming/SKILL.md

| Aspect | Original | Lite |
|--------|----------|------|
| 🚪 User Gate | Suggestive: "Wait for the user's response…" | **Mandatory**: "HARD STOP" |
| 🎨 Diagram-Driven Design | ❌ None | ✅ ASCII box drawings + Mermaid mandatory |
| 🐛 Bug Fix | `spec-document-reviewer-prompt.md` orphaned | ✅ Wired into flow: independent review subagent after design doc |
| 🌐 Language | English | Chinese |
| 📊 Impact | 🟡 Medium — diagrams + reviewer + translation |

#### 2️⃣ writing-plans/SKILL.md (Biggest Change)

| Aspect | Original | Lite |
|--------|----------|------|
| 🧠 Philosophy | Code-clone generator | Task decomposition + acceptance contract |
| 📄 Content | Full code blocks | Goal + Spec Reference + acceptance criteria |
| 🔗 Spec Reference | ❌ None | ✅ Precise section anchors |
| 🚪 User Gate | ❌ None | ✅ Mandatory hard stop |
| 🐛 Bug Fix | `plan-document-reviewer-prompt.md` orphaned | ✅ Wired into flow: independent review subagent after plan |
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
│      → 🎨 Diagram-Driven Design: ASCII layouts + Mermaid       │
│        flowcharts/sequence/state diagrams                      │
│      → Write to docs/superpowers/specs/xxx-design.md         │
│      → Dispatch independent spec-document-reviewer → Self-review│
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
│  │   ⚡ Enforced TDD: Red→Green→Refactor cycle               │  │
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
| `brainstorming/SKILL.md` | 🌐 English, suggestive gate | 🇨🇳 Chinese, mandatory gate + diagram-driven design | 🟡 Medium |
| `brainstorming/diagram-driven-design.md` | — | 🆕 **New**: ASCII box + Mermaid diagram specs | 🟡 Medium |
| `brainstorming/spec-document-reviewer-prompt.md` | — | 🇨🇳 Chinese, independent review subagent template | 🟡 Medium |
| `writing-plans/SKILL.md` | 🌐 English, code-clone gen. | 🇨🇳 Chinese, light task decomp. + plan review subagent | 🔴 **Massive** |
| `writing-plans/plan-document-reviewer-prompt.md` | — | 🇨🇳 Chinese, independent review subagent template | 🟡 Medium |
| `subagent-driven-dev/SKILL.md` | 🌐 English, self-review OK | 🇨🇳 Chinese, mandatory review | 🔴 **Massive** |
| `task-reviewer-prompt.md` | 🌐 `spec-reviewer` | 🇨🇳 `task-reviewer` + Spec Ref | 🟡 Medium |
| `code-quality-reviewer-prompt.md` | 🌐 English | 🇨🇳 Chinese | ⚪ Minimal |
| `implementer-prompt.md` | 🌐 English, TDD optional | 🇨🇳 Chinese, enforced TDD loading | 🟡 Medium |
| `requesting-code-review/SKILL.md` | 🌐 English | 🇨🇳 Chinese | 🔵 Small |
| `code-reviewer.md` | 🌐 English | 🇨🇳 Chinese | ⚪ Minimal |
| ~~`executing-plans/SKILL.md`~~ | 🌐 English (78 lines) | ❌ **Deleted** | ⚫ Removed |

---

## 🚀 Getting Started

### 📦 Installation

```bash
# Clone the Lite repository
git clone https://github.com/Geek-Bob/SuperpowersLite.git

# Register the official plugin (for non-skill files: hooks, config, etc.)
claude plugins install superpowers@obra

# Overwrite official skills with Lite skills
cp -r SuperpowersLite/skills/* ~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
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

[⬆ Back to top](#-superpowers-lite) · [🇨🇳 中文](./README.md)

<br>

</div>
