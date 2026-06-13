---
name: requesting-code-review
description: 当完成任务、实施主要功能或合并前需要验证工作是否符合要求时使用
---

# 请求代码审查

在问题扩散之前，派遣代码审查子代理来捕获问题。审查者获得精确定制的上下文用于评估——绝不包含你的会话历史。这让审查者专注于工作成果而非你的思考过程，同时保留你自身的上下文以便继续工作。

**核心原则：尽早审查，经常审查。**

## 何时请求审查

**强制要求：**
- 在子代理驱动的开发中，每个任务完成后
- 完成主要功能后
- 合并到 main 分支前

**可选但有价值：**
- 遇到困难时（获得新视角）
- 重构之前（基线检查）
- 修复复杂 Bug 之后

## 如何请求

**1. 获取 git SHAs：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派遣代码审查子代理：**

使用 `general-purpose` 类型的 Task 工具，填写 `code-reviewer.md` 模板

**占位符说明：**
- `{DESCRIPTION}` - 你所构建内容的简要总结
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- Critical 问题立即修复
- Important 问题在继续前修复
- Minor 问题记下稍后处理
- 如果审查者有误，提出反驳（附上理由）

## 示例

```
[刚刚完成 Task 2：添加验证函数]

你：让我在继续之前请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[派遣代码审查子代理]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，包含 4 种问题类型
  PLAN_OR_REQUIREMENTS: 来自 docs/superpowers/plans/deployment-plan.md 的 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]：
  Strengths: 架构清晰，有真实测试
  Issues:
    Important: 缺少进度指示器
    Minor: 报告间隔使用了魔法数字 (100)
  Assessment: 可以继续

你：[修复进度指示器]
[继续执行 Task 3]
```

## 与工作流的集成

**子代理驱动开发：**
- 在 EACH 任务后审查
- 在问题叠加前捕获
- 在进入下一个任务前修复

**执行计划：**
- 在每个任务后或自然的检查点审查
- 获取反馈，应用，继续

**临时开发：**
- 合并前审查
- 遇到困难时审查

## 红牌警告

**绝对不要：**
- 因为"很简单"而跳过审查
- 忽略 Critical 问题
- 带着未修复的 Important 问题继续
- 与有效的技术反馈争论

**如果审查者错误：**
- 用技术理由提出反驳
- 展示证明其可行的代码/测试
- 请求澄清

参见模板：requesting-code-review/code-reviewer.md
