# 上游跟踪台账

**Fork 点：** superpowers **v5.1.0**（2026-04-30）
**当前上游：** superpowers **v6.4.1**（2026-09-19T00:31Z，2026-09-24 v4 联网核实仍为最新；原记 09-18 为美东日期）
**Lite 版本：** `6.4.1-l1`（2026-09-24 首次发版，git tag `v6.4.1-l1`）
**上次同步：** 2026-09-23（初版 v5.1.0 → v6.4.1）· 2026-09-23（二次复核）

上游每个版本的变更都记在官方 `RELEASE-NOTES.md`（每条约带 PR 编号）。**同步时先读它**，不必重跑全量 diff。

Lite 的立场：**跟着官方走，只做优化与简化**。每项上游变更都要裁决（采纳/拒绝/已同构），并记下原因——原因比结论重要，否则下次同步会重复争论同一个问题。

---

## 判据

按优先级排序，冲突时取靠前的：

1. **减少不必要的流程** —— 大模型能力足够时，防傻步骤应当删掉
2. **减少 token** —— 尤其是每会话重复付费的部分
3. **高质量交付** —— 漏检是真实损耗，不因「省」而牺牲
4. **最少代码 / 能复用就复用** —— 不新增维护面
5. **避免过度设计** —— 不为假想的未来需求留钩子

---

## 已采纳

### 本次同步（2026-09-23，v5.1.0 → v6.4.1）

| 上游项 | 引入版本 | 落点 | 采纳原因 |
|---|:--:|---|---|
| **Native 内联执行**（`executing-plans` 从 64 行 stub 重建） | 6.4.1 | `executing-plans/`（新建） | ①Lite 成本阶梯有断层：Bounded 无计划、SDD 最贵，缺「有计划但不派子代理」档；②官方明说**紧耦合任务不该用 SDD**（同层并行前提失效）；③**无子代理工具的平台**原本无路可走。官方实测为「最便宜的执行方式」 |
| **执行交接二选一 + 成本说明 + 按计划推荐** | 6.4.1 | `writing-plans/SKILL.md` | 让用户能主动选更便宜的路径；与 HARD-GATE 兼容（仍由用户批准） |
| **SDD `when-to-use` 门槛** | 6.4.1 | `subagent-driven-development/SKILL.md` | 官方决策树明说紧耦合 → 不用 SDD；Lite 原先所有 Architectural 计划一律走 SDD |
| **bootstrap 压缩**（图→散文、折章节、删逐平台走查） | 6.1.0 | `using-superpowers/SKILL.md` | bootstrap **每会话注入、持续付费**；125 行 → 79 行 |
| **TDD：项目测试套件定义 green** | 6.4.1 | `test-driven-development/SKILL.md` | 官方 12 次探针中 **11 次**只跑了被点名的那个测试文件，隔壁坏测试无人发现。只改「测试范围」，不新增流程阶段 |
| **审查员禁预判 / 只读 / 「无法从 diff 判定」** | 6.0.0 | `subagent-driven-development/SKILL.md`、`spec-reviewer-prompt.md`、`requesting-code-review/code-reviewer.md` | 真实会话中抓到控制器教审查员忽略 finding 并已发布；审查员跑 `git checkout` 曾孤儿化后续 commit。**2026-09-24 补记：**官方同一项**也落在 `code-reviewer.md`**，原台账漏记该落点，导致 Lite 整轮最贵的审查席位（整体 code-reviewer）长期无只读约束——它正是 SDD 派去审全分支的那一个 |
| **计划 `Spec:` 指针** | 6.3.0 | `writing-plans/SKILL.md` | 计划冲突对着**设计**裁决，而不是猜 |
| **整体审查 BASE 用 `git merge-base origin/main HEAD`** | 6.4.1 | `subagent-driven-development/`、`spec-reviewer-prompt.md`、`requesting-code-review/SKILL.md` | 裸 `origin/main` 在 main 前进后会把 main 的新文件显示成**幻影删除**。**2026-09-24 补记：**官方同一项**也落在 `requesting-code-review/SKILL.md:28`**，原台账漏记该落点 → Lite 该行仍写「或 origin/main」，与自家 SDD 的禁令**自相矛盾** |
| **finishing：菜单不再展示「丢弃」** | 6.2.0 | `finishing-a-development-branch/SKILL.md` | 把「丢弃」与「合并」并列展示，等于向用户推销销毁一份已完成且测试通过的工作；改为 explicit-request-only（菜单 4→3 项，detached HEAD 3→2 项） |
| **finishing：worktree 移除被拒不自行 `--force`** | 6.3.0 | 同上 | 被拒意味着该 worktree 里有**别处不存在的文件**——`--force` 会永久销毁它们；改为停下、列出文件、征询用户 |
| **writing-skills：`Match the Form to the Failure`** | 6.0.0 | `writing-skills/SKILL.md` | 纠正一个**会主动造成伤害**的直觉：对「**输出形状错误**」用禁止式指导，实测比**不给指导**还差（prohibition arm 甚至差于 no-guidance control）。附两条实测规则：no nuance clauses、exemption clauses don't scope。连带给 Bulletproofing 加 Scope 交叉引用 |
| **writing-skills：删 `The Bottom Line`** | 6.2.0 | 同上 | 对**已读完整个技能**的读者的冗余复述。注意：writing-skills 是按需加载，删除**不省会话 token**——理由是消除冗余，不是省成本 |
| **writing-skills：CSO→SDO + `Claude`→`agent`** | 6.0.0 | 同上 | ①「描述写法影响技能发现」是通用机制，**不专属 Claude**；②Lite 支持 Codex / Copilot / Gemini，技能正文绑定「Claude」措辞不成立。14 处替换，保留真实路径 `` `~/.claude/skills` ` for Claude Code `` |
| **修 `@file` force-load 引用（3 处）+ SDO 小节编号错** | 6.0.0 | `writing-skills/`、`test-driven-development/` | `@file` 语法会**立即 force-load** 文件，消耗 **200k+ 上下文**——直接命中「减少 token」判据。Lite 的 SDO 第 5 节自己写着「❌ Bad: `@...` (force-loads, burns context)」，却在同文件另两处（加 TDD 技能一处）用了 `@`→ 改为 markdown 链接/反引号。同时修掉 SDO 第 5 节误编为 `### 4.` 的编号错（与第 4 节撞号）|

### 二次复核采纳（2026-09-23）

| 上游项 | 引入版本 | 落点 | 采纳原因 |
|---|:--:|---|---|
| **brainstorming `Establish Shared Understanding`**（发现意图 → 回述供纠正 → 带进设计） | 6.4.1 | `brainstorming/SKILL.md` | 官方头号新增。Lite 原缺此步，直接进入设计提问——**漏检设计方向的源头**。请求已含目的时「直接回述」而非重复提问，不增加流程长度 |
| **code-reviewer `Declined to judge` 清单 + 「合理用户期望」判据** | 6.4.1 | `requesting-code-review/code-reviewer.md` | ①spec 沉默 ≠ 许可：按合理用户期望定级，真实 crash 不再以「spec 没写」滑成 Minor；②搁置判定逐条列出交执行者裁决，**不让 finding 被静默丢弃**。与 Lite 已有的「无法从 diff 判定」同族但不同轴 |
| **文档审查自审化**（brainstorming 结构质量自审 + writing-plans 自审） | 6.0.0–6.4.1 | `brainstorming/`、`writing-plans/` | 官方 `Self-Review` 明写 "not a subagent dispatch"，两个 `*-document-reviewer-prompt.md` 在官方已成**刻意孤儿**。Lite 原把它们当「孤儿引用」修复回工作流，等于把官方主动删掉的重流程恢复。**决策（自审优于派子代理）维持**，但 2026-09-24 复核实测更正一处口径：官方自审 4 项**并非全是结构质量**——它含 `placeholder scan` 与 `scope check`，而 Lite 恰恰丢了这两项（转「Lite 自身缺陷」）。「Lite 只增不减」的隐含前提不成立 |
| **Native 末尾审查用最强模型** | 6.4.1 | `executing-plans/SKILL.md` | 官方明说这是 most capable model 唯一挣得成本的位置——内联执行把「每任务 fresh context」省了，末尾这一个审查员**是整轮唯一一次买独立视角**，不该降级 |

### 更早已采纳（fork 时起）

| 上游项 | 引入版本 | 落点 |
|---|:--:|---|
| 三路径分类 Spike / Bounded / Architectural | 6.3.0 | `brainstorming/SKILL.md` |
| Global Constraints 逐字块 | 6.0.0 | `writing-plans/SKILL.md` |
| 每任务 Interfaces（Consumes/Produces） | 6.0.0 | `writing-plans/SKILL.md`（并升级为 DAG 自动分层） |
| Review Focus 章节 | 6.4.1 | `writing-plans/SKILL.md` |
| 禁止嵌套派发 | 6.3.0 | `subagent-driven-development/SKILL.md` |
| 冲突非灾难性 → 记 Ruling 继续 | 6.3.0 | `subagent-driven-development/SKILL.md`、`writing-plans/SKILL.md` |
| 工作区 plan-scoped（`.superpowers/sdd/<plan-slug>/`） | 6.2.0 | `subagent-driven-development/SKILL.md` |
| 暂存文件移出 `.git/`（CC 保护路径，写入被拒） | 6.0.3 | 同上 |
| 每次派发必须声明模型 | 6.0.0 | 同上 |
| 审查员用 `file:line` 举证 | 6.0.0 | `spec-reviewer-prompt.md` |
| `writing-good-tests.md` 替代 `testing-anti-patterns.md` | 6.2.0 | `test-driven-development/` |

