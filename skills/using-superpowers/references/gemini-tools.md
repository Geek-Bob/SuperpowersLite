# Gemini CLI 工具映射

Skills 使用 Claude Code 的工具名称。当你在 skill 中遇到这些名称时，请使用对应平台的等价工具：

| Skill 中引用的工具 | Gemini CLI 等价工具 |
|-----------------|----------------------|
| `Read`（读取文件） | `read_file` |
| `Write`（创建文件） | `write_file` |
| `Edit`（编辑文件） | `replace` |
| `Bash`（执行命令） | `run_shell_command` |
| `Grep`（搜索文件内容） | `grep_search` |
| `Glob`（按名称搜索文件） | `glob` |
| `TodoWrite`（任务跟踪） | `write_todos` |
| `Skill` 工具（调用 skill） | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（派发子代理） | `@agent-name`（参见 [子代理支持](#子代理支持)） |

## 子代理支持

Gemini CLI 原生支持通过 `@` 语法派发子代理。使用内置的 `@generalist` 代理来派发任何任务——它可以访问所有工具并遵循你提供的提示。

当某个 skill 要求派发指定类型的代理时，请使用 `@generalist` 并传入 skill 提示模板中完整的提示内容：

| Skill 指令 | Gemini CLI 等价指令 |
|-------------------|----------------------|
| `Task tool (superpowers:implementer)` | `@generalist` 加上填充完成的 `implementer-prompt.md` 模板 |
| `Task tool (superpowers:spec-reviewer)` | `@generalist` 加上填充完成的 `spec-reviewer-prompt.md` 模板 |
| `Task tool (superpowers:code-reviewer)` | `@code-reviewer`（内置代理）或 `@generalist` 加上填充完成的审查提示 |
| `Task tool (superpowers:spec-reviewer)` | `@generalist` 加上填充完成的 `spec-reviewer-prompt.md` 模板 |
| `Task tool (general-purpose)` 配合内联提示 | `@generalist` 加上你的内联提示 |

### 提示填充

Skills 提供的提示模板中包含占位符，例如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]`。请填充所有占位符，并将完整的提示作为消息传递给 `@generalist`。提示模板本身包含了代理的角色、审查标准和预期输出格式——`@generalist` 会遵循该模板执行。

### 并行派发

Gemini CLI 支持并行派发子代理。当某个 skill 要求并行派发多个独立的子代理任务时，请在同一条提示中同时请求所有这些 `@generalist` 或具名子代理任务。保持有依赖关系的任务串行执行，但不要为了保留更简洁的历史记录而将独立的子代理任务串行化。

## 额外的 Gemini CLI 工具

这些工具在 Gemini CLI 中可用，但在 Claude Code 中没有对应工具：

| 工具 | 用途 |
|------|---------|
| `list_directory` | 列出文件和子目录 |
| `save_memory` | 将事实持久化到跨会话的 GEMINI.md |
| `ask_user` | 向用户请求结构化输入 |
| `tracker_create_task` | 丰富的任务管理（创建、更新、列表、可视化） |
| `enter_plan_mode` / `exit_plan_mode` | 在进行修改之前切换到只读研究模式 |
