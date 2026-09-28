---
name: finishing-a-development-branch
description: 当实现完成、全部测试通过、需要决定如何集成工作时使用——以结构化选项（合并 / PR / 保留）引导完成开发收尾
---

# 完成开发分支

## 概览

用清晰的选项引导开发收尾，并执行所选流程。

**核心原则：** 验证测试 → 探测环境 → 展示选项 → 执行选择 → 清理。

**开场宣告：** 「我正在使用 finishing-a-development-branch 技能完成这项工作。」

## 流程

### Step 1：验证测试

**展示选项之前先验证测试通过：**

```bash
# 运行项目测试套件
npm test / cargo test / pytest / go test ./...
```

**测试失败时：**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

停下。不要进入 Step 2。

**测试通过：** 继续 Step 2。

### Step 2：探测环境

**展示选项之前先确定工作区状态：**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# 现在捕获，趁还在工作区内——Step 5 会切换目录，而清理（Step 6）需要这个值
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

这决定展示哪个菜单、清理怎么做：

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 3 选项 | 无 worktree 可清 |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 3 选项 | 按来源判断（见 Step 6） |
| `GIT_DIR != GIT_COMMON`，detached HEAD | 精简 2 选项（无合并） | 不清理（外部托管） |

### Step 3：确定基线分支

```bash
# 尝试常见基线分支
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或询问：「这条分支从 main 切出——对吗？」

### Step 4：展示选项

**普通仓库与命名分支 worktree——恰好这 3 个选项：**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**detached HEAD——恰好这 2 个选项：**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

**不加解释**——选项保持简洁。

**菜单里不出现「丢弃」。** 丢弃只在用户明确要求时执行（见下方「用户明确要求丢弃工作时」）。把「丢弃」摆在「合并」旁边，等于向用户推销销毁一份已完成且测试通过的工作。

### Step 5：执行选择

#### Option 1：本地合并

```bash
# 获取主仓库根目录，保证 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并——验证成功后才移除任何东西
git checkout <base-branch>
git pull
git merge <feature-branch>

# 对合并结果运行测试
<test command>

# 合并成功后才清理 worktree（Step 6），然后删除分支
```

**合并结果测试失败就停手。** 保留 worktree 与分支原地不动，排查——此时**什么都还没 push**，merge 是本地的、可恢复的。

然后：清理 worktree（Step 6），再删除分支：

```bash
git branch -d <feature-branch>
```

#### Option 2：推送并创建 PR

```bash
# 推送分支
git push -u origin <feature-branch>
# detached HEAD 上没有 <feature-branch> 可命名，在远端命名新分支：
#   git push origin HEAD:refs/heads/<new-branch>

# 创建 PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**不要清理 worktree**——用户还需要它在 PR 反馈上迭代。

#### Option 3：原样保留

汇报：「Keeping branch <name>. Worktree preserved at <path>.」

**不清理 worktree。**

#### 用户明确要求丢弃工作时

**这段路径只因用户明确要求丢弃而存在——它不是菜单选项。**

先确认：
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

等到**一字不差**的确认。收到后：
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后：清理 worktree（Step 6），再强删分支：
```bash
git branch -D <feature-branch>
```

### Step 6：清理工作区

**只在 Option 1 与用户要求丢弃时运行。** Option 2 / 3 永远保留 worktree。

```bash
# 复用 Step 2 捕获的 GIT_DIR / GIT_COMMON / WORKTREE_PATH——那时还没进入
# Step 5 的切目录。在这里重算 --show-toplevel 会得到主仓库根，
# 让 GIT_DIR == GIT_COMMON 成立、清理静默 no-op。
```

**若 `GIT_DIR == GIT_COMMON`：** 普通仓库，无 worktree 可清。结束。

**若 worktree 路径在 `.worktrees/`、`worktrees/` 下：** 该 worktree 由 Superpowers 创建——归我们清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清掉任何过期注册
```

**移除被拒绝时**（报 `contains modified or untracked files`）：该 worktree 里存在**别处没有的文件**——未提交的计划、笔记、临时产物。**绝不自行加 `--force`**。先让用户看清代价：

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

**其余情况：** 该工作区归宿主环境（harness）所有。**不要移除它。** 若平台提供 workspace-exit 工具就用它，否则保持原样。

## Quick Reference

| 选项 | 合并 | 推送 | 保留 worktree | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | yes | - | - | yes |
| 2. 创建 PR | - | yes | yes | - |
| 3. 原样保留 | - | - | yes | - |
| 丢弃（仅用户明确要求时） | - | - | - | yes (force) |

## 常见合理化

| 借口 | 现实 |
|------|------|
| "测试晚点再跑也行" | 给选项前必须验测试，合并结果还要再验一次——未测的合并是坏代码与失败 PR 的入口 |
| "直接问用户下一步就行" | 开放问题会收到无限种回答；菜单恰好 3 个（detached HEAD 2 个），且先探测环境再展示 |
| "PR 选项选完了，顺手把 worktree 清掉" | 用户还要在 PR 上迭代；只清理 Option 1 与明确丢弃，Option 2/3 保留 worktree |
| "先删分支再清 worktree" | worktree 还引用分支时 `git branch -d` 会失败；顺序：合并 → 移 worktree → 删分支，且移除前先确认合并成功 |
| "就在 worktree 里移除它" | CWD 在被移除的 worktree 内时命令静默失败；先 `cd` 回主仓库根，移除后跑 `git worktree prune` |
| "周边的 worktree 也顺手清了" | 只清自己创建的、且在 `.worktrees/` / `worktrees/` 下的——移除 harness 创建的会产生幻影状态 |
| "丢弃就不用确认了吧" | 误删不可逆；必须一字不差输入 `discard` 确认 |
| "把「丢弃」摆进菜单更完整" | 把销毁与合并并列=推销销毁已完成且测试通过的工作；丢弃仅在用户明确要求时才存在 |
| "移除被拒，加 `--force` 就好" | 被拒=该 worktree 里有别处不存在的文件，`--force` 会永久销毁它们；停下、列出文件、征询用户 |
| "push 被拒了，force-push 解决" | 被拒=远端已前进，先 `git fetch` 查清差什么；force-push 仅在用户明确要求时 |
