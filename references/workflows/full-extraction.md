<workflow name="full-extraction">

Comprehensive extraction split into multiple files.

<steps>

1. Get content from source.
2. Read template: `~/.claude/skills/content/media-extract/templates/multi-file-output-template.md`
3. Ask user for output directory (or use current directory).
4. Generate files: INDEX.md, summary.md, workflows.md, commands.md, golden-nuggets.md, code-examples.md
5. Only generate files that have content (skip empty categories).

</steps>

<output>
Multiple files following the multi-file-output-template.md structure.
</output>

</workflow>
