# Chapters Template

Use this template for generating YouTube-formatted chapter timestamps from video/audio content.

---

## Rules

- First chapter MUST start at `00:00`
- Target 8-15 chapters for a 15-30min video (adjust proportionally)
- If native YouTube chapters exist in metadata (`metadata.chapters`), use them as the base and refine titles if needed
- If no native chapters: analyze transcript content flow and identify topic transitions

## Output Format (ready to paste in YouTube)

```
00:00 Introduction
01:23 [Chapter title]
04:56 [Chapter title]
08:12 [Chapter title]
12:30 [Chapter title]
```

No bullets, no markdown, no extra formatting — plain text ready for YouTube description.

## Notes

- If native chapters were used as base, add a note: "Based on native YouTube chapters (refined titles)."
- Chapter titles should be concise (2-5 words), descriptive, and searchable.
- Avoid generic titles like "Part 1", "Section 2" — use topic-specific titles.
- Timestamps must be in ascending order.
