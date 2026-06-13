---
name: using-git-worktrees
description: 当开始需要与当前工作空间隔离的功能开发或执行实施计划之前使用 - 通过原生工具或 git worktree 回退确保存在隔离的工作空间
---

# 使用 Git Worktrees

## 概述

确保工作在隔离的工作空间中进行。优先使用平台的原生 worktree 工具。仅在无原生工具可用时才回退到手动 git worktrees。

**核心原则：** 首先检测现有隔离。然后使用原生工具。最后回退到 git。切勿与工具链对抗。

**开始时声明：** "我正在使用 using-git-worktrees 技能来设置隔离的工作空间。"

## 步骤 0：检测现有隔离

**在创建任何内容之前，检查你是否已处于隔离的工作空间中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块防护：** `GIT_DIR != GIT_COMMON` 在 git 子模块内部也为 true。在得出"已在 worktree 中"的结论之前，请验证你不在子模块中：

```bash
# 如果返回路径，说明你在子模块中，而非 worktree — 按正常仓库处理
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（且不在子模块中）：** 你已处于链接的 worktree 中。跳到步骤 3（项目设置）。不要再创建另一个 worktree。

报告分支状态：
- 在分支上："已在 `<path>` 的隔离工作空间中，分支为 `<name>`。"
- 分离 HEAD："已在 `<path>` 的隔离工作空间中（分离 HEAD，外部管理）。完成时需创建分支。"

**如果 `GIT_DIR == GIT_COMMON`（或在子模块中）：** 你处于正常的仓库检出状态。

用户的指令中是否已经指明了 worktree 偏好？如果没有，在创建 worktree 前请求同意：

> "是否需要我设置一个隔离的 worktree？它可以保护你当前的分支免受更改影响。"

遵守任何已有声明的偏好，无需询问。如果用户拒绝同意，则原地工作并跳到步骤 3。

## 步骤 1：创建隔离的工作空间

**你有两种机制。按此顺序尝试。**

### 1a. 原生 Worktree 工具（首选）

用户已请求隔离的工作空间（步骤 0 的同意）。你是否已经有创建 worktree 的方式？它可能是一个名为 `EnterWorktree`、`WorktreeCreate` 的工具，一个 `/worktree` 命令，或一个 `--worktree` 标志。如果有，使用它并跳到步骤 3。

原生工具会自动处理目录放置、分支创建和清理。在拥有原生工具时使用 `git worktree add` 会创建工具链无法看到或管理的幻影状态。

只有在没有原生 worktree 工具可用时才继续执行步骤 1b。

### 1b. Git Worktree 回退

**仅在步骤 1a 不适用时使用** — 你没有可用的原生 worktree 工具。使用 git 手动创建 worktree。

#### 目录选择

遵循此优先级顺序。明确的用户偏好始终优先于观察到的文件系统状态。

1. **检查你的指令中是否有声明的 worktree 目录偏好。** 如果用户已指定，直接使用，无需询问。

2. **检查是否已存在项目本地的 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 首选（隐藏）
   ls -d worktrees 2>/dev/null      # 备选
   ```
   如果找到，使用它。如果两者都存在，`.worktrees` 优先。

3. **检查是否已存在全局目录：**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   如果找到，使用它（向后兼容旧版全局路径）。

4. **如果没有其他指引可用**，默认为项目根目录下的 `.worktrees/`。

#### 安全检查（仅限项目本地目录）

**在创建 worktree 前必须验证目录已被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未被忽略：** 添加到 .gitignore，提交更改，然后继续。

**为何关键：** 防止意外将 worktree 内容提交到仓库。

全局目录（`~/.config/superpowers/worktrees/`）无需验证。

#### 创建 Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# 根据所选位置确定路径
# 项目本地：path="$LOCATION/$BRANCH_NAME"
# 全局：path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱回退：** 如果 `git worktree add` 因权限错误（沙箱拒绝）而失败，告知用户沙箱阻止了 worktree 创建，你将在当前目录中工作。然后原地运行设置和基线测试。

## 步骤 3：项目设置

自动检测并运行适当的设置：

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

## 步骤 4：验证干净的基线

运行测试以确保工作空间以干净状态启动：

```bash
# 使用项目适用的命令
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：** 报告失败，询问是继续还是调查。

**如果测试通过：** 报告就绪。

### 报告

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情况 | 操作 |
|-----------|--------|
| 已在链接的 worktree 中 | 跳过创建（步骤 0） |
| 在子模块中 | 按正常仓库处理（步骤 0 防护） |
| 原生 worktree 工具可用 | 使用它（步骤 1a） |
| 无原生工具 | Git worktree 回退（步骤 1b） |
| `.worktrees/` 已存在 | 使用它（验证已忽略） |
| `worktrees/` 已存在 | 使用它（验证已忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 两者都不存在 | 检查指令文件，然后默认为 `.worktrees/` |
| 全局路径存在 | 使用它（向后兼容） |
| 目录未被忽略 | 添加到 .gitignore + 提交 |
| 创建时权限错误 | 沙箱回退，原地工作 |
| 基线测试失败 | 报告失败 + 询问 |
| 无 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 与工具链对抗

- **问题：** 在平台已提供隔离时使用 `git worktree add`
- **修复：** 步骤 0 检测现有隔离。步骤 1a 优先使用原生工具。

### 跳过检测

- **问题：** 在已有 worktree 内部创建嵌套 worktree
- **修复：** 在创建任何内容之前始终运行步骤 0

### 跳过忽略验证

- **问题：** worktree 内容被跟踪，污染 git 状态
- **修复：** 在创建项目本地 worktree 之前始终使用 `git check-ignore`

### 假设目录位置

- **问题：** 造成不一致，违反项目约定
- **修复：** 遵循优先级：已有目录 > 旧版全局 > 指令文件 > 默认

### 在测试失败的情况下继续

- **问题：** 无法区分新错误和既有问题
- **修复：** 报告失败，获得明确许可后再继续

## 红旗警示

**切勿：**
- 在步骤 0 检测到现有隔离时创建 worktree
- 在拥有原生 worktree 工具（如 `EnterWorktree`）时使用 `git worktree add`。这是最常见的错误 — 如果你有它，请使用它。
- 跳过步骤 1a，直接跳到步骤 1b 的 git 命令
- 未验证目录已被忽略就创建 worktree（项目本地）
- 跳过基线测试验证
- 在测试失败的情况下继续而不询问

**始终：**
- 先运行步骤 0 检测
- 优先使用原生工具而非 git 回退
- 遵循目录优先级：已有目录 > 旧版全局 > 指令文件 > 默认
- 验证项目本地目录已被忽略
- 自动检测并运行项目设置
- 验证干净的测试基线