---

## 已拒绝

| 上游项 | 引入版本 | 拒绝原因 | 错判代价 |
|---|:--:|---|---|
| **ledger / `progress.md`** | 6.0.0 | 计划文件 checkbox 已是唯一持久化真相源；再造一份只会制造第二个会不同步的真相源 | 上下文压缩后需从 `git log` 恢复，多花几轮 |
| **`task-brief` / `review-package` / `sdd-workspace` 脚本** | 6.0.0–6.2.0 | 用 `offset`/`limit` 行号指针 + 「子代理自跑 `git diff`」以更低成本达成同样目的；脚本还引入自身缺陷（参数解析、CRLF 行尾、executable bit 丢失） | 派发 prompt 略微变长；无功能损失 |
| **任务级独立审查**（每任务一个 reviewer） | 6.0.0 | 末尾整体审查门控已覆盖需求与质量。**2026-09-24 复核更正理由：**原记「官方 6.4.1 提供无任务级审查的 Native 模式，等于承认它可省」是**范畴错误**——官方 Native 能省每任务审查，是因为它同时付了三样补偿物（**brief 作 spec、ledger 作记忆、TDD 作每任务门控**），而 Lite SDD 这三样都不成立（ledger 被拒、TDD 证据不进报告、brief 是行窗口非自足需求源）。官方在 6.0.0 花整轮成本实验把每任务审查从 2 个 reviewer 收到 1 个，**并未取消它** | 任务级问题暴露更晚，修复成本略高；且控制器「只读报告」而实现者是另一个全新子代理，「不信任报告」这一环无人兑现 |
| **计划预检冲突扫描表** | 6.0.0 / 6.3.0 | 增加一整个前置阶段；Rulings 现场裁决已覆盖同类问题 | 个别任务间冲突在执行中才发现 |
| **fix loop 五轮熔断 + scoped re-review 模板** | 6.2.0 | Lite 任务级只自审、不派审查员，不存在任务级 loop；整体审查失败后的修复循环已由 ONE fix dispatch 覆盖 | 整体修复可能多跑一轮 |
| **`diagnosing-superpowers`** | 6.4.1 | 会话事后诊断（20 文件 857 行），与轻量目标无关 | 无——用户可直接看会话记录 |
| **8 个新 harness 支持**（OpenCode / Muse / Qwen / Grok / Kimi / Pi / Antigravity / Devin / Hermes） | 6.0–6.4 | 每个 harness 需独立 bootstrap + 工具映射 + 测试，维护面过大；Lite 只留 Codex / Copilot / Gemini | 这些平台的用户需自行适配 |
| **小同形任务批量派发** | 6.3.0 | 与 Lite 的「同层并行」重叠，收益不明 | 微任务计划的子代理成本略高 |
| **`Common Rationalizations` / `Example Workflow` 段** | 6.2.0 | 面向「已决定使用本技能」的读者属冗余篇幅 | 无 |
| packaging / 构建脚本 | 各版本 | 与 Lite 无脚本的路线冲突 | 无 |

> **2026-09-24 更正（原条目错）：** 原表此行为「游标清理类（`find-polluter.sh`、`render-graphs.js`、packaging 脚本）| 与 Lite 无脚本的路线冲突 | 无」。**该理由与仓库实态不符**：Lite **确实分发并使用** `find-polluter.sh`（`systematic-debugging/root-cause-tracing.md:101` 引用它），且带的是官方 6.2.0 已修的 glob bug（`./` 前缀不匹配 + `**/` 不匹配零级目录 + 空集时 `wc -l` 报「Found 1」）→ 定位污染源时得出**假阴性**。已改为**采纳上游修复**。`render-graphs.js` 是 Lite 自有脚本（`writing-skills/`），不属此类，其 Windows `which dot` 缺陷另记。
| **`Micro-Test Wording Before Full Scenarios`** | 6.0.0 | 它是**流程**（5+ reps × 多变体 × 人工读每个匹配），不是文档；兑现频率低。按判据 1「减少不必要的流程」排不上 | 措辞问题更晚才在压力场景中暴露 |

### 二次复核拒绝（2026-09-23）

| 上游项 | 引入版本 | 拒绝原因 | 错判代价 |
|---|:--:|---|---|
| **controller「one layer down」降级**（controller 作为 mid-tier 嵌套子代理） | 6.4.1 | opt-in 特性，与 Lite「禁止嵌套派发」的**精神**不冲突（那是禁子代理再派子代理，这是 controller 自身降级），但 Lite 已用「轮次比 token 单价更重要」覆盖同一成本问题；引入会新增一条需要解释的例外 | 在超长 SDD 计划上少省一半协调成本 |
| **同 basename 计划工作区冲突修复** | 6.4.1 | Lite 无 `sdd-workspace` 脚本，工作区以 `<plan-slug>` 命名且由计划文件名派生；同名计划在 Lite 流程下是**用户侧命名问题**，可用改名解决，不值得为此加规则 | 极端情况下两个同名计划共用目录，需手工改名 |
| **`review-package` 拒绝空/非同源 `BASE..HEAD`** | 6.4.1 | 已改为**采纳其规则（不引脚本）**。**2026-09-24 更正：**原记「等价保护已由 BASE 必须是派发前记录的 SHA 承担」**不成立**——该规则只防「多 commit 被截断」，既不查「range 非空」也不查「祖先关系」。实现者若提交到**别的分支**，当前分支 `BASE..HEAD` 为空，审查员会对空 diff 给出「Spec ✅、无 Extra」并放行，正是官方脚本要挡的那种「对空 diff 的干净审查」。Lite 已在 SDD 补入「审查前确认 BASE 是 HEAD 祖先且 range 非空，否则按 BLOCKED 上报」 | 已消除 |
| **finishing 的 `Red Flags` → `Common Rationalizations` 结构对齐** | 6.2.0 | 6.2.0 全库 campaign 的产物是**形式统一**，不是信息增减；Lite 的 `Red Flags` / `Common Mistakes` 三段结构信息量等价，改动只增加 diff 噪音 | 无 |
| **writing-good-tests 的 `Gate Function` / `Quick Reference` / `Warning Signs`** | 6.2.0 | Lite 版已有「写前自检」承担 gate 职责、有「三条反模式」承担 warning 职责；官方多出的是同一内容的**再包装**，按判据 4「能复用就复用」不重抄 | 门控措辞不如官方硬 |
| **bootstrap 平台清单换血**（官方列 CC/Codex/Pi/Antigravity/Hermes/Muse，删 Copilot） | 6.0–6.4 | Lite 目标平台是 Codex / Copilot / Gemini——**这是刻意选择**（轻量、覆盖主流），不是落后。官方清单里的 Pi/Antigravity/Hermes/Muse 是各自 harness 的适配，Lite 不含 | 这 5 个平台的用户需自行适配 |

---

## 已独立同构（Lite 与官方各自走到同一设计，无需动作）

这些项证明 Lite 的设计判断与官方收敛。**记录在此，避免下次同步时重复评估。**

| 机制 | 官方引入 | 说明 |
|---|:--:|---|
| 三路径随任务规模伸缩仪式 | 6.3.0 | 同期同构 |
| plan-scoped 工作区 | 6.2.0 | 同期同构（Lite 早于本次同步即已有） |
| 禁止嵌套派发 | 6.3.0 | 同期同构 |
| 冲突 → 记裁决继续，不阻塞 | 6.3.0 | 同期同构 |
| 暂存区移出 `.git/` | 6.0.3 | 同期同构 |

---

## Lite 独有（官方没有）

| 机制 | 价值 |
|---|---|
| **指针化派发**（`offset`/`limit` 行号窗口） | 用规则替代脚本，正文物理上不进上下文 |
| **审查按交付物分流**（spec-review 必跑；code-review 仅交付物含可执行代码时） | 免掉对 Markdown 无效的审查项 |
| **零辅助脚本**（官方 SDD 3 个 + executing-plans 2 个） | 无脚本自身缺陷，无维护面 |
| **「轮次比 token 单价更重要」** + 审查员/实现者的中档模型地板 | 官方只按任务类型推荐模型，未考虑轮次成本 |
| **Prompt Caching 前缀稳定** | 命中缓存按 10% 计费 |
| **ASCII → Mermaid 双阶段图表** | 交互快迭代，文档正式表达 |
| **契约与接口章节** | 并行的前提；官方只有 Interfaces 块而无自动分层 |
| **Consumes 文件指针**（`(@路径)`） | 下游子代理直接 Read 契约定义文件，免去全库 `Grep` 找定义；路径取自同任务的 Produces。官方无此约定 |
| **「固定开销 × 任务数」判据** | 官方选执行路径只有两条理由（要不要每任务审查门、计划是否会被压缩）。Lite 补第三条：每次派发子代理都要重付数十 k token 的启动开销（system prompt + 工具定义 + 指令文件），任务少时该成本占大头 → 判据从「任务多就走 SDD」变成「任务多到隔离收益抵得过启动费才走 SDD」，并把「任务别默认拆越细越好」写入任务粒度（实测依据见「成本结构实测」） |
| **TDD 测试输出重定向** | 全量套件日志可达数千行；要求重定向到文件 + grep 失败名与汇总行，只把关键行读回上下文。「任何失败都要按名报告」的要求不变，变的是获取方式 |

