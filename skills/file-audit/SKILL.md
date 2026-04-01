---
name: file-audit
description: >
  Audit workspace file hygiene. Use when the user asks to "audit files",
  "check file organization", "掃散落檔案", "整理檔案", or wants to identify
  files that need to be organized or archived.
---

Scan the workspace for file hygiene issues and report findings.

## Checks

Perform the following checks in order:

### 1. 根目錄散落檔案

Scan the project root for files that don't belong there:
- Exclude: `CLAUDE.md`, `TODOS.md`, `README.md`, hidden files (`.*/`)
- Flag anything else as "should be moved to a subdirectory"

### 2. 舊版檔案未歸檔

Find files with version markers (v1, v2, etc.) where a newer version exists in the same directory:
- Skip files already in `_歸檔/` or `archive/` directories
- Suggest moving old versions to `_歸檔/`

### 3. 工作紀錄連續性

Check the work log directory for gaps:
- Read `handoff_dir` from project config
- Find all handoff files, check for gaps > 7 days between consecutive entries
- Report gaps as "工作紀錄斷層"

### 4. 受阻任務提醒

Check active stories for ⛔ 受阻 status:
- List any blocked stories with their blocking reason

## Output Format

```
[fieldwork-flow] 檔案稽核結果：

✅ 根目錄：乾淨（或列出散落檔）
✅ 版本歸檔：OK（或列出需歸檔的舊版）
⚠ 工作紀錄：3/15-3/22 有 7 天斷層
✅ 受阻任務：無

共 {N} 項需處理。
```

## Reference

- Read `references/handoff-format.md` for handoff file naming convention
- Read `references/story-format.md` for story status definitions
