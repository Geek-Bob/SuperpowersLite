# 指针化派发 + 审查门控分流 实施计划

> 执行技能：`superpowers:subagent-driven-development`。进度**只翻 checkbox，不增删行**（防行号漂移）。

**目标：** 控制器只传指针不传内容；审查门控按交付物含不含可执行代码分流。

**Base SHA:** `b600953`

## Rulings

> **Ruling:** 用户裁定 code-review 只针对编码任务 — 整体 code-review 豁免，以整体 spec-review 通过（44/44）收口 — 2 个 bash 脚本未经独立质量审查的风险由本计划 T1 整体删除脚本而自动消解。

> **Ruling:** 造 `task-brief` / `review-package` 脚本的立论（省上下文）被「子代理自行 git diff + 按需 Read」以更低达成为 — 整体删除两脚本与 `.gitattributes`，改为规则表述 — 代价是丢弃 89 行代码与 3 处缺陷（N 参数、CRLF、与 implementer-prompt 自相矛盾）。

> **Ruling:** 纯 checkbox 翻转不改变行号，但新增「完成」行会漂移行号 — 进度只翻 checkbox、不增删行 — 派发行号用 `grep -n "^### Task N:"` 现场解析，不硬编码。

## 执行分层

| 层级 | 任务 | 依赖 | 可并行 |
|:----:|------|------|:------:|
| L0 | Task 1: 指针化派发 | 无 | — |
| L1 | Task 2: 审查门控分流 + 遗留收口 | Task 1 | — |

> T1 与 T2 争 `subagent-driven-development/SKILL.md` → **必须串行**。

---

### Task 1: 指针化派发

**Produces：** 指针化派发契约 / 无开场白契约 / 禁止嵌套派发 / ONE fix dispatch / 计划格式三节
**Consumes：** 无

**文件：**
- 删除：`skills/subagent-driven-development/scripts/task-brief`
- 删除：`skills/subagent-driven-development/scripts/review-package`
- 删除：`skills/subagent-driven-development/scripts/`（目录）
- 删除：`.gitattributes`（根，仅为脚本服务）
- 修改：`skills/subagent-driven-development/SKILL.md`
- 修改：`skills/subagent-driven-development/implementer-prompt.md`
- 修改：`skills/subagent-driven-development/spec-reviewer-prompt.md`
- 修改：`skills/writing-plans/SKILL.md`

**验收标准：**
- [x] 两脚本与 `.gitattributes` 删除，全仓库无残留引用（Grep 验证）
- [x] 指针化派发契约：派发仅含 路径 + `offset`/`limit` + 额外约束 + 报告路径；禁止粘贴任务全文、会话历史、前序摘要、整份计划
- [x] 行号解析约定：派发时 `grep -n "^### Task N:"` 现场取行号；进度只翻 checkbox、不增删行（写明防行号漂移的理由）
- [x] diff 获取协议：子代理自跑 `git diff --stat BASE..HEAD` 看全景 → 按文件 `git diff -- <path>` 分批读；禁止控制器粘 diff；禁止 `HEAD~1` 当 BASE
- [x] 报告契约：详细内容落 report 文件；返回仅 4 项（状态 / commit / 一行测试摘要 / 顾虑）
- [x] 无开场白契约（审查员与实现者通用）：第一行直接给结论；每行=结论 / 带 file:line 的发现 / 跑过的检查；无开场白、无过程叙述、无收尾总结
- [x] 禁止嵌套派发：实现者与审查员均不得再派子代理（写明理由：重复审查席位 + 上下文树爆炸）
- [x] ONE fix dispatch：整体审查全部 finding 一次派一个修复者
- [x] `writing-plans/SKILL.md` 计划格式补三节：`## Global Constraints`（逐字精确值）、`## 文件结构映射`（改哪些文件、各职责）、`## Review Focus`（5 类最易咬人的输入/失效模式 + 归属任务）
- [x] Rulings 三触发场景与禁止 Ledger 表述保持不变

**步骤：** RED（列出会被删脚本引用破坏的表述）→ GREEN（删脚本+改引用为规则）→ REFACTOR（消除重复、与 implementer-prompt 自相矛盾处）

---

### Task 2: 审查门控分流 + 遗留收口

**Produces：** 审查门控分流规则
**Consumes：** Task 1 的 `subagent-driven-development/SKILL.md`

**文件：**
- 修改：`skills/subagent-driven-development/SKILL.md`
- 修改：`CLAUDE.md`
- 修改：`README.md`
- 修改：`README.en.md`
- 修改：`skills/using-superpowers/SKILL.md`

**验收标准：**
- [x] 分流规则：需求侧 `spec-review` 永远跑；质量侧 `code-review` 仅当交付物含可执行代码时跑，且只审代码部分
- [x] 纯文档/技能任务明确写「跳过 code-review」并写明理由
- [x] 「两道关卡互补」表改为分流表述，清除「必须双审查」绝对措辞
- [x] `CLAUDE.md` / 双 README 的「整体双审查」描述同步分流
- [x] `skills/using-superpowers/SKILL.md` 流程图错误边修正（Bounded 不派子代理，不得接到「子代理强制加载 TDD」）
- [x] `CLAUDE.md`「单一执行路径」加限定「（计划执行阶段）」
- [x] 模型选择节补：轮次比 token 价更重要（最便宜模型常跑 2–3 倍轮次反而更贵；审查员与「从散文描述实现」的实现者用中档做地板）
- [x] 补 Prompt Caching 提示：派发保持前缀稳定，命中计费仅 10%

**步骤：** RED（列出四份文档与 SDD 中「必须双审查」绝对措辞）→ GREEN（改分流）→ REFACTOR（四份文档交叉核对互不矛盾）

---

## 牢记

- 全简体中文；技术术语（TDD、Ruling、spec-review、code-review、checkbox、offset/limit、Prompt Caching 等）保留英文
- 保留 Lite 独有优势：契约优先、Produces/Consumes→DAG 分层、ASCII→Mermaid 双阶段、设计文档锚点、任务级零独立审查、计划不含实现代码
- **不引入**：完整 Ledger、修复循环 + scoped re-review、`diagnosing-superpowers`、恢复 `executing-plans`、任何脚本
