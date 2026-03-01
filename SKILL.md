---
name: media-extract
description: Universal media extraction and analysis. Handles YouTube videos (with full metadata), web articles, raw transcripts, and pasted text. Extracts structured summaries, golden nuggets, workflows, commands, code examples, chapters, quotes, and competitive breakdowns. Use when user shares a YouTube URL, article URL, pastes a transcript, or asks to analyze any content.
---

<essential_principles>

<principle name="universal-input">
This skill handles ANY content source:
- **YouTube URL** → Fetch transcript + metadata via local bash script, then analyze
- **Article/web URL** → Fetch via WebFetch tool, then analyze
- **Pasted text** → Analyze directly (transcript, meeting notes, documentation, etc.)
- **File path** → Read file content, then analyze
The extraction workflows are the same regardless of source.
</principle>

<principle name="self-contained">
YouTube data fetched via a local bash script using yt-dlp. No MCP server, no Node.js, no npm.
Script at `~/.claude/skills/media-extract/fetch.sh`.
Requires: `yt-dlp` (`brew install yt-dlp`) and `jq` (`brew install jq`).
</principle>

<principle name="utility-first">
This is a utility skill. It extracts and transforms content into structured formats.
It does NOT add personality, voice, or branding. Skills that consume this output (Second Brain, YouTube Planner, Learn Anything) handle the creative layer.
</principle>

<principle name="structured-output">
Always return structured, parseable output with clear markdown sections.
Other skills depend on consistent formats.
</principle>

<principle name="timestamp-preservation">
When timestamps are available (video transcripts, meeting recordings), preserve and format them as HH:MM:SS or MM:SS. For articles and text without timestamps, skip timestamp references.
</principle>

</essential_principles>

<source_detection>

Detect the content source type:

1. **YouTube URL** — Contains `youtube.com`, `youtu.be`, or `youtube.com/shorts`
   → Fetch transcript + metadata in one call:

   ```bash
   ~/.claude/skills/media-extract/fetch.sh all "<url>" "<lang>"
   ```

   This returns BOTH transcript AND metadata in a single JSON response.

   When only transcript is needed (e.g., chapters workflow):

   ```bash
   ~/.claude/skills/media-extract/fetch.sh transcript "<url>" "<lang>" "timestamped"
   ```

   When only metadata is needed:

   ```bash
   ~/.claude/skills/media-extract/fetch.sh metadata "<url>"
   ```

2. **Web URL** — Any other URL (article, blog post, documentation)
   → Fetch content: Use WebFetch tool with prompt "Return the full article content as markdown"

3. **Pasted text** — No URL detected, text provided directly
   → Use the text as-is. Detect if it's a transcript (has timestamps/speaker labels) or plain text.

4. **File path** — Path to a local file (.txt, .srt, .md)
   → Read the file content

</source_detection>

<metadata_enrichment>

When processing YouTube URLs, automatically include metadata in the output header:

```markdown
- **Channel:** @handle (X subscribers)
- **Published:** YYYY-MM-DD
- **Duration:** MM:SS
- **Views:** X | **Likes:** Y | **Engagement:** Z%
- **Tags:** tag1, tag2, tag3
```

Calculate engagement rate as: `(like_count / view_count) * 100`, rounded to 2 decimal places.

If the video has native YouTube chapters (metadata.chapters is not null), mention them:

```markdown
- **Native Chapters:** Yes (N chapters)
```

</metadata_enrichment>

<intake>

Detect the user's intent and route to the right workflow:

**Analysis Workflows** (what to extract):

1. **Summary**: "summarize", "what's this about", URL without instruction
   → Execute **summary** workflow

2. **Golden Nuggets**: "golden nuggets", "key insights", "best insights", "extract nuggets"
   → Execute **golden-nuggets** workflow

3. **Chapters**: "generate chapters", "timestamps", "create chapters" (video only)
   → Execute **chapters** workflow

4. **Quotes**: "find quotes", "best moments", "quotable moments", "clips"
   → Execute **quotes** workflow

5. **Workflows**: "extract workflow", "step-by-step", "extract the process"
   → Execute **workflow-extraction** workflow

6. **Commands & Code**: "extract commands", "code examples", "CLI commands"
   → Execute **commands-code** workflow

7. **Breakdown**: "analyze", "how did they structure it", "video breakdown"
   → Execute **breakdown** workflow

8. **Full Extraction**: "extract everything", "full extraction", "deep dive extraction"
   → Execute **full-extraction** workflow (multi-file output)

9. **Batch**: Multiple URLs/texts provided, or "compare these"
   → Execute the relevant workflow for each, then compare

If a URL/text is provided without a specific command, default to **summary**.
If called programmatically by another skill, return structured output without extra commentary.

</intake>

<workflows>

## Summary Workflow

Deep structured summary of content from any source.

**Steps:**

1. Get content (fetch YouTube transcript + metadata, fetch article, or use pasted text)
2. Analyze and extract key information

**Output format:**

```markdown
# Summary: [Title]

- **Source:** [URL or "pasted text"]
- **Type:** [YouTube video / Article / Transcript / Text]
- **Channel:** @handle (X subscribers)
- **Published:** YYYY-MM-DD
- **Duration:** MM:SS
- **Views:** X | **Likes:** Y | **Engagement:** Z%
- **Tags:** tag1, tag2, tag3
- **Topic:** [one-line description]

## Main Message

[1-2 sentences: the core thesis]

## Key Concepts

1. **[Concept]** — [brief explanation]
2. **[Concept]** — [brief explanation]

## Techniques & Tools

- [Technique/tool]: [how it's used, why it matters]

## Action Items

- [ ] [Concrete takeaway]

## Notable Examples

- [Example]: [what it illustrates]
```

