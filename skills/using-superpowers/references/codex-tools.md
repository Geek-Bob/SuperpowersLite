# Codex 工具映射

技能使用 Claude Code 的工具名称。当你在技能中遇到这些名称时，请使用你平台上的对应项：

| 技能引用项 | Codex 对应项 |
|-----------------|------------------|
| `Task` 工具（派发子代理） | `spawn_agent`（参见[子代理派发需要多代理支持](#子代理派发需要多代理支持)） |
| 多个 `Task` 调用（并行） | 多个 `spawn_agent` 调用 |
| Task 返回结果 | `wait_agent` |
| Task 自动完成 | `close_agent` 释放槽位 |
| `TodoWrite`（任务跟踪） | `update_plan` |
| `Skill` 工具（调用技能） | 技能原生加载——直接遵循指令即可 |
| `Read`、`Write`、`Edit`（文件） | 使用你的原生文件工具 |
| `Bash`（运行命令） | 使用你的原生 shell 工具 |

## 子代理派发需要多代理支持

添加到你的 Codex 配置中（`~/.codex/config.toml`）：

```toml
[features]
multi_agent = true
```

此配置启用 `spawn_agent`、`wait_agent` 和 `close_agent`，用于 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能。

遗留说明：`rust-v0.115.0` 之前的 Codex 构建版本将派生子代理的等待暴露为 `wait`。当前 Codex 对派生子代理使用 `wait_agent`。`wait` 名称现在归属于代码模式的 `exec/wait`，用于通过 `cell_id` 恢复一个已挂起的执行单元；它不是派生子代理的结果工具。

## 环境检测

创建工作树或完成分支的技能应在继续之前，使用只读 git 命令检测其环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已在链接的工作树中（跳过创建）
- `BRANCH` 为空 → 分离 HEAD（无法从沙箱进行分支/推送/PR）

请参见 `using-git-worktrees` 的第 0 步和 `finishing-a-development-branch` 的第 1 步，了解每个技能如何使用这些信号。

## Codex 应用完成操作

当沙箱阻止分支/推送操作（在外部管理工作树中处于分离 HEAD 状态）时，代理会提交所有工作并告知用户使用应用的本地控制功能：

- **"Create branch"（创建分支）** — 命名分支，然后通过应用 UI 进行提交/推送/PR
- **"Hand off to local"（移交到本地）** — 将工作传输到用户的本地检出

代理仍然可以运行测试、暂存文件，并输出建议的分支名称、提交消息和 PR 描述，供用户复制使用。
