---
name: standup
description: >
  Daily standup summary. Use when the user asks for a "standup",
  "站會", "daily briefing", "what's the status", or wants a quick
  overview of active work and recent progress.
---

Generate a daily standup summary by reading handoff files and active stories.

## Steps

1. Read `.claude/project-config.json` for paths. Use defaults if missing.

2. Find the most recent handoff file in `handoff_dir`.

3. Scan `story_dir` for all active stories (status is not "已完成").

4. Output a standup summary:

```
📋 最近 handoff: {filename}
   - 完成: {brief summary from handoff}
   - 下一步: {from 開工前置 section}

📌 活躍 Story ({count}):
  {priority emoji} {ID} {title} — {status}
  {priority emoji} {ID} {title} — {status}

⚠ 受阻項目:
  {any stories with 受阻 status, or "無"}
```

5. If no handoff or stories exist, say so clearly.

## Reference

- Read `references/handoff-format.md` for handoff structure
- Read `references/story-format.md` for story structure and status definitions
