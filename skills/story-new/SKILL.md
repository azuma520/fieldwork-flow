---
name: story-new
description: >
  Create a new story card. Use when the user asks to "create a story",
  "new story", "建 story", "開新卡", or wants to track a new piece of work.
---

Create a new story card using the standard template.

## Steps

1. Read `.claude/project-config.json` for `story_dir`. Default: `文檔/stories`.

2. Determine the next ID:
   - Scan `story_dir` for all `S*.md` files
   - Extract the highest number
   - New ID = highest + 1, zero-padded to 3 digits (S001, S002, ...)
   - If no stories exist, start at S001

3. Ask the user for required fields (skip if already provided):
   - 標題 (title)
   - 優先級 (🔴 高 / 🟡 中 / 🟢 低)
   - 工作線 (work stream)
   - 背景 (why this needs to be done)

4. Fill in the template from `references/story-format.md`:
   - 狀態: 規劃中
   - 建立日: today
   - 負責人: ask or infer from context

5. Write the story file to `{story_dir}/S{NNN}-{title}.md`.

6. Confirm: "Created {ID} {title} at {path}."

## Reference

Read `references/story-format.md` for the complete template and field definitions.
