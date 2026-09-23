# Superpowers 官方借鉴落地 实施计划

> **给执行代理的说明：** 必须使用子技能 superpowers:subagent-driven-development 逐层实现此计划。验收标准使用 checkbox（`- [ ]`）语法跟踪。

**目标：** 从官方 Superpowers 借鉴「减负」类改进——三路径分类、测试核心原则、上下文脚本、Rulings 一行记录——并同步项目文档。

**架构：** 单向分层改造 4 处技能文件 + 1 处文档同步。L0 两项为独立技能内改造；L1 两项为执行层工具与格式契约；L2 为跨文档一致性同步。

**技术栈：** Markdown 技能文档 + Bash 脚本（bash/git/awk/sed）

**Base SHA:** `e8cc10fb2d6eb1eacf059213b4f569044ea77de8`

## Rulings

> **Ruling:** T3 与 T4 原同属 L1 且均修改 `subagent-driven-development/SKILL.md`，违反「同层任务修改不同文件」的并行前提 — 将 Rulings 触发时机并入 T3，T4 只负责 `writing-plans/SKILL.md` 的 Rulings 格式定义 — 文件归属互斥后 L1 可安全并行；若强行并行会丢失其中一方的编辑。

> **Ruling:** Task 2 报告计划散文写「30 行」与验收标准「≤60 行」冲突 — 以验收标准为准（约束性契约），散文「30 行」视为简写 — 交付 58 行有效；若强行压到 30 行须砍掉强制内容，与验收标准冲突。

> **Ruling:** Task 1 发现 `skills/using-superpowers/SKILL.md` 仍描述无条件线性链（brainstorming → writing-plans → subagent-driven-development），与三路径分类矛盾 — 该文件是 Task 1 计划未列全导致的缺陷，补入 Task 5 文件清单 — 不补则入口技能与 brainstorming 自相矛盾，三路径落地即失效。

> **Ruling:** T3 上报仓库 `core.autocrlf=true` 且无 `.gitattributes`，脚本检出后 shebang 变 `bash\r`，严格 env 下 bad interpreter — 该风险使 T3「Windows 兼容」验收标准实质不成立 — 增补根 `.gitattributes` 强制两脚本 `-text`（commit `062b8f8`）— 不补则脚本在严格 env 下无法执行，物理阻断失效。

> **Ruling:** T4 报 DONE 但改动未提交（`writing-plans/SKILL.md` 停在工作区）— 派修复者补提交（commit `bd8123b`）— 未提交等于未持久化，违反「实现+自审后立即提交」的 Per Task 流程。

> **Ruling:** T3 与 T4 各自提交时 git index 可能竞态 — 修复者与 T5 必须串行派发，不同层并行 — 并发 `git add/commit` 会互相丢暂存。

## 执行分层

> 同层任务修改不同文件且无依赖关系 → 可并行执行。

| 层级 | 任务 | 依赖 | 可并行 | Commit |
|:----:|------|------|:------:|
| L0 | Task 1: 三路径分类 | 无 | ✅ | `16dbd8d` |
| L0 | Task 2: 测试核心原则 | 无 | ✅ | `53e6b8c` |
| L1 | Task 3: 上下文脚本 + Rulings 触发 | Task 1 | ✅ | `f4c9471` |
| L1 | Task 4: Rulings 格式定义 | Task 1 | ✅ | `bd8123b` |
| L2 | Task 5: 项目文档同步 | Task 1,2,3,4 | — | 进行中 |
| 修复 | gitattributes + 补提交 | T3/T4 顾虑 | — | `062b8f8` |

---

### Task 1: 三路径分类

**目标：** 让小需求不必走完整 spec→plan→subagent 链路，按复杂度分档。

**设计文档索引：** 本计划「Task 1 验收标准」即规格来源（无独立设计文档，需求源自官方 `superpowers-main/skills/brainstorming/SKILL.md` 对比结论）。

**需求描述：**
在 `skills/brainstorming/SKILL.md` 中引入官方的三路径分类（Spike / Bounded / Architectural），使简单需求走轻量路径。同时把 HARD-GATE 从粗粒度的「设计批准前不得实现」细化为阶段级授权。保留 Lite 独有的 ASCII→Mermaid 双阶段图表、契约与接口、双审查（子代理结构质量 + Controller 需求一致性）。

**产出（Produces）：**
- 文件：`skills/brainstorming/SKILL.md`
- 概念：`Spike / Bounded / Architectural` 路径分类（被 Task 3/4/5 引用）

