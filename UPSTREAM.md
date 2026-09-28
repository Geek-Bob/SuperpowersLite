# 上游跟踪台账

**Fork 点：** superpowers **v5.1.0**（2026-04-30）
**当前上游：** superpowers **v6.4.1**（2026-09-19T00:31Z，2026-09-24 四路交叉核实仍为最新）
**Lite 版本：** `6.4.1-l2`（l1=四轮对比修复+完备性证明；l2=插件市场结构）
**上次同步：** 2026-09-23（v5.1.0 → v6.4.1）· 同日二次复核
**发版：** v6.4.1-l1（commit 2a7e5a1）· v6.4.1-l2（commit 2106fce）——历史轮次见文末索引

上游每个版本的变更都记在官方 `RELEASE-NOTES.md`。**同步时先读它**，不必重跑全量 diff。

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

| 上游项 | 引入版本 | 落点 | 采纳原因 |
|---|:--:|---|---|
| **Native 内联执行**（`executing-plans` 从 64 行 stub 重建） | 6.4.1 | `executing-plans/`（新建） | ①成本阶梯断层：Bounded 无计划、SDD 最贵，缺中间档；②官方明说紧耦合任务不该用 SDD；③无子代理工具的平台（Codex/Copilot/Gemini）原本无路可走 |
| **执行交接二选一 + 成本说明 + 按计划推荐** | 6.4.1 | `writing-plans/SKILL.md` | 让用户主动选更便宜的路径；与 HARD-GATE 兼容 |
| **SDD `when-to-use` 门槛** | 6.4.1 | `subagent-driven-development/SKILL.md` | 官方决策树明说紧耦合 → 不用 SDD |
| **bootstrap 压缩**（图→散文、折章节） | 6.1.0 | `using-superpowers/SKILL.md` | bootstrap 每会话注入；125 行 → 79 行 |
| **TDD：项目测试套件定义 green** | 6.4.1 | `test-driven-development/SKILL.md` | 官方 12 次探针 11 次只跑被点名测试文件，隔壁坏测试无人发现 |
| **审查员禁预判 / 只读 / 「无法从 diff 判定」** | 6.0.0 | SDD / `spec-reviewer-prompt.md` / `code-reviewer.md` | 真实会话抓到控制器教审查员忽略 finding；审查员 `git checkout` 曾孤儿化 commit。**补记：官方也落在 `code-reviewer.md`**，原台账漏记导致最贵的整体 code-reviewer 席位长期无只读约束 |
| **整体审查 BASE 用 `git merge-base origin/main HEAD`** | 6.4.1 | SDD / `spec-reviewer-prompt.md` / `requesting-code-review/SKILL.md` | 裸 `origin/main` 在 main 前进后把新文件显示成幻影删除。**补记：官方也落在 `requesting-code-review:28`**，原漏记 → Lite 该行曾写「或 origin/main」自相矛盾，已修 |
| **finishing：菜单不展示「丢弃」** | 6.2.0 | `finishing-a-development-branch/SKILL.md` | 「丢弃」与「合并」并列展示等于推销销毁已测试的工作 |
| **finishing：worktree 移除被拒不自行 `--force`** | 6.3.0 | 同上 | 被拒 = 该 worktree 有别处不存在的文件，`--force` 永久销毁；改停下、列文件、征询用户 |
| **writing-skills：`Match the Form to the Failure`** | 6.0.0 | （该技能已删除） | 对输出形状问题禁止式实测比无指导还差——结论已移用至「审计方法学」与 SDD 重写 |
| **修 `@file` force-load 引用（3 处）** | 6.0.0 | TDD / writing-skills | `@file` 语法立即 force-load，烧 200k+ 上下文——直接命中判据 2 |
| **brainstorming 意图回述**（发现意图→回述供纠正→带进设计） | 6.4.1 | `brainstorming/SKILL.md` | 官方头号新增，漏检设计方向的源头；请求已含目的时直接回述，不加流程长度 |
| **code-reviewer `Declined to judge` 清单 + 合理用户期望判据** | 6.4.1 | `requesting-code-review/code-reviewer.md` | spec 沉默 ≠ 许可；搁置判定逐条上呈，不被静默丢弃 |
| **文档审查自审化** | 6.0.0–6.4.1 | brainstorming / writing-plans | 官方 `Self-Review` 明写 "not a subagent dispatch"。**注意：**官方自审 4 项含 `placeholder scan` 与 `scope check`，Lite 已补（v1） |
| **Native 末尾审查用最强模型** | 6.4.1 | `executing-plans/SKILL.md` | 内联执行省了每任务 fresh context，末尾审查员是整轮唯一一次买独立视角，不该降级 |
| **计划 `Spec:` 指针** | 6.3.0 | `writing-plans/SKILL.md` | 计划冲突对着设计裁决，而不是猜 |
| **小任务合并派发** | 6.3.0 | SDD | 每次派发重付数十 k 固定开销，同形小任务最付不起 |
| **禁嵌套派发** | 6.3.0 | SDD | 嵌套 = 重复审查席位 + 上下文树指数爆炸 |
| **计划文件 Rulings 区** | 6.3.0 | SDD / writing-plans | 原先冲突上呈，改为记 Ruling 继续 |
| 三路径分类 Spike / Bounded / Architectural | 6.3.0 | brainstorming | （fork 前已同构，此处归类采纳） |
| Global Constraints 逐字块 | 6.0.0 | writing-plans | |
| 每任务 Interfaces（Consumes/Produces，Lite 升级为 DAG 自动分层） | 6.0.0 | writing-plans | |
| Review Focus 章节 | 6.4.1 | writing-plans | |
| 工作区 plan-scoped（`.superpowers/sdd/<plan-slug>/`） | 6.2.0 | SDD | |
| 暂存文件移出 `.git/` | 6.0.3 | SDD | |
| 每次派发声明模型 | 6.0.0 | SDD | 缺省继承会话模型 = 静默击穿分档 |
| 审查员用 `file:line` 举证 | 6.0.0 | spec-reviewer-prompt | |
| `writing-good-tests.md` 替代 `testing-anti-patterns.md` | 6.2.0 | TDD（Lite 重写 66 行） | |

