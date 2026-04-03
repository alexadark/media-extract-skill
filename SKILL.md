---
name: media-extract
description: Universal media extraction and analysis. Handles YouTube videos (visual + transcript), web articles, local files (video, audio, PDF, text), pasted content, and folders of videos. Extracts structured summaries, visual analysis via Gemini, golden nuggets, workflows, commands, code examples, chapters, quotes, and breakdowns. Downloads YouTube videos. Cleans meeting transcripts (Fathom, Otter, Zoom) by removing timestamps, filler words, small talk. Use when user shares a YouTube URL, article URL, pastes a transcript, points to local media, asks to analyze/download any content, or says "clean this transcript", "nettoyer", "remove timestamps".
---

<essential_principles>

<principle name="universal-input">
This skill handles ANY content source:
- **YouTube URL** - Transcript + metadata via yt-dlp, OR download + Gemini visual analysis
- **YouTube playlist/channel** - Batch download + Gemini visual analysis
- **Web URL** - Fetch via WebFetch or linkup-fetch (for JS-heavy pages), then analyze
- **Local video file** - Upload to Gemini for visual analysis
- **Local audio file** - Upload to Gemini for analysis
- **Local document** - Read file content (PDF, MD, TXT, SRT, etc.)
- **Pasted text** - Analyze directly (transcript, meeting notes, documentation, etc.)
- **Folder of videos** - Batch Gemini visual analysis
</principle>

<principle name="self-contained">
YouTube data fetched via a local bash script using yt-dlp. No MCP server, no Node.js, no npm.
Script at `~/.claude/skills/content/media-extract/fetch.sh`.
Requires: `yt-dlp` (`brew install yt-dlp`) and `jq` (`brew install jq`).

Visual analysis uses Gemini via a Python script.
Script at `~/.claude/skills/content/media-extract/scripts/extract.py`.
Requires: `google-genai` (`pip install google-genai`).
API key: copy `.env.example` to `.env` and add your Gemini API key. The script loads it automatically.
</principle>

<principle name="utility-first">
This is a utility skill. It extracts and transforms content into structured formats.
It does NOT add personality, voice, or branding. Skills that consume this output handle the creative layer.
</principle>

<principle name="structured-output">
Always return structured, parseable output with clear markdown sections.
Other skills depend on consistent formats.
</principle>

<principle name="timestamp-preservation">
When timestamps are available (video transcripts, meeting recordings), preserve and format them as HH:MM:SS or MM:SS. For articles and text without timestamps, skip timestamp references.
</principle>

</essential_principles>

<configuration>

On first use, check if config exists at `~/.media-extract/config.json`.

If not, create it with defaults:

```json
{
  "save_transcripts": true,
  "transcript_dir": "~/.media-extract/cache/transcripts",
  "download_dir": "~/Downloads"
}
```

Mention to the user: "Config saved at ~/.media-extract/config.json - edit anytime to change transcript/download paths."

If config exists, read it silently and use the settings.

When `save_transcripts` is true: after fetching a YouTube transcript, save it to the transcript directory as `{video-id}-{slug}.md` with metadata header. Before fetching, check if a cached transcript exists and reuse it.

</configuration>

<source_detection>

Detect the content source type from the input:

1. **YouTube URL** - Contains `youtube.com`, `youtu.be`, or `youtube.com/shorts`
   - Single video URL - route based on intent
   - Playlist URL (contains `list=`) - batch mode

2. **Web URL** - Any other URL (article, blog post, documentation)
   - Standard HTML - Use WebFetch with prompt "Return the full article content as markdown"
   - If WebFetch returns poor results (empty, less than 100 chars, login wall) - retry with linkup-fetch (`renderJs: true`)

3. **Local video file** - Path ending in `.mp4`, `.mov`, `.avi`, `.mkv`, `.webm`, `.m4v`, `.flv`
   - Route to Gemini visual analysis

4. **Local audio file** - Path ending in `.mp3`, `.wav`, `.m4a`, `.aac`, `.ogg`, `.flac`
   - Route to Gemini analysis

5. **Local document** - Path ending in `.pdf`, `.md`, `.txt`, `.srt`, `.doc`, `.docx`
   - Read the file content, then analyze with Claude

