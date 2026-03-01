# Multi-File Output Template

Templates for generating split output files by category. Use when `output_mode: multi` is enabled.

---

## INDEX.md Template

The navigation hub for all extracted content.

```markdown
# [Video/Series Title] - Extraction Index

**Source**: [Video URL or file reference]
**Extracted**: [Date]
**Author/Presenter**: [Name]

## Quick Navigation

| File                                   | Description                    | Items   |
| -------------------------------------- | ------------------------------ | ------- |
| [summary.md](summary.md)               | Executive summary and overview | -       |
| [workflows.md](workflows.md)           | Step-by-step processes         | [count] |
| [commands.md](commands.md)             | CLI/terminal commands          | [count] |
| [golden-nuggets.md](golden-nuggets.md) | Key insights and tips          | [count] |
| [code-examples.md](code-examples.md)   | Code snippets with context     | [count] |

## Topic Index

| Topic     | Location  | Section   |
| --------- | --------- | --------- |
| [Topic 1] | [file.md] | [#anchor] |
| [Topic 2] | [file.md] | [#anchor] |

## Cross-References

- [Topic A] relates to [Topic B] (see workflows.md#section)
- [Command X] used in [Workflow Y] (see workflows.md#workflow-y)

---

_Extracted using video-transcript-extractor skill_
```

---

## summary.md Template

Executive summary and high-level overview.

```markdown
# [Video/Series Title] - Summary

## Overview

[2-3 paragraph summary of the video content, main themes, and target audience]

## Key Takeaways

1. **[Takeaway 1]**: [Brief explanation]
2. **[Takeaway 2]**: [Brief explanation]
3. **[Takeaway 3]**: [Brief explanation]
4. **[Takeaway 4]**: [Brief explanation]
5. **[Takeaway 5]**: [Brief explanation]

## Main Topics Covered

### [Topic 1]

[Brief description and where to find details]

- See: [workflows.md#topic-1](workflows.md#topic-1)

### [Topic 2]

[Brief description and where to find details]

- See: [golden-nuggets.md#topic-2](golden-nuggets.md#topic-2)

### [Topic 3]

[Brief description and where to find details]

- See: [commands.md#topic-3](commands.md#topic-3)

## Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]
- [Tool/software requirement]

## Related Resources

- [Link to related documentation]
- [Link to referenced tools]
- [Link to follow-up content]

---

**Source**: [Video reference]
**Duration**: [HH:MM:SS]
**Navigation**: [Back to INDEX](INDEX.md)
```

---

## workflows.md Template

Step-by-step processes and procedures.

````markdown
# [Video/Series Title] - Workflows

## Table of Contents

