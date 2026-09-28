## 子代理派发需要多代理支持

添加到你的 Codex 配置中（`~/.codex/config.toml`）：

```toml
[features]
multi_agent = true
```

此配置启用 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能所使用的多代理工具。你获得哪些工具取决于你的模型预设所选的多代理版本（当前预设运行 V2；较旧的运行 V1）。当它们不一致时，以你的实际工具列表为准，而非任何表格——包括本表。

- **派发（Spawning）：** 用 `spawn_agent {fork_turns: "none"}` 给子代理一个干净的上下文；默认的 `"all"` 会把你的完整 transcript 复制进子代理。在 Codex 0.145+ 上，`~/.codex/agents/` 下的角色文件通过 `agent_type` 附着到隔离 fork。全历史 fork 接受 `model` 和 `reasoning_effort` 覆盖（在那里只有 `agent_type` 被拒绝）——隔离 fork 是 SDD 出于上下文卫生（context hygiene）考虑的默认选择，而非因为覆盖需要它们。
- **修复轮次（Fix rounds）：** 用 `followup_task` 恢复实现者——它投递你的消息、触发一轮对话，并透明地重新加载被 harness 驱逐的子代理。绝不要基于"派发出去的代理无法再次收到消息"这一臆断而重新派发一个全新的实现者；在 V2 上它始终可以再次收到消息。
- **生命周期（Lifecycle）：** V2 没有 `close_agent`。完成的子代理在需要槽位时被自动驱逐；不关闭它们不产生任何开销。只有 V1 会话才有 `close_agent`——在那里，审查者返回审查结果时关闭它，每个实现者在其任务的审查通过后关闭。
- **模型名称（Model names）：** 绝不要把技能、表格或旧会话中的模型名称直接复制进 `spawn_agent`，除非已对照你当前的 spawn 允许列表核查过——V2 只接受支持 V2 的预设，对其余的会硬报错。

## 等待子代理

`wait_agent` 是事件订阅，而非轮询：长等待会在子代理产生邮箱活动的那一刻唤醒，延迟与短等待相同。短超时轮询毫无收益，且每次轮询都要消耗一次工具调用——以及一次上下文重新计费（context rebill）。在实测会话中，大约三分之二的等待调用都是超时的短轮询。

- 当你仍有本地工作时，完全不要等待。已完成子代理的最终答案会被推入你的邮箱，并随你的下一轮对话到达。
- 当你确实空闲且有子代理未完成时，以有界的时间段等待：`wait_agent` 配上 `timeout_ms` 300000-600000（5-10 分钟）。每一段结束后——无论唤醒还是超时——发布一行状态、运行 `list_agents`，并追问任何已完成但未上报的子代理。绝不要堆叠短于五分钟的轮询；事件订阅唤醒一个有界时间段的速与短轮询一样快。
- 完成邮件无法唤醒空闲的控制器（它的投递不触发一轮对话）；覆盖该空闲窗口正是 `wait_agent` 唯一的职责。一段无任何活动而超时的时间段，是提示你去做对账（reconcile）的信号，而不是让你缩短下一段的信号。

## 派发时的模型路由

你发出的每一个 `spawn_agent`——包括当你自己也是一个正在执行扇出（fan-out）的子代理时——都要显式设置 `model` 和 `reasoning_effort`，并遵循你正在执行的技能的模型选择（Model Selection）规则。只设置 `model` 是个陷阱：子代理的 effort 会被静默重置为该模型的默认值，而不是你的值。

请你的真人搭档往 `~/.codex/config.toml` 中添加一个机器级兜底（backstop），使得任何漏网的派发仍然路由到一个经过斟酌的层级，而不是静默继承会话中最昂贵的模型：

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

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