### 已拒绝

| 上游项 | 引入版本 | 拒绝原因 | 错判代价 |
|---|:--:|---|---|
| **ledger / `progress.md`** | 6.0.0 | 计划文件 checkbox 已是唯一持久化真相源；再造一份只会制造第二个会不同步的真相源 | 上下文压缩后需从 `git log` 恢复，多花几轮 |
| **SDD 脚本（`task-brief` / `review-package` / `sdd-workspace` / `task-start` / `task-done`）** | 6.0.0–6.2.0 | 用 offset/limit 行号指针 + 子代理自跑 git diff 以更低成本达成同样目的；脚本还引入自身缺陷（参数解析、CRLF、执行位丢失）。**保证已用规则逐项承接**：围栏检查、range 守卫、`git clean` 警告、TDD 证据 | 派发 prompt 略长；无功能损失 |
| **任务级独立审查**（每任务一个 reviewer） | 6.0.0 | 末尾整体审查门控已覆盖。**复核更正原范畴错误：**官方 Native 能省每任务审查，是因为同时付了三样补偿物（brief 作 spec、ledger 作记忆、TDD 作每任务门控），Lite 三样都不成立 | 任务级问题暴露更晚，修复成本略高 |
| **两审查员→一**（v6.0.0） | 6.0.0 | Lite 是整体审查门控（spec 必跑 + code 按交付物），不是每任务双审——机制不同构，无从承接 | 无 |
| **`diagnosing-superpowers`**（20 文件 857 行） | — | 会话事后诊断，与轻量目标无关 | 无 |
| **官方 `Real Example from Session` 26 行英文案例** | — | 官方 6.4.1 仍保留 → 删除会是 Lite 单方面偏离 | 无 |
| **平台映射 `claude-code-tools.md`** | — | 内容 100% 是被 Lite 拒绝的 one-layer-down | 无 |
| **视觉伴侣 server + `visual-companion.md`** | — | 官方 6.0.0 加 per-session key，Lite 版无鉴权（同网可读整个 brainstorm 或注入事件）→ 整体删除，消除无鉴权洞；连带使「零脚本」宣称成立 | 失去可视化界面；可接受 |
| **#2320 控制器降档嵌套** | 6.4.1 | Lite 极简路线：主会话即控制器，嵌套降档徒增复杂度；要省成本直接换更便宜的会话模型 | 深度成本敏感场景少一档省法；可接受 |
| **#2089 审查员重读不可读证据** | 6.3.0 | 部分承接：「无法从 diff 判定」+ 按需读代码已覆盖主语义；重读 vs 重跑的显式区分不引入（零脚本路线） | 极端场景审查员多跑一次套件；可接受 |
| **Kimi/Pi/Antigravity/Devin/Hermes/Grok/OpenCode/Muse/Qwen 平台** | 6.0.0–6.4.1 | Lite 只支持 Codex/Copilot/Gemini 三平台 | 少数平台用户不可用 |
| **pre-flight 预检** | 6.0.0 | 上移至 writing-plans DAG——依赖在分层时已解析 | 无 |

