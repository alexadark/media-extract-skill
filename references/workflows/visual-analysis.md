<workflow name="visual-analysis">

Analyze video content visually using Gemini - sees code on screen, diagrams, UI, terminal output.

**When to use:** Technical tutorials, coding videos, any video where screen content matters.

<steps>

1. **Check prerequisites:**

   ```bash
   python3 -c "from google import genai; print('OK')"
   ```

   If missing, help user install: `pip install google-genai`
   If `.env` file missing in skill directory, help user create it from `.env.example`.

2. **Determine source and get video file:**
   - **YouTube URL (single video):**

     ```bash
     ~/.claude/skills/content/media-extract/fetch.sh download "<url>" analyze "/tmp/media-extract-visual"
     ```

     This downloads at 420p into a temp folder.

   - **YouTube playlist URL:**

     ```bash
     ~/.claude/skills/content/media-extract/fetch.sh download "<url>" playlist "/tmp/media-extract-visual"
     ```

     Downloads all playlist videos at 420p.

   - **Local video file:** Use the file path directly.

   - **Folder of videos:** Use the folder path directly.

3. **Run Gemini analysis:**

   ```bash
   python3 ~/.claude/skills/content/media-extract/scripts/extract.py "<path>" --type technical --cleanup
   ```

   Use `--type general` for non-technical content.
   Use `--cleanup` only for temp downloads (not local files the user owns).
   The script handles single files and folders.

4. **Read the output file** and present results to the user.

5. **Save transcript** if configured (extract the Transcript section from Gemini output).

</steps>

<output>
Structured markdown with: Overview, Key Concepts, Code & Commands, Architecture, Step-by-Step Procedures, Tips & Gotchas, References, Full Transcript.
</output>

</workflow>