> ⚠️ 注意：官方 6.1.0 曾把 bootstrap 的图**换成散文**（理由是每会话成本）。Lite 的双阶段图表策略用于**设计文档**，不与 bootstrap 冲突——两处用途不同。

---

## 文档瘦身（Lite 自研，非上游）

2026-09-24，`brainstorming/SKILL.md` 363 → 296 行（省 67）。

**为什么只动 SKILL.md：** 它是唯一「Skill 工具调用即全量载入上下文」的文件，**每次调用都付费**；`diagram-driven-design.md` / `visual-companion.md` / `scripts/` 只有被显式读取时才付费。因此**把细节从 SKILL.md 移到附加文件是真省，往附加文件加内容≈免费**。

| 项 | 省 | 做法 | 依据 |
|---|---:|---|---|
| 图表策略段 | 30 | 压为 1 行 + 链接 | 与 `diagram-driven-design.md` 的「两阶段图表策略」「选图规则」**逐字重复** |
| 关键原则段 | 8 | 整段删除，YAGNI 折回「探索方案」 | 6 条中 5 条是正文已写过的 recap；官方 6.2.0 campaign 正是删除 `Key Principles` / `Bottom Line` 类收尾段，并要求「每个 load-bearing 论证折进使用点」 |
| 契约与接口示例 | 24 | 两张示例表移入 `diagram-driven-design.md`；classDiagram 代码块直接删（该文件已有超集版本） | 保留 5 点清单（真价值），只减示例体量 |
| 设计之后的文档化 | 5 | 与图表/契约重复的两行合并 | 同源重复 |

**未做（已评估）：** dot 流程图（58 行）改 ASCII 树可再省 43 行，但会失去 graphviz 可渲染性，暂缓。

**注：** 这是 Lite 自研优化，不是上游同步项——官方无对应变更。记录在此是为了下次同步重算行数时知道这 67 行去哪了。

---

## 外部方法论对齐（2026-09-24）

用户提出一套「子代理优先 + 外部结构化记忆」方法论：上下文污染从第一个多余 token 起就伤害检索精度，调提示词救不回来；主 agent 不读原始材料，脏活分派给独立窗口的子代理，只回收 1–2k 浓缩结论（实测 +90.2%，代价 15× token）；维护外部结构化记忆（NOTES.md / 决策日志）对抗上下文腐烂；MetaGPT 证据——结构化工作交接可执行性 3.75/4.0，自然语言只有 2.25/4.0。

逐条对照 Lite 后：

### 已同构（无需动作）

| 方法论主张 | Lite 对应机制 |
|---|---|
| 主 agent 不读原始材料，脏活分派给独立窗口 | **指针化派发**：只传计划路径 + `offset`/`limit` + 报告路径，子代理自跑 `git diff`，正文不进主上下文 |
| 分派要写清目标 / 输出格式 / 可用工具 / 任务边界 | **派发铁律** + **报告契约四项**（状态 / commit / 一行测试摘要 / 顾虑） |
| 子问题递归给更便宜的模型 | **模型选择**：按复杂度取最弱可用模型，且「轮次比 token 单价更重要」 |
| 写给机器看的信息，格式本身就是防丢手段 | **Rulings 一行裁决**（决定了什么 — 为什么 — 错了代价）+ 报告契约固定字段 |

### 维持不变（已争论，勿重复）

| 议题 | 方法论主张 | Lite 裁决 | 理由 |
|---|---|---|---|
| 判据排序 | 质量优先，愿付 15× token 换 +90% | **维持**「减少流程 > 减少 token > 高质量」 | 那些论文的基线是无外部记忆的单 agent；Lite 已用指针化 + 报告契约吃掉大部分污染，15× 的边际收益远小于论文数字 |
| 外部记忆 | 另起 NOTES.md / ledger | **维持**由计划文件承担（checkbox + Rulings 区） | 判据 4「能复用就复用」：复用已在的工件，避免第二个会不同步的真相源 |
| 文档审查 | 多派子代理 | **维持**自审不派 | 自审的输入是「自己刚写的文档」，已在上下文中，不产生新污染；派子代理要从零再读一遍 |

### 本轮已执行

`dispatching-parallel-agents` 去冗余（182 → 159，省 23 行）：删除 `## Key Benefits`、`## Real-World Impact` 两个 recap 段（官方 6.2.0 campaign 删除同类）；`## Verification` 与 `### 4. Review and Integrate` 4 条中重复 3 条，仅「spot check」一条并入后者，该段整段删除。`## Real Example from Session`（26 行英文案例）**保留**——见「待办」。

### 已识别未执行

见下方「待办」。

---

## 成本结构实测（2026-09-24）

来源：本会话 `/context` 实测。用于校准「减少 token」（判据 2）到底该往哪里使劲。

| 项 | tokens | 性质 |
|---|---:|---|
| System tools | 43.8k | 每会话固定，Lite 无法削减 |
| MCP tools | 39.6k | 每会话固定，Lite 无法削减 |
| System prompt | 9.8k | 每会话固定 |
| Memory files | 3.9k | 两份 CLAUDE.md |
| Skills | 4.9k | 技能描述行（含非 Lite 插件） |
| **会话基础开销合计** | **≈102k** | 每次派发子代理要重付其中大部分 |

**三条结论：**

1. **「固定开销 × 任务数」由估计升级为实测。** 单次派发的固定部分（system prompt + 工具定义 + 指令文件）与会话基础开销同构、同一量级（数十 k）；而单个任务的实现内容通常只有 10–20k。**固定开销占单次派发的大头（约七至八成），派发「次数」因此比派发「内容」大得多。**
2. **Lite 能省的是技能正文，天花板很低。** 全库比官方少 616 行（统一口径后），折算到 token 是数 k 量级；而工具定义一项就是 83.4k。**不是方向错了，是量级差两个数量级**——后续轮次别指望靠瘦身技能换来可观节省。
3. **最大一笔在 Lite 范围之外。** `System tools 43.8k + MCP tools 39.6k = 83.4k`（`ccd_*` / `Claude_Browser` / `scheduled-tasks` / `terminal` 等 MCP server）。若不常用，**禁用对应 MCP server 比优化任何技能文档都有效**。Lite 不处理此层——改成「Lite 待办」会把非 Lite 动作塞进上游台账。仅在此知会，避免后续轮次在错误的量级上优化。

**不在本台账记录：** git 状态（未推送提交数、commit message 笔误）——`git log` / `git status` 是权威来源，记进台账只会制造第二个会过期的真相源（判据 4）。

**本轮据此执行的三项：** 详见 `Lite 独有` 表末三行。

---

## 上游简化未同步（2026-09-24 复查）

逐技能骨架对比 14 个共同技能 + 官方 6.2.0 campaign 点名清单核对。

### 本轮已执行

**recap / 社会证明段（官方 6.2.0 已删）—— 净省 91 行**

| 技能 | 删除段 | 行数 | 性质 |
|---|---|---:|---|
| `receiving-code-review` | `## The Bottom Line` | 8 | 纯 recap |
| `verification-before-completion` | `## Why This Matters` | 9 | 社会证明 + 恐吓（"If you lie, you'll be replaced"） |
| `verification-before-completion` | `## The Bottom Line` | 8 | 纯 recap |
| `systematic-debugging` | `## Real-World Impact` | 8 | 社会证明（95% vs 40%） |
| `test-driven-development` | `## 为什么顺序重要` | 50 | 官方实测删整节会降级（8/10→5/10），故折进 `Common Rationalizations`。**2026-09-24 判定更正：**原记「Lite 的 `## 常见合理化` 表已 100% 覆盖这 5 条论证 → 可整删」**不成立**。逐条比对（官方现行形态 `SKILL.md:227-230,234` ↔ Lite 表）结果：**完全覆盖 0/5**；4 条仅覆盖 1/4–1/5 子论点，1 条基本覆盖。被删掉的是整条推理链（被已写代码偏见化 / 验证记住的而非发现的 / 覆盖率≠证明 / 成本显式二选一 / 四类收益）。**Lite 删得比官方更彻底**（官方折进表，Lite 没折）→ 正处在官方实测为降级的那个条件。**已按「部分恢复」补回论证（约 +8 行，未恢复整节 50 行）** |
| `writing-plans` | `## 牢记` | 8 | recap |

**缺陷修复：`using-git-worktrees` 步骤编号断裂**

官方 6.0.0 修过（#1522）。Lite 是 `Step 0 → 1 → 3 → 4`（缺 Step 2），现修正为 `0 → 1 → 2 → 3`，5 处引用同步。

### 本轮未执行（转待办）

**house form 覆盖差异**：官方 8 个技能有 `Common Rationalizations` 表，Lite 只有 3 个（`systematic-debugging` / `test-driven-development` / `writing-skills`）。缺的是：

| 技能 | Lite 现状 |
|---|---|
| `requesting-code-review` | 完全缺失 |
| `finishing-a-development-branch` | `Common Mistakes`(38) + `Red Flags`(22) |
| `using-git-worktrees` | `Common Mistakes`(27) + `Red Flags`(17) |

