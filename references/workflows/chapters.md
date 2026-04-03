<workflow name="chapters">

Generate YouTube-formatted chapter timestamps. Video/audio only.

<steps>

1. Check metadata for native chapters (`metadata.chapters`).
2. Read template: `~/.claude/skills/content/media-extract/templates/chapters-template.md`
3. If native chapters exist: use them as the base, refine titles if needed.
4. If no native chapters: fetch transcript with `timestamped` format, analyze content flow and identify topic transitions.
5. Follow template rules and output format.

</steps>

For timestamped transcript only:

```bash
~/.claude/skills/content/media-extract/fetch.sh transcript "<url>" "" "timestamped"
```

</workflow>