### 已独立同构（双方各自走到同一设计，无需动作）

| 机制 | 说明 |
|---|---|
| 三路径分类 | 官方 6.3.0 加入时 Lite 已有（fork 前自研） |
| 计划文件 `## Rulings` 承接官方 ledger | **优于官方**——计划文件受 git 跟踪，官方 ledger 是会被 `git clean -fdx` 毁掉的 scratch |
| diff 走文件 / 子代理自跑 | 指针化 + 自跑 diff，同构且更简 |
| workspace plan-scoped（规则级 plan-slug） | 与官方同构 |
| plan-scoped workspace / review-package range 守卫 | 规则级承接 |
| 全库压缩运动 | fork 时已删（Lite 天然更简） |
| writing-good-tests | Lite 重写版（66 行 vs 官方 198） |

---

## Lite 独有（官方没有）

| 机制 | 价值 |
|---|---|
| **指针化派发**（`offset`/`limit` 行号窗口） | 用规则替代脚本，正文物理上不进上下文 |
| **审查按交付物分流**（spec-review 必跑；code-review 仅交付物含可执行代码时） | 免掉对 Markdown 无效的审查项。**防回退论证（勿删）：** code-review 的检查项（错误处理、类型安全、Schema 迁移、安全隐患）对技能 Markdown 是无效项——无控制流、无类型、无运行时、无 schema，硬跑只产噪音 finding，并诱使修复者为过审改写文档措辞。需求侧对文档完全有效（漏需求/曲解/范围蔓延/任务间接口不一致在文档里同样成立）。夹带内嵌代码片段时只审片段——防一刀切 |
| **零辅助脚本**（官方 SDD 3 个 + executing-plans 2 个） | 无脚本自身缺陷，无维护面 |
| **「轮次比 token 单价更重要」** + 审查员/实现者的中档模型地板 | 官方只按任务类型推荐模型，未考虑轮次成本 |
| **Prompt Caching 前缀稳定** | 命中缓存按 10% 计费 |
| **ASCII → Mermaid 双阶段图表** | 交互快迭代，文档正式表达 |
| **契约与接口章节** | 并行的前提；官方只有 Interfaces 块而无自动分层 |
| **Consumes 文件指针**（`(@路径)`） | 下游子代理直接 Read 契约定义，免去全库 Grep |
| **「固定开销 × 任务数」判据** | 每次派发重付数十 k token 启动开销，任务少时占大头 → 判据从「任务多就走 SDD」变为「隔离收益抵得过启动费才走 SDD」（实测见「成本校准」） |
| **TDD 测试输出重定向** | 全量套件日志数千行；重定向到文件 + grep 失败名与汇总行，只读关键行回上下文 |
| **插件名 superpowers 与官方同名互斥** | 库内几十处 `superpowers:xxx` 技能引用不改前缀，改前缀=全库改动+每次同步多维护一层差异；Lite 语义即「官方替代品」，不能与官方共存 |

> ⚠️ 注意：官方 6.1.0 曾把 bootstrap 的图换成散文（理由是每会话成本）。Lite 的双阶段图表策略用于**设计文档**，不与 bootstrap 冲突——两处用途不同。

---

## 已裁定等价 / 更优，勿再标记为缺陷

历轮对比中实测确认与官方等价或更优的设计——**勿修复，勿再标记**：

