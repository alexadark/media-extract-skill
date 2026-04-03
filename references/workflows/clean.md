# Clean Transcript Workflow

Aggressively clean transcripts to keep ONLY business-relevant content. Remove 60-80% of text while keeping 100% of business value.

## What Gets Removed

### Timestamps (all formats)

- `00:00:00`, `[00:00]`, `(00:00)`, `12:34 -`
- `Speaker Name 00:00:00`
- ACTION ITEM markers and watch links from Fathom

### Filler Words

- "um", "uh", "eh", "ah", "euh"
- "you know", "tu sais", "I mean", "like" (when filler)
- "so basically", "essentially", "en fait", "genre"
- "kind of", "sort of" (when meaningless)
- Repeated words/stutters ("I I think" -> "I think")
- "right, right", "okay okay", "yes yes"

### Small Talk & Pleasantries (REMOVE ENTIRELY)

- Greetings, weather/location chitchat, personal tangents
- Meta-comments ("Can you hear me?"), polite filler ("No worries")
- Closing pleasantries, how-they-found-you discussions

### Noise

- `[inaudible]`, `[crosstalk]`, `[silence]`
- Empty speaker turns, excessive whitespace
- Redundant speaker labels, partial sentences that add nothing

## What Gets Preserved

- **Project requirements** - What they need built
- **Pain points** - Problems they're trying to solve
- **Budget signals** - Any mention of money, investment, priorities
- **Timeline** - Deadlines, urgency indicators
- **Decision criteria** - How they'll evaluate success
- **Technical details** - Stack, integrations, constraints
- **Team/stakeholders** - Who else is involved in decisions
- **Red flags** - Scope creep, unrealistic expectations
- **Opportunities** - Expansion potential, additional projects
- **Key quotes** - Statements revealing priorities or concerns
- **Action items** - Commitments made by either party

## Processing Steps

1. **Detect format** - Identify timestamp pattern and speaker format
2. **Strip timestamps** - Remove all time markers
3. **Remove small talk** - Delete greetings, pleasantries, tangents
4. **Remove non-business** - Delete anything not project/business relevant
5. **Remove fillers** - Clean filler words contextually
6. **Consolidate turns** - Merge fragmented speaker turns into coherent points
7. **Restructure** - Organize by topic, not chronology
8. **Format output** - Clean, scannable sections

## Guiding Principle

**Ask for each sentence: "Does this help me deliver the project or close the deal?"**

- YES -> Keep it
- NO -> Remove it

## Output Template

```markdown
## Project Requirements

[What they need]

## Current Situation / Pain Points

[Problems they described]

## Technical Context

[Stack, integrations, constraints]

## Timeline & Budget

[Any signals about timing or investment]

## Decision Process

[Who decides, what criteria]

## Opportunities

[Expansion potential mentioned]

## Action Items

- [ ] [Party]: [Commitment]

## Key Quotes

> "[Important statement]" - [Speaker]
```

Skip any section that has no content. Only include sections with actual extracted information.
