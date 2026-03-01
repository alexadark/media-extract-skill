# SUMMARY: Build media-extract skill

## Result: COMPLETE

## What was built

`media-extract` — a zero-dependency replacement for `content-extractor` that uses `yt-dlp` + `jq` instead of Node.js/npm.

## Files created

| File                                      | Purpose                                                     |
| ----------------------------------------- | ----------------------------------------------------------- |
| `fetch.sh`                                | Bash script with 3 modes: `transcript`, `metadata`, `all`   |
| `SKILL.md`                                | Skill definition with all 8 workflows + metadata enrichment |
| `templates/golden-nugget-format.md`       | Copied from content-extractor                               |
| `templates/workflow-template.md`          | Copied from content-extractor                               |
| `templates/multi-file-output-template.md` | Copied from content-extractor                               |

## Key changes from content-extractor

1. **No npm/Node.js** — `fetch.sh` uses `yt-dlp` and `jq` (both via brew)
2. **YouTube metadata** — new `metadata` mode extracts views, likes, subscribers, tags, chapters, etc.
3. **Combined fetch** — `all` mode gets transcript + metadata in a single yt-dlp call
4. **Metadata enrichment** — SKILL.md adds `<metadata_enrichment>` section for automatic header generation
5. **Native chapters** — chapters workflow checks for YouTube native chapters first
6. **Bash 3.2 compat** — regex patterns stored in variables for macOS default bash

## Deviations from plan

- **Bash 3.2 fix**: `extract_video_id()` had `[?&]` in regex which fails on macOS default bash. Fixed by storing regex in variables.
- **Skill registration**: Plan mentioned checking settings.json — skills are auto-detected from `~/.claude/skills/`, no manual registration needed.

## Tests passed

- `fetch.sh metadata` — valid JSON with title, view_count, duration_formatted
- `fetch.sh transcript en timestamped` — `[MM:SS] text` format
- `fetch.sh transcript en json` — JSON array of `{timestamp, offset, text}`
- `fetch.sh all` — combined `{metadata, transcript}` JSON
- No temp files left in `/tmp/` after any mode
- `content-extractor` left untouched
