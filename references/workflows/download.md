<workflow name="download">

Download YouTube video to keep locally.

<steps>

1. Read config for download directory (default: `~/Downloads`).
2. Download at 1080p:
   ```bash
   ~/.claude/skills/content/media-extract/fetch.sh download "<url>" keep "<download_dir>"
   ```
3. Report file path and size to user.

</steps>

</workflow>
