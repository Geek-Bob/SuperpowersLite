# 根本原因追踪

## 概述

Bug 通常在调用栈深处表现出来（在错误的目录中执行 `git init`、在错误的位置创建文件、数据库使用了错误的路径打开）。你的本能是在错误出现的地方去修复，但那只是在治疗症状。

**核心原则：** 沿着调用链向上回溯，直到找到最初的触发点，然后在源头修复。

## 何时使用

```dot
digraph when_to_use {
    "Bug 出现在调用栈深处？" [shape=diamond];
    "能否向上回溯？" [shape=diamond];
    "在症状点修复" [shape=box];
    "追踪到最初触发点" [shape=box];
    "更佳：同时添加纵深防御" [shape=box];

    "Bug 出现在调用栈深处？" -> "能否向上回溯？" [label="是"];
    "能否向上回溯？" -> "追踪到最初触发点" [label="是"];
    "能否向上回溯？" -> "在症状点修复" [label="否 - 死胡同"];
    "追踪到最初触发点" -> "更佳：同时添加纵深防御";
}
```

**适用场景：**
- 错误发生在执行深处（而不是入口点）
- 堆栈跟踪显示很长的调用链
- 不清楚无效数据从何而来
- 需要找出是哪个测试/代码触发了问题

## 追踪过程

### 1. 观察症状
```
Error: git init failed in ~/project/packages/core
```

### 2. 找出直接原因
**哪段代码直接导致了这个问题？**
```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. 追问：谁调用了它？
```typescript
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → 被 Session.initializeWorkspace() 调用
  → 被 Session.create() 调用
  → 被 Project.create() 处的测试调用
```

### 4. 继续向上追踪
**传入的值是什么？**
- `projectDir = ''`（空字符串！）
- 以空字符串作为 `cwd` 会解析为 `process.cwd()`
- 那就是源码目录！

### 5. 找到最初触发点
**空字符串从哪里来的？**
```typescript
const context = setupCoreTest(); // 返回 { tempDir: '' }
Project.create('name', context.tempDir); // 在 beforeEach 之前访问！
```

## 添加堆栈跟踪

当你无法手动追踪时，可以添加插桩代码：

```typescript
// 在问题操作之前
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**关键点：** 在测试中使用 `console.error()`（不要用 logger - 可能不显示）

**运行并捕获：**
```bash
npm test 2>&1 | grep 'DEBUG git init'
```

**分析堆栈跟踪：**
- 查找测试文件名
- 找到触发调用的行号
- 识别模式（同一个测试？同一个参数？）

## 找出造成污染的测试

如果某样东西在测试期间出现，但你不知道是哪个测试造成的：

使用本目录中的二分查找脚本 `find-polluter.sh`：

```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
```

逐个运行测试，在第一个污染源处停止。详见脚本用法。

## 实际示例：空的 projectDir

**症状：** 在 `packages/core/`（源代码）中创建了 `.git`

**追踪链：**
1. `git init` 在 `process.cwd()` 中运行 ← cwd 参数为空
2. WorktreeManager 被传入了空的 projectDir
3. Session.create() 传入了空字符串
4. 测试在 beforeEach 之前访问了 `context.tempDir`
5. setupCoreTest() 初始返回 `{ tempDir: '' }`

**根本原因：** 顶层变量初始化时访问了空值

**修复：** 将 tempDir 改为 getter，如果在 beforeEach 之前访问则抛出异常

**同时添加了纵深防御：**
- 第 1 层：Project.create() 验证目录
- 第 2 层：WorkspaceManager 验证不为空
- 第 3 层：NODE_ENV 守卫拒绝在 tmpdir 之外执行 git init
- 第 4 层：在 git init 之前进行堆栈跟踪日志记录

## 核心原则

```dot
digraph principle {
    "找到直接原因" [shape=ellipse];
    "能否向上追踪一层？" [shape=diamond];
    "向上回溯" [shape=box];
    "这是源头吗？" [shape=diamond];
    "在源头修复" [shape=box];
    "在每一层添加验证" [shape=box];
    "Bug 不可能发生" [shape=doublecircle];
    "绝对不要只修复症状" [shape=octagon, style=filled, fillcolor=red, fontcolor=white];

    "找到直接原因" -> "能否向上追踪一层？";
    "能否向上追踪一层？" -> "向上回溯" [label="是"];
    "能否向上追踪一层？" -> "绝对不要只修复症状" [label="否"];
    "向上回溯" -> "这是源头吗？";
    "这是源头吗？" -> "向上回溯" [label="否 - 继续追踪"];
    "这是源头吗？" -> "在源头修复" [label="是"];
    "在源头修复" -> "在每一层添加验证";
    "在每一层添加验证" -> "Bug 不可能发生";
}
```

**绝对不要只修复错误出现的地方。** 向上回溯找到最初的触发点。

## 堆栈跟踪技巧

**在测试中：** 使用 `console.error()` 而不是 logger - logger 可能被抑制
**在操作之前：** 在危险操作之前记录日志，而不是在失败之后
**包含上下文：** 目录、cwd、环境变量、时间戳
**捕获堆栈：** `new Error().stack` 显示完整的调用链

## 实际影响

来自调试会话（2025-10-03）：
- 通过 5 层追踪找到根本原因
- 在源头修复（getter 验证）
- 添加了 4 层防御
- 1847 个测试通过，零污染
