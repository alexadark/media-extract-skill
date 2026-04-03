<workflow name="batch">

When processing multiple sources, run the relevant workflow for each, then provide a comparison.

<steps>

1. Execute the appropriate workflow for each source individually.
2. After all individual outputs, generate a comparison table:

</steps>

<output>

```markdown
## Comparison

| Aspect             | Source 1             | Source 2 | Source 3 |
| ------------------ | -------------------- | -------- | -------- |
| Type               | [video/article/text] | ...      | ...      |
| Length             | ...                  | ...      | ...      |
| Structure          | ...                  | ...      | ...      |
| Key differentiator | ...                  | ...      | ...      |

### Patterns Across Sources

- [Common patterns]

### Unique Approaches

- [Source X] does [thing] differently: [how]
```

</output>

</workflow>