**消费（Consumes）：** 无

**文件：**
- 修改：`skills/brainstorming/SKILL.md`

**验收标准：**
- [x] 新增「三条路径」章节，含 Spike / Bounded / Architectural 判定条件与产出物对照表
- [x] 每条路径各一份检查清单（Spike 5 步 / Bounded 5 步 / Architectural 保留现有 10 步）
- [x] HARD-GATE 细化为阶段级授权：对话层批准只允许写 spec；书面 spec 批准才允许调用 writing-plans；一次回复只批准当前呈现的那个阶段，批准想法不等于批准尚不存在的工件
- [x] 新增三条硬规则：分类必须说出口 / 怀疑时走重的那条 / 中途发现复杂度只升不降
- [x] Red Flags 表补充路径逃逸条目（如「我把它算 bounded 免得走流程」「快做完了就不用重新分类了」）
- [x] Bounded 路径终点明确为「TDD 直接实现 + requesting-code-review」，不调用 writing-plans
- [x] Spike 路径终点明确为「输出结论 + 标注一次性产物」，不写文档、不提交要保留的代码
- [x] 保留 Lite 独有内容不被删减：ASCII→Mermaid 两阶段图表策略、契约与接口章节、双审查（子代理 + Controller）流程

**完成：** commit `16dbd8d`，状态 DONE_WITH_CONCERNS（顾虑见 Rulings）

**步骤：**
1. 通读现有 `skills/brainstorming/SKILL.md`，标注保留区与改造区
2. 编写「三条路径」章节与三份检查清单
3. 细化 HARD-GATE 为阶段级授权，补充三条硬规则
4. 扩充 Red Flags 表
5. 自审：对照验收标准逐条核对，检查与 Lite 独有内容无冲突
6. 提交

---

### Task 2: 测试核心原则

**目标：** 用正向规则替换纯反模式列表，堵住「测 mock 不测真」「镜像断言」等模型习惯性通病。

**设计文档索引：** 本计划「Task 2 验收标准」即规格来源。

**需求描述：**
用 30 行精简版的 `writing-good-tests.md` 替换现有的 `testing-anti-patterns.md`。内容取自官方 `superpowers-main/skills/test-driven-development/writing-good-tests.md` 的内核，但**不整篇搬运**——官方那篇约 200 行且含大量 TypeScript 示例，与 Lite「文档量精简」定位冲突。只保留两条原则、两个写前自检 Gate Function、一条收尾变异检查、三条反模式。

**产出（Produces）：**
- 文件：`skills/test-driven-development/writing-good-tests.md`（新建）
- 删除：`skills/test-driven-development/testing-anti-patterns.md`

**消费（Consumes）：** 无

**文件：**
- 创建：`skills/test-driven-development/writing-good-tests.md`
- 修改：`skills/test-driven-development/SKILL.md`
- 删除：`skills/test-driven-development/testing-anti-patterns.md`

**验收标准：**
- [x] `writing-good-tests.md` 含两条原则原文级表述（每个测试要能说出它捕获哪种破坏 / 每个测试要跑真实的东西）
- [x] 含写前自检一（写测试体之前）：说不出「哪处生产改动会让它失败」→ 重设计到可观察行为；失败原因只能是「源文本变了」→ 改成跑产物断言副作用；期望值由被测代码或其 helper 算出 → 改成手写常量或手工核对 fixture
- [x] 含写前自检二（加 mock 之前）：列出真实方法全部副作用，测试依赖的部分保持真实，只 mock 慢的/外部的那层；mock 响应镜像完整结构；只被测试调用的方法放测试工具类，不进生产类
- [x] 含一条收尾变异检查：改错常量、走错分支、丢掉副作用、返回默认值、丢掉校验——每一类现实变异至少一个测试挂掉
- [x] 含三条反模式：断言 mock 存在、给生产类加测试专用方法、不理解副作用就 mock
- [x] 全文 ≤ 60 行，无超过 4 行的代码示例（实际 58 行）
- [x] `SKILL.md` 中对 `testing-anti-patterns.md` 的引用全部替换为 `writing-good-tests.md`
- [x] `testing-anti-patterns.md` 已删除，仓库内无残留引用（用 Glob/Grep 验证）

**完成：** commit `53e6b8c`，状态 DONE

**步骤：**
1. 编写 `writing-good-tests.md`（≤60 行）
2. 更新 `SKILL.md` 引用
3. 删除 `testing-anti-patterns.md`
4. Grep 全仓库确认无残留引用
5. 自审：对照验收标准逐条核对
6. 提交

