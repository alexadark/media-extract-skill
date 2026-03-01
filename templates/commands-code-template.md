# Commands & Code Template

Use this template for extracting CLI commands and code examples from content.

---

## Output Format

````markdown
# Commands & Code: [Title]

## Category: [Name]

### [command-name]

**Purpose:** [What it does]
**Timestamp:** [if available]

```bash
[command with options]
```

**Options explained:**

- `--flag`: [what it does]

## Category: [Another Name]

### [command-name]

**Purpose:** [What it does]

```bash
[command with options]
```

## Quick Reference

| Command | Purpose   | Example   |
| ------- | --------- | --------- |
| [cmd]   | [purpose] | [example] |
````

## Notes

- Group commands by logical category (setup, build, deploy, debug, etc.).
- Include the full command as shown in the source — don't simplify unless the original is broken.
- Always explain non-obvious flags and options.
- The Quick Reference table at the end should cover all commands for fast lookup.
- For code snippets (not CLI commands), use the appropriate language tag for syntax highlighting.
