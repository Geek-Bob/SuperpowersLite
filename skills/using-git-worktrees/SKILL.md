---
name: using-git-worktrees
description: 开始需要与当前工作区隔离的功能开发时使用，或在执行实施计划之前使用 —— 通过原生工具或 git worktree 兜底，确保存在隔离工作区
---

# 使用 Git Worktree

## 概述

确保工作在隔离的工作区中进行。优先用你平台的原生 worktree 工具。只有在没有原生工具时，才退回手动 git worktree。

**核心原则：** 先检测已有隔离。然后用原生工具。最后才退回 git。绝不要和 harness 对着干。

**开始时声明：** "我正在使用 using-git-worktrees 技能建立隔离工作区。"

## Step 0: 检测已有隔离

**创建任何东西之前，先检查你是否已经在隔离工作区中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule 守卫：** `GIT_DIR != GIT_COMMON` 在 git submodule 内部同样成立。在断定"已经在 worktree 中"之前，先确认你不在 submodule 里：

```bash
# 若这返回一个路径，你就在 submodule 里而非 worktree —— 按普通仓库处理
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**若 `GIT_DIR != GIT_COMMON`（且不在 submodule 中）：** 你已经在链接式 worktree 中。跳到 Step 2（项目 Setup）。不要再创建另一个 worktree。

汇报分支状态：
- 在某个分支上："已在隔离工作区 `<path>`，分支 `<name>`。"
- Detached HEAD："已在隔离工作区 `<path>`（detached HEAD，外部管理）。收尾时需要创建分支。"

**若 `GIT_DIR == GIT_COMMON`（或在 submodule 中）：** 你在普通仓库检出中。

用户是否已在给你的指令中表明 worktree 偏好？如果没有，创建 worktree 前先征得同意：

> "要我给你建一个隔离 worktree 吗？它能保护你当前的分支不受改动影响。"

已有明确声明的偏好就照办、不必再问。如果用户拒绝同意，就在原地工作，跳到 Step 2。

## Step 1: 创建隔离工作区

**你有两种机制。按此顺序尝试。**

### 1a. 原生 Worktree 工具（首选）

用户已请求隔离工作区（Step 0 已同意）。你是否已经有创建 worktree 的方式？它可能是一个名为 `EnterWorktree`、`WorktreeCreate`、`/worktree` 命令或 `--worktree` 标志的工具。如果有，就用它并跳到 Step 2。

原生工具会自动处理目录位置、分支创建和清理。在有原生工具时用 `git worktree add` 会造出 harness 看不见也管不了的幻影状态。

只有在没有可用的原生 worktree 工具时，才进入 Step 1b。

### 1b. Git Worktree 兜底

**只有在 Step 1a 不适用时才用这个** —— 你没有可用的原生 worktree 工具。用 git 手动创建 worktree。

#### 目录选择

遵循这个优先级顺序。用户明确的偏好永远优先于观察到的文件系统状态。

1. **在你的指令中查找已声明的 worktree 目录偏好。** 如果用户已经指定，直接用它、不必再问。

2. **查找已存在的项目内 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 首选（隐藏）
   ls -d worktrees 2>/dev/null      # 备选
   ```
   如果找到，用它。如果两者都存在，`.worktrees` 胜出。

3. **如果没有其他可用的指引**，默认用项目根目录下的 `.worktrees/`。

#### 安全校验（仅限项目内目录）

**创建 worktree 前必须校验目录已被 ignore：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**若未被 ignore：** 加进 .gitignore，commit 这个改动，再继续。

**为何关键：** 防止把 worktree 内容意外提交进仓库。

#### 创建 Worktree

```bash
# path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox 兜底：** 如果 `git worktree add` 因权限错误失败（sandbox 拒绝），告诉用户 sandbox 阻止了 worktree 创建，你改为在当前目录工作。然后在原地运行 setup 和基线测试。

## Step 2: 项目 Setup

自动探测并运行相应的 setup：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Step 3: 验证干净基线

运行测试，确保工作区从干净状态起步：

```bash
# 使用项目管理对应的命令
npm test / cargo test / pytest / go test ./...
```

**若测试失败：** 报告失败，询问是继续还是先调查。

**若测试通过：** 报告就绪。

### 汇报

```
Worktree 就绪，位于 <full-path>
测试通过（<N> 个测试，0 失败）
可以开始实现 <feature-name>
```

## 快速参考

| 情形 | 动作 |
|-----------|--------|
| 已在链接式 worktree 中 | 跳过创建（Step 0） |
| 在 submodule 中 | 按普通仓库处理（Step 0 守卫） |
| 有原生 worktree 工具 | 用它（Step 1a） |
| 无原生工具 | Git worktree 兜底（Step 1b） |
| `.worktrees/` 已存在 | 用它（校验已 ignore） |
| `worktrees/` 已存在 | 用它（校验已 ignore） |
| 两者都存在 | 用 `.worktrees/` |
| 两者都不存在 | 查指令文件，再默认 `.worktrees/` |
| 目录未被 ignore | 加进 .gitignore + commit |
| 创建时权限错误 | Sandbox 兜底，原地工作 |
| 基线测试失败 | 报告失败 + 询问 |
| 无 package.json/Cargo.toml | 跳过依赖安装 |

## 常见合理化

| 借口 | 现实 |
|------|------|
| "`git worktree add` 我熟，原生工具还得现找" | 平台已提供隔离工具（如 `EnterWorktree`、`/worktree`）时改用 git，会造出 harness 看不见也管不了的幻影状态。这是头号错误——有原生工具就用它（Step 1a），别跳过 1a 直奔 1b 的 git 命令 |
| "我直接建下一个 worktree 就行" | 不先跑 Step 0，会在已有隔离里套娃建出嵌套 worktree。创建任何东西前先运行 Step 0 检测 |
| "目录加不加 .gitignore 无所谓，回头再说" | 项目内 worktree 未被 ignore 时，其内容会被 git 跟踪、污染 git status。创建前必须 `git check-ignore` 校验 |
| "worktree 放哪我自己定就行" | 随意选址会造成不一致、违反项目约定。优先级：项目内已有目录 > 指令文件声明 > 默认 `.worktrees/` |
| "测试红着也先往下做，八成是既有问题" | 分不清新 bug 还是既有问题。报告失败，取得明确许可再继续 |
| "基线测试走个过场，没必要认真跑" | 必须验证干净的测试基线。跳过它 = 从未知状态开工，之后无法归因新 bug |
| "依赖和 setup 回头再装" | Step 2 要自动探测并运行项目 setup；不跑就是带着坏环境开工 |