---

### Task 3: 上下文脚本 + Rulings 触发

**目标：** 物理阻断「派发 prompt 膨胀」「diff 进主上下文」，并定义 Rulings 的三个触发时机。

**设计文档索引：** 本计划「Task 3 验收标准」即规格来源。

**需求描述：**
为 `subagent-driven-development` 添加两个 bash 脚本（`task-brief` / `review-package`）和配套 prompt 禁令，并在 SDD 技能文件中定义 Rulings 的触发时机。**不创建 ledger / progress.md**——Lite 只用计划文件 checkbox + Rulings 一行记录。固定产出路径约定替代官方的 `sdd-workspace` 脚本。

**产出（Produces）：**
- 文件：`skills/subagent-driven-development/scripts/task-brief`
- 文件：`skills/subagent-driven-development/scripts/review-package`
- 概念：固定路径约定 `.superpowers/sdd/<plan-slug>/`
- 概念：Rulings 三个触发场景（被 Task 4 格式契约消费）

**消费（Consumes）：**
- Task 1：`Spike / Bounded / Architectural` 路径分类（SDD 仅服务 Architectural / 计划路径）

**文件：**
- 创建：`skills/subagent-driven-development/scripts/task-brief`
- 创建：`skills/subagent-driven-development/scripts/review-package`
- 修改：`skills/subagent-driven-development/implementer-prompt.md`
- 修改：`skills/subagent-driven-development/spec-reviewer-prompt.md`
- 修改：`skills/subagent-driven-development/SKILL.md`

**验收标准：**

*脚本 `task-brief`：*
- [x] 输入：计划文件路径 + 任务编号 N；输出：任务全文写入 `.superpowers/sdd/<plan-slug>/task-N-brief.md`，stdout 打印绝对路径
- [x] 任务边界按 `### Task N:` 行切分，N 精确匹配（Task 1 不匹配 Task 10）
- [x] 找不到任务时退出码非 0，stderr 给出原因

*脚本 `review-package`：*
- [x] 输入：计划文件路径 + BASE + HEAD；输出：commit 列表（`git log --oneline`）+ stat 摘要（`--stat`）+ 上下文 diff（`-U10`）写入 `review-N.diff`，stdout 打印路径
- [x] 文档中明确禁止用 `HEAD~1` 当 BASE（会静默丢弃多 commit 任务的前序改动）

*约束：*
- [x] 两个脚本仅依赖 `bash` + `git` + `awk`/`sed`，不依赖 jq / python / node
- [x] Windows 兼容：路径拼接不硬编码 `\`，在 Git Bash 下实测各跑通一次（CRLF 风险已由 `062b8f8` 的 `.gitattributes` 处置）
- [x] **不创建 ledger、不创建 progress.md、不创建逐任务历史**——只创建 brief / report / diff 文件

*Prompt 模板禁令（物理阻断）：*
- [x] `implementer-prompt.md` 增加禁令：派发禁止包含前序任务摘要、会话历史、整个计划文件正文
- [x] `implementer-prompt.md` 明确：报告写入 report 文件，返回时只给状态 + commit + 一行测试摘要 + 顾虑
- [x] `spec-reviewer-prompt.md` 明确：diff 必须以文件路径传递，禁止把 diff 内容粘进派发 prompt

*固定路径约定（替代 sdd-workspace）：*
- [x] `SKILL.md` 写明产出路径约定：`.superpowers/sdd/<plan-slug>/` 下只放 `task-N-brief.md` / `task-N-report.md` / `review-N.diff`
- [x] `SKILL.md` 明确禁止创建 ledger / progress.md

*Rulings 触发时机（格式由 Task 4 定义）：*
- [x] 三个触发场景写入 `SKILL.md`：审查发现与计划文本冲突 / 实现者 BLOCKED 且控制器现场改计划 / 整体审查不通过且裁决某 finding 不成立
- [x] 明确禁止：完整 Ledger、progress.md、逐任务历史记录、决策之外的流水账
- [x] 收尾时 Rulings 汇总进最终报告，供用户复核判断对错

**完成：** commit `f4c9471` + 修复 `062b8f8`，状态 DONE_WITH_CONCERNS（顾虑已裁决处置）

**步骤：**
1. 编写 `task-brief` 脚本，本地用临时计划文件测边界（N=1/10 不误匹配、缺失任务非 0 退出）
2. 编写 `review-package` 脚本，用临时 git 仓库造 BASE..HEAD 实测
3. 更新 `implementer-prompt.md` 与 `spec-reviewer-prompt.md` 禁令
4. 更新 `SKILL.md`：路径约定 + 禁止 ledger + Rulings 触发时机
5. 自审：对照验收标准逐条核对
6. 提交

---

### Task 4: Rulings 格式定义

**目标：** 在计划文档中提供裁决落点，让控制器替用户做的判断可被复核。

**设计文档索引：** 本计划「Task 4 验收标准」即规格来源。

**需求描述：**
在 `writing-plans/SKILL.md` 的计划文档模板中增加 `## Rulings` 区，并定义一行式裁决格式。触发时机由 Task 3 在 SDD 侧定义，本任务只管格式与计划文档结构。**不引入完整 Ledger。**

