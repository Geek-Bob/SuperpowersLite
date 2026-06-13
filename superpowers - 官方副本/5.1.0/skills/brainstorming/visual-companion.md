---
name: visual-companion
description: 在头脑风暴过程中通过浏览器显示视觉内容（线框图、模型、对比图）时使用。当问题本身是视觉性的——布局、设计、空间关系——而不是文字性的，文字描述会让用户难以判断时。
---

# 视觉伴侣指南

基于浏览器的可视化头脑风暴伴侣，用于显示模型、图表和选项。

## 何时使用

按问题决定，而非按会话决定。判断标准是：**用户是通过看到内容还是阅读文字能更好地理解？**

**使用浏览器** 当内容本身是视觉性的：

- **UI 模型** — 线框图、布局、导航结构、组件设计
- **架构图** — 系统组件、数据流、关系图
- **并排视觉对比** — 比较两个布局、两种配色方案、两个设计方向
- **设计润色** — 当问题涉及外观和感觉、间距、视觉层次时
- **空间关系** — 状态机、流程图、实体关系（以图表形式呈现）

**使用终端** 当内容是文字或表格性的：

- **需求和范围问题** — "X 是什么意思？""哪些功能在范围内？"
- **概念性的 A/B/C 选择** — 在用文字描述的方法之间进行选择
- **权衡列表** — 优缺点、对比表
- **技术决策** — API 设计、数据建模、架构方法选择
- **澄清性问题** — 任何答案是文字而非视觉偏好的问题

一个"关于"UI 主题的问题并不自动是视觉问题。"你想要什么样的向导？"是概念性的——使用终端。"这些向导布局中哪个感觉更合适？"是视觉性的——使用浏览器。

## 工作原理

服务器监视一个目录中的 HTML 文件，并将最新的一个提供给浏览器。你将 HTML 内容写入 `screen_dir`，用户在浏览器中看到并可以点击选择选项。选择会被记录到 `state_dir/events`，你在下一轮读取。

**内容片段 vs 完整文档：** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头，服务器会原样提供（仅注入辅助脚本）。否则，服务器会自动将你的内容包裹在框架模板中——添加头部、CSS 主题、选择指示器和所有交互式基础设施。**默认编写内容片段。** 仅在需要对页面进行完全控制时才编写完整文档。

## 启动会话

```bash
# 启动服务器并保持持久化（模型保存到项目）
scripts/start-server.sh --project-dir /path/to/project

# 返回：{"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从响应中保存 `screen_dir` 和 `state_dir`。告诉用户打开该 URL。

**查找连接信息：** 服务器将其启动 JSON 写入 `$STATE_DIR/server-info`。如果你在后台启动了服务器但没有捕获 stdout，读取该文件以获取 URL 和端口。使用 `--project-dir` 时，检查 `<project>/.superpowers/brainstorm/` 中的会话目录。

**注意：** 将项目根目录作为 `--project-dir` 传递，以便模型持久化在 `.superpowers/brainstorm/` 中并在服务器重启后保留。否则，文件会进入 `/tmp` 并被清理。如果 `.superpowers/` 还没有在 `.gitignore` 中，提醒用户添加。

**按平台启动服务器：**

**Claude Code（macOS / Linux）：**
```bash
# 默认模式有效——脚本自行将服务器置于后台
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code（Windows）：**
```bash
# Windows 自动检测并使用前台模式，这会阻塞工具调用。
# 在 Bash 工具调用上使用 run_in_background: true 以便服务器
# 在多轮对话之间保持运行。
scripts/start-server.sh --project-dir /path/to/project
```
通过 Bash 工具调用此命令时，设置 `run_in_background: true`。然后在下一轮读取 `$STATE_DIR/server-info` 以获取 URL 和端口。

**Codex：**
```bash
# Codex 会回收后台进程。脚本自动检测 CODEX_CI 并
# 切换到前台模式。正常运行——无需额外标志。
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI：**
```bash
# 使用 --foreground 并在你的 shell 工具调用上设置 is_background: true
# 以便进程在多轮对话之间保持运行
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**其他环境：** 服务器必须在多轮对话之间在后台保持运行。如果你的环境会回收分离的进程，请使用 `--foreground` 并使用你平台的后台执行机制启动该命令。

如果从浏览器无法访问该 URL（远程/容器化设置中很常见），请绑定非环回主机：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

使用 `--url-host` 来控制返回的 URL JSON 中打印的主机名。

