---
name: requesting-code-review
description: 在完成任务、实现主要功能或合并之前使用，验证工作成果是否满足需求
---

# 请求代码审查

派发代码审查子代理，在问题扩散之前发现它们。审查员获得精确构建的评估上下文——而不是你会话的历史记录。这使审查员专注于工作产出而非你的思考过程，同时为你保留继续工作的上下文。

**核心原则：** 尽早审查，经常审查。

## 何时请求审查

**必须：**
- 在 subagent-driven-development 中**所有任务完成后、整体 spec-review 通过后**（即整体双审查门控的第二关）
- 在完成主要功能后
- 在合并到 main 之前

**可选但有价值：**
- 卡住时（新的视角）
- 重构之前（基线检查）
- 修复复杂 bug 之后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码审查子代理：**

使用 Task 工具，类型为 `general-purpose`，填写 `code-reviewer.md` 中的模板

**占位符：**
- `{DESCRIPTION}` — 你构建内容的简要摘要
- `{PLAN_OR_REQUIREMENTS}` — 应该实现什么
- `{BASE_SHA}` — 起始 commit
- `{HEAD_SHA}` — 结束 commit

**3. 根据反馈行动：**
- 立即修复严重问题
- 在继续之前修复重要问题
- 记录次要问题稍后处理
- 如果审查员错了，据理反驳（附理由）

## 示例

```
[刚完成 Task 2：添加验证函数]

你：让我在继续之前请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[派发代码审查子代理]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，包含 4 种问题类型
  PLAN_OR_REQUIREMENTS: deployment-plan.md 中的 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]:
  优点：架构整洁，真实测试
  问题：
    重要：缺少进度指示器
    次要：魔法数字 (100) 用于报告间隔
  评估：可以继续

你：[修复进度指示器]
[继续 Task 3]
```

## 与工作流的集成

**子代理驱动开发：**
- 所有任务完成、整体 spec-review 通过后审查（**整体 code-review**）
- 看到全量 diff，具备全局视角
- 修复后再进入 finishing-a-development-branch

**临时开发：**
- 合并前审查
- 卡住时审查

## 红线

**绝对禁止：**
- 因为"很简单"而跳过审查
- 忽略严重问题
- 带着未修复的重要问题继续
- 与有效的技术反馈争论

**如果审查员错了：**
- 用技术理由反驳
- 展示证明其正常工作的代码/测试
- 请求澄清

参见模板：requesting-code-review/code-reviewer.md