**产出（Produces）：**
- 概念：Rulings 一行格式 `> **Ruling:** <决定了什么> — <为什么> — <错了代价是什么>`

**消费（Consumes）：**
- Task 3：Rulings 三个触发场景（本任务只提供格式落点，不重复定义场景）

**文件：**
- 修改：`skills/writing-plans/SKILL.md`

**验收标准：**
- [x] 计划文档头部模板增加空的 `## Rulings` 区（无裁决时保留为空区，不写「无」）
- [x] 格式定义为一行：`> **Ruling:** <决定了什么> — <为什么> — <错了代价是什么>`
- [x] 明确禁止：完整 Ledger、progress.md、逐任务历史记录、决策之外的流水账
- [x] 收尾要求：最终报告中汇总所有 Rulings 供用户复核
- [x] 本任务**不修改** `subagent-driven-development/SKILL.md`（该文件由 Task 3 独占）
- [x] 与现有「任务结构」模板、「禁止占位符」章节无冲突

**完成：** commit `bd8123b`（由修复者补提交），状态 DONE

**步骤：**
1. 在计划文档头部模板插入 `## Rulings` 区
2. 增加 Rulings 格式定义与禁止项
3. 增加收尾汇总要求
4. 自审：对照验收标准逐条核对，确认未越权修改 SDD 文件
5. 提交

---

### Task 5: 项目文档同步

**目标：** 三份项目文档对工作流的描述互不矛盾。

**设计文档索引：** 本计划「Task 5 验收标准」即规格来源。

**需求描述：**
同步 `CLAUDE.md`、`README.md`、`README.en.md` 中的工作流描述，使其反映三路径分档，并在仓库结构图中补充新增的脚本目录与测试文档。这是纯描述性同步，不含新设计。

**产出（Produces）：** 无新概念

**消费（Consumes）：**
- Task 1：`Spike / Bounded / Architectural` 路径分类
- Task 2：`writing-good-tests.md` 文件名
- Task 3：`scripts/` 目录
- Task 4：Rulings 一行记录机制

**文件：**
- 修改：`CLAUDE.md`
- 修改：`README.md`
- 修改：`README.en.md`
- 修改：`skills/using-superpowers/SKILL.md`（Ruling 补入：入口技能链路描述与三路径矛盾）

**验收标准：**
- [x] `CLAUDE.md` 工作流描述改为三路径分档（Spike / Bounded / Architectural），保留「未确认不推进」门控语义
- [x] `CLAUDE.md` 仓库结构图补充 `subagent-driven-development/scripts/` 与 `test-driven-development/writing-good-tests.md`
- [x] `README.md` 工作流图同步三路径说明
- [x] `README.en.md` 与 `README.md` 语义一致（英文表述准确，非机翻痕迹）
- [x] `skills/using-superpowers/SKILL.md` 链路描述改为三路径分档（消除与 brainstorming 的矛盾）
- [x] 四份文档对工作流的描述互不矛盾

**完成：** commit `b600953`，状态 DONE

**步骤：**
1. 更新 `CLAUDE.md` 工作流与仓库结构
2. 更新 `README.md`
3. 更新 `README.en.md`
4. 交叉核对三份文档一致性
5. 自审：对照验收标准逐条核对
6. 提交

---

## 牢记

- 所有技能文件与文档使用简体中文；技术术语（TDD、DAG、Produces/Consumes、checkbox、Ruling、Spike/Bounded/Architectural）保留英文
- 保留 Lite 独有优势：契约优先、Produces/Consumes→DAG 分层、ASCII→Mermaid 双阶段、整体双审查、设计文档锚点、任务级零独立审查
- **不引入**：修复循环 + scoped re-review、完整 Ledger、diagnosing-superpowers、executing-plans、平台 references 扩充、`sdd-workspace` 脚本
