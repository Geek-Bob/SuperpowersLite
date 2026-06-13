# 测试反模式

**在以下情况加载本参考文档：** 编写或修改测试、添加 mock 的时候，或者想往生产代码中添加仅供测试使用的方法时。

## 概述

测试必须验证真实的行为，而不是 mock 的行为。Mock 是用于隔离的手段，而不是被测试的对象。

**核心原则：** 测试代码做了什么，而不是 mock 做了什么。

**严格遵循 TDD 可以避免这些反模式。**

## 铁律

```
1. 永远不要测试 mock 的行为
2. 永远不要在生产类中添加仅供测试使用的方法
3. 永远不要在不理解依赖关系的情况下使用 mock
```

## 反模式 1：测试 Mock 的行为

**违规示例：**
```typescript
// ❌ 错误：测试 mock 是否存在
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**为什么这是错误的：**
- 你在验证 mock 是否工作，而不是组件是否工作
- 当 mock 存在时测试通过，不存在时失败
- 完全没有告诉你关于真实行为的任何信息

**你的人类伙伴的纠正：** "我们是在测试 mock 的行为吗？"

**修正方法：**
```typescript
// ✅ 正确：测试真实组件或不 mock 它
test('renders sidebar', () => {
  render(<Page />);  // 不要 mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// 或者如果 sidebar 必须被 mock 以实现隔离：
// 不要对 mock 进行断言 - 测试 Page 在 sidebar 存在时的行为
```

### 门控函数

```
在对任何 mock 元素进行断言之前：
  问自己："我是在测试真实组件的行为，还是仅仅在测试 mock 的存在？"

  如果是在测试 mock 的存在：
    停止 - 删除该断言或取消对组件的 mock

  改为测试真实行为
```

## 反模式 2：生产代码中的仅供测试使用的方法

**违规示例：**
```typescript
// ❌ 错误：destroy() 仅在测试中使用
class Session {
  async destroy() {  // 看起来像生产 API！
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... 清理
  }
}

// 在测试中
afterEach(() => session.destroy());
```

**为什么这是错误的：**
- 生产类被仅供测试的代码污染了
- 如果在生产环境中被意外调用会很危险
- 违反了 YAGNI 原则和关注点分离
- 混淆了对象生命周期和实体生命周期

**修正方法：**
```typescript
// ✅ 正确：测试工具处理测试清理工作
// Session 没有 destroy() - 它在生产中是无状态的

// 在 test-utils/ 中
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// 在测试中
afterEach(() => cleanupSession(session));
```

### 门控函数

```
在向生产类添加任何方法之前：
  问自己："这是否只被测试使用？"

  如果是：
    停止 - 不要添加它
    改为放在测试工具中

  问自己："这个类是否拥有此资源的生命周期？"

  如果不是：
    停止 - 这个方法不属于这个类
```

## 反模式 3：在不理解的情况下使用 Mock

**违规示例：**
```typescript
// ❌ 错误：Mock 破坏了测试逻辑
test('detects duplicate server', () => {
  // Mock 阻止了测试依赖的 config 写入！
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // 应该抛出异常 - 但不会！
});
```

**为什么这是错误的：**
- 被 mock 的方法具有测试所依赖的副作用（写入 config）
- 为了"安全"而过度 mock 会破坏实际行为
- 测试因错误的原因通过或以神秘的方式失败

**修正方法：**
```typescript
// ✅ 正确：在正确的层级进行 mock
test('detects duplicate server', () => {
  // Mock 慢的部分，保留测试需要的行为
  vi.mock('MCPServerManager'); // 仅 mock 慢的服务器启动

  await addServer(config);  // Config 已写入
  await addServer(config);  // 检测到重复 ✓
});
```

### 门控函数

```
在对任何方法进行 mock 之前：
  停止 - 先不要 mock

  1. 问："真实的方法有什么副作用？"
  2. 问："这个测试是否依赖于这些副作用中的任何一个？"
  3. 问："我是否完全理解了这个测试需要什么？"

  如果依赖于副作用：
    在更低的层级进行 mock（实际的慢速/外部操作）
    或使用保留必要行为的测试替身
    而不是在测试所依赖的高层级方法

  如果不确定测试依赖什么：
    首先使用真实实现运行测试
    观察实际需要发生什么
    然后在正确的层级添加最小的 mock

  危险信号：
    - "我会 mock 它以防万一"
    - "这可能很慢，最好 mock 它"
    - 在不理解依赖链的情况下进行 mock
```

## 反模式 4：不完整的 Mock

**违规示例：**
```typescript
// ❌ 错误：部分 mock - 只有你认为需要的字段
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // 缺少：下游代码使用的 metadata
};

// 之后：当代码访问 response.metadata.requestId 时会中断
```

**为什么这是错误的：**
- **部分 mock 隐藏了结构假设** - 你只 mock 了你知道的字段
- **下游代码可能依赖于你未包含的字段** - 静默失败
- **测试通过但集成失败** - Mock 不完整，真实 API 完整
- **虚假的信心** - 测试没有证明关于真实行为的任何东西

**铁律规则：** Mock 真实存在的数据结构的完整内容，而不仅仅是你当前测试使用的字段。

**修正方法：**
```typescript
// ✅ 正确：镜像真实 API 的完整性
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // 真实 API 返回的所有字段
};
```

### 门控函数

```
在创建 mock 响应之前：
  检查："真实 API 响应包含哪些字段？"

  操作：
    1. 检查来自文档/示例的实际 API 响应
    2. 包含系统下游可能使用的所有字段
    3. 验证 mock 完全匹配真实响应结构

  关键：
    如果你正在创建 mock，你必须理解整个结构
    当代码依赖于被省略的字段时，部分 mock 会静默失败

  如果不确定：包含所有已文档化的字段