> 官方 `requesting-code-review` 的表里有一条关键护栏：「*我自己看 diff 就行，不用派审查员*」→ **你是协调者，inline 审 diff 会烧掉你驱动工作所需的上下文窗口**。这与 Lite「指针化派发」的判据一致，值得补。

### 明确保留

- `requesting-code-review` 的 `## 与工作流的集成`（Lite 独有）——说明自定义审查门控的触发时机，非冗余
- `subagent-driven-development` / `executing-plans`——Lite 主动重写，不适用「官方简化」判据
- `writing-skills` 的 `## Real-World Impact (optional)`——官方也有，非残留

---

## Lite 自身缺陷（二次复核实录）

**记录成因，防止下次同步再写反。**

### 紧耦合判据读反（已修正）

| | 官方 6.4.1 | Lite（修正前） |
|---|---|---|
| 紧耦合任务的去向 | **手工执行，或先 brainstorming** | ~~走 Native 内联执行~~ |

**官方证据：** SDD `when_to_use` 决策树 `"Tasks mostly independent?" -> "Manual execution or brainstorm first" [label="no - tightly coupled"]`；`executing-plans` 的 When to Use 明写 *"Tasks are mostly independent — the same precondition as subagent-driven-development"*。

**成因：** 初版同步时读到「官方明说紧耦合不该用 SDD」，正确结论是「该手工做」，但被推成了「所以用 Native」——**把否定判断当成了正向推荐**。官方立场是 Native 与 SDD **前提完全相同**，紧耦合时两者都不适用。

**连带影响：** `CLAUDE.md` 决策 #6 的恢复理由（2）、`README` / `README.en.md` 的对应行。理由（1）成本阶梯断层与（3）无子代理平台**不受影响**，Native 本身该恢复。

**教训：** 引用官方判据时，必须**摘录判据原文 + 行号**，不能只记自己的推论结论。推论一旦写进台账，下次同步会拿它当既成事实复读。

### 统计口径错误（已更正）

**曾误报「Lite brainstorming 比官方重 +599 行」，结论作废。**

**成因：** 统计脚本只匹配 `.md / .sh / .js / .ts`，**漏了 `.cjs` 和 `.html`**；而官方 6.4.1 的 `brainstorming/scripts/` 已从 5.1.0 的 860 行涨到 **1432 行**（6.0.0 给视觉伴侣加了完整安全模型）。两个因素叠加，把「Lite 更轻」显示成了「Lite 更重」。

**统一口径后的真实数据（全目录，含 `.cjs`/`.html`）：**

| 文件 | 官方 6.4.1 | Lite（2026-09-24 实测） | Δ |
|---|---:|---:|---:|
| SKILL.md | 285 | 297 | +12 |
| diagram-driven-design.md | 不存在 | 190 | +190 |
| spec-document-reviewer-prompt.md | 49 | 51 | +2 |
| visual-companion.md | 299 | 286 | −13 |
| scripts（5 个） | 1432 | 860 | −572 |
| **合计** | **2065** | **1684** | **−381** |

**结论：Lite brainstorming 整体比官方轻 381 行。**

> **原「−616」系算错（2026-09-24 更正，留档防复述）：** 原表官方列写 2350，但该列各行相加为 **2065** —— SKILL.md 的 285 被**重复计入两次**；Δ 列写 −616，但各行 Δ 相加为 **−331**。明细与合计自相矛盾。旧表的 SKILL.md 行也停在瘦身前的 363。

> **口径提醒（2026-09-24 后续实测）：** 上面是「brainstorming 单技能 × 全部文件类型」。「Lite 比官方轻多少」另有三个合法口径，**不可互相相减**：**−185**（14 共有技能 × 仅 `SKILL.md`，**唯一推荐**——只有它每次 Skill 调用全量载入、每次付费）；**−509**（14 共有技能 × 仅 `.md`，含按需读取文件）；**−1366**（全部 skills × 仅 `.md`，**不可对外使用**——混入官方独有 `diagnosing-superpowers` 的 857 行，会高估 857）。脚本永不进上下文，把 `.sh/.js/.cjs/.html` 算进「轻量」比较等于把**执行体体积**当**上下文成本**。

**教训：** 跨仓库比行数时先统一文件类型口径；`wc -l` 的合计值依赖 `find` 的匹配规则，换一次脚本就换一个结论。

---

## 本轮采纳（2026-09-24 技能层对比）

5 个并行审查代理按技能分片全量比对官方 v6.4.1（90+ 条发现，逐条附 `file:line` + 原文；原始报告在 `.superpowers/compare/2026-09-24/`）。以下为**已执行**部分；未执行项见「待办」。

**A. 缺陷修复（已执行）**

| 项 | 影响 |
|---|---|
| `find-polluter.sh` 移植官方修好版 | 原版给**假阴性**（匹配不到测试文件，空集却报 Found 1） |
| `render-graphs.js` `which dot` → `execFileSync('dot', ['-V'])`（**该文件已于 2026-09-24 v2 随 `writing-skills/` 被用户删除，此项作废**） | Windows 无 `which` → 即便装了 graphviz 也恒报 not found，唯一用途静默失效 |
| `code-reviewer.md` 补**只读**条款 + 禁止派子审查员 | 最贵审查席位原无只读约束，可 `git checkout` 孤儿化 commit |
| `finishing` Step 2 捕获 `WORKTREE_PATH`（原在 Step 6 现算） | Step 5 已 `cd` 到主仓库 → 原写法 **worktree 静默永不清理**（官方 6.2.0 修过同一 bug） |
| `finishing` 补 detached HEAD 的 push 形式 | 照抄原命令必失败（detached HEAD 上不存在 `<feature-branch>`） |
| 全局 worktree 目录 `~/.config/superpowers/worktrees/` 全部移除（`using-git-worktrees` 6 处 + `finishing` 2 处） | 官方 6.0.0 已移除；原会把 worktree 建到项目外，`.gitignore` 与清理逻辑都看不见 |
| SDD / EP 补 **Setup**（隔离工作区 + 读 Spec + 强制加载 TDD） | 原两个执行器无工作区校验；**EP 连 main/master 红线都没有** |
| SDD 补**四类安全停机条件** | 长链自主执行下，原可能无人同意就 merge / push 共享分支 |
| SDD 补**循环上限（3 轮）+ 残余上呈 + Minor 分流** | 原循环无出口；Minor 无归宿（无人读的汇总 = 静默丢弃）；复审改为 `FIX_BASE..HEAD` 限定范围 |
| SDD 补 **BASE 祖先/非空守卫** | 堵「实现者提交到别的分支 → 空 diff 得到『干净审查』」 |
| `implementer-prompt` 补 **TDD RED/GREEN 证据** | 原「事后补测」与「真 TDD」在报告里不可区分 |
| TDD 补回**被删的 5 条论证**（约 +8 行，非恢复整节 50 行） | 官方实测删整节降级（8/10→5/10），Lite 原删得更彻底 |
| `writing-good-tests` 补 3 条规则（测你的代码非框架 / 替身要具体 / 测试随实现交付） | 一并解掉与自家 checklist「每个新函数都有测试」的冲突；触发词由「加 mock 时」改为「编写或修改任何测试时」 |
| `systematic-debugging` 把 VBC 指针折进 Phase 4 使用点 | 原在文末「Related skills」→ 执行到「测试过了吗」时看不到 |
| brainstorming 自审补 `placeholder scan` + `scope check` | 原推迟到 writing-plans 才暴露 |
| brainstorming 视觉伴侣改 **just-in-time + 拒绝即止** | 原开场就预告（且邀请文案自带 token 告警），拒绝后规则未禁止再提 → 与判据 2 冲突 |
| `writing-plans` Review Focus 改为**「由归属任务的测试钉住」** | 原只是审查员的注意力清单 → TDD 阶段没有任何测试拦截 |
| SDD 加 `.superpowers/sdd/.gitignore` + **`git clean -fdx` 警告** | 目标仓库里报告会成为未跟踪文件；`git clean -fdx` 会静默删光全部报告 |
| SDD 行号解析补**代码围栏警告** | 裸 `grep` 在计划含围栏时会算出错误窗口（**静默错任务**） |
| 安装说明（`CLAUDE.md` / `README.md` / `README.en.md`）改**动态解析版本目录** + 装后校验 | 原写死 `.../superpowers/6.4.1/skills/`，**该路径本机不存在**（缓存只有 `5.1.0`） |
| 新建 `.gitattributes`（`*.sh text eol=lf`） | 本机 `core.autocrlf=true` → 3 个 `.sh` 会被检出为 CRLF，`bash x.sh` 报 `\r: command not found` |
| `dispatching-parallel-agents` 补并行可执行规则 + 去方言 | 原缺「同一响应内多次派发才是并行」；`Task(...)` 伪代码是官方 6.0.0 明令去掉的方言 |

**B. 本轮裁决为「不采纳」（防下次复述）**

