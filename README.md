# media-extract

A Claude Code skill for universal media extraction and analysis. Handles YouTube videos, web articles, raw transcripts, and pasted text — extracting structured summaries, golden nuggets, workflows, commands, code examples, chapters, quotes, and competitive breakdowns.

## Requirements

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — `brew install yt-dlp`
- [jq](https://jqlang.github.io/jq/) — `brew install jq`

No MCP server, no Node.js, no npm. Just a bash script and yt-dlp.

## Installation

```bash
# Clone to your Claude Code skills directory
git clone https://github.com/alexadark/media-extract-skill.git ~/.claude/skills/media-extract

# Install dependencies
brew install yt-dlp jq
```

## Supported Sources

| Source      | Detection                 | Method              |
| ----------- | ------------------------- | ------------------- |
| YouTube URL | `youtube.com`, `youtu.be` | `fetch.sh` (yt-dlp) |
| Web URL     | Any other URL             | WebFetch tool       |
| Pasted text | No URL detected           | Direct analysis     |
| File path   | Local file path           | Read tool           |

## Extraction Workflows

| Workflow            | Trigger                              | Description                         |
| ------------------- | ------------------------------------ | ----------------------------------- |
| **Summary**         | "summarize", URL without instruction | Deep structured summary             |
| **Golden Nuggets**  | "golden nuggets", "key insights"     | Key insights rated by importance    |
| **Chapters**        | "generate chapters"                  | YouTube-ready timestamp chapters    |
| **Quotes**          | "find quotes", "best moments"        | Quotable moments for clips/social   |
| **Workflows**       | "extract workflow", "step-by-step"   | Step-by-step processes              |
| **Commands & Code** | "extract commands", "code examples"  | CLI commands and code snippets      |
| **Breakdown**       | "analyze", "video breakdown"         | Structural and competitive analysis |
| **Full Extraction** | "extract everything"                 | Multi-file comprehensive output     |

## Usage

Share a YouTube URL, article link, or paste any text in Claude Code:

```
# Summarize a video
https://youtube.com/watch?v=...

# Extract golden nuggets
extract golden nuggets from https://youtube.com/watch?v=...

# Generate chapters
generate chapters for https://youtube.com/watch?v=...

# Full extraction to files
extract everything from https://youtube.com/watch?v=...
```

## Project Structure

```
media-extract/
├── SKILL.md              # Skill definition (routing, workflows, principles)
├── fetch.sh              # YouTube data fetcher (yt-dlp + jq)
├── templates/            # Output format templates
│   ├── summary-template.md
│   ├── golden-nugget-format.md
│   ├── chapters-template.md
│   ├── quotes-template.md
│   ├── commands-code-template.md
│   ├── workflow-template.md
│   ├── breakdown-template.md
│   └── multi-file-output-template.md
└── README.md
```

## Design Principles

- **Utility-first** — Extracts and transforms content into structured formats. No personality, no branding.
- **Self-contained** — Zero external dependencies beyond yt-dlp and jq.
- **Structured output** — Consistent markdown formats that other skills can consume.
- **Timestamp preservation** — Keeps timestamps when available (HH:MM:SS or MM:SS).

## License

MIT