```

## 反模式 5：将集成测试视为事后补充

**违规示例：**
```
✅ 实现完成
❌ 没有编写测试
"准备好测试了"
```

**为什么这是错误的：**
- 测试是实现的一部分，不是可选的后续步骤
- TDD 本可以避免这种情况
- 没有测试就不能声称完成

**修正方法：**
```
TDD 循环：
1. 编写失败的测试
2. 实现以通过测试
3. 重构
4. 然后才能声称完成
```

## 当 Mock 变得过于复杂时

**警告信号：**
- Mock 设置比测试逻辑还长
- 为了让测试通过而 mock 一切
- Mock 缺少真实组件具有的方法
- 当 mock 改变时测试中断

**你的人类伙伴的问题：** "我们真的需要在这里使用 mock 吗？"

**考虑：** 使用真实组件的集成测试通常比复杂的 mock 更简单

## TDD 防止这些反模式

**为什么 TDD 有帮助：**
1. **先写测试** → 强迫你思考你真正在测试什么
2. **观察它失败** → 确认测试的是真实行为而不是 mock
3. **最小化实现** → 不会让仅供测试使用的方法潜入
4. **真实依赖** → 在 mock 之前看到测试实际需要什么

**如果你在测试 mock 的行为，你违反了 TDD** —— 你在没有先针对真实代码观察测试失败的情况下添加了 mock。

## 快速参考

| 反模式 | 修正方法 |
|--------------|-----|
| 对 mock 元素进行断言 | 测试真实组件或取消 mock |
| 生产代码中的仅供测试使用的方法 | 移至测试工具 |
| 在不理解的情况下使用 mock | 首先理解依赖，最小化 mock |
| 不完整的 mock | 完整地镜像真实 API |
| 测试作为事后补充 | TDD - 测试先行 |
| 过度复杂的 mock | 考虑使用集成测试 |

## 危险信号

- 断言检查 `*-mock` 测试 ID
- 仅在测试文件中被调用的方法
- Mock 设置占测试的 50% 以上
- 当你移除 mock 时测试失败
- 无法解释为什么需要 mock
- "只是为了安全"而进行 mock

## 核心要点

**Mock 是用于隔离的工具，而不是被测试的对象。**

如果 TDD 揭示了你在测试 mock 的行为，那你已经走偏了。

修正：测试真实行为，或者反思你为什么要使用 mock。