| 项 | 理由 |
|---|---|
| 官方 skills 内的 5 个可执行脚本（`task-brief` / `review-package` / `sdd-workspace` / `task-start` / `task-done`） | 维持「零辅助脚本」；其**保证**改用规则承接，不等价处已单独补规则（见 A 表：围栏感知、range guard、`git clean` 警告、TDD 证据） |
| `diagnosing-superpowers`（20 文件 857 行） | 会话事后诊断，与轻量目标无关；用户可直接看会话记录 |
| 官方 26 行英文案例（`dispatching-parallel-agents` 的 `## Real Example from Session`） | **官方 6.4.1 仍保留** → 删除会成为 Lite 单方面偏离（原待办方向已更正） |
| 平台映射 `claude-code-tools.md` | 其内容 100% 是被 Lite 拒绝的 one-layer-down；正文即 CC 工具名 |

**C. 共盲区（双方都没有，台账首次记录这一类）**

- **安装态 / 运行态无一致性校验。** 官方默认「插件即仓库」故不校验，其盲区在第三方覆盖层；Lite 的盲区**已实测致害**（注入每会话的 bootstrap 是旧 Lite、不知道三路径；`executing-plans` 仓库有运行时无）。它只产生**沉默的偏差**，不报错，比断链更难发现。→ 已用安装校验部分对冲，**版本标记**这条仍在待办。
- **无全库级技能交叉引用完整性检查。** 官方只对 `diagnosing-superpowers` 一个技能有结构测试。`brainstorming:45` 那类「少写一个兄弟」既非断链也非语法错，两边都查不出。

---

## 第二轮对比（2026-09-24 v2）

对**修复后**的 Lite 重跑对比。方法改为「主控机械化底盘 + 3 个子代理判断层 + 主控逐条核实」——**三份子报告共出现 3 例断言误差，均被主控复跑纠正**（子代理结论不可直接采信）。原始报告在 `.superpowers/compare/2026-09-24-v2/`。

**口径（SKILL.md，14 共同技能）：** 官方 **3756** / 上轮前 **3571（−185）** / 本轮后 **3626（−130）**。

> **⚠️ 2026-09-24 v2 期间，用户删除了 `skills/writing-skills/`（7 文件）。** 该技能是元技能（技能写法的唯一来源，见文末「下次同步流程」第 6 条）。删除属**用户决定**，非本轮方案内容。连带：`render-graphs.js`（其 dot 渲染脚本，含上轮 `execFileSync` 修复）一并消失；Lite 技能数由 14 → **13**。
> **新口径（13 技能 × SKILL.md）：官方 3075 / Lite 2950 = −125。** 本节的逐技能表与结构分析仍按 14 技能口径留档。

**结构：** Lite 的「省」全部来自 4 个技能（`executing-plans` −258、SDD −89、`writing-skills` −17、`dispatching-parallel-agents` −6 = **−370**）；自研机制集中在增重的 5 个（`writing-plans` +106、`finishing` +61、`using-git-worktrees` +34、`brainstorming` +12、`requesting-code-review` +12 = **+240**）。

**本轮修复（12 项）：**

| 批 | 项 |
|---|---|
| **P0** | ① 安装校验针 `grep -q "三路径"` 在目标文件**不存在**（恒失败、且与旧安装无鉴别力）→ 换成实测存在的串；② EP 声明「无子代理工具时同样适用」却**无 self-review 兜底**（在 Lite 明确支持的 Codex/Copilot/Gemini 上门控无出路）；③ `writing-plans` DAG 示例类名被 `Controller`→`控制器` 误伤（`User控制器`/`Order控制器`）；④ **删除视觉伴侣 server**（`brainstorming/scripts/` 5 文件 + `visual-companion.md` + SKILL.md / CLAUDE.md 引用）——用户裁决，消除无鉴权洞 |
| **P1** | ⑤ SDD 补「同形小任务合并派发」（与自家 CLAUDE.md #6 开销判据同源）；⑥ `spec-reviewer-prompt` 补 plan-mandated；⑦ 补 re-grade by effect；⑧ EP 补每任务「测试命令 → 结果」持久行；⑨ `finishing` 补 merged-停手 + push-被拒 2 句；⑩ `codex-tools.md` 按官方对齐（删 `close_agent`——官方 V2 已无此工具）；⑪ `gemini-tools.md` 删重复行；⑫ CLAUDE.md「仓库里没有任何辅助脚本」收窄语境 |

**本轮对上轮报告 3 处断言的更正：**

| 上轮断言 | 本轮实测 |
|---|---|
| `dispatching` 的 Real Example 被删 | **保留**（本台账 L181 已写对；真删的是 `## Verification` 标题，其 4 条已无损并入 §4） |
| `finishing` 官方 5 行新规则中「4 条 Lite 也缺」 | **证伪**：实缺 **2 条**（见 L356 更正） |
| 5 脚本的保证缺陷「N 处」 | 收敛为 **1 处**（`task-done` 的持久证据，且仅 Native 路径）；`SDD:119` 已含 range 守卫、`SDD:108` 已含围栏检查 |

**明确判定为「好的简化」（下轮不要加回来）：** 计划文件 `## Rulings` 承接官方 ledger（**优于官方**——计划文件受 git 跟踪，官方 ledger 是会被 `git clean -fdx` 毁掉的 scratch）；`## Verification` 并入 §4；diff 改「子代理自跑」+ range 守卫；删 Pre-flight 改由 writing-plans DAG 表承接；`Common Rationalizations` → 红线；`task-start` 无承接（Lite 无任务级审查）；EP「不派二次审查」与官方有意对齐。

**方法学陷阱（下轮复用）：** `$'\r'` 在本环境 Bash 工具**不展开** → `grep -c $'\r'` 退化为 `grep ''`（匹配全部行），恒报「全行 CRLF」；`grep -oP '[\x{4e00}-\x{9fff}]'` 恒返回 0，误报「零汉字」；`diff` 未归一化行尾时每行都报不同、diff 行数虚高数倍。正确做法：`tr -cd '\r' | wc -c` / `perl -CSD -p{Han}` / 归一化后 diff。

**行尾实态（实测更正）：** Lite `skills/` 是**文件级二态**（19 个纯 CRLF / 21 个纯 LF / **0 个混合**），非「混合」；官方副本全为 LF。CRLF 来自 `core.autocrlf=true` 的 checkout。`.gitattributes` 现仅覆盖 `*.sh`，`server.cjs`(CRLF) 与 `helper.js`(LF) 不一致——`.js/.cjs` 未受控。

---

## 第三轮对比（2026-09-24 v3）

全新四维（避开 v1/v2 已覆盖面）：**A 语义行为**（规则级对照，非文本 diff）/ **B Lite 内部一致性**（纯 Lite 侧自洽）/ **C 事故场景推演**（14 场景边界压力测试）/ **D 未来同步成本**。方法：**动态工作流**（Workflow 工具）——4 个 haiku 审计员并行 → 每维度 1 个 haiku 复核员逐条证伪 P0/P1 → 1 个盲区批评家找四维共同漏网面。9 子代理、887k tokens、33 分钟。主控对 P0/P1 全部亲验，**零翻案**；原始报告在 `.superpowers/compare/2026-09-24-v3/`。

**发现 33 项（P0×1 / P1×10 / P2×10 / info×12）+ 盲区 6 项。本轮修复 20 项：**

| 档 | 项 |
|---|---|
| **P0** | ① D1 安装契约无删除机制——45 个已拒/已删官方文件在 `cp -r` 后静默残留（含无鉴权 server.cjs；实测官方树 75 − 同名 30）→ 三处安装段改**先删后拷 + 正反向校验**（rm 13 路径 + 两条反向针） |
| **P1** | ② A5 `requesting-code-review:28` 教 `HEAD~1`/裸 `origin/main`，与自家 6 处红线矛盾（复核员定性：**Lite 相对官方的回归点**——官方同行注释的备选是 merge-base，中文化时被降级）→ 改 `git merge-base origin/main HEAD`；③ B1 README 双语索引 4 行路径指向不存在的位置（`subagent-driven-dev` 错误目录名 + 3 个裸文件名）→ 补目录前缀；④ B2 「自审化」中英两份各留一半旧表述（README.md ⑤ 节 + ASCII 块、README.en.md 流程图 Stage 1/2）→ 统一为作者自审两遍；⑤ B3 LICENSE 缺失（MIT 派生分发合规缺口，非单纯死链）→ 补 LICENSE（官方原文）+ NOTICE.md；⑥ C1 压缩恢复只有数据面（checkbox）无程序面 → SDD/EP 各补「中断恢复」规则（已 [x] 不重派、续跑前查半成品、信文件与 git log 不信记忆）；⑦ C2 EP:59「Rulings 会被后续任务读到」与自身读协议（每任务只读自己那一段）自相矛盾 → EP 取段前扫 Rulings 区 + SDD 派发表加第五组件「相关 Ruling」；⑧ C3 checkbox 仅总数自检（三种污染模式全穿透）→ 扩展状态抽查（抽 [x] 对照 git log）；⑨ C4 同层并行漏声明同文件时执行期零规则 → implementer-prompt 补「开工前检查目标文件」（意外改动 → BLOCKED）；⑩ D2 翻译型交织定性（patch 不可用）→ 新增「技能贴近度基线」表（见文末） |
| **P2** | ⑪ A2 SDD 补「派发时必须显式指定模型」（官方：缺省继承会话模型 = silently defeats 整套分档）；⑫ A3 EP 完成契约绑定 `verification-before-completion`（原全库仅 systematic-debugging 一处引用）；⑬ A4 「搁置判定（Declined to judge）」补消费者（EP 收尾第三项 + SDD 收尾句）；⑭ A6 EP 补代码围栏检查（对齐 SDD 同机制）；⑮ B4 结构树对 8 技能只列目录（15 文件未列）→ 记录不改（避免树膨胀）；⑯ B5 索引 11 文件不全 → 记录（与 B1 一并核过无其他错行）；⑰ C5 SDD:134 报告清掉补降级动作 + 统一口径（审查不依赖报告，报告是事后审计材料）；⑱ C6 Rulings 触发 2 现场改计划补在飞保护（同层未返回时推迟到层结束，或改后重发指针）；⑲ D3 下次同步 step 5 清单 3 → 8 技能；⑳ 盲区⑤ SDD description 补「任务基本独立」限定（原触发面比自家红线宽） |