| 项 | 裁决 |
|---|---|
| setup 并入所属任务 | 可接受弱承接 |
| 每任务审查员移除 | CLAUDE.md 决策 5/6 明文的核心取舍 |
| 修复循环 3 轮上呈 vs 官方 5 轮自裁 | 与门控文化自洽的有意分歧 |
| finishing 硬编码 `gh` | 平台 drift 同族 |
| UPSTREAM 历史条目带作废标注 | 非死链 |
| 升级失效有双警告 | 运行时察觉 = 已知待办「版本标记」 |
| 无子代理平台兜底 | 两侧等价 |
| EP「不派二次审查」 | 与官方有意对齐 |
| `## Verification` 并入 §4 | 无损合并 |
| 删 Pre-flight 改由 writing-plans DAG 表承接 | 好的简化 |
| `Common Rationalizations` → 红线（writing-skills 删除前） | 好的简化 |
| 文档自审不派子代理（方法论议题） | 自审输入是「自己刚写的文档」已在上下文中，不产生新污染；派子代理要从零再读一遍 |
| 外部记忆（NOTES.md / ledger 议题） | 维持计划文件承担（checkbox + Rulings 区）——复用已在工件，避免第二真相源 |
| 判据排序议题（质量优先 15× token 换 +90%） | 维持「减少流程 > 减少 token > 高质量」——论文基线是无外部记忆的单 agent，Lite 已用指针化+报告契约吃掉大部分污染 |
| `requesting-code-review` 的 `## 与工作流的集成` | Lite 独有，非冗余 |
| SDD / EP 主动重写 | 不适用「官方简化」判据 |
| TDD「为什么顺序重要」节 | 官方实测删整节降级（8/10→5/10），Lite 已补回 5 条论证（约 +8 行，非恢复整节） |

---

## 成本校准（2026-09-24 `/context` 实测）

会话基础开销 ≈ **102k tokens**（System tools 43.8k + MCP tools 39.6k + System prompt 9.8k + Memory 3.9k + Skills 4.9k），每次派发子代理要重付其中大部分；单个任务的实现内容通常只有 10–20k。**三条结论：**

1. **固定开销占单次派发的大头（约七至八成）**——「固定开销 × 任务数」由估计升级为实测；派发**次数**比派发**内容**大得多。
2. **瘦身技能正文的天花板很低**——全库比官方少 616 行折算数 k tokens，而工具定义一项就 83.4k。**不是方向错，是量级差两个数量级。**
3. **最大一笔在 Lite 范围之外**——不常用的话，**禁用 MCP server 比优化任何技能文档都有效**。Lite 不处理此层，仅知会以免在错误的量级上优化。

**不在本台账记录：** git 状态——`git log` / `git status` 是权威来源，记进台账只会制造第二个会过期的真相源（判据 4）。

---

## 审计方法学（历轮沉淀，下轮复用）

**四条规则：**

1. **子代理数字必须主控复测定数** —— haiku 审计+证伪复核双层质量超预期（v3：11 项 P0/P1 复核全确认、主控 20+ 项亲验零翻案），但复核员自己的 SDD diff 数字仍错 20 行（报 1045，实测 1025，主控定数）。盲区批评家是性价比最高的角色
2. **推演必须实测** —— v4 的 H3「静默失败」推演被主控临时目录双场景实测**证伪**（cp 报错、校验失败可见）
3. **主控也会带错前提** —— 写任务书前必须先查台账（v4 F 审计员纠正主控 3 处过时前提，台账本来就有正确答案）
4. **指导形态匹配失败类型**（`Match the Form to the Failure`）—— 纪律型失败用合理化对照表，输出形状问题用正向配方；禁止式对形状问题实测比无指导还差。2026-09-28 SDD 重写（498→143 行）即按此执行

**三个测量陷阱（Windows/Bash 环境）：**

- `$'\r'` 在 Bash 工具**不展开** → `grep -c $'\r'` 恒报「全行 CRLF」。正确：`tr -cd '\r' | wc -c`
- `grep -oP '[\x{4e00}-\x{9fff}]'` 恒返回 0，误报「零汉字」。正确：`perl -CSD -p{Han}`
- `diff` 未归一化行尾时每行都报不同、行数虚高数倍。正确：先归一化再 diff

---

## 待办（已识别，未执行）

