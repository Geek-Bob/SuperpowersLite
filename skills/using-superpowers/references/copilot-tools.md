# Copilot CLI 工具映射

技能使用 Claude Code 工具名称。当你在技能中遇到这些工具时，请使用你所在平台的对应工具：

| 技能中引用的工具 | Copilot CLI 对应工具 |
|-----------------|----------------------|
| `Read`（读取文件） | `view` |
| `Write`（创建文件） | `create` |
| `Edit`（编辑文件） | `edit` |
| `Bash`（运行命令） | `bash` |
| `Grep`（搜索文件内容） | `grep` |
| `Glob`（按名称搜索文件） | `glob` |
| `Skill` 工具（调用技能） | `skill` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（分派子代理） | 使用 `agent_type: "general-purpose"` 或 `"explore"` 的 `task` |
| 多个 `Task` 调用（并行） | 多个 `task` 调用 |
| 任务状态/输出 | `read_agent`、`list_agents` |
| `TodoWrite`（任务跟踪） | 使用内置 `todos` 表的 `sql` |
| `WebSearch` | 无对应工具 — 使用带有搜索引擎 URL 的 `web_fetch` |
| `EnterPlanMode` / `ExitPlanMode` | 无对应工具 — 保持在主会话中 |

## 异步 Shell 会话

Copilot CLI 支持持久化的异步 shell 会话，在 Claude Code 中没有直接对应工具：

| 工具 | 用途 |
|------|---------|
| `bash` 带 `async: true` | 在后台启动长时间运行的命令 |
| `write_bash` | 向正在运行的异步会话发送输入 |
| `read_bash` | 读取异步会话的输出 |
| `stop_bash` | 终止异步会话 |
| `list_bash` | 列出所有活动的 shell 会话 |

## 其他 Copilot CLI 工具

| 工具 | 用途 |
|------|---------|
| `store_memory` | 持久化存储有关代码库的事实，供未来会话使用 |
| `report_intent` | 使用当前意图更新 UI 状态行 |
| `sql` | 查询会话的 SQLite 数据库（todos、元数据） |
| `fetch_copilot_cli_documentation` | 查找 Copilot CLI 文档 |
| GitHub MCP 工具（`github-mcp-server-*`） | 原生 GitHub API 访问（issues、PRs、代码搜索） |
