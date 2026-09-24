# 上游跟踪台账

**Fork 点：** superpowers **v5.1.0**（2026-04-30）
**当前上游：** superpowers **v6.4.1**（2026-09-18）
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
| **审查员禁预判 / 只读 / 「无法从 diff 判定」** | 6.0.0 | `subagent-driven-development/SKILL.md`、`spec-reviewer-prompt.md` | 真实会话中抓到控制器教审查员忽略 finding 并已发布；审查员跑 `git checkout` 曾孤儿化后续 commit |
| **计划 `Spec:` 指针** | 6.3.0 | `writing-plans/SKILL.md` | 计划冲突对着**设计**裁决，而不是猜 |
| **整体审查 BASE 用 `git merge-base origin/main HEAD`** | 6.4.1 | `subagent-driven-development/`、`spec-reviewer-prompt.md` | 裸 `origin/main` 在 main 前进后会把 main 的新文件显示成**幻影删除** |
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
| **文档审查自审化**（brainstorming 结构质量自审 + writing-plans 自审） | 6.0.0–6.4.1 | `brainstorming/`、`writing-plans/` | 官方 `Self-Review` 明写 "not a subagent dispatch"，两个 `*-document-reviewer-prompt.md` 在官方已成**刻意孤儿**。Lite 原把它们当「孤儿引用」修复回工作流，等于把官方主动删掉的重流程恢复。**Lite 改后优于官方**：官方自审 4 项全是结构质量，**丢掉了需求一致性检查**；Lite 保住「需求遗漏/曲解/假设」三项，且少一次子代理启动 |
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
| **任务级独立审查**（每任务一个 reviewer） | 6.0.0 | 末尾整体审查门控已覆盖需求与质量；官方自己也在 6.4.1 提供了无任务级审查的 Native 模式，等于承认它可省 | 任务级问题暴露更晚，修复成本略高 |
| **计划预检冲突扫描表** | 6.0.0 / 6.3.0 | 增加一整个前置阶段；Rulings 现场裁决已覆盖同类问题 | 个别任务间冲突在执行中才发现 |
| **fix loop 五轮熔断 + scoped re-review 模板** | 6.2.0 | Lite 任务级只自审、不派审查员，不存在任务级 loop；整体审查失败后的修复循环已由 ONE fix dispatch 覆盖 | 整体修复可能多跑一轮 |
| **`diagnosing-superpowers`** | 6.4.1 | 会话事后诊断（20 文件 857 行），与轻量目标无关 | 无——用户可直接看会话记录 |
| **8 个新 harness 支持**（OpenCode / Muse / Qwen / Grok / Kimi / Pi / Antigravity / Devin / Hermes） | 6.0–6.4 | 每个 harness 需独立 bootstrap + 工具映射 + 测试，维护面过大；Lite 只留 Codex / Copilot / Gemini | 这些平台的用户需自行适配 |
| **小同形任务批量派发** | 6.3.0 | 与 Lite 的「同层并行」重叠，收益不明 | 微任务计划的子代理成本略高 |
| **`Common Rationalizations` / `Example Workflow` 段** | 6.2.0 | 面向「已决定使用本技能」的读者属冗余篇幅 | 无 |
| 游标清理类（`find-polluter.sh`、`render-graphs.js`、packaging 脚本） | 各版本 | 与 Lite 无脚本的路线冲突 | 无 |
| **`Micro-Test Wording Before Full Scenarios`** | 6.0.0 | 它是**流程**（5+ reps × 多变体 × 人工读每个匹配），不是文档；兑现频率低。按判据 1「减少不必要的流程」排不上 | 措辞问题更晚才在压力场景中暴露 |

### 二次复核拒绝（2026-09-23）

| 上游项 | 引入版本 | 拒绝原因 | 错判代价 |
|---|:--:|---|---|
| **controller「one layer down」降级**（controller 作为 mid-tier 嵌套子代理） | 6.4.1 | opt-in 特性，与 Lite「禁止嵌套派发」的**精神**不冲突（那是禁子代理再派子代理，这是 controller 自身降级），但 Lite 已用「轮次比 token 单价更重要」覆盖同一成本问题；引入会新增一条需要解释的例外 | 在超长 SDD 计划上少省一半协调成本 |
| **同 basename 计划工作区冲突修复** | 6.4.1 | Lite 无 `sdd-workspace` 脚本，工作区以 `<plan-slug>` 命名且由计划文件名派生；同名计划在 Lite 流程下是**用户侧命名问题**，可用改名解决，不值得为此加规则 | 极端情况下两个同名计划共用目录，需手工改名 |
| **`review-package` 拒绝空/非同源 `BASE..HEAD`** | 6.4.1 | Lite 无该脚本；等价保护已由「BASE 必须是派发前记录的 SHA，禁用 `HEAD~1`」这条规则承担 | 无 |
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

| 文件 | 官方 6.4.1 | Lite | Δ |
|---|---:|---:|---:|
| SKILL.md | 285 | 363 | +78 |
| diagram-driven-design.md | 不存在 | 174 | +174 |
| spec-document-reviewer-prompt.md | 49 | 51 | +2 |
| visual-companion.md | 299 | 286 | −13 |
| scripts（5 个） | 1432 | 860 | −572 |
| **合计** | **2350** | **1734** | **−616** |

**结论：Lite brainstorming 整体比官方轻 616 行。** 唯一比官方长的是 `SKILL.md`（+78），已由下方「文档瘦身」处理。

**教训：** 跨仓库比行数时先统一文件类型口径；`wc -l` 的合计值依赖 `find` 的匹配规则，换一次脚本就换一个结论。

---

## 待办（已识别，未执行）

| 项 | 说明 |
|---|---|
| **全库措辞形式审查** | `Match the Form to the Failure` 的结论是「对**输出形状**问题，禁止式比不给指导还差」。Lite 多处用禁止式描述输出形状（各技能的「禁止开场白 / 过程叙述」清单、writing-plans 的「禁止占位符」等）。逐处判断该改成**正向配方**还是保留禁止式，是一次独立的全库改动，不夹带在同步里 |
| **`render-graphs.js` 调用加 `node` 前缀** | 官方 6.4.1 修复：打包器会剥掉可执行位，裸路径调用报 `Permission denied`，故改为 `node ./render-graphs.js`。**Lite 风险低**（经 `cp -r` 安装，git 保留 mode 100755），但 zip 分发可能丢位。成本 2 行 |
| **`writing-skills` 第 12 行的技能目录说明** | 官方新版分别列出 Claude Code / Codex / Gemini 的路径与 `~/.agents/skills/` 别名；Lite 是 5.1.0 的旧版（只提 Claude Code + Codex）。中价值（影响个人技能的放置可发现性）|

---

## 下次同步流程

1. 取官方新版本，读 `RELEASE-NOTES.md` 中 v6.4.1 之后的新段
2. 逐条对照本台账：
   - 已在「已采纳 / 已拒绝 / 已同构」中出现 → 跳过
   - 新条目 → 列入「待裁决」
3. 对待裁决项按**判据**逐条裁决，把结论与原因追加到对应表格
4. 更新文首的「当前上游」与「上次同步」
5. 若官方改动触及 Lite 已改造的技能（brainstorming / writing-plans / SDD），需额外 diff 该技能的**正文**，不只看 release notes
6. **别漏元技能。** `writing-skills` 在 2026-09-23 那次同步中被漏掉（只处理了 CSO→SDO 的版本分叉，没做系统性 diff）。它是**技能的文件来源技能**——漏掉它，等于漏掉后续所有技能写法改进的入口