For non-YouTube sources, omit Channel/Published/Views/Likes/Engagement/Tags lines.

## Golden Nuggets Workflow

Extract key insights, tips, and memorable moments. Uses the golden nugget template for deep extraction.

**Steps:**

1. Get content from source
2. Read template: `~/.claude/skills/media-extract/templates/golden-nugget-format.md`
3. Identify insights that are: actionable, surprising, quotable, or paradigm-shifting
4. Categorize by theme (Philosophy, Best Practices, Tips & Tricks)
5. Rate importance (1-5)

**Output format:** Follow the golden-nugget-format.md template. Always include:

- Quick Reference: Top 5 Nuggets
- Nuggets by Theme
- Actionable Takeaways

## Chapters Workflow (video/audio only)

Generate YouTube-formatted chapter timestamps.

**Steps:**

1. Check metadata for native chapters (`metadata.chapters`)
2. If native chapters exist: use them as the base, refine titles if needed
3. If no native chapters: fetch transcript with `timestamped` format, analyze content flow and identify topic transitions
4. First chapter MUST start at 00:00
5. Target 8-15 chapters for 15-30min video (adjust proportionally)

**Output format (ready to paste in YouTube):**

```
00:00 Introduction
01:23 [Chapter title]
04:56 [Chapter title]
```

No bullets, no markdown, no extra formatting.

If native chapters were used, note: "Based on native YouTube chapters (refined titles)."

## Quotes Workflow

Extract quotable moments for clips or social posts.

**Steps:**

1. Get content from source
2. Identify moments that are insightful, strong opinions, memorable analogies, practical wisdom
3. For each quote: exact words, timestamp (if available), type, shareability rating

**Output format:**

```markdown
# Quotes: [Title]

## Top Quotes

### [MM:SS] "[Exact quote]"

- **Type:** insight | hot-take | wisdom | story | humor
- **Shareability:** high | medium | low
- **Context:** [1 sentence]
```

For text without timestamps, omit the timestamp and use sequential numbering.

## Workflow Extraction

Extract step-by-step processes and procedures from content.

**Steps:**

1. Get content from source
2. Read template: `~/.claude/skills/media-extract/templates/workflow-template.md`
3. Identify all processes, procedures, and step-by-step instructions
4. For each workflow: name, steps with detail, commands if any, validation checklist

**Output format:** Follow the workflow-template.md template. Include:

- Clear numbered steps
- Commands/code per step (if applicable)
- Expected output per step
- Validation checklist
- Common issues & solutions

## Commands & Code Extraction

Extract CLI commands and code examples.

**Steps:**

1. Get content from source
2. Identify all terminal commands, code snippets, configuration examples
3. Group by category
4. Add context and purpose for each

**Output format:**

````markdown
# Commands & Code: [Title]

## Category: [Name]

### [command-name]

**Purpose:** [What it does]
**Timestamp:** [if available]

```bash
[command with options]
```
````

**Options explained:**

- `--flag`: [what it does]

## Quick Reference

| Command | Purpose   | Example   |
| ------- | --------- | --------- |
| [cmd]   | [purpose] | [example] |

````

## Breakdown Workflow

Structural and competitive analysis (works for videos AND articles).

**Steps:**
1. Get content from source
2. Analyze structure, hook, pacing, engagement techniques
3. For articles: analyze headline, intro hook, section structure, CTAs, SEO patterns

**Output format:**
```markdown
# Breakdown: [Title]

- **Source:** [url or type]
- **Duration/Length:** [estimate]

## Structure

### Hook
- **Technique:** [type]
- **Effectiveness:** [high/medium/low + why]

### Content Format
- **Type:** [listicle/tutorial/story/problem-solution]
- **Sections:** [list with timestamps/positions]

### Engagement Techniques
- [Technique]: [example from content]

## Communication Style
- **Tone:** [description]
- **Teaching approach:** [description]

## Strengths
- [What works well]

## Opportunities
- [What could be improved]
````

## Full Extraction Workflow (Multi-File)

Comprehensive extraction split into multiple files.

**Steps:**

1. Get content from source
2. Read template: `~/.claude/skills/media-extract/templates/multi-file-output-template.md`
3. Ask user for output directory (or use current directory)
4. Generate files: INDEX.md, summary.md, workflows.md, commands.md, golden-nuggets.md, code-examples.md
5. Only generate files that have content (skip empty categories)

**Output:** Multiple files following the multi-file-output-template.md structure.

</workflows>

<saving_output>

When saving to files, use this naming:

```
[type]-[source]-[slug].md
```

Examples:

- `summary-yt-how-to-build-mcp-servers.md`
- `nuggets-article-react-router-v7-guide.md`
- `breakdown-yt-competitor-launch-video.md`
- `workflows-transcript-team-meeting-jan.md`

Where to save depends on calling context:

- **Direct call**: current working directory, or ask user
- **Learn Anything**: `research/` folder
- **Second Brain**: relevant project/content folder
- **YouTube Planner**: project's research folder

</saving_output>

<batch_mode>

When processing multiple sources, after individual outputs provide a comparison:

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

</batch_mode>
