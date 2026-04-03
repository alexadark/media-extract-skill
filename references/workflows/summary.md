<workflow name="summary">

Deep structured summary of content from any source.

<steps>

1. Get content (fetch YouTube transcript + metadata, fetch article, or use pasted text)

   For YouTube:

   ```bash
   ~/.claude/skills/content/media-extract/fetch.sh all "<url>"
   ```

   **IMPORTANT:** Do NOT pass a language parameter. Most YouTube videos only have auto-generated subtitles. Omitting the lang parameter lets yt-dlp fetch whatever is available. Only pass a specific language code (e.g., `"fr"`, `"es"`) if the user explicitly requests it.

   For web URLs: Use WebFetch with prompt "Return the full article content as markdown". If results are poor (empty body, less than 100 chars, or contains login/paywall indicators), retry with linkup-fetch (`renderJs: true`).

2. Read template: `~/.claude/skills/content/media-extract/templates/summary-template.md`
3. Analyze and extract key information following the template format.
4. Save transcript if configured.

</steps>

</workflow>
