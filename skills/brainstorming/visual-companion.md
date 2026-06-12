# 可视化伴侣指南

基于浏览器的可视化头脑风暴伴侣，用于展示原型、图表和选项。

## 何时使用

逐个问题决策，而非按会话。测试标准：**用户通过看比通过读能更好地理解这个内容吗？**

**使用浏览器**处理真正可视化的内容：

- **UI 原型** — 线框图、布局、导航结构、组件设计
- **架构图** — 系统组件、数据流、关系图
- **并排视觉对比** — 两种布局、配色方案、设计方向对比
- **设计润色** — 外观和感觉、间距、视觉层次
- **空间关系** — 状态机、流程图、实体关系图

**使用终端**处理文本或表格内容：

- **需求和范围问题** — "X 是什么意思？"、"哪些功能在范围内？"
- **概念性 A/B/C 选择** — 在文字描述的方案中做选择
- **权衡列表** — 优缺点、对比表
- **技术决策** — API 设计、数据建模、架构方案选择
- **澄清问题** — 任何答案靠文字而非视觉偏好的问题

关于 UI 话题的问题并不自动等于可视化问题。"你想要哪种向导？"是概念问题——用终端。"这些向导布局哪个感觉对？"是可视化问题——用浏览器。

## 工作原理

服务器监听一个目录中的 HTML 文件，将最新的文件推送到浏览器。你将 HTML 内容写入 `screen_dir`，用户在浏览器中看到并可点击选择选项。选择结果记录到 `state_dir/events`，下一回合读取。

**内容片段 vs 完整文档：** HTML 文件以 `<!DOCTYPE` 或 `<html` 开头时，服务器直接返回（仅注入 helper 脚本）。否则服务器自动将内容包装到 frame 模板中——添加 header、CSS 主题、选择指示器和所有交互基础设施。**默认写内容片段。** 只在需要完全控制页面时才写完整文档。

## 启动会话

```bash
# 启动服务器（持久化模式，原型保存到项目目录）
scripts/start-server.sh --project-dir /path/to/project

# 返回：{"type":"server-started","port":52341,"url":"http://localhost:52341",
#         "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#         "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

保存返回的 `screen_dir` 和 `state_dir`。告诉用户打开 URL。

**查找连接信息：** 服务器将启动 JSON 写入 `$STATE_DIR/server-info`。如果后台启动了服务器但未捕获 stdout，读取该文件获取 URL 和端口。使用 `--project-dir` 时，检查 `<project>/.superpowers/brainstorm/` 目录。

**注意：** 传入项目根目录作为 `--project-dir`，使原型持久化到 `.superpowers/brainstorm/`，服务器重启后不丢失。不加此参数则文件写入 `/tmp` 并在停止时清理。提醒用户将 `.superpowers/` 加入 `.gitignore`。

**各平台启动方式：**

**Claude Code（macOS / Linux）：**
```bash
# 默认模式即可——脚本自动后台运行
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code（Windows）：**
```bash
# Windows 自动检测并使用前台模式，会阻塞工具调用。
# 在 Bash 工具调用上设置 run_in_background: true 使服务器跨回合存活。
scripts/start-server.sh --project-dir /path/to/project
```
通过 Bash 工具调用时设置 `run_in_background: true`。下一回合读取 `$STATE_DIR/server-info` 获取 URL 和端口。

**Codex：**
```bash
# Codex 会回收后台进程。脚本自动检测 CODEX_CI 并切换到前台模式。
# 正常运行——无需额外参数。
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI：**
```bash
# 使用 --foreground 并在 shell 工具调用上设置 is_background: true
# 使进程跨回合存活
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**其他环境：** 服务器必须跨会话回合保持后台运行。如果环境回收分离的进程，使用 `--foreground` 并以平台的 background 机制启动命令。

如果 URL 从浏览器不可达（常见于远程/容器环境），绑定非回环地址：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

使用 `--url-host` 控制返回 JSON 中打印的主机名。

## 循环

1. **检查服务器存活**，然后**写入 HTML** 到 `screen_dir` 中的新文件：
   - 每次写入前检查 `$STATE_DIR/server-info` 是否存在。如果不存在（或 `$STATE_DIR/server-stopped` 存在），服务器已关闭——继续前用 `start-server.sh` 重启。服务器在 30 分钟无活动后自动退出。
   - 使用语义化文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **禁止复用文件名**——每屏一个新文件
   - 使用 Write 工具——**禁止用 cat/heredoc**（会往终端倾倒噪音）
   - 服务器自动提供最新文件

2. **告诉用户预期内容并结束回合：**
   - 提醒 URL（每步都提醒，不仅是第一次）
   - 给出屏幕上内容的简短摘要（如："展示首页的 3 种布局方案"）
   - 让他们在终端回复："看一下，告诉我你的想法。可以点击选择选项。"