**盲区批评家 6 项裁决：**

| 盲区 | 裁决 |
|---|---|
| ① 部署态四态不一致（注册表服务纯官方 5.1.0：Spike 0 命中、无 executing-plans、writing-skills 存活；本会话加载的却是中文 Lite） | **待办**：按新安装段重跑覆盖（动用户环境，时机由用户定） |
| ② 官方 skills/ 外运行面（hooks / plugin.json / 多平台清单 / tests）从未纳入对比 | **裁决：不接管**——Lite 定位是技能覆盖层，插件工程面由官方本体提供 |
| ③ 审计基线未钉 SHA（Lite 侧 30+ 文件未提交） | v3 报告头部已补基线声明；本节即存档 |
| ④ MIT 派生分发合规 | 已修（LICENSE + NOTICE，见 P1 ⑤） |
| ⑤ SDD description 丢「独立任务」限定 | 已修（见 P2 ⑳） |
| ⑥ 上游 6 天增量未核实（v6.4.1 快照是 09-18） | 下次同步 step 1 补「先 ls-remote 核实最新 tag」 |

**好的等价确认（info×12，勿修复）：** setup 并入所属任务为可接受弱承接；每任务审查员移除 = CLAUDE.md 决策 5/6 明文的核心取舍；修复循环 3 轮上呈 vs 官方 5 轮自裁 = 与门控文化自洽的有意分歧；finishing 硬编码 gh = 平台 drift 同族；UPSTREAM 历史条目带作废标注非死链；升级失效有双警告（运行时察觉 = 已知待办「版本标记」）；无子代理平台兜底两侧等价；升级路径 / Spike 保留 / 门控抗压逐条同构（官方 v6.4.1 已吸收同款文本）；EP 压缩后末尾审查证据链完整；同层失败隔离 Lite 明文覆盖。

**方法学（v3 新增）：** haiku 双层（审计 + 证伪复核）质量超预期——11 项 P0/P1 复核全确认、主控 20+ 项亲验零翻案；但复核员自己的 SDD diff 数字错 20 行（报 1045，实测 **1025**，主控定数）。盲区批评家是本轮性价比最高的角色（6 盲区中 2 个为当下事实级）。**结论不变：子代理数字必须主控复测定数。**

---

## 第四轮对比+审计（2026-09-24 v4）

用户三问：官网差异与优劣 / 自身是否有问题 / 是否合理。方法：**动态工作流**（8 个 haiku 子代理）——E 官方增量核实（联网）/ F 优劣裁决（10 机制）/ G 设计自洽 / H v3 修复回归，每维度证伪复核 + 盲区批评家。711k tokens。主控对 P0/P1 全部亲验，并**首次真实执行安装段**（临时目录双场景）。原始报告在 `.superpowers/compare/2026-09-24-v4/`。

**E：官方无增量。** v6.4.1（2026-09-19T00:31Z）仍是最新——ls-remote tags / GitHub API / releases 页 / main HEAD 四路交叉一致（tag 5bf4e78 == main HEAD，无「已 commit 未发版」增量）。最活跃 5 个 open PR 全部止于 2026-03-23。三轮对比基线全部有效，无需同步；v3 盲区⑥关闭。附注：官方从未发过 v6.4.0（跳号非缺漏）。

**F：优劣总评（10 机制，无一边倒）。** 取舍偏 Lite 4（契约前置到设计期 / **Rulings 进 git**——官方自认 ledger 死于 `git clean`、"a decision made in secret" / 指针化派发但有围栏残差 / 文档自审化）/ 纯取舍 4（DAG 分层 / 双执行路径——**官方 v6.4.1 已恢复 Native 内联** / 分层并行自认代价 / 三路径）/ 场景二分 2（审查门控：官方稳 Lite 省 / 中文化）。**主控终审：Lite 的结构性优势集中在持久化设计与成本阶梯；结构性代价集中在「规则级 vs 物理级」——围栏检查、提交互染、完成契约都靠自觉，官方靠脚本熔断。与「零脚本」定位自洽，是同一个决定的两面。** F 审计员同时纠正了主控任务书的 3 处过时前提（把三路径/Interfaces 块/Native 路径当「官方没有」）——台账 :59 早已正确记录同构，错在主控没查台账就写任务书；仓库文档无错。

**G：设计自洽 10 检查面——6 自洽 / 2 张力可接受 / 2 矛盾（均已修）。** v3 新加的 Rulings 六条规则全家桶放一起仍自洽。

**H：v3 修复回归——18/21 干净，2 项只落一半（已补），1 项守卫缺口（已补）。** 安装段首次真跑：场景 A（正常路径）rm→cp→正反向校验全链通过；场景 B（SP 拼错）实测**证伪** H3 的「静默失败」推演——cp 报错、校验失败可见、真实版本目录完好。

**本轮修复（10 项）：**

| 档 | 项 |
|---|---|
| **P1** | ① G1 SDD 模型分档自相矛盾（「快速审查→廉价」vs 审查员 sonnet 地板；复核员查出血统：官方原义仅为「小型修复 diff 的 re-review」，Lite 改写时扩大）→ 改官方原义并在地板条款收编例外；② G2 EP 红线「别把任务全文读进上下文」与自身 Setup「通读一遍」冲突（SDD 搬运未适配内联语境，`offset/limit` 是 SDD 派发词汇）→ 改「别每任务重读整份计划——Setup 通读一次即可」；③ H1 C2 修复只落一半（SDD 派发表五组件，但 implementer-prompt 仍「四样东西」、模板无 Ruling 槽位、SDD Per-Task 清单缺项——照模板派发则保护静默失效）→ 三套清单对齐（模板五样+表加行+「## 相关 Ruling」槽位+Per-Task 清单补全）；④ H2 C5 口径残留（SDD 整体 spec-review 步骤仍「+ 实现者报告路径」，与「输入不含报告路径」互斥）→ 删 |
| **P2** | ⑤ G3 EP 审查员模型界定覆盖侧（code-reviewer 最强 / spec-reviewer 标准档）；⑥ G4 writing-plans 补「执行器的可变面授权」（SDD 只翻 checkbox / EP 追加证据行 = 全部例外，非逐任务历史记录）；⑦ G5 brainstorming Bounded 终点补按交付物分流（纯文档/技能跳 code-review）；⑧ G6 计划头部 Base SHA 字段悬空 → SDD/EP Setup 各补「开工前记录 Base SHA」；⑨ H4 模型显式指定无模板槽位 → 两个 Task 骨架各加 model 字段行；⑩ H3 三处安装段加 `[ -n "$VER" ]` 守卫（实测证伪静默链后仍保留——报错更早、信息更明确） |

**盲区批评家 5 条裁决：** ② 安装段从未真跑 → 本轮已补（双场景实测）；③ F 前提修正未回灌 E/G/H → 主控评估影响有限（记录）；④ 证据无快照锚 → v4 报告头已补声明（根解待提交工作树）；⑤ RELEASE-NOTES 正向映射缺失 → 新待办；① `.gitignore` 忽略 `docs/` 与技能层契约冲突 → 新待办（待用户裁决）。

**方法学（v4 新增两条，与 v3 的「子代理数字必须主控复测」并列）：** （1）**推演必须实测**——H3 的「静默失败」被主控临时目录实测证伪；（2）**主控也会带错前提**——写任务书前必须先查台账（F 审计员纠正了主控 3 处，台账本来就有正确答案）。haiku 复核层连续两轮有效（本轮 F3/F5 两个 P1 被正确打回，台账行号引用精确）。

---

## 待办（已识别，未执行）

