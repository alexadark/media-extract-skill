# Media Extract

Universal media extraction and analysis skill for Claude Code. Extracts structured knowledge from YouTube videos, web articles, local files, and pasted content.

## Features

- **YouTube videos** - transcript-based analysis OR visual analysis via Gemini
- **Web articles** - fetch and analyze any URL
- **Local media** - video, audio, PDF, text files
- **Pasted content** - transcripts, meeting notes, any text
- **Batch mode** - multiple sources with comparison
- **11 workflows** - summary, golden nuggets, chapters, quotes, workflows, commands, breakdown, full extraction, visual analysis, download, batch

## Prerequisites

### Required

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube data extraction
- [jq](https://jqlang.github.io/jq/) - JSON processing

```bash
brew install yt-dlp jq
```

### Optional (for visual analysis)

- Python 3.8+
- [google-genai](https://pypi.org/project/google-genai/) - Gemini API client
- A [Gemini API key](https://aistudio.google.com/apikey)

```bash
pip install google-genai
```

## Installation

1. Copy the skill to your Claude Code skills directory:

```bash
cp -r media-extract ~/.claude/skills/content/media-extract
```

2. **(For visual analysis only)** Set up your Gemini API key:

```bash
cd ~/.claude/skills/content/media-extract
cp .env.example .env
# Edit .env and add your Gemini API key
```

3. Make the fetch script executable:

```bash
chmod +x ~/.claude/skills/content/media-extract/fetch.sh
```

4. Verify installation:

```bash
# Test yt-dlp
yt-dlp --version

# Test jq
jq --version

# Test Gemini (optional)
python3 -c "from google import genai; print('OK')"
```

## Usage

The skill activates automatically when you share content with Claude Code:

```
# YouTube - transcript summary (default)
Summarize this: https://youtube.com/watch?v=...

# YouTube - visual analysis (sees code on screen)
Watch this and extract the code: https://youtube.com/watch?v=...

# YouTube - download
Download this video: https://youtube.com/watch?v=...

# Web article
Summarize this article: https://example.com/blog/post

# Local video
Analyze this video: /path/to/tutorial.mp4

# Pasted text
[paste transcript] Extract the golden nuggets from this

# Batch
Compare these two videos: [url1] [url2]
```

### Available workflows

| Trigger                             | Workflow            | Description                     |
| ----------------------------------- | ------------------- | ------------------------------- |
| "summarize", URL only               | summary             | Deep structured summary         |
| "golden nuggets", "key insights"    | golden-nuggets      | Key insights extraction         |
| "chapters", "timestamps"            | chapters            | YouTube chapter generation      |
| "quotes", "best moments"            | quotes              | Quotable moments                |
| "extract workflow", "step-by-step"  | workflow-extraction | Process extraction              |
| "extract commands", "code examples" | commands-code       | CLI/code extraction             |
| "breakdown", "content structure"    | breakdown           | Structural analysis             |
| "extract everything"                | full-extraction     | Multi-file comprehensive output |
| "watch this", "visual analysis"     | visual-analysis     | Gemini multimodal analysis      |
| "download this"                     | download            | Save video locally              |
| Multiple URLs, "compare"            | batch               | Batch + comparison              |

## Configuration

On first use, a config file is created at `~/.media-extract/config.json`:

```json
{
  "save_transcripts": true,
  "transcript_dir": "~/.media-extract/cache/transcripts",
  "download_dir": "~/Downloads"
}
```

- `save_transcripts` - Cache YouTube transcripts for reuse (saves API calls)
- `transcript_dir` - Where cached transcripts are stored
- `download_dir` - Default directory for downloaded videos

## Directory Structure

```
media-extract/
  SKILL.md              # Main skill file (router)
  fetch.sh              # YouTube data fetcher (yt-dlp wrapper)
  .env.example          # Gemini API key template
  scripts/
    extract.py          # Gemini visual analysis script
  templates/
    summary-template.md
    golden-nugget-format.md
    chapters-template.md
    quotes-template.md
    workflow-template.md
    commands-code-template.md
    breakdown-template.md
    multi-file-output-template.md
  references/
    workflows/          # Individual workflow instructions
      visual-analysis.md
      download.md
      summary.md
      golden-nuggets.md
      chapters.md
      quotes.md
      workflow-extraction.md
      commands-code.md
      breakdown.md
      full-extraction.md
      batch.md
```

## Sub-commands

This skill also registers slash command variants:

- `/media-extract` - Default (auto-detect intent)
- `/media-extract:visual` - Force visual analysis mode
- `/media-extract:batch` - Force batch mode
- `/media-extract:download` - Force download mode

## Troubleshooting

**"yt-dlp not installed"** - Run `brew install yt-dlp`

**"jq not installed"** - Run `brew install jq`

**"google-genai package not installed"** - Run `pip install google-genai`

**"GEMINI_API_KEY not set"** - Copy `.env.example` to `.env` and add your key

**No subtitles available** - The video may not have auto-generated captions. Try visual analysis instead.

**Video processing failed** - The video may be too long for Gemini upload. Try a shorter clip or transcript-based analysis.
