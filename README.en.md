<div align="center">

# ⚡ Superpowers Lite

> **Contract-First · DAG Layered Parallelism · Enforced TDD · Dual Review Gates · Persistent Progress**

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Based on](https://img.shields.io/badge/based%20on-Superpowers%20v5.1.0-8A2BE2?style=flat-square)](https://github.com/obra/superpowers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/Geek-Bob/SuperpowersLite/pulls)

<br>

[🇨🇳 **中文**](./README.md)

</div>

---

> 🎯 A lightweight, deeply customized fork of Superpowers. Transforms the "code-copy" pattern into a precision engineering workflow: **Contract-First + Dynamic DAG Layered Parallelism + Mandatory Review Gates**.

---

## 📖 Table of Contents

- [🔄 Full Workflow](#-full-workflow)
- [⚡ Six Key Innovations](#-six-key-innovations)
- [📋 Quick Comparison vs Official](#-quick-comparison-vs-official)
- [📂 Skill File Index](#-skill-file-index)
- [🚀 Getting Started](#-getting-started)
- [📜 License](#-license)

---

## 🔄 Full Workflow

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                         ⚡ Superpowers Lite Full Workflow                              │
│          Contract-First · DAG Layered Parallelism · Enforced TDD · Dual Gates         │
└──────────────────────────────────────────────────────────────────────────────────────┘

  ┌─ ① brainstorming 📝 (Requirements) ────────────────────────────────────────────┐
  │                                                                                  │
  │  Explore context → Clarifying questions → Propose 2-3 solutions                   │
  │      │                                                                           │
  │      ▼                                                                           │
  │  🆕 ASCII diagrams for discussion ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
  │      │  Sketch architecture, data flow, layouts — user sees and discusses   │  │
  │      │  Interactive: ASCII (fast iteration) → Document: Mermaid (formal)     │  │
  │      ▼                                                                       │  │
  │  Section-by-section design → Write design doc → git commit                       │
  │      │               │                                                         │
  │      │               ├── 🆕 Mermaid diagrams (flowchart/sequence/state/class)       │
  │      │               ├── 🆕 Contract & Interfaces: shared types + module APIs + endpoints│
  │      │               └── 🆕 Naming conventions: one rule for all implementers        │
  │      │               │                                                         │
  │      │               ▼                                                         │
  │      │       ┌─── 🆕 Stage 1: Subagent Review (Structural Quality) ──┐         │
  │      │       │  Completeness / Consistency / Clarity                   │── ❌ → Fix ──┘│
  │      │       │  Subagent reads only the doc, finds structural issues   │         │
  │      │       └──────────────────────────────────────────────────────┘         │
  │      │               │ ✅                                                       │
  │      │               ▼                                                          │
  │      │       ┌─── 🆕 Stage 2: Controller Self-Review (Requirement Fidelity) ──┐│
  │      │       │  Against original discussion: omissions? distortions? assumptions?││
  │      │       │  Controller was in the discussion — catches what subagent can't  ││
  │      │       └────────────────────────────────────────────────────────────┘    │
  │      │               │                                                         │
  │      ▼               ▼                                                         │
  │  🛑 User Confirmation Gate (HARD STOP)                                           │
  │  "Please review this design document. Any changes needed?"                       │
  │      │                                                                          │
  │      │ ✅ User confirms                                                          │
  └──────┼──────────────────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌─ ② writing-plans 📋 (Task Decomposition) ──────────────────────────────────────┐
  │                                                                                  │
  │  Read design doc → Plan file structure → Decompose into independently TDD-able tasks│
  │      │                                                                           │
  │      ▼                                                                           │
  │  🆕 Each task = acceptance contract (no implementation code)                       │
  │  ┌────────────────────────────────────────────────────────────────────┐         │
  │  │ Task N: [Goal] + Spec Reference (precise section anchor) + description│       │
  │  │ Produces: files / modules / types (what this task outputs)           │         │
  │  │ Consumes: Task 0 : IUser, IUserRepository (contracts this task needs)│        │
  │  │ Acceptance Criteria: - [ ] checkbox list (quality contract)          │         │
  │  │ Steps: 1.Write tests 2.Verify fail 3.Implement 4.Verify pass 5.Commit│        │
  │  └────────────────────────────────────────────────────────────────────┘         │
  │      │                                                                           │
  │      ▼                                                                           │
  │  🆕 Produces / Consumes → Auto DAG Topological Sort → Execution Layer Table       │
  │  ┌────────────────────────────────────────────────────────────────────┐         │
  │  │ 1. Collect all Produces and Consumes                                 │         │
  │  │ 2. Build dependency graph: B.Consumes references A.Produces → A → B  │         │
  │  │ 3. Detect cycles → cycle found = plan invalid                        │         │
  │  │ 4. Topological sort → natural layers: L0(indeg=0) → L1 → ... → Ln   │         │
  │  │ 5. Same-layer tasks: different files + no mutual Consumes → safe parallel│     │
  │  └────────────────────────────────────────────────────────────────────┘         │
  │      │                                                                           │
  │      ▼                                                                           │
  │  Output execution layer table:                                                    │
  │  ┌────────────────────────────────────────────────────────────────────┐         │
  │  │  Layer │  Task                │  Deps       │  Parallel              │         │
  │  │  :──:  │  ─────               │  ────       │  :──:                  │         │
  │  │  L0   │  Task 0: Contracts    │  None       │  —                     │         │
  │  │  L1   │  Task 1: UserRepo    │  Task 0     │  ✅                    │         │
  │  │  L1   │  Task 2: OrderRepo   │  Task 0     │  ✅ (same-layer para)  │         │
  │  │  L1   │  Task 3: Logger      │  Task 0     │  ✅                    │         │
  │  │  L2   │  Task 4: UserSvc     │  Task 0,1   │  ✅                    │         │
  │  │  L2   │  Task 5: OrderSvc    │  Task 0,2   │  ✅                    │         │
  │  │  L3   │  Task 6: DI + Routes │  Task 4,5   │  —                     │         │
  │  └────────────────────────────────────────────────────────────────────┘         │
  │      │                                                                           │
  │      ▼                                                                           │
  │  🆕 Subagent full review (against design doc: requirement fidelity + structural) → ❌ → Fix → ✅│
  │      │                                                                           │
  │      ▼                                                                           │
  │  🛑 User Confirmation Gate (HARD STOP)                                            │
  │  "Please review this plan. Is the decomposition reasonable? Criteria complete?"   │
  │      │                                                                           │
  │      │ ✅ User confirms                                                            │
  └──────┼──────────────────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌─ ③ subagent-driven-development 🤖 (Execution) ──────────────────────────────────┐
  │                                                                                  │
  │  🆕 Controller Role: Pure Coordinator                                             │
  │  ┌────────────────────────────────────────────────────────────────────┐         │
  │  │ 🚫 No code review · 🚫 No code fixes · ✅ Read reports only          │         │
  │  │ ✅ Decide next step · ✅ Coordinate layer progression                │         │
  │  └────────────────────────────────────────────────────────────────────┘         │
  │                                                                                  │
  │  ┌─ Phase 0: Read Execution Layer Table ──────────────────────────────┐         │
  │  │ Pre-computed by writing-plans via DAG. Controller reads, no re-analysis│      │
  │  └────────────────────────────────────────────────────────────────────┘         │
  │      │                                                                           │
  │      ▼                                                                           │
  │  ┌─ Phase 1: Execute Layer by Layer, Parallel Within Layer ──────────┐          │
  │  │                                                                    │          │
  │  │  Layer 0 ──────────────────── all passed ─────────────────────▶    │          │
  │  │    │                                                               │          │
  │  │    ▼                                                               │          │
  │  │  Layer 1 ┌─ Task A ─ Impl(TDD) → spec-review → code-review → [x] ─┐│          │
  │  │          ├─ Task B ─ Impl(TDD) → spec-review → code-review → [x] ─┤│          │
  │  │          └─ Task C ─ Impl(TDD) → spec-review → code-review → [x] ─┘│          │
  │  │    │     ↑ Dispatched together (different files + shared contract) ↑│          │
  │  │    │     ↑ Each proceeds independently — A in code-review while B in spec-review│
  │  │    │     ↑ One fails → new implementer fix → re-review (others unaffected)│    │
  │  │    │                                                               │          │
  │  │    ▼ all passed                                                     │          │
  │  │  Layer 2 ┌─ Task D ─ Impl(TDD) → spec-review → code-review → [x] ─┐│          │
  │  │          └─ Task E ─ Impl(TDD) → spec-review → code-review → [x] ─┘│          │
  │  │    │                                                               │          │
  │  │    ▼ ...until all layers done                                       │          │
  │  │                                                                    │          │
  │  │  🚫 Cross-layer must be serial: upper layer all passed → next layer  │          │
  │  │  🚫 File conflicts resolved by layer table: same-layer = different files│       │
  │  └────────────────────────────────────────────────────────────────────┘          │
  │                                                                                  │
  │  ┌─ Per Task Detailed Flow ─────────────────────────────────────────┐          │
  │  │                                                                    │          │
  │  │  ┌─── Dispatch Implementer (new subagent) ────────────────────┐   │          │
  │  │  │                                                              │   │          │
  │  │  │  🆕 Enforced TDD loading:                                     │   │          │
  │  │  │     Skill("superpowers:test-driven-development")             │   │          │
  │  │  │     Red (failing test) → Green (minimal impl) → Refactor     │   │          │
  │  │  │                                                              │   │          │
  │  │  │  🆕 Contract constraint: only use interfaces/types in Consumes│   │          │
  │  │  │     Need undeclared type? → Report NEEDS_CONTEXT, don't invent│   │          │
  │  │  │                                                              │   │          │
  │  │  │  Commit + self-review (completeness/quality/discipline/tests) │   │          │
  │  │  │  Report: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT  │   │          │
  │  │  └──────────────────────────────────────────────────────────────┘   │          │
  │  │    │                                                               │          │
  │  │    ▼                                                               │          │
  │  │  ┌─── Stage 1: spec-review (Spec Compliance) ──────────────────┐   │          │
  │  │  │                                                              │   │          │
  │  │  │  Dispatch spec-reviewer (new subagent, fresh eyes, no bias)  │   │          │
  │  │  │  🆕 Spec Reference on-demand (reads only anchored section)   │   │          │
  │  │  │  Check: missing requirements? extra features? misunderstood?  │   │          │
  │  │  │                                                              │   │          │
  │  │  │  ❌ Fail:                                                    │   │          │
  │  │  │     🆕 New implementer fix (with original context + issue list)│  │          │
  │  │  │     → New spec-reviewer re-review (loop until pass)          │   │          │
  │  │  │  ✅ Pass → Enter Stage 2                                      │   │          │
  │  │  └──────────────────────────────────────────────────────────────┘   │          │
  │  │    │                                                               │          │
  │  │    ▼                                                               │          │
  │  │  ┌─── Stage 2: code-review (Code Quality) ─────────────────────┐   │          │
  │  │  │                                                              │   │          │
  │  │  │  Controller calls Skill("superpowers:requesting-code-review")│   │          │
  │  │  │  Dispatch code-reviewer (new subagent, BASE_SHA ~ HEAD_SHA)  │   │          │
  │  │  │  🆕 Added architecture checks: file responsibility clarity,  │   │          │
  │  │  │     unit testability, structure compliance, file bloat check  │   │          │
  │  │  │                                                              │   │          │
  │  │  │  ❌ Fail:                                                    │   │          │
  │  │  │     🆕 New implementer fix (with original context + issue list)│  │          │
  │  │  │     → Re-invoke requesting-code-review (loop until pass)     │   │          │
  │  │  │  ✅ Pass → Mark complete                                      │   │          │
  │  │  └──────────────────────────────────────────────────────────────┘   │          │
  │  │    │                                                               │          │
  │  │    ▼                                                               │          │
  │  │  🆕 Progress Persistence (mandatory, executed immediately per task) │          │
  │  │  ┌────────────────────────────────────────────────────────────┐   │          │
  │  │  │ ① Edit plan file checkbox: - [ ] → - [x]                    │   │          │
  │  │  │    File is the single persistent source of truth             │   │          │
  │  │  │ ② TodoWrite mark complete                                    │   │          │
  │  │  │    Edit MUST precede TodoWrite                                │   │          │
  │  │  └────────────────────────────────────────────────────────────┘   │          │
  │  └────────────────────────────────────────────────────────────────────┘          │
  │                                                                                  │
  │  🚫 Absolutely Forbidden                                                           │
  │  ┌────────────────────────────────────────────────────────────────────┐         │
  │  │ Controller self-review · Controller fixes code · Skip any review    │         │
  │  │ Cross-layer parallel · Same-layer serial · Fix without context      │         │
  │  │ TodoWrite without file update · Proceed with unresolved issues      │         │
  │  └────────────────────────────────────────────────────────────────────┘         │
  └──────┬───────────────────────────────────────────────────────────────────────────┘
         │ All tasks complete
         ▼
  ┌─ ④ requesting-code-review 👀 (Final Review) ────────────────────────────────────┐
  │  Dispatch code-reviewer subagent → BASE_SHA ~ HEAD_SHA full diff review → Fix → Pass│
  └──────┬──────────────────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌─ ⑤ finishing-a-development-branch 🏁 (Wrap-up) ─────────────────────────────────┐
  │  Verify → Merge → Clean up                                                         │
  └──────────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Six Key Innovations

### ① Contract-First + Diagram-Driven Design

Interfaces are locked down during the design phase. **ASCII diagrams** rapidly clarify architecture and data flow during interactive discussion — users see and discuss immediately. Once confirmed, they're converted to **Mermaid formal diagrams** embedded in the design document. Every design document requires a **"Contracts & Interfaces"** chapter: shared types, module APIs, cross-endpoint contracts, naming conventions — all implementers code against the same interfaces, laying the groundwork for parallel execution.

```
Interactive: ASCII diagrams (fast iteration)  →  Document: Mermaid diagrams (renderable, maintainable)
```

### ② Dynamic DAG Layered Parallelism

Each task declares **Produces** (what it outputs) and **Consumes** (what it needs). Writing-plans automatically performs **topological sort** to build a dependency graph and compute execution layers. Same-layer tasks modify different files with no mutual dependencies → **dispatched simultaneously, no waiting**. Cross-layer is serial — upper layer must all pass before the next begins.

```
L0 (Contracts) → L1 (Data layer, parallel) → L2 (Business layer, parallel) → L3 (Integration)
  Same-layer parallel ⚡                    Cross-layer serial 🔗
```

### ③ Enforced TDD + Dual Review Gates

Implementer subagents **force-load the TDD skill** on startup, strictly following Red → Green → Refactor. Every task passes through **two mandatory review gates**: spec-review (spec compliance: missing? extra? misunderstood?) → code-review (code quality: architecture? tests? security?). Any gate fails → loop fix until pass. **Every reviewer is a fresh subagent** — fresh eyes, zero bias.

```
Implement(TDD) → spec-review → code-review → mark done
   ❌               ❌            ❌
   └─ fix ────→ re-review ──→ re-review (loop)
```

### ④ Persistent Progress + Context Preservation

After each task completes, **immediately edit the plan file** checkbox (`- [ ]` → `- [x]`), then TodoWrite. The file is the single persistent source of truth — progress can be recovered from checkbox state even if the session is interrupted. Fixes dispatch a **new implementer + original task context + review issue list** — context is never lost, old paths are never retread.

```
Edit plan file checkbox (persistent) → TodoWrite (session marker)
Fix: new subagent + original context + issue list
```

### ⑤ Comprehensive Document Review System

Three-tier review贯穿全流程. Design docs: **subagent reviews structural quality** (completeness/consistency/clarity) + **Controller reviews requirement fidelity** (omissions/distortions) — complementary, not redundant. Plan docs: **subagent reviews against design doc** (requirement alignment + Produces/Consumes reference integrity + cycle detection). Code review: **added architecture/file responsibility checkpoints**.

```
Design doc: subagent(structural) → Controller(requirement fidelity)
Plan doc: subagent(against design doc, requirement + structural)
Code review: added architecture checks (file responsibility/testability/structure/bloat)
```

### ⑥ Streamlined & Unified

Removed the official **executing-plans** skill (two execution paths → single entry). Eliminated all orphan review files (spec-document-reviewer-prompt.md, plan-document-reviewer-prompt.md, etc. — from dead references to working workflow steps). Skill chain unified as `brainstorming → writing-plans → subagent-driven-development`.

---

## 📋 Quick Comparison vs Official

| # | Official | Lite |
|:--:|----------|------|
| 🧠 | Plans are code clones (500-2000 lines), subagents copy-paste | Plans are acceptance contracts (100-300 lines), subagents do real TDD |
| 🎨 | Text-only design, no visualization | ASCII diagrams for interaction + Mermaid formal diagrams + classDiagram contracts |
| ⚡ | All tasks serial | DAG layered: same-layer parallel, cross-layer serial |
| 🔗 | No contract mechanism, interfaces written ad-hoc | Contracts & Interfaces chapter mandatory, all implementers share one API |
| 🧪 | TDD optional, subagents often skip | Enforced TDD loading, Red → Green → Refactor |
| 👀 | Controller self-reviews | Mandatory independent subagent: spec-review + code-review dual gates |
| 💾 | TodoWrite only, progress lost on session end | Edit plan file checkbox in real-time, file is persistent source of truth |
| 🔧 | Fixes lose context | New implementer + original task context + review issue list |
| 📋 | Design/plan reviews ineffective (orphan files) | Dual review + cross-reference review, every review file is called in workflow |
| 🗑️ | Two execution paths (subagent + executing) | Single execution path, executing-plans deleted |
| 🏗️ | Code review lacks architecture checks | Added file responsibility/testability/structure compliance/bloat checks |

---

## 📂 Skill File Index

| File | Original | Lite | Impact |
|------|----------|------|:------:|
| `brainstorming/SKILL.md` | 🌐 English, suggestive gate | 🇨🇳 Chinese, mandatory gate + diagram-driven + contract & interfaces + dual review | 🟡 Medium |
| `brainstorming/diagram-driven-design.md` | — | 🆕 **New**: ASCII box + Mermaid diagram specs (incl. classDiagram) | 🟡 Medium |
| `brainstorming/spec-document-reviewer-prompt.md` | — | 🇨🇳 Chinese, structural quality review template (completeness/consistency/clarity) | 🟡 Medium |
| `writing-plans/SKILL.md` | 🌐 English, code-clone generator | 🇨🇳 Chinese, task decomposition + Produces/Consumes + auto DAG layering + subagent full review | 🔴 **Massive** |
| `writing-plans/plan-document-reviewer-prompt.md` | — | 🇨🇳 Chinese, review template (incl. Produces/Consumes reference integrity check) | 🟡 Medium |
| `subagent-driven-dev/SKILL.md` | 🌐 English, self-review OK | 🇨🇳 Chinese, mandatory review + layered parallel execution | 🔴 **Massive** |
| `spec-reviewer-prompt.md` | 🌐 `spec-reviewer` | 🇨🇳 `spec-reviewer` + Spec Reference on-demand | 🟡 Medium |
| `implementer-prompt.md` | 🌐 English, TDD optional | 🇨🇳 Chinese, enforced TDD loading + contract constraints | 🟡 Medium |
| `requesting-code-review/SKILL.md` | 🌐 English | 🇨🇳 Chinese, triggered in Stage 2 per task | 🔵 Small |
| `code-reviewer.md` | 🌐 English | 🇨🇳 Chinese, added architecture/file responsibility checks | 🟡 Medium |
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
