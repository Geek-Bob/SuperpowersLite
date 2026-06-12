# 测试反模式

**何时加载此参考：** 编写或修改测试、添加 mock、或想给生产代码加仅供测试的方法时。

## 概述

测试必须验证真实行为，而非 mock 行为。Mock 是隔离手段，不是被测试的东西。

**核心原则：** 测试代码做了什么，而非 mock 做了什么。

**严格遵循 TDD 可以防止这些反模式。**

## 铁律

```
1. 绝不测试 mock 行为
2. 绝不向生产类添加仅供测试的方法
3. 绝不在不理解依赖的情况下 mock
```

## 反模式 1：测试 Mock 行为

**违规：**
```typescript
// ❌ 坏：测试 mock 存在
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**为什么错：**
- 你在验证 mock 工作，而非组件工作
- mock 存在时测试通过，不存在时失败
- 对真实行为没有任何信息

**你的用户伙伴的纠正：** "我们是在测试一个 mock 的行为吗？"

**修复：**
```typescript
// ✅ 好：测试真实组件，或不要 mock 它
test('renders sidebar', () => {
  render(<Page />);  // 不要 mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// 或如果 sidebar 必须 mock 以隔离：
// 不要断言 mock —— 测试 Page 在 sidebar 存在时的行为
```

### 门控函数

```
对任何 mock 元素做断言之前：
  问："我是在测试真实组件行为还是 mock 存在？"

  如果测试 mock 存在：
    停止 —— 删除断言或取消 mock 组件

  改为测试真实行为
```

## 反模式 2：生产代码中的仅供测试方法

**违规：**
```typescript
// ❌ 坏：destroy() 仅用于测试
class Session {
  async destroy() {  // 看起来像生产 API！
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... 清理
  }
}

// 测试中
afterEach(() => session.destroy());
```

**为什么错：**
- 生产类被仅供测试的代码污染
- 如果在生产环境意外调用则危险
- 违反 YAGNI 和关注点分离
- 混淆对象生命周期和实体生命周期

**修复：**
```typescript
// ✅ 好：测试工具处理测试清理
// Session 没有 destroy() —— 在生产中它是无状态的

// 在 test-utils/ 中
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// 测试中
afterEach(() => cleanupSession(session));
```

### 门控函数

```
向生产类添加任何方法之前：
  问："这是否仅用于测试？"

  如果是：
    停止 —— 不要加
    改为放入测试工具

  问："这个类是否拥有此资源的生命周期？"

  如果否：
    停止 —— 这个方法不应该在这个类中
```

## 反模式 3：不理解就 Mock

**违规：**
```typescript
// ❌ 坏：Mock 破坏了测试依赖的逻辑
test('detects duplicate server', () => {
  // Mock 阻止了测试依赖的配置写入！
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // 应该抛出 —— 但不会！
});
```

**为什么错：**
- Mock 的方法有测试依赖的副作用（写配置）
- "为了安全"过度 mock 破坏了实际行为
- 测试因错误原因通过或神秘失败

**修复：**
```typescript
// ✅ 好：在正确层级 mock
test('detects duplicate server', () => {
  // Mock 慢的部分，保留测试需要的行为
  vi.mock('MCPServerManager'); // 只 mock 慢的服务器启动

  await addServer(config);  // 配置写入
  await addServer(config);  // 检测到重复 ✓
});
```

### 门控函数

```
Mock 任何方法之前：
  停止 —— 先不要 mock

  1. 问："真实方法有哪些副作用？"
  2. 问："此测试是否依赖这些副作用？"
  3. 问："我是否完全理解此测试需要什么？"

  如果依赖副作用：
    在更低层级 mock（实际慢/外部操作）
    或使用保留必要行为的测试替身
    而非测试依赖的高层方法

  如果不确定测试依赖什么：
    先用真实实现运行测试
    观察实际需要发生什么
    然后在正确层级添加最小 mock

  红旗：
    - "我 mock 这个为了安全"
    - "这个可能慢，最好 mock 掉"
    - 不理解依赖链就 mock
```

## 反模式 4：不完整的 Mock

**违规：**
```typescript
// ❌ 坏：部分 mock —— 只包含你认为需要的字段
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // 缺失：下游代码使用的 metadata
};

// 后来：代码访问 response.metadata.requestId 时崩溃
```

**为什么错：**
- **部分 mock 隐藏结构假设** —— 你只 mock 你知道的字段
- **下游代码可能依赖你没包含的字段** —— 静默失败
- **测试通过但集成失败** —— mock 不完整，真实 API 完整
- **虚假信心** —— 测试对真实行为什么也没证明

**铁律：** Mock 真实存在的完整数据结构，而非仅你当前测试用的字段。

**修复：**
```typescript
// ✅ 好：镜像真实 API 的完整性
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // 真实 API 返回的所有字段
};
```

### 门控函数

```
创建 mock 响应之前：
  检查："真实 API 响应包含哪些字段？"

  操作：
    1. 从文档/示例中检查实际 API 响应
    2. 包含系统下游可能消费的所有字段
    3. 验证 mock 完全匹配真实响应结构

  关键：
    如果你在创建 mock，必须理解整个结构
    部分 mock 在代码依赖被省略字段时静默失败

  如果不确定：包含所有文档中的字段
```

## 反模式 5：集成测试作为事后补充

**违规：**
```
✅ 实现完成
❌ 没有写测试
"可以测试了"
```

**为什么错：**
- 测试是实现的一部分，不是可选的后续
- TDD 会捕获这个问题
- 没有测试不能声称完成

**修复：**
```
TDD 循环：
1. 写失败测试
2. 实现使其通过
3. 重构
4. 然后才能声称完成
```

## 当 Mock 变得过于复杂时

**警告信号：**
- Mock setup 比测试逻辑还长
- Mock 一切使测试通过
- Mock 缺少真实组件的方法
- Mock 变更时测试崩溃

**你的用户伙伴的问题：** "我们这里需要用到 mock 吗？"

**考虑：** 使用真实组件的集成测试通常比复杂 mock 更简单

## TDD 防止这些反模式

**为什么 TDD 有帮助：**
1. **先写测试** → 强迫你思考实际在测什么
2. **看着它失败** → 确认测试在测真实行为，而非 mock
3. **最小实现** → 仅供测试的方法无法潜入
4. **真实依赖** → 你在 mock 前看到测试实际需要什么

**如果你在测试 mock 行为，你违反了 TDD** —— 你在没有先用真实代码看到测试失败的情况下加了 mock。

## 快速参考

| 反模式 | 修复 |
|--------|------|
| 断言 mock 元素 | 测试真实组件或取消 mock |
| 生产代码中的仅供测试方法 | 移到测试工具 |
| 不理解就 mock | 先理解依赖，最小化 mock |
| 不完整的 mock | 完全镜像真实 API |
| 测试作为事后补充 | TDD —— 测试先行 |
| 过于复杂的 mock | 考虑集成测试 |

## 红旗

- 断言检查 `*-mock` 测试 ID
- 方法仅在测试文件中调用
- Mock setup 超过测试的 50%
- 移除 mock 后测试失败
- 解释不了为什么需要 mock
- "为了安全"而 mock

## 底线

**Mock 是隔离工具，不是被测试的东西。**

如果 TDD 揭示你在测试 mock 行为，你走偏了。

修复：测试真实行为，或质疑为什么需要 mock。
