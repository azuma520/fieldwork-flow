---
name: story-list
description: >
  List active stories. Use when the user asks to "list stories",
  "show stories", "看 story", "有哪些任務", or wants to see current work items.
---

列出所有活躍（未完成）的 Story，依優先級排序，並顯示相關 session 紀錄。

## Steps

1. Read `.claude/project-config.json` for `story_dir`. Default: `文檔/stories`.

2. Scan `story_dir` for all `S*.md` files.

3. For each file, extract from the metadata table:
   - ID and title (from H1)
   - 優先級
   - 狀態
   - 負責人
   - 工作線

4. Filter out stories with 狀態 = "✅ 已完成".

5. Sort by priority: 🔴 高 first, then 🟡 中, then 🟢 低.

6. **查詢相關 session**：
   - Read `.claude/project-config.json` for `handoff_dir`. Default: `文檔`.
   - Scan `handoff_dir` for all `session-handoff-*.md` files.
   - For each handoff file, read its YAML frontmatter（`---` 區塊）。如果檔案沒有 frontmatter，跳過該檔案。
   - Parse frontmatter 中的 `stories` array（例如 `stories: [S002, S011]`）。
   - **精確比對**：逐一檢查 story ID 是否完全匹配 array 中的元素。不可用 substring 或 regex 匹配——S01 不應匹配到 S013。
   - 統計每個 story 被多少個 session 引用，並記錄最近一次 session 的日期（從檔名 `session-handoff-YYYY-MM-DD` 或 frontmatter `date` 欄位取得）。

7. Output as a table:

```
📌 活躍 Story（{count} 個）：

| ID | 標題 | 優先級 | 狀態 | 相關 session | 最近操作 |
|----|------|--------|------|-------------|---------|
| S002 | 西班牙檸檬汁桶裝上架 | 🔴 高 | 進行中 | 3 次 | 2026-04-01 |
| S011 | 分類頁 Meta Description | 🟡 中 | 規劃中 | 0 次 | — |

已完成 Story: {count} 個（用 /fieldwork-flow:story-list --all 顯示全部）
```

8. If `--all` argument provided, include completed stories in a separate section.

## 單一 Story 詳情模式

當使用者指定特定 Story（例如 `/fieldwork-flow:story-list S002` 或「show S002」「看 S002」）：

1. 讀取該 Story 檔案，顯示完整 story card 內容。
2. 列出所有相關 session（同樣使用步驟 6 的精確比對邏輯），按日期降序排列：

```
📋 相關 session：
  - 2026-04-01 S1（完成: GTM Alt text Tag 34）
  - 2026-03-31 S2（進度: 圖片檔名更新）
```

   Session 摘要從 handoff 檔案的 frontmatter `summary` 或 `session` 欄位取得。如果沒有摘要資訊，僅顯示日期與 session 編號。

3. 如果沒有找到任何相關 session，顯示「尚無相關 session 紀錄」。

## Reference

Read `references/story-format.md` for status definitions and field structure.