3. **下一回合**——用户回复后：
   - 读取 `$STATE_DIR/events`（如果存在）——包含用户的浏览器交互（点击、选择）JSON 行
   - 与用户终端文本合并获取完整信息
   - 终端消息是主要反馈；`state_dir/events` 提供结构化交互数据

4. **迭代或推进**——如果反馈改变当前屏幕，写新文件（如 `layout-v2.html`）。只在当前步骤确认后进入下一个问题。

5. **回到终端时卸载**——当下一步不需要浏览器（如澄清问题、权衡讨论），推送等待屏幕清除过期内容：

   ```html
   <!-- 文件名：waiting.html（或 waiting-2.html 等） -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">正在终端中继续……</p>
   </div>
   ```

   防止用户在已解决的选项上发呆而会话已经推进。当下一个可视化问题到来时，正常推送新内容文件。

6. 重复直到完成。

## 写内容片段

只写放入页面内部的内容。服务器自动包装到 frame 模板中（header、主题 CSS、选择指示器及所有交互基础设施）。

**最小示例：**

```html
<h2>哪种布局更好？</h2>
<p class="subtitle">考虑可读性和视觉层次</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>单栏</h3>
      <p>干净、专注的阅读体验</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>双栏</h3>
      <p>侧边导航 + 主内容区</p>
    </div>
  </div>
</div>
```

就这些。不需要 `<html>`、CSS、`<script>` 标签。服务器提供全部。

## 可用 CSS 类

frame 模板为你的内容提供以下 CSS 类：

### 选项（A/B/C 选择）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>标题</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

**多选：** 在容器上添加 `data-multiselect` 允许用户选择多个选项。每次点击切换选中状态。指示栏显示选中数量。

```html
<div class="options" data-multiselect>
  <!-- 同样的 option 标记——用户可选择/取消选择多项 -->
</div>
```

### 卡片（视觉设计）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- 原型内容 --></div>
    <div class="card-body">
      <h3>名称</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

### 原型容器

```html
<div class="mockup">
  <div class="mockup-header">预览：仪表盘布局</div>
  <div class="mockup-body"><!-- 你的原型 HTML --></div>
</div>
```

### 分屏视图（并排）

```html
<div class="split">
  <div class="mockup"><!-- 左 --></div>
  <div class="mockup"><!-- 右 --></div>
</div>
```

### 优缺点

```html
<div class="pros-cons">
  <div class="pros"><h4>优点</h4><ul><li>好处</li></ul></div>
  <div class="cons"><h4>缺点</h4><ul><li>不足</li></ul></div>
</div>
```

### 原型元素（线框图构建块）

```html
<div class="mock-nav">Logo | 首页 | 关于 | 联系</div>
<div style="display: flex;">
  <div class="mock-sidebar">导航</div>
  <div class="mock-content">主内容区</div>
</div>
<button class="mock-button">操作按钮</button>
<input class="mock-input" placeholder="输入框">
<div class="placeholder">占位区域</div>
```

### 排版和分区

- `h2` — 页面标题
- `h3` — 分区标题
- `.subtitle` — 标题下方的辅助文字
- `.section` — 带底部边距的内容块
- `.label` — 小号大写标签文字

## 浏览器事件格式

用户点击浏览器中的选项时，交互记录到 `$STATE_DIR/events`（每行一个 JSON 对象）。推送新屏幕时文件自动清除。

```jsonl
{"type":"click","choice":"a","text":"选项 A - 简洁布局","timestamp":1706000101}
{"type":"click","choice":"c","text":"选项 C - 复杂网格","timestamp":1706000108}
{"type":"click","choice":"b","text":"选项 B - 混合方案","timestamp":1706000115}
```

完整事件流展示用户的探索路径——可能点击多个选项后才确定。最后一个 `choice` 事件通常是最终选择，但点击模式可以揭示值得追问的犹豫或偏好。

如果 `$STATE_DIR/events` 不存在，用户未与浏览器交互——只使用终端文本。

## 设计技巧

- **保真度匹配问题** — 线框图回答布局问题，精修图回答润色问题
- **每页解释问题** — "哪种布局感觉更专业？"而不是"选一个"
- **迭代再推进** — 如果反馈改变当前屏幕，写新版本
- **每屏 2-4 个选项**上限
- **需要时用真实内容** — 摄影作品集用真实图片（Unsplash）。占位内容掩盖设计问题。
- **原型保持简单** — 关注布局和结构，不是像素级设计

## 文件命名

- 使用语义化名称：`platform.html`、`visual-style.html`、`layout.html`
- 禁止复用文件名——每屏必须新文件
- 迭代版：加版本后缀如 `layout-v2.html`、`layout-v3.html`
- 服务器按修改时间提供最新文件

## 清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果会话使用了 `--project-dir`，原型文件持久化到 `.superpowers/brainstorm/` 供后续参考。只有 `/tmp` 会话在停止时删除。

## 参考

- Frame 模板（CSS 参考）：`scripts/frame-template.html`
- Helper 脚本（客户端）：`scripts/helper.js`
