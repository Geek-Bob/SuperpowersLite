# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目定位

Superpowers Lite 是官方 [Superpowers](https://github.com/obra/superpowers) (v5.1.0) 的轻量化深度定制版。将官方"代码副本"模式改造为"契约优先 + 动态分层并行 + 强制审查门控"的工程师工作流。

**核心差异：** 计划不再包含实现代码，只包含验收契约。子代理自行 TDD，不走抄代码捷径。

## 仓库结构

```
skills/                          # 所有技能文件（核心产出）
├── brainstorming/               # 🔴 重度改造：需求 → 设计文档
│   ├── SKILL.md                 #   全中文 + 强制阻断 + ASCII/Mermaid 双阶段图表 + 契约与接口 + 双审查
│   ├── diagram-driven-design.md # 🆕 ASCII 框图 + Mermaid 规范（flowchart/sequenceDiagram/stateDiagram/classDiagram）
│   ├── spec-document-reviewer-prompt.md  # 🆕 结构质量审查模板
│   └── visual-companion.md      # 浏览器可视化伴侣（来自官方，未改造）
├── writing-plans/               # 🔴 重度改造：设计文档 → 实施计划
│   ├── SKILL.md                 #   全中文 + 任务分解 + Produces/Consumes + 自动 DAG 分层 + 子代理全面审查
│   └── plan-document-reviewer-prompt.md  # 🆕 计划审查模板（含 Produces/Consumes 引用完整性检查）
├── subagent-driven-development/ # 🔴 重度改造：执行计划
│   ├── SKILL.md                 #   全中文 + 整体双审查门控 + 分层并行 + 进度持久化（Edit → TodoWrite）
│   ├── implementer-prompt.md    #   全中文 + 强制加载 TDD 技能 + 契约约束 + 自审提示
│   └── spec-reviewer-prompt.md  #   全中文 + 整体审查模板（按需读取全量代码，自主定位）
├── test-driven-development/     # 🟡 TDD 技能（来自官方，部分中文化）
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
```

## 核心工作流（三条技能链）

```
brainstorming → writing-plans → subagent-driven-development
     📝              📋                    🤖
  需求梳理          任务分解              子代理执行
```

**每条链的交接规则：**
- brainstorming 终态 → 调用 writing-plans（禁止调用其他技能）
- writing-plans 终态 → 调用 subagent-driven-development（用户确认后）
- 所有阶段都有强制用户确认门控（Hard Stop），用户未明确批准不得进入下一阶段

## 关键设计决策

### 1. 契约优先（Contract-First）
设计文档必须包含「契约与接口」章节：共享类型、模块接口、跨端契约。没有契约，writing-plans 无法判断哪些任务可以并行。

### 2. Produces/Consumes → 动态 DAG 分层
每个任务声明 Produces（产出）和 Consumes（消费），writing-plans 自动拓扑排序计算执行分层。同层任务修改不同文件、无相互依赖 → 安全并行。

### 3. ASCII → Mermaid 双阶段图表策略
- 交互阶段（展示设计）：ASCII 框图，快速迭代
- 文档阶段（写设计文档）：Mermaid 正式图表，嵌入 markdown

### 4. 双审查分工（brainstorming）
- 子代理：结构质量（完整性/一致性/清晰度）
- Controller：需求一致性（遗漏/曲解）

### 5. 进度持久化（subagent-driven-development）
每个任务完成后，**先** Edit 计划文件 checkbox（`- [ ]` → `- [x]`），**再** TodoWrite 标记。文件是唯一持久化真相源。**所有任务完成后**进入整体双审查门控（整体 spec-review → 整体 code-review）。

### 6. 已删除 executing-plans
官方有两条执行路径（executing-plans + subagent-driven-development），Lite 统一为 subagent-driven-development 单一执行路径。

## 改造范围

| 技能 | 改动程度 | 语言 | 核心变化 |
|------|:--------:|------|---------|
| brainstorming | 🟡 中 | 🇨🇳 | 强制阻断 + 图表驱动 + 契约与接口 + 双审查 |
| writing-plans | 🔴 极大 | 🇨🇳 | 完全重写：代码副本 → 任务分解 + Produces/Consumes + DAG 分层 |
| subagent-driven-development | 🔴 极大 | 🇨🇳 | 整体双审查门控 + 分层并行执行 |
| requesting-code-review | 🔵 小 | 🇨🇳 | 中文化 |
| executing-plans | ⚫ 删除 | — | 统一执行路径 |

其余技能（test-driven-development、systematic-debugging 等）基本保持官方原样或仅中文化。

## 安装方式

```bash
git clone https://github.com/Geek-Bob/SuperpowersLite.git
claude plugins install superpowers@obra
cp -r SuperpowersLite/skills/* ~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/
```

## 语言约定

- 所有技能文件和文档使用简体中文
- 技术术语保留英文（如 TDD、DAG、Produces/Consumes、checkbox）
- README 提供中英双语版本

