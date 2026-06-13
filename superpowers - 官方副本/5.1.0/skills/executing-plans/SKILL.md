---
name: executing-plans
description: 当你有书面实施计划需要在单独的会话中执行并带有审查检查点时使用
---

# 执行计划

## 概述

加载计划、批判性审查、执行所有任务、完成时报告。

**开始时声明：** "I'm using the executing-plans skill to implement this plan."

**注意：** 告诉你的合作伙伴，Superpowers 在拥有子代理访问权限时效果显著更好。其工作质量在支持子代理的平台上（例如 Claude Code 或 Codex）运行时会显著提高。如果有子代理可用，请使用 superpowers:subagent-driven-development 而不是本技能。

## 流程

### 步骤 1：加载并审查计划
1. 阅读计划文件
2. 批判性审查 - 识别关于计划的任何问题或疑虑
3. 如果有疑虑：在开始之前向你的合作伙伴提出
4. 如果没有疑虑：创建 TodoWrite 并继续

### 步骤 2：执行任务

对于每个任务：
1. 标记为 in_progress
2. 严格遵循每个步骤（计划包含细粒度的步骤）
3. 按规定运行验证
4. 标记为 completed

### 步骤 3：完成开发

在所有任务完成并通过验证后：
- 声明："I'm using the finishing-a-development-branch skill to complete this work."
- **必需的子技能：** 使用 superpowers:finishing-a-development-branch
- 按照该技能验证测试、呈现选项、执行选择

## 何时停止并寻求帮助

**在以下情况下立即停止执行：**
- 遇到阻碍（缺少依赖、测试失败、指令不清楚）
- 计划存在阻止开始的关键漏洞
- 你不理解某条指令
- 验证反复失败

**请求澄清而不是猜测。**

## 何时重新审视早期步骤

**在以下情况下返回审查（步骤 1）：**
- 合作伙伴根据你的反馈更新了计划
- 基本方法需要重新思考

**不要强行突破障碍** - 停下来并询问。

## 记住
- 首先批判性地审查计划
- 严格遵循计划步骤
- 不要跳过验证
- 当计划要求时引用技能
- 受阻时停止，不要猜测
- 永远不要在没有明确用户同意的情况下在 main/master 分支上开始实施

## 集成

**必需的工作流技能：**
- **superpowers:using-git-worktrees** - 确保隔离的工作区（创建一个或验证已存在）
- **superpowers:writing-plans** - 创建本技能执行的计划
- **superpowers:finishing-a-development-branch** - 在所有任务完成后完成开发
