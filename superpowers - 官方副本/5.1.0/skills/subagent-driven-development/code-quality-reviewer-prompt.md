# 代码质量审查员提示模板

在分派代码质量审查员子代理时使用此模板。

**目的：** 验证实现是否构建良好（整洁、有测试、可维护）

**仅在规格合规审查通过后分派。**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**除了标准的代码质量关注点之外，审查员还应检查：**
- 每个文件是否具有单一明确的职责和良好定义的接口？
- 各个单元是否被分解，以便可以独立理解和测试？
- 实现是否遵循计划中的文件结构？
- 此实现是否创建了已经很大的新文件，或显著增长了现有文件？（不要标记已存在的文件大小——专注于此更改所贡献的内容。）

**代码审查员返回：** 优点、问题（关键/重要/次要）、评估

完整翻译后的文件已写入上方输出。