| 项 | 说明 |
|---|---|
| **全库措辞形式审查** | `Match the Form to the Failure` 的结论是「对**输出形状**问题，禁止式比不给指导还差」。Lite 多处用禁止式描述输出形状（各技能的「禁止开场白 / 过程叙述」清单、writing-plans 的「禁止占位符」等）。逐处判断该改成**正向配方**还是保留禁止式，是一次独立的全库改动，不夹带在同步里 |
| ~~**`render-graphs.js` 的 Windows 探测缺陷 + 调用加 `node` 前缀**~~ — **已关闭（2026-09-24 v2）：该文件随 `writing-skills/` 被用户删除，本项作废。** | **已修一半（2026-09-24）**：①`which dot` 在 Windows 上不存在 → 即便装了 graphviz 也恒报 not found，脚本唯一用途在 win32 **静默失效**；已改为 `execFileSync('dot', ['-V'])`；②官方 6.4.1 另有「打包器剥可执行位 → 裸路径 `Permission denied`，改用 `node ./render-graphs.js`」，**Lite 仍未改**（风险低：经 `cp -r` 安装保留 mode，zip 分发可能丢位）。成本 2 行 |
| ~~**`writing-skills` 第 12 行的技能目录说明**~~ — **已关闭（2026-09-24 v2）：该技能已被用户删除。** | 官方新版分别列出 Claude Code / Codex / Gemini 的路径与 `~/.agents/skills/` 别名；Lite 是 5.1.0 的旧版（只提 Claude Code + Codex）。中价值（影响个人技能的放置可发现性）|
| **5 个技能未中文化（原 6 个）** | **2026-09-24 v2 后续：`writing-skills` 已被用户删除 → 6 个减为 5 个。** **2026-09-24 实测更正口径**：原记「`dispatching-parallel-agents` 仍是全英文，与其余 13 个技能的语言约定不一致」→ **计数错**。实测 14 个 `SKILL.md` 的汉字数：**6 个为 0**（`dispatching-parallel-agents` / `receiving-code-review` / `systematic-debugging` / `using-git-worktrees` / `verification-before-completion` / `writing-skills`），另 `finishing-a-development-branch` 为英文主体（321 汉字）。按原口径排期会只中文化 1 个，漏掉 6 个。**2026-09-24 v2 精确化**：这 6 个技能**并非未改造**——归一化行尾后实测与官方的 diff 为 `using-git-worktrees` 54 行、`writing-skills` 31、`dispatching-parallel-agents` 14、`systematic-debugging` 9、`receiving-code-review` 4、`verification-before-completion` 2，且**这些改动本身也用英文写**；6 个的 description 与官方**逐字相同**。真正的缺陷是「**同一仓库两种语言**」，而非「6 个文件没动」。另：`dispatching-parallel-agents` 的 `## Real Example from Session`（26 行英文案例）**官方 6.4.1 仍保留**，原记「应与 `Example Workflow` 一并评估删除」应改判为**保留**（删除会成为 Lite 单方面偏离） |
| **报告契约缺「未解 bug」通道** | 三项摘要里「架构决策」有 Rulings 承接，「未解 bug / 下一步计划」只有模糊的「顾虑」，且「顾虑」没有明确的接收方处理流程。加它会给每次派发 +1~2 行，与判据 2 有张力，故暂缓裁决 |
| **house form 未对齐（`Common Rationalizations`）** | 官方 8 个技能有此表，Lite 只有 3 个。`requesting-code-review` 完全缺失（含「别自己 inline 审 diff」的护栏——**2026-09-24 已补**）；`finishing-a-development-branch`（60 行 vs 官方 14 行）、`using-git-worktrees`（44 行 vs 官方 9 行）仍是 `Common Mistakes` + `Red Flags` 两段旧形式，转表可省约 60 行。**注意：不只是形式统一**——官方 `finishing` 的表里至少 5 行编码了 6.2.0/6.3.0 的新规则（merged 结果失败、base 确认、push 被拒、stale worktree、PR 存活期保留）。**2026-09-24 v2 实测更正**：base 确认 / stale worktree / PR 存活期 **均已在 Lite 正文**（原记「4 条也缺」不成立）；实缺仅 **2 条**（merged 结果失败就停手、push 被拒诊断），已单列修复 |
| **视觉伴侣 server 鉴权** | **2026-09-24 v2 已裁决：从 Lite 删除该 server。** 原问题：官方 6.0.0 加了 per-session key（Closes #1014），Lite 版 `brainstorming/scripts/server.cjs` **无任何鉴权**（仅 WebSocket 握手 key）→ 同网可读整个 brainstorm，**或注入被 agent 当作用户输入的事件**。删除面：`brainstorming/scripts/`（5 文件）+ `visual-companion.md`（整份是 server 操作手册）+ `brainstorming/SKILL.md` 的引用 + CLAUDE.md 仓库结构行。删除后 Lite 的「零辅助脚本」宣称才接近成立 |
| **Lite 版本标记 + 兼容版本约束** | 安装态与运行态无校验机制（见「共盲区」）。官方有 `.claude-plugin/plugin.json` + `bump-version.sh`；Lite 无任何版本标记 → 无法回答「运行时跑的是哪一版 Lite」。实测已发生漂移（安装目录 bootstrap 121 行、无三路径）。建议加一行版本标记并写入安装校验 |
| **最小结构冒烟测试** | Lite 零测试；且**官方 66 个测试不可直接复用**（`test-subprocess-driven-development.sh` 断言的是官方审查顺序与 `Step 1` 编号，Lite 两者都没有）。候选 3 项（纯文件断言、零依赖）：① 每个技能 frontmatter 合法 ② 技能引用的其他技能/文件都存在 ③ 安装目录的 `using-superpowers/SKILL.md` 与仓库一致。**与判据 4「不新增维护面」有张力，待用户裁决** |
| **5 个技能中文化** | **2026-09-24 v2 裁决：暂不做**（工作量大，不夹带在修复轮里）。见上「待办」语言口径更正。（原「`writing-skills` 元技能是否中文化」这一子问题**已随该技能被删除而消失**——它已不在库中。） |
| **`.gitattributes` 覆盖不足** | 现仅 `*.sh text eol=lf`。实测 `brainstorming/scripts/server.cjs` 是 CRLF 而 `helper.js` 是 LF（`.js/.cjs` 未受控）；Lite `skills/` 整体是文件级二态（19 纯 CRLF / 21 纯 LF）。注：删除视觉伴侣后这两个脚本一并消失，本条**自动消解** |
| **平台映射文件已 drift** | `codex-tools.md`（Lite 53 行 vs 官方 108 行）与 `gemini-tools.md`（50 vs 63）都停留在 5.1.0 时代（**v3 更正行数**：v2 修复后为 53/50，原记 51/51 已漂移）。本轮只修 `close_agent`（官方 V2 已无该工具）与重复行，**其余未对齐**。官方已扩展为 7 个平台（antigravity / claude-code / codex / gemini / hermes / muse / pi） |
| **`copilot-tools.md` 去留** | 官方 6.1.0 已删（判定「已无 harness 专属内容」）；Lite 保留并在维护一份上游已无对照的文件 → 未来 Copilot 工具名变化时无上游参照，映射会静默过期 |
| ~~**零产物 vs 每任务证据**~~ — **已解决（2026-09-24 v2 修复，v3 台账补记）** | v2 在 EP 收尾加了「每任务章节内追加证据行」（计划文件内、紧接 checkbox）；SDD 不适用——SDD 有 `task-N-report.md` + RED/GREEN 证据承接。不需要计划文件之外的产物 |
| **四处「自审」定义是否统一** | brainstorming（结构质量 + 需求一致性）/ writing-plans（5 维）/ SDD（4 维）/ EP（完成契约 4 项）各定义一套清单，维度名互不相同。同一模式四处重述，新增交付物时不知该改哪份 |
| **8 条纯推理机制是否补实测** | 「Lite 独有」表 11 条自研机制中**仅 1 条有实测**（固定开销判据，来自 `/context`）。其余为纯推理；指针化派发有一个 n=1 无对照的观察（某会话派发 prompt 42k 字符、99% 是粘贴历史）。补实测成本高、收益不明 |
| **重跑安装覆盖（v3 盲区①）** | 本机注册表实际服务**纯官方 5.1.0**（Spike 针 0 命中、无 executing-plans、writing-skills 存活），会话加载的中文 Lite 来源不在注册表路径——「静默回退」是当下事实非未来风险。按新版安装段（先删后拷）重跑覆盖即可对齐。**动用户环境，时机由用户定** |
| **官方 skills/ 外运行面（v3 盲区②）** | hooks/session-start（SessionStart 硬注入 bootstrap）、hooks.json + run-hook.cmd、多平台 plugin 清单、tests/、AGENTS.md 等 Lite 从未接管（安装只覆盖 skills/）。**已裁决：不接管**——Lite 定位是技能覆盖层，插件工程面由官方本体提供；官方升级后 hooks 注入文本会随之更新，重跑覆盖即可（README 已警告） |
| **RELEASE-NOTES 正向映射（v4 盲区⑤）** | 台账是自下而上的发现式记录，无自上而下的完备性证明：官方 RELEASE-NOTES.md（v5.1.0→v6.4.1 全部变更，~100KB）无「每条变更 → 台账裁决位置」的正向映射。非核心技能（systematic-debugging / receiving-code-review / verification-before-completion 等）的静默漏更新正落在这条缝里。独立轮次，工作量中等 |
| **`.gitignore` 忽略 `docs/` 与技能层契约冲突（v4 盲区①，待用户裁决）** | spec/plan 从此不受版本控制（换机器/克隆/`git clean -fdx` 都会丢计划）；worktree 链路断裂——gitignored 文件不随 checkout 出现在 worktree，指针化派发的计划路径悬空；该裁决未记台账（违反「每项裁决记入台账」契约）。已向用户呈现后果，未获回退指示，现状保持。若保持：建议 spec/plan 改存受控路径，或在技能里注明此约束 |

---

## 下次同步流程

1. 取官方新版本（`git ls-remote --tags https://github.com/obra/superpowers.git` 先核实最新 tag，别对着过时快照同步），读 `RELEASE-NOTES.md` 中 v6.4.1 之后的新段
2. 逐条对照本台账：
   - 已在「已采纳 / 已拒绝 / 已同构」中出现 → 跳过
   - 新条目 → 列入「待裁决」