| 项 | 说明 |
|---|---|
| **全库措辞形式审查** | 按「指导形态匹配失败类型」逐处判断禁止式该改正向配方还是保留，是一次独立的全库改动 |
| **5 个技能未中文化** | 真缺陷是「同一仓库两种语言」而非「没动过」——6 个 SKILL.md 汉字数为 0 或英文主体（dispatching / receiving-code-review / systematic-debugging / using-git-worktrees / verification-before-completion），description 与官方逐字相同 |
| **报告契约缺「未解 bug」通道** | 「未解 bug / 下一步计划」只有模糊的「顾虑」，无明确接收方处理流程；与判据 2 有张力，暂缓 |
| **house form 未对齐** | `finishing`（60 行 vs 官方 14）与 `using-git-worktrees`（44 vs 9）仍是 `Common Mistakes` + `Red Flags` 旧形式，转 `Common Rationalizations` 表可省约 60 行。**实缺规则仅 2 条**（merged 结果失败就停手、push 被拒诊断），v2 已修 |
| **最小结构冒烟测试** | 官方 66 个测试不可直接复用。候选 3 项（纯文件断言、零依赖）：frontmatter 合法 / 技能引用的文件存在 / 安装目录与仓库一致。**与判据 4 有张力，待用户裁决** |
| **平台映射文件已 drift** | `codex-tools.md`（53 行 vs 官方 108）与 `gemini-tools.md`（50 vs 63）停留 5.1.0 时代；官方已扩展为 7 平台 |
| **`copilot-tools.md` 去留** | 官方 6.1.0 已删（「已无 harness 专属内容」）；Lite 保留 = 维护一份上游已无对照的文件，映射会静默过期 |
| **四处「自审」定义是否统一** | brainstorming（结构+需求）/ writing-plans（5 维）/ SDD（4 维）/ EP（完成契约 4 项）各一套清单，新增交付物时不知该改哪份 |
| **8 条纯推理机制是否补实测** | 「Lite 独有」11 条中仅 1 条有实测（固定开销判据）。补实测成本高、收益不明 |
| **` RELEASE-NOTES 正向映射`已完成（2026-09-28 前确认）** | 官方 v6.0.0→v6.4.1 全部 77 条变更逐条对账完毕，漏裁决 0，补裁决 2 条（#2320 拒绝 / #2089 部分承接，已入上方拒绝表）。**本项关闭** |

---

## 下次同步流程

1. 取官方新版本（`git ls-remote --tags https://github.com/obra/superpowers.git` 先核实最新 tag，别对着过时快照同步），读 `RELEASE-NOTES.md` 中 v6.4.1 之后的新段
2. 逐条对照本台账：已在「已采纳 / 已拒绝 / 已同构」→ 跳过；新条目 → 列入「待裁决」
3. 对待裁决项按**判据**逐条裁决，把结论与原因追加到对应表格
4. 更新文首的「当前上游」与「上次同步」
5. 若官方改动触及 Lite 已改造的技能，需额外 diff 该技能的**正文**，不只看 release notes——**远 divergence 共 8 个**：brainstorming / writing-plans / SDD / executing-plans / test-driven-development / finishing-a-development-branch / requesting-code-review / using-superpowers（分级见下方「技能贴近度基线」）
6. **别漏元技能。** `writing-skills` 曾在 2026-09-23 同步中被漏掉——它是技能的文件来源技能（2026-09-24 已由用户删除，本条仅作历史记录，防的是「同类元层文件被漏」这个模式）

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

## 历史轮次索引

四轮对比-修复与发版的完整过程记录（发现清单、修复明细、方法学原始数据、逐条 77 条对账表）在 **git 历史**中——重构前版本即本文档的父提交；各轮原始报告在 `.superpowers/compare/`（gitignored）。

| 轮次 | 日期 | 核心产出 | commit |
|---|---|---|---|
| 初次同步 + 二次复核 | 2026-09-23 | v5.1.0 → v6.4.1 全量裁决；26 项采纳落地 | a30c0c0 前后 |
| 技能层对比（v1） | 2026-09-24 | 90+ 发现；修复 21 项（P0×1/P1×9/P2×10）；视觉伴侣删除 | 8ed4055 前后 |
| v2 | 2026-09-24 | 对修复后 Lite 重跑；12 项修复；3 处子报告断言更正 | 5b49695 前后 |
| v3 | 2026-09-24 | 四维动态工作流（9 子代理）；33+6 发现；修复 20 项 | 011b590 前后 |
| v4 + 正向映射 | 2026-09-24 | 官方无增量（四路核实）；10 项修复；77 条完备性证明 | 2a7e5a1（l1） |
| l2 发版 | 2026-09-24 | 插件市场结构（plugin.json / marketplace.json / hooks） | 2106fce |
| 文档三连 | 2026-09-24~28 | CLAUDE.md 190→28 行；README 463/470→225/229；SDD 498→143 行（方法论重构） | c7981a2 / 7c12907 / d49f380 |
