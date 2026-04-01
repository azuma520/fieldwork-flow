---
name: story-close
description: >
  Close a completed story. Use when the user asks to "close story",
  "結案 story", "story 結案", "mark story done", or wants to finalize
  a story card after all work is complete.
---

Close a story card by updating its status and filling in the closing record.

## Steps

1. Read `.claude/project-config.json` for `story_dir`. Default: `文檔/stories`.

2. Identify which story to close:
   - If user provides an ID (e.g., "close S002"), use that
   - If not, list active stories and ask which one

3. Read the story file. Verify:
   - All subtasks (子任務) are checked `[x]`
   - If unchecked items remain, ask user: "還有未完成的子任務，確定要結案嗎？"

4. Update the story file:
   - Change 狀態 to `✅ 已完成`
   - Set 完成日 to today's date
   - Fill in 結案紀錄 section with:
     - Key decisions made
     - Output file locations
     - Technical notes (if any)

5. Ask the user to provide or confirm the 結案紀錄 content.

6. Save the updated story file.

7. Confirm: "{ID} {title} 已結案。"

## Reference

Read `references/story-format.md` for the complete template and status transition rules.