## 循环流程

1. **检查服务器是否存活**，然后**将 HTML 写入** `screen_dir` 中的一个新文件：
   - 每次写入之前，检查 `$STATE_DIR/server-info` 是否存在。如果不存在（或 `$STATE_DIR/server-stopped` 存在），服务器已关闭——在继续之前使用 `start-server.sh` 重新启动它。服务器在 30 分钟无活动后会自动退出。
   - 使用语义化文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **永远不要重用文件名** — 每个屏幕使用一个新文件
   - 使用 Write 工具 — **永远不要使用 cat/heredoc**（会在终端中产生大量噪音）
   - 服务器自动提供最新的文件

2. **告诉用户会发生什么，然后结束你的回合：**
   - 提醒他们 URL（每一步都要提醒，不仅仅是第一次）
   - 简要文字总结屏幕上显示的内容（例如，"为主页显示 3 个布局选项"）
   - 要求他们在终端中回复："看一下，告诉我你的想法。如果想选择，点击选项。"

3. **在你的下一轮** — 用户在终端中回复后：
   - 如果 `$STATE_DIR/events` 存在则读取它——这包含用户的浏览器交互（点击、选择），以 JSON 行形式记录
   - 与用户的终端文本合并以获得完整画面
   - 终端消息是主要反馈；`state_dir/events` 提供结构化的交互数据

4. **迭代或推进** — 如果反馈改变了当前屏幕，写一个新文件（例如，`layout-v2.html`）。仅在当前步骤已验证后才进入下一个问题。

5. **返回终端时卸载** — 当下一步不需要浏览器（例如，澄清性问题、权衡讨论）时，推送一个等待屏幕以清除陈旧内容：

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这可以防止用户在对话已推进时盯着已解决的选择。当下一个视觉问题出现时，照常推送一个新的内容文件。

6. 重复直到完成。

## 编写内容片段

只编写页面内部的内容。服务器会自动将其包裹在框架模板中（头部、主题 CSS、选择指示器和所有交互式基础设施）。

**最小示例：**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

就这样。不需要 `<html>`、CSS 或 `<script>` 标签。服务器会提供所有这些。

## 可用的 CSS 类

框架模板为你的内容提供以下 CSS 类：

### 选项（A/B/C 选择）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**多选：** 在容器上添加 `data-multiselect` 以允许用户选择多个选项。每次点击切换该项。指示器条会显示计数。

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### 卡片（视觉设计）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### 模型容器

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### 分屏视图（并排）

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### 优缺点

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### 模型元素（线框图构建块）

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 排版和分区

- `h2` — 页面标题
- `h3` — 分区标题
- `.subtitle` — 标题下方的次要文字
- `.section` — 带底部边距的内容块
- `.label` — 小型大写标签文字

## 浏览器事件格式

当用户在浏览器中点击选项时，他们的交互会被记录到 `$STATE_DIR/events`（每行一个 JSON 对象）。当你推送新屏幕时，文件会自动清除。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流显示了用户的探索路径——他们可能在确定之前点击多个选项。最后的 `choice` 事件通常是最终选择，但点击的模式可以揭示犹豫或值得询问的偏好。

如果 `$STATE_DIR/events` 不存在，则用户没有与浏览器交互——仅使用他们的终端文字。

## 设计提示

- **保真度与问题匹配** — 布局用线框图，润色问题用润色
- **在每个页面上解释问题** — "哪个布局感觉更专业？"而不仅仅是"选一个"
- **先迭代再推进** — 如果反馈改变了当前屏幕，编写新版本
- **每屏最多 2-4 个选项**
- **在重要时使用真实内容** — 对于摄影作品集，使用真实图片（Unsplash）。占位内容会掩盖设计问题。
- **保持模型简单** — 专注于布局和结构，而非像素完美的设计

## 文件命名

- 使用语义化名称：`platform.html`、`visual-style.html`、`layout.html`
- 永远不要重用文件名 — 每个屏幕必须是一个新文件
- 对于迭代：附加版本后缀，如 `layout-v2.html`、`layout-v3.html`
- 服务器按修改时间提供最新文件

## 清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果会话使用了 `--project-dir`，模型文件会持久化在 `.superpowers/brainstorm/` 中以供以后参考。只有 `/tmp` 中的会话在停止时会被删除。

## 参考

- 框架模板（CSS 参考）：`scripts/frame-template.html`
- 辅助脚本（客户端）：`scripts/helper.js`