6. **Folder path** - Path to a directory
   - Scan for video files, route to batch Gemini analysis

7. **Pasted text** - No URL detected, no file path
   - Use the text as-is. Detect if it's a transcript (has timestamps/speaker labels) or plain text.

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

If the video has native YouTube chapters (metadata.chapters is not null):

```markdown
- **Native Chapters:** Yes (N chapters)
```

</metadata_enrichment>

<intake>

Detect the user's intent and route to the right workflow.
After detecting intent, read the corresponding workflow file from `references/workflows/`.

<intent name="visual-analysis">
Triggers: "watch this", "look at this video", "what's on screen", "show me the code", "visual analysis", "make a course from this", "teach me from this video", "analyze the video visually", "what are they showing", "extract the code from screen"
Right choice when: video shows code, terminal, UI, diagrams, architecture on screen.
Read: `references/workflows/visual-analysis.md`
</intent>

<intent name="download">
Triggers: "download this", "save this video", "I want to keep it", "download for later"
Read: `references/workflows/download.md`
</intent>

<intent name="summary">
Triggers: "summarize", "what's this about", URL without specific instruction
Read: `references/workflows/summary.md`
</intent>

<intent name="golden-nuggets">
Triggers: "golden nuggets", "key insights", "best insights", "extract nuggets"
Read: `references/workflows/golden-nuggets.md`
</intent>

<intent name="chapters">
Triggers: "generate chapters", "timestamps", "create chapters" (video only)
Read: `references/workflows/chapters.md`
</intent>

<intent name="quotes">
Triggers: "find quotes", "best moments", "quotable moments", "clips"
Read: `references/workflows/quotes.md`
</intent>

<intent name="workflow-extraction">
Triggers: "extract workflow", "step-by-step", "extract the process"
Read: `references/workflows/workflow-extraction.md`
</intent>

<intent name="commands-code">
Triggers: "extract commands", "code examples", "CLI commands"
Read: `references/workflows/commands-code.md`
</intent>

<intent name="breakdown">
Triggers: "how did they structure it", "video breakdown", "content structure"
Read: `references/workflows/breakdown.md`
</intent>

<intent name="full-extraction">
Triggers: "extract everything", "full extraction", "deep dive extraction"
Read: `references/workflows/full-extraction.md`
</intent>

<intent name="clean">
Triggers: "clean this transcript", "clean this", "remove timestamps", "nettoyer", "enlever les timestamps", "enlever le fluff", "clean the meeting notes"
Right choice when: pasted text with timestamps/speaker labels from meeting tools (Fathom, Otter, Zoom), or user wants business-only content extracted from a conversation transcript.
Read: `references/workflows/clean.md`
</intent>

<intent name="batch">
Triggers: Multiple URLs/texts provided, playlist URL, or "compare these"
Read: `references/workflows/batch.md`
</intent>

<defaults>
- YouTube URL without instruction - **summary**
- YouTube URL with "analyze", "look at", "what's in this" - **visual-analysis**
- Web URL without instruction - **summary**
- Local video file - **visual-analysis**
- Pasted text - **summary** (or **clean** if it has timestamps/speaker labels from meeting tools)
- If called programmatically by another skill, return structured output without extra commentary.
</defaults>

</intake>

<saving_output>

When saving to files, use this naming: `[type]-[source]-[slug].md`

Examples:

- `summary-yt-how-to-build-mcp-servers.md`
- `visual-yt-claude-code-tutorial.md`
- `nuggets-article-react-router-v7-guide.md`

Where to save depends on calling context:

- **Direct call**: current working directory, or ask user
- **Called by another skill**: let the calling skill decide

When `save_transcripts` is enabled in config:

1. Before fetching, check `{transcript_dir}/{video-id}-*.md` for cached version
2. If found, use cached transcript (skip yt-dlp call)
3. If not found, fetch and save with metadata header (video_id, title, channel, date, duration, url)

</saving_output>

<success_criteria>

- Source type correctly detected from input
- Correct workflow selected based on intent
- Output follows the corresponding template format
- YouTube metadata header included when processing YouTube URLs
- Timestamps preserved when available
- Transcript cached when config enables it
- No empty sections in output (skip sections with no content)
  </success_criteria>
