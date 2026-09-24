---
name: using-superpowers
description: 在开始任何会话时使用 - 建立如何查找和使用技能，要求在生成任何响应（包括澄清问题）之前调用 Skill 工具
---

> **Lite 版本：`6.4.1-l1`**（基于上游 superpowers v6.4.1 · 完整裁决台账见仓库 `UPSTREAM.md`）

<SUBAGENT-STOP>
如果你是作为子代理被派发来执行特定任务，请跳过本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
即使你认为只有 1% 的可能性某个技能可能适用于你正在做的事情，你绝对必须调用该技能。

如果有技能适用于你的任务，你没有选择余地。你必须使用它。

这是不可协商的。这不是可选的。你无法为自己找借口开脱。
</EXTREMELY-IMPORTANT>

## 规则

**在任何响应或操作之前，调用相关或被请求的技能**——包括澄清问题、探索代码库、查看文件之前。调用后发现不适合当前情况，可以不用。

**准备进入实现前：** 若尚未 brainstorming，先调用它。brainstorming 先分类路径，三条路各不相同：

- **Spike** —— 可行性问题、产出是答案 → 汇报结论（不写文档、不留要保留的代码）
- **Bounded** —— 本仓库已有流程的小改动 → TDD 直接实现 + requesting-code-review
- **Architectural** —— 新子系统、改动他人依赖的接口 → writing-plans，再在执行交接时二选一：**subagent-driven-development**（每任务派子代理）或 **executing-plans**（内联，最省）

然后宣告「使用 [技能] 来完成 [目的]」，严格遵循它。技能带检查清单 → 为每项建一个任务。

## 技能优先级

多个技能都适用时，**流程类技能优先**——它们决定怎么做：

1. **流程类**（brainstorming、writing-plans、systematic-debugging）
2. **实现类**（subagent-driven-development、executing-plans、test-driven-development、dispatching-parallel-agents）

「让我们构建 X」→ 先 brainstorming 分类；Architectural 走 writing-plans → 执行交接二选一。
「修复这个 bug」→ 先 systematic-debugging，再按需其他。

## 危险信号

这些想法意味着停下来——你正在为自己找借口：

| 想法 | 现实 |
|---------|---------|
| "这只是一个简单的问题" | 问题就是任务。检查是否有相关技能。 |
| "我需要先获取更多上下文" | 技能检查在澄清问题之前进行。 |
| "让我先探索一下代码库" | 技能会告诉你如何探索。先检查。 |
| "我可以快速查看一下 git/文件" | 文件缺乏对话上下文。检查是否有相关技能。 |
| "让我先收集一些信息" | 技能会告诉你如何收集信息。 |
| "这不需要正式的技能" | 如果存在相关技能，就使用它。 |
| "我记得这个技能" | 技能会不断演进。阅读当前版本。 |
| "这不算是一个任务" | 行动 = 任务。检查是否有相关技能。 |
| "这个技能有点大材小用" | 简单的事情会变得复杂。使用它。 |
| "我先做完这一件事" | 在做任何事之前先检查。 |
| "这感觉很有成效" | 无纪律的行动浪费时间。技能可以防止这种情况。 |
| "我知道那是什么意思" | 知道概念 ≠ 使用技能。调用它。 |

## 平台适配

技能正文使用 Claude Code 的工具名。非 CC 平台读对应 reference，含该平台的技能调用方式与工具映射：

- Codex：`references/codex-tools.md`
- Copilot CLI：`references/copilot-tools.md`
- Gemini CLI：`references/gemini-tools.md`

## 用户指令

**用户指令始终优先**（CLAUDE.md、AGENTS.md、GEMINI.md、直接请求）> Superpowers 技能 > 默认系统提示。

指令说明的是"做什么"，不是"怎么做"。"添加 X"或"修复 Y"不意味着可以跳过工作流。除非用户明确说了跳，否则不跳。