3. 对待裁决项按**判据**逐条裁决，把结论与原因追加到对应表格
4. 更新文首的「当前上游」与「上次同步」
5. 若官方改动触及 Lite 已改造的技能，需额外 diff 该技能的**正文**，不只看 release notes——**远 divergence 共 8 个**：brainstorming / writing-plans / SDD / executing-plans / test-driven-development / finishing-a-development-branch / requesting-code-review / using-superpowers（分级见下方「技能贴近度基线」）
6. **别漏元技能。** `writing-skills` 在 2026-09-23 那次同步中被漏掉（只处理了 CSO→SDO 的版本分叉，没做系统性 diff）。它是**技能的文件来源技能**——漏掉它，等于漏掉后续所有技能写法改进的入口。（**2026-09-24 v2：该技能已由用户删除，本条自此后仅作历史记录。**）

---

## 技能贴近度基线（2026-09-24 v3 实测，下次同步后更新）

归一化行尾后 diff（官方 v6.4.1 → Lite），按下次同步的动作分级：

| 技能 | diff 行 | 分级 | 形态 | 预计动作 |
|---|---:|---|---|---|
| verification-before-completion | 2 | 贴近 | 英文逐字 | 直接套 |
| receiving-code-review | 4 | 贴近 | 英文逐字 | 直接套 |
| systematic-debugging | 9 | 贴近 | 英文逐字 | 直接套 |
| dispatching-parallel-agents | 14 | 贴近 | 英文逐字 | 直接套 |
| using-git-worktrees | 54 | 中 | 主体逐字 + 尾部自研 | 小改 |
| using-superpowers | 88 | 远 | 翻译交织 | 重译落位 |
| requesting-code-review | 136 | 远 | 翻译交织 | 重译落位 |
| finishing-a-development-branch | 210 | 远 | 翻译交织 | 重译落位 |
| test-driven-development | 340 | 远 | 翻译交织 | 重译落位 |
| writing-plans | 350 | 远 | 翻译交织 | 重译落位 |
| brainstorming | 452 | 远 | 翻译交织 | 重译落位 |
| executing-plans | 465 | 远 | 全文重写 | 设计级移植 |
| subagent-driven-development | 1025 | 远 | 设计级重写 | 设计级移植 |

「翻译交织」= 官方行被逐行替换为中文（change-hunks 主导、纯新增块 ≈ 0）——**patch / 三方合并不可用**，同步成本的真实单位是「官方 delta 条数 × 重译落位难度」，不是 diff 行数。辅助文件：`code-reviewer.md`（278）/ `implementer-prompt.md`（301）为重写级；`writing-good-tests.md` Lite 主动重写（66 行 vs 官方 198）；systematic-debugging 的 4 个附属 .md diff=0；Lite 独有 3 文件（`diagram-driven-design.md` / `spec-reviewer-prompt.md` / `copilot-tools.md`）零冲突。

---

## 正向映射：官方 v6.0.0→v6.4.1 全部变更 → Lite 裁决（2026-09-24 发版前完成）

自上而下的完备性证明：fork 窗口（基线 v5.1.0 之后）的全部官方 release 条目逐条对账（v5.1.0 自身为 fork 基线，不在窗口内）。**77 条全部有裁决承接，历史漏裁决 2 条已在本节补裁。**

| 官方版本 | 条目 → Lite 裁决（括号内为台账/文件落点） |
|---|---|
| v6.4.1 | diagnosing-superpowers → 已拒绝（:82）；EP 重建 Native → 已采纳（决策 6）；交接二选一+成本 → 已采纳；批准 scope≠批准 plan → 已采纳（HARD-GATE 阶段级授权）；Review Focus 5 槽 → 已采纳（writing-plans）；brainstorming 意图回述 → 已采纳；合理用户期望+Declined to judge → 已采纳（v3 补消费者）；BASE 改 merge-base → 已采纳（v3 修，含 Lite 回归点修正）；TDD 项目套件定义 green → 已采纳（TDD:170）；plan-scoped workspace → 同构（`.superpowers/sdd/<plan-slug>/`）；review-package range 守卫 → 同构（SDD:119 规则级）；**控制器降档嵌套 #2320 → 补裁决：拒绝**；OpenCode/Muse/Qwen → 已拒绝（:83）；打包器执行位 → 天然不适用（零脚本）；issue 模板/docs/testing/AGENTS.md → 工程面不接管（v3 盲区②） |
| v6.3.0 | Devin/Hermes/Grok → 已拒绝；三路径分类 → 已同构（:59/:110）；控制器不 stall → 已采纳；pre-flight 记录 → 已拒绝（上移 DAG，v2 好的简化 4）；小任务合并派发 → 已采纳（SDD:185）；禁嵌套派发 → 已采纳（红线）；Spec 指针+setup 读 → 已采纳；**审查员重读不可读证据 #2089 → 补裁决：部分承接**（「无法从 diff 判定」+按需读代码覆盖主语义，重读 vs 重跑的显式区分不引入）；circuit-breaker 进 Finish → 已采纳（收尾汇总）；Codex 事件驱动/固定 model → drift 待办；worktree remove 不毁未跟踪 → 已采纳（finishing:196-200）；render-graphs Windows → 随技能删除关闭；Copilot 背景化 → drift 待办 |
| v6.2.0 | workspace plan-scoped → 同构（规则级 plan-slug）；ledger 首行计划名 → 同构（checkbox 真相源天然 per-plan）；resume-implementer+re-review+5 轮熔断 → 已裁决（A9：Lite 3 轮上呈为有意分歧；「不派二次审查」有意对齐）；全库压缩运动 → 已采纳（fork 时已删）；writing-good-tests 重建 → 已采纳（Lite 重写 66 行）；TDD 反 rationalization 行 → 覆盖（重写版）；finishing 去丢弃选项 → 已采纳（:96）；forge 中性 → info 记录（A10 drift 同族）；worktree 路径 bug → 已含；hook Git Bash dispatch → 工程面；Gemini 恢复 → 天然保留；find-polluter 修复 → 已采纳（diff=5）；Codex 包/SDD 测试 → 工程面；死链清理 → 同构（claude-code-tools 已删；copilot-tools 去留在待办） |
| v6.1.1 | Codex hooks:{} / 死代码 / 包脚本 → 工程面不接管 |
| v6.1.0 | bootstrap 压缩 → 已采纳（全中文重写版）；references 剪枝 → 已采纳（Lite 留 3 个）；Codex marketplace/hook → 工程面；Gemini 删除 → 未跟随（保留，drift 待办） |
| v6.0.3 | scratch 移出 .git/ → 已采纳（`.superpowers/sdd/` + .gitignore） |
| v6.0.2 | evals 子模块 → 工程面 |
| v6.0.1 | Codex 版本显示/同步 → 工程面 |
| v6.0.0 | 两审查员→一 → 已拒绝（决策 5）；末尾整体审查 → 已采纳；pre-flight 预检 → 已拒绝（上移 DAG）；diff 走文件 → 同构（指针化+自跑 diff，好的简化 3）；**每次派发必写明模型 → 已采纳（v4 补——曾为漏项）**；禁压制 finding → 已采纳（派发禁令节）；审查员只读+怀疑 → 已采纳；证据强化/报告文件化/ledger 恢复 → 已采纳（file:line 契约+报告契约+checkbox 真相源）；Global Constraints → 已采纳；Interfaces 块 → 已采纳（形态不同：契约章节+Consumes，F2 记录）；right-sizing → 弱承接（A7 info）；视觉伴侣安全模型 → 已裁决删除（v2 P0-4）；Kimi/Pi/Antigravity → 已拒绝；harness 中性词汇+映射 → 已采纳（中文+3 平台）；finishing forge 中性 → info（A10）；CSO→SDO → 已记录（:413）；Match Form/Micro-Test → 待办引用（:385）；evals/drill → 工程面；systematic-debugging keyword 修复 → 已采纳（diff 含 :241 Ultrathink 连字符）；Windows printf/前台/bootstrap → 工程面/中文重写覆盖；TDD 链接 → 覆盖；worktrees 步骤编号 → 已修（git 6d9fa89）；PR/issue 披露 → 工程面 |

**本节补裁决 2 条：**

| 官方条目 | 裁决 | 理由 | 错了代价是什么 |
|---|---|---|---|
| #2320 控制器降档嵌套（v6.4.1，opt-in：控制器作为嵌套子代理在中档模型上跑一层） | **拒绝** | Lite 极简路线：主会话即控制器，嵌套降档徒增复杂度；要省成本直接用更便宜的会话模型开新会话 | 深度成本敏感的多任务计划中少一档省法；可接受——用户仍可通过会话模型选择获得同等成本控制 |
| #2089 审查员重读不可读证据而非重跑套件（v6.3.0） | **部分承接** | SDD「无法从 diff 判定」+按需读代码已覆盖主语义；重读 vs 重跑的显式区分不引入（零脚本路线，措辞收益小） | 极端场景下审查员可能多跑一次套件，浪费一次执行；可接受 |

**结论：fork 窗口完备性证明达成——官方 v6.0.0→v6.4.1 的每一条变更都有 Lite 侧裁决，无静默漏项。**
