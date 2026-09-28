# Gemini CLI 工具映射

技能用动作来说话（"派发一个子代理"、"创建一个待办"、"读取一个文件"）。在 Gemini CLI 上，这些动作解析为下表工具。

| 技能请求的动作 | Gemini CLI 等价工具 |
|----------------------|----------------------|
| 读取一个文件 | `read_file` |
| 一次读取多个文件 | `read_many_files` |
| 创建一个新文件 | `write_file` |
| 编辑一个文件 | `replace` |
| 运行一条 shell 命令 | `run_shell_command` |
| 搜索文件内容 | `grep_search` |
| 按名称查找文件 | `glob` |
| 列出文件和子目录 | `list_directory` |
| 获取一个 URL | `web_fetch` |
| 搜索网络 | `google_web_search` |
| 调用一个技能 | `activate_skill` |
| 派发一个子代理（`Subagent (general-purpose):` 模板） | `invoke_agent` 配上 `agent_name: "generalist"`（可通过 `@generalist` 聊天语法调用——参见[子代理支持](#子代理支持)） |
| 多个并行派发 | 在同一条响应中的多个 `invoke_agent` 调用 |
| 任务跟踪（"创建一个待办"、"标记完成"） | `write_todos`（状态：pending、in_progress、completed、cancelled、blocked） |

## 指令文件

当某个技能提到"你的指令文件"（your instructions file）时，在 Gemini CLI 上它指的是 **`GEMINI.md`**。Gemini CLI 以层级方式加载 `GEMINI.md`：全局位于 `~/.gemini/GEMINI.md`，项目级文件位于工作区目录及其祖先目录，并且当某个工具访问子目录中的文件时，也会加载这些子目录的 `GEMINI.md`。

## 个人技能目录

用户级技能位于 **`~/.gemini/skills/`**，并以 **`~/.agents/skills/`** 作为跨运行时别名（与 Codex 和 Copilot CLI 共享）。当同一作用域下两个目录都存在时，`.agents/skills/` 优先。每个技能是一个包含 `SKILL.md` 的子目录（带有 `name` 和 `description` frontmatter）。

## 子代理支持

Gemini CLI 通过 `invoke_agent` 工具派发子代理，该工具接受 `agent_name` 和 `prompt` 参数。同样的派发也以聊天语法快捷方式呈现：输入 `@generalist <prompt>` 等价于调用 `invoke_agent` 并传入 `agent_name: "generalist"`。内置代理名称包括 `generalist`、`cli_help`、`codebase_investigator`，以及（在启用浏览器工具时）`browser_agent`。

技能使用 `Subagent (general-purpose):` 进行派发，并引用一个提示模板文件（例如 `superpowers:subagent-driven-development` 的 `./implementer-prompt.md`）或提供一段内联提示。在 Gemini CLI 上：

| 技能派发形式 | Gemini CLI 等价形式 |
|---------------------|----------------------|
| 引用一个 `*-prompt.md` 模板（implementer、task-reviewer、code-reviewer 等） | 填充该模板，然后用 `invoke_agent` 传入 `agent_name: "generalist"` 和填充后的提示 |
| 引用 `superpowers:requesting-code-review` 的 `./code-reviewer.md` | 用 `invoke_agent` 传入 `agent_name: "generalist"` 和填充后的审查模板 |
| 内联提示（未引用模板） | 用 `invoke_agent` 传入 `agent_name: "generalist"` 和你的内联提示 |

### 提示填充

技能提供的提示模板包含诸如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]` 的占位符。在把完整提示传给 `invoke_agent` 之前填充所有占位符。提示模板本身包含代理的角色、审查标准和预期输出格式——子代理会遵循它。

### 并行派发

Gemini CLI 支持并行派发子代理。在同一条响应中发出多个 `invoke_agent` 调用（或在一条提示中发起多个 `@generalist` 调用），即可并行运行独立的子代理工作。保持有依赖关系的任务串行，但不要仅仅为了保留更简洁的历史记录而将独立的子代理任务串行化。

## 额外的 Gemini CLI 工具

这些工具是 Gemini CLI 独有的：

| 工具 | 用途 |
|------|---------|
| `save_memory`（遗留） | 当 `experimental.memoryV2 = false` 时跨会话持久化事实 |
| `get_internal_docs` | 查阅 Gemini CLI 的内置文档 |
| `ask_user` | 向用户提出结构化问题（文本 / 单选 / 多选） |
| `enter_plan_mode` / `exit_plan_mode` | 切换到只读计划模式并切出 |
| `update_topic` | 更新当前会话的主题 / 战略意图（strategic-intent）元数据 |
| `complete_task` | 表示一个 Gemini 子代理已完成，并将其结果返回给父代理 |
| `tracker_create_task`, `tracker_update_task`, `tracker_get_task`, `tracker_list_tasks`, `tracker_add_dependency`, `tracker_visualize` | 带依赖和可视化支持的丰富任务跟踪器 |
| `read_mcp_resource`, `list_mcp_resources` | MCP 资源访问 |
