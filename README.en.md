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

> 🎯 **Remove code from plans. Let subagents truly TDD.**

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

[⬆ Back to top](#-superpowers-lite) · [🇨🇳 中文](./README.md)

<br>

</div>
