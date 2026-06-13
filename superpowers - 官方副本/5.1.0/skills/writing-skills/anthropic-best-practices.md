# Skill 编写最佳实践

> 了解如何编写有效的 Skill，让 Claude 能够发现并成功使用。

好的 Skill 应当简洁、结构清晰，并经过实际使用检验。本指南提供实用的编写决策建议，帮助你编写 Claude 能够发现并有效使用的 Skill。

关于 Skill 工作原理的概念背景，请参阅 [Skill 概述](/en/docs/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows) 是一种公共资源。你的 Skill 与 Claude 需要了解的其他所有内容共享上下文窗口，包括：

* 系统提示词
* 对话历史
* 其他 Skill 的元数据
* 你的实际请求

并非 Skill 中的每个 token 都会立即产生成本。在启动时，仅所有 Skill 的元数据（名称和描述）会被预加载。只有当 Skill 变得相关时，Claude 才会读取 SKILL.md，并且仅在需要时读取其他文件。然而，SKILL.md 中的内容保持简洁仍然很重要：一旦 Claude 加载了它，每个 token 都会与对话历史和其他上下文竞争。

**默认假设**：Claude 已经非常聪明

只添加 Claude 尚未掌握的上下文。质疑每条信息：

* "Claude 真的需要这个解释吗？"
* "我能假设 Claude 已经知道这个吗？"
* "这段文字值得它占用的 token 成本吗？"

**好的示例：简洁**（约 50 个 token）：

````markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**不好的示例：过于冗长**（约 150 个 token）：

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

简洁版本假设 Claude 知道什么是 PDF 以及库是如何工作的。

### 设置适当的自由度

让具体程度与任务的脆弱性和可变性相匹配。

**高自由度**（基于文本的指令）：

适用于以下情况：

* 多种方法都可行
* 决策取决于上下文
* 启发式方法指导方向

示例：

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**中等自由度**（带参数的伪代码或脚本）：

适用于以下情况：

* 存在首选模式
* 允许一定变化
* 配置影响行为

示例：

````markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**低自由度**（特定脚本，很少或没有参数）：

适用于以下情况：

* 操作脆弱且容易出错
* 一致性至关重要
* 必须遵循特定顺序

示例：

````markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**类比**：把 Claude 想象成一个探索路径的机器人：

* **两侧都是悬崖的窄桥**：只有一条安全的路。提供具体的护栏和精确的指令（低自由度）。例如：必须按精确顺序运行的数据库迁移。
* **没有障碍的开阔地**：很多路都能通向成功。给出大致方向，相信 Claude 能找到最佳路线（高自由度）。例如：由上下文决定最佳方法的代码审查。

### 在所有计划使用的模型上进行测试

Skill 是对模型的补充，因此有效性取决于底层模型。请在所有计划使用的模型上测试你的 Skill。

**按模型划分的测试考虑因素**：

* **Claude Haiku**（快速、经济）：Skill 是否提供了足够的指导？
* **Claude Sonnet**（均衡）：Skill 是否清晰高效？
* **Claude Opus**（强大推理）：Skill 是否避免了过度解释？

在 Opus 上完美运行的内容可能需要为 Haiku 提供更多细节。如果你计划在多个模型上使用 Skill，请确保指令在所有模型上都能良好运行。

## Skill 结构

