---
name: handoff
description: >
  Generate a session handoff document (v0.2). Use when the user asks to
  "write handoff", "create handoff", "do session handoff", "交接",
  or when ending a work session and needing to document progress for the next session.
  Features: six-block format with YAML frontmatter, auto-generated draft,
  story_updates suggestion mode with user confirmation.
---

Generate a session handoff document following the six-block format with YAML frontmatter.
Auto-analyze the session context, produce a draft, and let the user confirm before writing.

## Steps

1. Read `.claude/project-config.json` to find `handoff_dir` (default: `文檔`) and `story_dir` (default: `文檔/stories`).

2. Determine filename: `session-handoff-{YYYYMMDD}-s{N}.md`
   - Date: today
   - Session number: count existing handoffs for today + 1

3. Scan `story_dir` for active stories (S*.md files where 狀態 ≠ ✅ 已完成) — needed to identify which stories were touched in this session.

4. Analyze the current session context and auto-generate a **draft** of the six-block record with YAML frontmatter:

   **YAML Frontmatter:**
   ```yaml
   date: 2026-04-01          # today's date
   stories: [S002, S013]     # story IDs touched in this session
   story_updates:            # for each story touched, suggest what changed
     - story: S002
       subtask: "GTM Alt text Tag 34 加 ID 289"
       action: complete       # complete | progress | block
     - story: S013
       subtask: "Plugin 骨架建立"
       action: complete
   tags: [seo, gtm, cms]     # infer from the work done
   ```

   **六區塊內容：**

   - **一、本次工作摘要** — 2-3 句話概述本次 session 做了什麼、達成什麼目標。
   - **二、完成事項明細** — 條列完成項目，有對應 story 的用 `[SXXX]` 前綴標註。
   - **三、洞見紀錄** — 本次發現的關鍵技術知識、踩過的坑、繞道方案。
   - **四、待辦清單** — 用 checkbox 格式列出待辦事項。包含 `### 開工前置` 子區塊，列出下次 session 開工前需要確認或準備的事項（環境狀態、登入、工具、需確認的資訊）。
   - **五、行動複盤** — 分「做得好」和「可改進」兩段，反思本次 session 的工作方式。
   - **六、檔案異動紀錄** — 表格格式（路徑 | 說明），列出本次 session 新增、修改、刪除的檔案。

5. Present the draft to the user. If `story_updates` is non-empty, explicitly list the suggestions:
   ```
   📝 Story 更新建議：
   - S002 子任務「GTM Alt text Tag 34 加 ID 289」→ ✅ complete
   - S013 子任務「Plugin 骨架建立」→ ✅ complete

   確認要套用這些更新嗎？（Y/N/修正）
   ```

6. User confirms or modifies the draft.

7. Write the handoff file to `{handoff_dir}/{filename}`.

8. If user confirmed story updates: update the corresponding story files (mark subtasks as checked, update status if all subtasks done).
   - **After writing each story file, verify the write succeeded.**
   - If write fails (e.g. file locked by OneDrive), tell the user which updates were NOT applied.

9. Confirm: show file path, brief summary, and which story updates were applied (or skipped).

## Reference

Read `references/handoff-format.md` for the complete format specification and example.
