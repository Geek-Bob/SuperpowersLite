---
name: finishing-a-development-branch
description: 当实施完成、所有测试通过，需要决定如何集成工作时使用 - 通过提供合并、PR 或清理的结构化选项来指导开发工作的完成
---

# 完成开发分支

## 概述

通过呈现清晰的选项并处理所选工作流，指导开发工作的完成。

**核心原则：** 验证测试 → 检测环境 → 呈现选项 → 执行选择 → 清理。

**开始时声明：** "我正在使用 finishing-a-development-branch 技能来完成这项工作。"

## 流程

### 步骤 1：验证测试

**在呈现选项之前，确认测试通过：**

```bash
# 运行项目的测试套件
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：**
```
测试失败（<N> 个失败）。完成前必须修复：

[显示失败信息]

在测试通过之前，无法进行合并/PR。
```

停止。不要进入步骤 2。

**如果测试通过：** 继续执行步骤 2。

### 步骤 2：检测环境

**在呈现选项之前确定工作区状态：**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

这决定显示哪个菜单以及如何执行清理：

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 4 个选项 | 无需清理工作树 |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 4 个选项 | 基于来源（见步骤 6） |
| `GIT_DIR != GIT_COMMON`，分离 HEAD | 缩减为 3 个选项（无合并） | 不清除（外部管理） |

### 步骤 3：确定基础分支

```bash
# 尝试常见的基础分支
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或者询问："此分支是从 main 分出的 - 是否正确？"

### 步骤 4：呈现选项

**普通仓库和命名分支工作树 — 呈现确切的 4 个选项：**

```
实施完成。您想做什么？

1. 合并回本地 <base-branch>
2. 推送并创建 Pull Request
3. 保持分支原样（稍后自行处理）
4. 放弃此工作

选择哪个选项？
```

**分离 HEAD — 呈现确切的 3 个选项：**

```
实施完成。您处于分离 HEAD 状态（外部管理工作区）。

1. 作为新分支推送并创建 Pull Request
2. 保持原样（稍后自行处理）
3. 放弃此工作

选择哪个选项？
```

**不要添加解释** — 保持选项简洁。

### 步骤 5：执行选择

#### 选项 1：本地合并

```bash
# 获取主仓库根目录以确保 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并 — 在移除任何内容前确认成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 在合并结果上验证测试
<test command>

# 仅在合并成功后：清理工作树（步骤 6），然后删除分支
```

然后：清理工作树（步骤 6），然后删除分支：

```bash
git branch -d <feature-branch>
```

#### 选项 2：推送并创建 PR

```bash
# 推送分支
git push -u origin <feature-branch>

# 创建 PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**不要清理工作树** — 用户需要它保持活跃以迭代 PR 反馈。

#### 选项 3：保持原样

报告："保持分支 <name>。工作树保留在 <path>。"

**不要清理工作树。**

#### 选项 4：放弃

**先确认：**
```
这将永久删除：
- 分支 <name>
- 所有提交：<commit-list>
- 工作树位于 <path>

输入 'discard' 确认。
```

等待确切的确认。

如果已确认：
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后：清理工作树（步骤 6），然后强制删除分支：
```bash
git branch -D <feature-branch>
```

### 步骤 6：清理工作区

**仅对选项 1 和 4 执行。** 选项 2 和 3 始终保留工作树。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**如果 `GIT_DIR == GIT_COMMON`：** 普通仓库，无需清理工作树。完成。

**如果工作树路径位于 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下：** Superpowers 创建了此工作树 — 我们负责清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清理任何过时的注册信息
```

**否则：** 宿主环境（harness）拥有此工作区。不要移除它。如果您的平台提供了工作区退出工具，请使用它。否则，保持工作区不变。

## 快速参考

| 选项 | 合并 | 推送 | 保留工作树 | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 保持原样 | - | - | 是 | - |
| 4. 放弃 | - | - | - | 是（强制） |

## 常见错误

**跳过测试验证**
- **问题：** 合并损坏的代码，创建失败的 PR
- **修复：** 在提供选项之前始终验证测试

**开放式问题**
- **问题：** "接下来我该做什么？" 表述含糊
- **修复：** 呈现确切 4 个结构化选项（分离 HEAD 为 3 个）

**为选项 2 清理工作树**
- **问题：** 移除了用户迭代 PR 所需的工作树
- **修复：** 仅对选项 1 和 4 执行清理

**在移除工作树之前删除分支**
- **问题：** `git branch -d` 失败，因为工作树仍引用该分支
- **修复：** 先合并，移除工作树，然后删除分支

**在工作树内部运行 git worktree remove**
- **问题：** 当 CWD 位于被移除的工作树内部时，命令静默失败
- **修复：** 在执行 `git worktree remove` 之前始终 `cd` 到主仓库根目录

**清理 harness 拥有的工作树**
- **问题：** 移除 harness 创建的工作树会导致幻影状态
- **修复：** 仅清理 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下的工作树

**放弃时未确认**
- **问题：** 意外删除工作
- **修复：** 要求输入 "discard" 确认

## 红旗标志

**绝不：**
- 在测试失败时继续
- 未在结果上验证测试就进行合并
- 未确认就删除工作
- 未经明确请求就强制推送
- 在确认合并成功之前移除工作树
- 清理不是自己创建的工作树（来源检查）
- 在工作树内部运行 `git worktree remove`

**始终：**
- 在提供选项之前验证测试
- 在呈现菜单之前检测环境
- 呈现确切 4 个选项（分离 HEAD 为 3 个）
- 获取选项 4 的输入确认
- 仅对选项 1 和 4 清理工作树
- 在移除工作树之前 `cd` 到主仓库根目录
- 移除后运行 `git worktree prune`
