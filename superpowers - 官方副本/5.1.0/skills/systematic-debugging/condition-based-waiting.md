# 基于条件的等待

## 概述

不稳定的测试经常使用任意的延迟来猜测时机。这会产生竞态条件，导致测试在快速机器上通过，但在负载下或在 CI 中失败。

**核心原则：** 等待你真正关心的实际条件，而不是猜测需要多长时间。

## 何时使用

```dot
digraph when_to_use {
    "测试使用了 setTimeout/sleep？" [shape=diamond];
    "正在测试时间相关行为？" [shape=diamond];
    "记录使用超时的原因" [shape=box];
    "使用基于条件的等待" [shape=box];

    "测试使用了 setTimeout/sleep？" -> "正在测试时间相关行为？" [label="是"];
    "正在测试时间相关行为？" -> "记录使用超时的原因" [label="是"];
    "正在测试时间相关行为？" -> "使用基于条件的等待" [label="否"];
}
```

**使用场景：**
- 测试存在任意延迟（`setTimeout`、`sleep`、`time.sleep()`）
- 测试不稳定（有时通过，负载下失败）
- 并行运行时测试超时
- 等待异步操作完成

**不要使用的场景：**
- 测试实际的时间相关行为（防抖、节流间隔）
- 如果使用任意超时，必须记录原因

## 核心模式

```typescript
// ❌ 之前：猜测时机
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// ✅ 之后：等待条件
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

## 快速模式参考

| 场景 | 模式 |
|----------|---------|
| 等待事件 | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| 等待状态 | `waitFor(() => machine.state === 'ready')` |
| 等待数量 | `waitFor(() => items.length >= 5)` |
| 等待文件 | `waitFor(() => fs.existsSync(path))` |
| 复杂条件 | `waitFor(() => obj.ready && obj.value > 10)` |

## 实现

通用轮询函数：
```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise(r => setTimeout(r, 10)); // 每 10ms 轮询一次
  }
}
```

本目录中的 `condition-based-waiting-example.ts` 提供了来自实际调试会话的完整实现，包含领域特定的辅助函数（`waitForEvent`、`waitForEventCount`、`waitForEventMatch`）。

## 常见错误

**❌ 轮询过快：** `setTimeout(check, 1)` - 浪费 CPU
**✅ 修复：** 每 10ms 轮询一次

**❌ 没有超时：** 如果条件永远不满足，循环将无限执行
**✅ 修复：** 始终包含超时并附带清晰的错误信息

**❌ 数据过期：** 在循环外缓存了状态
**✅ 修复：** 在循环内调用 getter 以获取最新数据

## 任意超时的正确使用场景

```typescript
// 工具每 100ms tick 一次 - 需要 2 个 tick 来验证部分输出
await waitForEvent(manager, 'TOOL_STARTED'); // 首先：等待条件
await new Promise(r => setTimeout(r, 200));   // 然后：等待时间相关行为
// 200ms = 100ms 间隔下的 2 个 tick - 已记录并有合理依据
```

**要求：**
1. 首先等待触发条件
2. 基于已知时间（而非猜测）
3. 添加注释说明原因

## 实际效果

来自调试会话（2025-10-03）：
- 在 3 个文件中修复了 15 个不稳定的测试
- 通过率：60% → 100%
- 执行时间：快了 40%
- 不再有竞态条件