- [Workflow 1: Name](#workflow-1-name)
- [Workflow 2: Name](#workflow-2-name)
- [Workflow 3: Name](#workflow-3-name)

---

## Workflow 1: [Name]

**Purpose**: [What this workflow accomplishes]
**When to use**: [Situations where this applies]
**Prerequisites**: [What's needed before starting]
**Source timestamp**: [HH:MM:SS] (if available)

### Steps

1. **[Step Title]**
   - [Detailed instruction]
   - [Additional context if needed]
   ```bash
   # Optional: Command for this step
   [command here]
   ```
````

2. **[Step Title]**
   - [Detailed instruction]
   - [Additional context if needed]

3. **[Step Title]**
   - [Detailed instruction]
   - [Additional context if needed]

### Expected Outcome

[What the user should see/have when complete]

### Troubleshooting

- **Issue**: [Common problem]
  **Solution**: [How to fix]

### Related

- Commands used: [commands.md#command-name](commands.md#command-name)
- See also: [Workflow 2](#workflow-2-name)

---

## Workflow 2: [Name]

[Repeat structure as above]

---

## Workflow 3: [Name]

[Repeat structure as above]

---

**Navigation**: [Back to INDEX](INDEX.md) | [Summary](summary.md)

````

---

## commands.md Template

CLI commands and terminal operations.

```markdown
# [Video/Series Title] - Commands

## Table of Contents

- [Category 1: Name](#category-1-name)
- [Category 2: Name](#category-2-name)
- [Quick Reference](#quick-reference)

---

## Category 1: [Name]

### [command-name]

**Purpose**: [What this command does]
**Source timestamp**: [HH:MM:SS] (if available)

```bash
# Basic usage
[command with basic options]

# With common flags
[command with flags] [arguments]

# Full example from video
[exact command shown in video]
````

**Options explained**:

- `--flag1`: [What it does]
- `--flag2`: [What it does]
- `-x`: [What it does]

**Example output**:

```
[Expected output if shown]
```

**Used in**: [workflows.md#workflow-name](workflows.md#workflow-name)

---

### [another-command]

[Repeat structure as above]

---

## Category 2: [Name]

### [command-name]

[Repeat structure as above]

---

## Quick Reference

| Command  | Purpose         | Example     |
| -------- | --------------- | ----------- |
| `[cmd1]` | [Brief purpose] | `[example]` |
| `[cmd2]` | [Brief purpose] | `[example]` |
| `[cmd3]` | [Brief purpose] | `[example]` |

---

**Navigation**: [Back to INDEX](INDEX.md) | [Workflows](workflows.md)

````

---

## golden-nuggets.md Template

Key insights, tips, and memorable quotes.

```markdown
# [Video/Series Title] - Golden Nuggets

## Table of Contents

- [Philosophy & Mindset](#philosophy--mindset)
- [Best Practices](#best-practices)
- [Tips & Tricks](#tips--tricks)
- [Memorable Quotes](#memorable-quotes)

---

## Philosophy & Mindset

### [Nugget Title]

> "[Exact quote or key insight]"

**Context**: [When/why this was mentioned]
**Why it matters**: [Practical significance]
**Source timestamp**: [HH:MM:SS] (if available)

---

### [Nugget Title]

> "[Exact quote or key insight]"

**Context**: [When/why this was mentioned]
**Why it matters**: [Practical significance]

---

## Best Practices

### [Practice Title]

**The Practice**: [Clear description of the best practice]

**Rationale**: [Why this is recommended]

**Example**: [How to apply it]

**Avoid**: [Common anti-pattern]

---

### [Practice Title]

[Repeat structure as above]

---

## Tips & Tricks

### [Tip Title]

**Tip**: [Concise actionable tip]

**Details**: [Additional context]

**Saves you**: [Time/effort/problems avoided]

---

### [Tip Title]

[Repeat structure as above]

---

## Memorable Quotes

| Quote | Context |
|-------|---------|
| "[Quote 1]" | [Brief context] |
| "[Quote 2]" | [Brief context] |
| "[Quote 3]" | [Brief context] |

---
**Navigation**: [Back to INDEX](INDEX.md) | [Summary](summary.md)
````

---

## code-examples.md Template

Code snippets with full context.

````markdown
# [Video/Series Title] - Code Examples

## Table of Contents

- [Language/Category 1](#languagecategory-1)
- [Language/Category 2](#languagecategory-2)
- [Configuration Files](#configuration-files)

---

## Language/Category 1

### [Example Title]

**Purpose**: [What this code demonstrates]
**Context**: [When/where this was shown in the video]
**Source timestamp**: [HH:MM:SS] (if available)

```[language]
[Code block with proper syntax highlighting]
```
````

**Line-by-line explanation** (if complex):

- Line X: [Explanation]
- Line Y: [Explanation]

**Key Points**:

- [Important aspect 1]
- [Important aspect 2]

**Used in workflow**: [workflows.md#workflow-name](workflows.md#workflow-name)

---

### [Example Title]

[Repeat structure as above]

---

## Language/Category 2

### [Example Title]

[Repeat structure as above]

---

## Configuration Files

### [Config File Name]

**File**: `[filename.ext]`
**Purpose**: [What this configures]

```[json/yaml/toml]
[Configuration content]
```

**Key settings**:

- `[setting1]`: [What it controls]
- `[setting2]`: [What it controls]

---

## Code Patterns Summary

| Pattern     | Language | Purpose   | Example Location |
| ----------- | -------- | --------- | ---------------- |
| [Pattern 1] | [Lang]   | [Purpose] | [#anchor]        |
| [Pattern 2] | [Lang]   | [Purpose] | [#anchor]        |

---

**Navigation**: [Back to INDEX](INDEX.md) | [Commands](commands.md)

```

---

## Usage Instructions

### Generating Multi-File Output

1. Set `output_mode: multi` in extraction configuration
2. Enable desired file types in `multi_file_structure`
3. Specify `output_directory` for generated files
4. Run extraction - files are created automatically

### Customizing Templates

- Copy relevant sections for your content type
- Remove unused sections (e.g., no code = skip code-examples.md)
- Adjust table of contents to match actual content
- Update navigation links between files

### File Generation Order

Recommended order for creating files:
1. **INDEX.md** - Create skeleton first, update counts after extraction
2. **summary.md** - High-level overview helps frame other content
3. **workflows.md** - Core procedural content
4. **commands.md** - Reference material
5. **golden-nuggets.md** - Insights and quotes
6. **code-examples.md** - Technical snippets
7. **INDEX.md** - Final update with accurate counts and cross-references

### Consolidation Notes

When consolidating multiple videos:
- Use INDEX.md to track sources per section
- Add "Source: Video X" annotations within files
- Build cross-references in INDEX.md topic table
- See [consolidation-extraction.md](../cookbook/consolidation-extraction.md) for full guide
```
