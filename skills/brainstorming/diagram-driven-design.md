# 图表驱动设计规范

ASCII 框图 + Mermaid 图表的语法规范和示例。

## 两阶段图表策略

| 阶段 | 工具 | 目的 | 风格 |
|------|------|------|------|
| 交互阶段（展示设计） | ASCII 框图 | 和用户边讨论边澄清，快速迭代 | 随手画，可擦改 |
| 文档阶段（写设计文档） | Mermaid | 嵌入 Spec 正式呈现，可渲染可维护 | 规范完整，嵌入 markdown |

## 选图规则

怎么摆、怎么连 → ASCII 框图。怎么走、怎么变 → Mermaid。

| 项目类型 | 交互阶段（ASCII） | 文档阶段（Mermaid） |
|---------|------------------|-------------------|
| 🖥️ UI | ASCII 布局原型 | flowchart + stateDiagram |
| ⚙️ 后端/API | ASCII 架构图 | sequenceDiagram + erDiagram |
| 🔗 全栈 | ASCII 布局 + ASCII 架构 | flowchart + sequenceDiagram |
| 📐 契约层（所有项目） | — | classDiagram（类型 + 接口关系） |

## ASCII 框图

框线字符：`─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼`

### UI 布局原型

每个页面必须有一张。标注核心交互区域。多状态 UI 画出关键状态差异。

```
┌─────────────────────────────────────────┐
│            ⚡ 系统登录                    │
├─────────────────────────────────────────┤
│                                          │
│  ┌─ 用户名 ──────────────────────────┐  │
│  │ 请输入用户名                        │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ┌─ 密码 ────────────────────────────┐  │
│  │ ••••••••                   👁️     │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ☐ 记住密码                              │
│  ┌────────────────────────────────────┐  │
│  │            登  录                   │  │
│  └────────────────────────────────────┘  │
│                                          │
│  还没有账号？立即注册 →                   │
└─────────────────────────────────────────┘
```

### 架构图

标注模块名、端口、数据流向。箭头表达调用方向。

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   API        │────▶│   用户服务    │────▶│   PostgreSQL │
│   Gateway    │     │   :3001      │     │  用户库       │
│   :8080      │     └──────┬───────┘     └──────────────┘
└──────┬───────┘            │
       │            ┌───────┴───────┐     ┌──────────────┐
       └───────────▶│   订单服务     │────▶│   PostgreSQL │
                    │   :3002      │     │  订单库       │
                    └───────────────┘     └──────────────┘
```

### 组件树

层级缩进表达包含/依赖关系。

```
App
├── Header
│   ├── Logo
│   └── NavMenu
├── Main
│   └── Router
│       ├── HomePage
│       └── AboutPage
└── Footer
```

## Mermaid 图表

直接嵌入 markdown 代码块，GitHub 原生渲染。

### flowchart

覆盖正常路径 + 异常分支 + 边界条件。

```mermaid
flowchart TD
    A[用户打开页面] --> B{有缓存凭据?}
    B -->|是| C[自动填充表单]
    B -->|否| D[显示空白表单]
    C --> E[点击登录]
    D --> E
    E --> F{字段为空?}
    F -->|是| G[红色边框 + 抖动]
    G --> E
    F -->|否| H[登录成功]
    H --> I{记住密码?}
    I -->|是| J[存入 localStorage]
    I -->|否| K[清除 localStorage]
```

### sequenceDiagram

标注参与者和消息方向。覆盖成功和失败分支。

```mermaid
sequenceDiagram
    participant U as 用户
    participant B as 浏览器
    participant S as 服务器

    U->>B: 点击登录
    B->>S: POST /api/login
    alt 成功
        S-->>B: 200 {token}
        B->>U: 跳转首页
    else 失败
        S-->>B: 401
        B->>U: 显示错误提示
    end
```

### stateDiagram

覆盖所有关键状态和转换条件。

```mermaid
stateDiagram-v2
    [*] --> 空白表单
    空白表单 --> 填写中: 用户输入
    填写中 --> 验证中: 点击登录
    验证中 --> 错误态: 字段为空
    验证中 --> 成功态: 验证通过
    错误态 --> 填写中: 抖动结束
    成功态 --> [*]
```

### classDiagram

用于表达契约层：类型定义和模块接口关系。每个项目的设计文档必须包含此图。

```mermaid
classDiagram
    class IUser {
        +string id
        +string name
        +string email
        +string role
    }
    class Result~T~ {
        +boolean success
        +T data
        +string error
    }
    class IUserRepository {
        +findById(id: string) Promise~IUser~
        +create(data: CreateUserDTO) Promise~Result~IUser~~
    }
    class IUserService {
        +getUser(id: string) Promise~Result~IUser~~
        +createUser(data) Promise~Result~IUser~~
    }
    IUserRepository ..> IUser : 返回
    IUserService ..> Result : 返回
    IUserService ..> IUser : 返回
    IUserService ..> IUserRepository : 依赖
```
