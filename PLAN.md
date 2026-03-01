# PLAN: Build media-extract skill

## Context

New skill `media-extract` replaces `content-extractor` with zero npm dependencies.
Uses `yt-dlp` + `jq` instead of Node.js. Adds YouTube metadata extraction (views, likes, duration, channel, tags).
All 8 analysis workflows carry over unchanged. Templates copied as-is.

**Reference skill:** `~/.claude/skills/content-extractor/` (read for patterns, do NOT modify)

**Target:** `~/.claude/skills/media-extract/`

**Prerequisites verified:** yt-dlp v2026.02.04 at `/opt/homebrew/bin/yt-dlp`, jq available via brew

---

## Phase 1 — Parallel (launch 3 agents simultaneously)

### Agent 1: Create `fetch.sh`

Write `~/.claude/skills/media-extract/fetch.sh` (make executable with chmod +x).

Bash script with 3 modes:

```
Usage: fetch.sh <mode> <url> [lang] [format]
Modes: transcript | metadata | all
```

**Mode `transcript`:**

- Use `yt-dlp --write-auto-sub --write-sub --sub-lang <lang> --skip-download --sub-format vtt -o "/tmp/media-extract-%(id)s"` to download subtitles
- Parse the .vtt file to extract text + timestamps
- Output formats:
  - `plain` — single text block, no timestamps
  - `timestamped` — `[MM:SS] text` per segment
  - `json` — `[{"timestamp":"MM:SS","offset":45,"text":"..."}]`
- Default lang: `en`, default format: `json`
- Clean up temp files after extraction
- Decode HTML entities: `&amp;` `&#39;` `&quot;` `&lt;` `&gt;`

**Mode `metadata`:**

- Use `yt-dlp --dump-json --no-download "$url"` piped through jq
- Extract and output JSON:
  ```json
  {
    "title": "",
    "channel": "",
    "channel_id": "",
    "channel_followers": 0,
    "upload_date": "YYYY-MM-DD",
    "duration": 0,
    "duration_formatted": "MM:SS",
    "view_count": 0,
    "like_count": 0,
    "comment_count": 0,
    "description": "",
    "tags": [],
    "chapters": [{ "title": "", "start_time": 0, "end_time": 0 }],
    "thumbnail": ""
  }
  ```
- Format duration as HH:MM:SS or MM:SS
- Format upload_date from YYYYMMDD to YYYY-MM-DD
- chapters may be null if video has no chapters

**Mode `all`:**

- Single `yt-dlp --dump-json --write-auto-sub --write-sub --sub-lang <lang> --skip-download --sub-format vtt -o "/tmp/media-extract-%(id)s"`
- Output JSON: `{"metadata": {...}, "transcript": [...]}`
- Combines both outputs in one call

**Error handling:**

- If yt-dlp not found: `echo "Error: yt-dlp not installed. Run: brew install yt-dlp" >&2; exit 1`
- If jq not found: `echo "Error: jq not installed. Run: brew install jq" >&2; exit 1`
- If video not found or private: forward yt-dlp error, exit 1
- If no subtitles available: return metadata only with warning on stderr

**Video ID extraction** (for temp file naming):

- Extract from youtube.com/watch?v=ID, youtu.be/ID, youtube.com/shorts/ID, youtube.com/embed/ID

### Agent 2: Copy templates

Copy these 3 files from `~/.claude/skills/content-extractor/templates/` to `~/.claude/skills/media-extract/templates/`:

- `golden-nugget-format.md`
- `workflow-template.md`
- `multi-file-output-template.md`

Exact copies, no modifications.

### Agent 3: (nothing — wait for phase 2)

Only 2 agents needed in phase 1.

---

## Phase 2 — Sequential (after phase 1 completes)

### Step 1: Test `fetch.sh`