<Note>
  **YAML Frontmatter**：SKILL.md 的 frontmatter 需要两个字段：

  * `name` - Skill 的人类可读名称（最多 64 个字符）
  * `description` - Skill 功能及使用场景的单行描述（最多 1024 个字符）

  有关完整的 Skill 结构详情，请参阅 [Skill 概述](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名规范

使用一致的命名模式，使 Skill 更易于引用和讨论。我们建议使用 **动名词形式**（动词 + -ing）作为 Skill 名称，因为这能清晰地描述 Skill 提供的活动或能力。

**好的命名示例（动名词形式）**：

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**可接受的替代方案**：

* 名词短语："PDF Processing"、"Spreadsheet Analysis"
* 动作导向："Process PDFs"、"Analyze Spreadsheets"

**应避免**：

* 模糊的名称："Helper"、"Utils"、"Tools"
* 过于通用："Documents"、"Data"、"Files"
* 技能集合内不一致的模式

一致的命名便于：

* 在文档和对话中引用 Skill
* 一眼了解 Skill 的功能
* 组织和管理多个 Skill
* 维护专业、内聚的 Skill 库

### 编写有效的描述

`description` 字段用于 Skill 的发现，应同时包含 Skill 的功能和使用时机。

<Warning>
  **始终使用第三人称编写**。描述会被注入系统提示词，视角不一致可能导致发现问题。

  * **好的写法**："Processes Excel files and generates reports"
  * **应避免**："I can help you process Excel files"
  * **应避免**："You can use this to process Excel files"
</Warning>

**具体化并包含关键术语**。同时包含 Skill 的功能以及特定的触发条件/上下文，说明何时使用。

每个 Skill 只有一个描述字段。描述对于 Skill 选择至关重要：Claude 使用它从可能 100 多个可用的 Skill 中选择正确的那个。你的描述必须提供足够的细节，让 Claude 知道何时选择此 Skill，而 SKILL.md 的其余部分则提供实现细节。

有效的示例：

**PDF Processing skill:**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis skill:**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper skill:**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免像下面这样模糊的描述：

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### 渐进式披露模式

SKILL.md 作为一个概览，在需要时引导 Claude 查看详细材料，就像入职指南中的目录一样。关于渐进式披露工作原理的解释，请参阅概述中的 [Skill 的工作原理](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

**实用指导**：

* 保持 SKILL.md 主体在 500 行以内以获得最佳性能
* 接近此限制时，将内容拆分到单独的文件中
* 使用以下模式有效组织指令、代码和资源

#### 可视化概览：从简单到复杂

一个基础的 Skill 从仅包含元数据和指令的 SKILL.md 文件开始：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着 Skill 的增长，你可以打包 Claude 仅在需要时才加载的附加内容：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的 Skill 目录结构可能如下所示：

```
pdf/
├── SKILL.md              # 主要指令（被触发时加载）
├── FORMS.md              # 表单填写指南（按需加载）
├── reference.md          # API 参考（按需加载）
├── examples.md           # 使用示例（按需加载）
└── scripts/
    ├── analyze_form.py   # 实用脚本（执行而非加载）
    ├── fill_form.py      # 表单填写脚本
    └── validate.py       # 验证脚本
```

#### 模式 1：高级指南 + 参考资料

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

Claude 仅在需要时加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：按领域组织

对于涉及多个领域的 Skill，按领域组织内容以避免加载不相关的上下文。当用户询问销售指标时，Claude 只需读取与销售相关的模式，而不需要读取财务或营销数据。这样可以保持低 token 使用量和专注的上下文。

```
bigquery-skill/
├── SKILL.md (概览和导航)
└── reference/
    ├── finance.md (收入、计费指标)
    ├── sales.md (机会、管道)
    ├── product.md (API 使用、功能)
    └── marketing.md (活动、归因)
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3：条件详情

展示基础内容，链接到进阶内容：

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude 仅在用户需要这些功能时读取 REDLINING.md 或 OOXML.md。

### 避免深层嵌套的引用

当文件被其他引用文件引用时，Claude 可能只部分读取文件。遇到嵌套引用时，Claude 可能使用 `head -100` 之类的命令预览内容而不是读取整个文件，导致信息不完整。

**保持从 SKILL.md 出发的引用只有一层深度**。所有引用文件都应直接从 SKILL.md 链接，以确保 Claude 在需要时能读取完整文件。

**不好的示例：层级过深**：

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**好的示例：一层深度**：

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 为较长的参考文件添加目录

对于超过 100 行的参考文件，在顶部包含一个目录。这样可以确保即使通过部分读取预览时，Claude 也能看到可用信息的完整范围。

**示例**：

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

然后 Claude 可以读取完整文件，或根据需要跳转到特定章节。

有关这种基于文件系统的架构如何实现渐进式披露的详细信息，请参阅下方高级部分中的[运行时环境](#runtime-environment)章节。

## 工作流和反馈循环

### 对复杂任务使用工作流

将复杂操作拆分为清晰、有序的步骤。对于特别复杂的工作流，提供一个清单，让 Claude 可以复制到其回复中并逐步勾选。

**示例 1：研究综合工作流**（适用于不包含代码的 Skill）：

````markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
````

这个示例展示了工作流如何应用于不需要代码的分析任务。清单模式适用于任何复杂的多步骤过程。

**示例 2：PDF 表单填写工作流**（适用于包含代码的 Skill）：

````markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
````

清晰的步骤可以防止 Claude 跳过关键验证。清单帮助 Claude 和你跟踪多步骤工作流的进度。

### 实现反馈循环

**常见模式**：运行验证器 → 修复错误 → 重复

这种模式能大幅提高输出质量。

**示例 1：风格指南合规性**（适用于不包含代码的 Skill）：

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

这展示了使用参考文档而非脚本的验证循环模式。"验证器"是 STYLE_GUIDE.md，Claude 通过阅读和比较来执行检查。

**示例 2：文档编辑流程**（适用于包含代码的 Skill）：

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

验证循环能及早发现错误。

## 内容指南

### 避免时间敏感信息

不要包含会过时的信息：

**不好的示例：时间敏感**（会变得错误）：

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**好的示例**（使用"旧模式"章节）：

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

旧模式章节提供了历史上下文，而不会使主要内容变得杂乱。

### 使用一致的术语

选择一个术语，并在整个 Skill 中一致使用：

**好的写法 - 一致**：

* 始终使用 "API endpoint"
* 始终使用 "field"
* 始终使用 "extract"

**不好的写法 - 不一致**：

* 混用 "API endpoint"、"URL"、"API route"、"path"
* 混用 "field"、"box"、"element"、"control"
* 混用 "extract"、"pull"、"get"、"retrieve"

一致性有助于 Claude 理解并遵循指令。

## 常见模式

### 模板模式

为输出格式提供模板。根据需求匹配严格程度。

**对于严格要求**（如 API 响应或数据格式）：

````markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**对于灵活指导**（当需要适应调整时）：

````markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### 示例模式

对于输出质量依赖示例的 Skill，像常规提示那样提供输入/输出对：

````markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

示例比纯描述更清晰地帮助 Claude 理解期望的风格和详细程度。

### 条件工作流模式

引导 Claude 通过决策点：

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  如果工作流变得庞大或复杂且包含许多步骤，考虑将它们推送到单独的文件中，并告知 Claude 根据手头任务读取相应的文件。
</Tip>

## 评估与迭代

### 先构建评估

**在编写大量文档之前先创建评估。** 这能确保你的 Skill 解决的是真实问题，而不是记录想象中的需求。

**评估驱动开发：**

1. **识别差距**：在没有 Skill 的情况下让 Claude 执行代表性任务。记录具体的失败或缺失的上下文
2. **创建评估**：构建三个测试这些差距的场景
3. **建立基准**：衡量没有 Skill 时 Claude 的表现
4. **编写最少指令**：创建刚好足以解决差距并通过评估的内容
5. **迭代**：执行评估，与基准比较，然后优化

这种方法确保你解决的是实际问题，而不是预测可能永远不会出现的需求。

**评估结构**：

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  此示例演示了带有简单测试标准的数据驱动评估。我们目前不提供运行这些评估的内置方法。用户可以创建自己的评估系统。评估是衡量 Skill 有效性的真理来源。
</Note>

### 与 Claude 一起迭代开发 Skill

最有效的 Skill 开发过程本身就涉及 Claude。与一个 Claude 实例（"Claude A"）一起创建一个将由其他实例（"Claude B"）使用的 Skill。Claude A 帮助你设计和优化指令，而 Claude B 在实际任务中测试它们。这种方法有效，因为 Claude 模型既理解如何编写有效的 agent 指令，也知道 agent 需要什么信息。

**创建新 Skill：**

1. **在没有 Skill 的情况下完成任务**：使用 Claude A 通过正常提示解决问题。在过程中，你会自然地提供上下文、解释偏好并分享程序性知识。注意你反复提供的信息。

2. **识别可复用的模式**：完成任务后，识别你提供的哪些上下文对类似未来任务有用。

   **示例**：如果你完成了一个 BigQuery 分析，你可能提供了表名、字段定义、过滤规则（如"始终排除测试账户"）和常用查询模式。

3. **请 Claude A 创建一个 Skill**："创建一个捕捉我们刚刚使用的这个 BigQuery 分析模式的 Skill。包括表模式、命名约定以及过滤测试账户的规则。"

   <Tip>
     Claude 模型原生理解 Skill 的格式和结构。你不需要特殊的系统提示或"编写技能"技能来让 Claude 帮助创建 Skill。只需让 Claude 创建一个 Skill，它就会生成具有适当 frontmatter 和主体内容的正确结构的 SKILL.md 内容。
   </Tip>

4. **检查简洁性**：检查 Claude A 是否添加了不必要的解释。要求："删除关于胜率含义的解释——Claude 已经知道了。"

5. **改进信息架构**：请 Claude A 更有效地组织内容。例如："这样组织，把表模式放在单独的参考文件中。我们以后可能还会添加更多表。"

6. **在类似任务上测试**：在相关用例上使用带有 Skill 的 Claude B（一个加载了该 Skill 的新实例）。观察 Claude B 是否能找到正确的信息、正确应用规则并成功处理任务。

7. **基于观察进行迭代**：如果 Claude B 遇到困难或遗漏了某些内容，带着具体问题返回 Claude A："当 Claude 使用这个 Skill 时，它忘了按日期过滤 Q4 的数据。我们应该添加一个关于日期过滤模式的章节吗？"

**迭代现有 Skill：**

相同的分层模式在改进 Skill 时延续使用。你在以下步骤之间交替进行：

* **与 Claude A 合作**（帮助优化 Skill 的专家）
* **用 Claude B 测试**（使用 Skill 执行实际工作的 agent）
* **观察 Claude B 的行为**并将洞察带回给 Claude A

1. **在实际工作流中使用 Skill**：给 Claude B（加载了 Skill）实际任务，而非测试场景

2. **观察 Claude B 的行为**：注意它在哪些方面遇到困难、成功或做出意外选择

   **示例观察**："当我让 Claude B 制作区域销售报告时，它编写了查询但忘了过滤掉测试账户，尽管 Skill 中提到了这条规则。"

3. **返回 Claude A 进行改进**：分享当前的 SKILL.md 并描述你观察到的内容。询问："我注意到 Claude B 在我要求区域报告时忘了过滤测试账户。Skill 中提到了过滤，但也许不够突出？"

4. **审查 Claude A 的建议**：Claude A 可能建议重新组织以使规则更突出，使用更强烈的语言如"MUST filter"而不是"always filter"，或重新结构化工作流章节。

5. **应用并测试更改**：用 Claude A 的优化更新 Skill，然后在类似请求上再次用 Claude B 测试

6. **根据使用情况重复**：随着遇到新场景，继续这个观察-优化-测试的循环。每次迭代都基于真实的 agent 行为（而非假设）来改进 Skill。

**收集团队反馈：**

1. 与团队成员分享 Skill 并观察他们的使用情况
2. 询问：Skill 是否按预期触发？指令是否清晰？缺少什么？
3. 整合反馈以弥补自身使用模式中的盲点

**为什么这种方法有效**：Claude A 理解 agent 需求，你提供领域专业知识，Claude B 通过实际使用暴露差距，迭代优化基于观察到的行为（而非假设）改进了 Skill。

### 观察 Claude 如何导航 Skill

在迭代 Skill 时，关注 Claude 在实际中是如何使用它们的。注意以下几点：

* **意外的探索路径**：Claude 是否以你未预料到的顺序读取文件？这可能表明你的结构没有你想象的那么直观
* **遗漏的连接**：Claude 是否未能跟踪对重要文件的引用？你的链接可能需要更明确或更突出
* **过度依赖某些章节**：如果 Claude 反复读取同一个文件，考虑是否应该将该内容放到主 SKILL.md 中
* **被忽略的内容**：如果 Claude 从未访问打包的文件，该文件可能是不必要的，或者在主指令中的信号不够充分

基于这些观察而非假设进行迭代。Skill 元数据中的 'name' 和 'description' 特别关键。Claude 在决定是否根据当前任务触发该 Skill 时会用到它们。确保它们清晰地描述了 Skill 的功能和使用时机。

## 应避免的反模式

### 避免 Windows 风格路径

始终在文件路径中使用正斜杠，即使在 Windows 上也是如此：

* ✓ **好的写法**：`scripts/helper.py`、`reference/guide.md`
* ✗ **应避免**：`scripts\helper.py`、`reference\guide.md`

Unix 风格路径在所有平台上都能工作，而 Windows 风格路径在 Unix 系统上会导致错误。

### 避免提供过多选项

除非必要，否则不要展示多种方法：

````markdown  theme={null}
**不好的示例：选择太多**（令人困惑）：
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**好的示例：提供默认方案**（带备用方案）：
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
````

## 进阶：带可执行代码的 Skill

以下章节专注于包含可执行脚本的 Skill。如果你的 Skill 仅使用 markdown 指令，请跳到[有效 Skill 清单](#checklist-for-effective-skills)。

### 解决问题，而非推诿

在编写 Skill 脚本时，处理错误条件而非将问题推给 Claude。

**好的示例：显式处理错误**：

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # Create file with default content instead of failing
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # Provide alternative instead of failing
        print(f"Cannot access {path}, using default")
        return ''
```

**不好的示例：推诿给 Claude**：

```python  theme={null}
def process_file(path):
    # Just fail and let Claude figure it out
    return open(path).read()
```

配置参数也应有合理的理由和文档说明，以避免"神秘常量"（Ousterhout 法则）。如果你不知道正确的值，Claude 又如何确定？

**好的示例：自文档化**：

```python  theme={null}
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3
```

**不好的示例：魔法数字**：

```python  theme={null}
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### 提供实用脚本

即使 Claude 可以自己编写脚本，预制脚本也有优势：

**实用脚本的好处**：

* 比生成的代码更可靠
* 节省 token（无需将代码包含在上下文中）
* 节省时间（无需代码生成）
* 确保跨使用的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上图展示了可执行脚本如何与指令文件配合工作。指令文件（forms.md）引用了脚本，Claude 可以在不将其内容加载到上下文中的情况下执行它。

**重要区别**：在指令中明确说明 Claude 应该：

* **执行脚本**（最常见）："Run `analyze_form.py` to extract fields"
* **作为参考读取**（用于复杂逻辑）："See `analyze_form.py` for the field extraction algorithm"

对于大多数实用脚本，执行是首选，因为它更可靠和高效。有关脚本执行如何工作的详细信息，请参阅下面的[运行时环境](#runtime-environment)章节。

**示例**：

````markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用视觉分析

当输入可以渲染为图像时，让 Claude 进行分析：

````markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. Claude can see field locations and types visually
````

<Note>
  在此示例中，你需要编写 `pdf_to_images.py` 脚本。
</Note>

Claude 的视觉能力有助于理解布局和结构。

### 创建可验证的中间输出

当 Claude 执行复杂的、开放式的任务时，它可能会犯错。"计划-验证-执行"模式通过让 Claude 首先以结构化格式创建计划，然后在执行前用脚本验证计划，来及早发现错误。

**示例**：假设让 Claude 根据电子表格更新 PDF 中的 50 个表单字段。没有验证的情况下，Claude 可能会引用不存在的字段、创建冲突的值、遗漏必填字段或错误地应用更新。

**解决方案**：使用上面展示的工作流模式（PDF 表单填写），但添加一个在应用更改前经过验证的中间 `changes.json` 文件。工作流变为：分析 → **创建计划文件** → **验证计划** → 执行 → 验证。

**为什么这种模式有效：**

* **及早发现错误**：验证在更改应用前发现问题
* **机器可验证**：脚本提供客观验证
* **可逆的计划**：Claude 可以在不触及原始文件的情况下迭代计划
* **清晰的调试**：错误信息指向具体问题

**何时使用**：批量操作、破坏性更改、复杂的验证规则、高风险操作。

**实施技巧**：使验证脚本的输出更详细，包含具体的错误消息，如"Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed"，以帮助 Claude 修复问题。

### 打包依赖项

Skill 在代码执行环境中运行，具有特定平台的限制：

* **claude.ai**：可以从 npm 和 PyPI 安装包，并从 GitHub 仓库拉取
* **Anthropic API**：没有网络访问权限，也没有运行时包安装

在 SKILL.md 中列出所需的包，并在[代码执行工具文档](/en/docs/agents-and-tools/tool-use/code-execution-tool)中确认它们可用。

### 运行时环境

Skill 在具有文件系统访问权限、bash 命令和代码执行能力的代码执行环境中运行。有关此架构的概念性解释，请参阅概述中的 [Skill 架构](/en/docs/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这对你的编写有何影响：**

**Claude 如何访问 Skill：**

1. **元数据预加载**：启动时，所有 Skill 的 YAML frontmatter 中的 name 和 description 被加载到系统提示词中
2. **按需读取文件**：Claude 在需要时使用 bash Read 工具从文件系统访问 SKILL.md 和其他文件
3. **高效执行脚本**：实用脚本可以通过 bash 执行，无需将其完整内容加载到上下文中。只有脚本的输出消耗 token
4. **大文件无上下文惩罚**：参考文件、数据或文档在实际被读取之前不消耗上下文 token

* **文件路径很重要**：Claude 像浏览文件系统一样导航你的 Skill 目录。使用正斜杠（`reference/guide.md`），而非反斜杠
* **文件名要有描述性**：使用能指示内容的名称：`form_validation_rules.md`，而不是 `doc2.md`
* **为便于发现而组织**：按领域或功能组织目录
  * 好的写法：`reference/finance.md`、`reference/sales.md`
  * 不好的写法：`docs/file1.md`、`docs/file2.md`
* **打包全面的资源**：包含完整的 API 文档、大量示例、大型数据集；访问前无上下文惩罚
* **确定性操作优先使用脚本**：编写 `validate_form.py` 而不是让 Claude 生成验证代码
* **明确执行意图**：
  * "Run `analyze_form.py` to extract fields"（执行）
  * "See `analyze_form.py` for the extraction algorithm"（作为参考读取）
* **测试文件访问模式**：通过实际请求测试，验证 Claude 能否导航你的目录结构

**示例：**

```
bigquery-skill/
├── SKILL.md (概览，指向参考文件)
└── reference/
    ├── finance.md (收入指标)
    ├── sales.md (管道数据)
    └── product.md (使用分析)
```

当用户询问收入时，Claude 读取 SKILL.md，看到对 `reference/finance.md` 的引用，并调用 bash 仅读取该文件。sales.md 和 product.md 文件保留在文件系统中，在需要之前不消耗任何上下文 token。这种基于文件系统的模型正是渐进式披露的实现方式。Claude 可以导航并选择性地加载每个任务所需的内容。

有关技术架构的完整详细信息，请参阅 Skill 概述中的 [Skill 的工作原理](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具引用

如果你的 Skill 使用 MCP（Model Context Protocol）工具，请始终使用完全限定的工具名称以避免"工具未找到"错误。

**格式**：`ServerName:tool_name`

**示例**：

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

其中：

* `BigQuery` 和 `GitHub` 是 MCP 服务器名称
* `bigquery_schema` 和 `create_issue` 是这些服务器中的工具名称

没有服务器前缀，Claude 可能无法定位到该工具，尤其是当多个 MCP 服务器可用时。

### 避免假设工具已安装

不要假设包是可用的：

````markdown  theme={null}
**不好的示例：假设已安装**：
"Use the pdf library to process the file."

**好的示例：明确说明依赖**：
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技术说明

### YAML Frontmatter 要求

SKILL.md 的 frontmatter 需要 `name`（最多 64 个字符）和 `description`（最多 1024 个字符）字段。有关完整结构详情，请参阅 [Skill 概述](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。

### Token 预算

保持 SKILL.md 主体在 500 行以内以获得最佳性能。如果内容超出此限制，使用前面描述的渐进式披露模式将其拆分到多个文件中。有关架构细节，请参阅 [Skill 概述](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

## 有效 Skill 的清单

在分享 Skill 之前，请确认：

### 核心质量

* [ ] 描述具体且包含关键术语
* [ ] 描述同时包含 Skill 的功能和使用时机
* [ ] SKILL.md 主体在 500 行以内
* [ ] 额外详情在单独的文件中（如需要）
* [ ] 没有时间敏感信息（或在"旧模式"章节中）
* [ ] 整个 Skill 中使用一致的术语
* [ ] 示例具体而非抽象
* [ ] 文件引用只有一层深度
* [ ] 渐进式披露使用得当
* [ ] 工作流有清晰的步骤

### 代码和脚本

* [ ] 脚本解决问题而非推诿给 Claude
* [ ] 错误处理显式且有帮助
* [ ] 没有"神秘常量"（所有值都有合理理由）
* [ ] 所需的包已在指令中列出并确认可用
* [ ] 脚本有清晰的文档
* [ ] 没有 Windows 风格路径（全部使用正斜杠）
* [ ] 关键操作有验证/确认步骤
* [ ] 质量关键任务包含反馈循环

### 测试

* [ ] 至少创建了三个评估
* [ ] 已用 Haiku、Sonnet 和 Opus 测试
* [ ] 已使用真实使用场景测试
* [ ] 已整合团队反馈（如适用）

## 下一步

<CardGroup cols={2}>
  <Card title="开始使用 Agent Skills" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    创建你的第一个 Skill
  </Card>

  <Card title="在 Claude Code 中使用 Skill" icon="terminal" href="/en/docs/claude-code/skills">
    在 Claude Code 中创建和管理 Skill
  </Card>

  <Card title="通过 API 使用 Skill" icon="code" href="/en/api/skills-guide">
    以编程方式上传和使用 Skill
  </Card>
</CardGroup>
