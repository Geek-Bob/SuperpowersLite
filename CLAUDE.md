# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目定位

Superpowers Lite 是官方 [Superpowers](https://github.com/obra/superpowers) 的轻量化深度定制版。

**Fork 点：** v5.1.0（2026-04-30）· **当前上游：** v6.4.1（2026-09-19）· **Lite 版本：** `6.4.1-l2` · 裁决台账见 [`UPSTREAM.md`](UPSTREAM.md)

**核心差异：** 计划不再包含实现代码，只包含验收契约。实现者自行 TDD，不走抄代码捷径。**持续跟踪官方上游**——只做优化与简化，每项采纳/拒绝都记入 `UPSTREAM.md`，便于下次增量合并。

**这是技能仓库，不是代码仓库。** 核心产出是 `skills/` 下的 13 个技能文件（Markdown），没有构建、测试套件或运行时代码。工作流规则（三路径分类、门控、审查分流）的权威源是技能文件本身——每会话经 SessionStart hook 注入 `skills/using-superpowers/SKILL.md`，本文件不复述规则，只做指针。

## 硬约束

1. **产出物语言**：技能文件与文档用简体中文，技术术语保留英文（TDD、DAG、Produces/Consumes、checkbox）；README 双语。
2. **单一真相源**：工作流行为只在技能文件里改；本文件与 README 只做指针、不复述规则——多副本必然漂移（v6.4.1-l2 发版曾漏同步本文件，即为此故）。
3. **裁决记录**：对官方上游的每项采纳/拒绝都记入 `UPSTREAM.md`，原因比结论重要，否则下次同步会重复争论同一个问题。

## 文件索引（按需读，别通读）

- `skills/` —— 13 个技能。流程类：`brainstorming`（三路径分类 Spike / Bounded / Architectural）、`writing-plans`、执行二选一（`subagent-driven-development` / `executing-plans`）；其余为支撑技能（TDD、调试、代码审查、worktree 等）
- `UPSTREAM.md` —— 上游跟踪台账：逐项裁决 + 原因、同步待办区
- `README.md` / `README.en.md` —— 面向用户：快速开始、工作流图、与官方的差异、安装方式（插件市场 + 覆盖式）
- `.claude-plugin/` + `hooks/` —— 插件清单（plugin.json + marketplace.json）与 SessionStart 注入器；版本号三处统一：plugin.json / bootstrap 版本行 / README 安装校验针
- `LICENSE` / `NOTICE.md` —— MIT 许可（官方原文）+ 衍生声明
- 设计背景（契约优先 / DAG 分层 / 审查门控分流 / 两条执行路径的分界判据 / Rulings / 指针化派发）：README「与官方的差异」+ 对应技能文件，此处不复述