Run these tests with a real YouTube URL (use: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`):

```bash
# Test metadata mode
~/.claude/skills/media-extract/fetch.sh metadata "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Test transcript mode (timestamped)
~/.claude/skills/media-extract/fetch.sh transcript "https://www.youtube.com/watch?v=dQw4w9WgXcQ" en timestamped | head -20

# Test transcript mode (json)
~/.claude/skills/media-extract/fetch.sh transcript "https://www.youtube.com/watch?v=dQw4w9WgXcQ" en json | head -20

# Test all mode
~/.claude/skills/media-extract/fetch.sh all "https://www.youtube.com/watch?v=dQw4w9WgXcQ" en | head -40
```

**Validation criteria:**

- metadata returns valid JSON with title, view_count, duration
- transcript returns segments with timestamps
- all returns combined JSON with both metadata and transcript keys
- No temp files left behind in /tmp/

Fix any issues before proceeding.

### Step 2: Write `SKILL.md`

Write `~/.claude/skills/media-extract/SKILL.md`.

**Structure — adapt from `~/.claude/skills/content-extractor/SKILL.md` with these changes:**

**Header:**

```yaml
---
name: media-extract
description: Universal media extraction and analysis. Handles YouTube videos (with full metadata), web articles, raw transcripts, and pasted text. Extracts structured summaries, golden nuggets, workflows, commands, code examples, chapters, quotes, and competitive breakdowns. Use when user shares a YouTube URL, article URL, pastes a transcript, or asks to analyze any content.
---
```

**`<principle name="self-contained">`:**

- YouTube data fetched via local bash script using yt-dlp. No MCP server, no Node.js, no npm.
- Script at `~/.claude/skills/media-extract/fetch.sh`
- Requires: `yt-dlp` (`brew install yt-dlp`) and `jq` (`brew install jq`)

**`<source_detection>` — YouTube section:**
Replace the node command with:

```
node ~/.claude/skills/content-extractor/fetch.mjs ...
```

becomes:

```
~/.claude/skills/media-extract/fetch.sh all "<url>" "<lang>"
```

This returns BOTH transcript AND metadata in one call.

When only transcript is needed (e.g., chapters workflow), use:

```
~/.claude/skills/media-extract/fetch.sh transcript "<url>" "<lang>" "timestamped"
```

**NEW section `<metadata_enrichment>`:**
When processing YouTube URLs, automatically include metadata in the output header:

```markdown
- **Channel:** @handle (X subscribers)
- **Published:** YYYY-MM-DD
- **Duration:** MM:SS
- **Views:** X | **Likes:** Y | **Engagement:** Z%
- **Tags:** tag1, tag2, tag3
```

If the video has native YouTube chapters, mention them and use them in the chapters workflow instead of generating from scratch.

**Chapters workflow update:**

- If `metadata.chapters` is not null, use native chapters as the base and refine
- If null, generate from transcript analysis (current behavior)

**All other workflows:** Keep identical to content-extractor. Copy them exactly.

**All template references:** Update paths from `~/.claude/skills/content-extractor/templates/` to `~/.claude/skills/media-extract/templates/`

**Saving output naming:** Same convention but update the footer reference from "content-extractor" to "media-extract"

### Step 3: Register skill

Add to `~/.claude/settings.json` under the skills array (if not auto-detected):

- Check if skills are auto-detected from `~/.claude/skills/` or need manual registration
- Read `~/.claude/settings.json` to understand current registration pattern
- Add `media-extract` following the same pattern as `content-extractor`

### Step 4: End-to-end test

Test the complete skill by running in Claude Code:

1. Process a YouTube URL — verify metadata appears in output header
2. Process an article URL with WebFetch — verify normal extraction works
3. Verify templates are referenced correctly

---

## Completion criteria

- [ ] `fetch.sh` works for all 3 modes (transcript, metadata, all)
- [ ] No npm, no node_modules, no package.json in media-extract
- [ ] Templates copied and paths updated in SKILL.md
- [ ] YouTube workflows include metadata in output headers
- [ ] Chapters workflow uses native chapters when available
- [ ] Skill registered and callable
- [ ] content-extractor left completely untouched
