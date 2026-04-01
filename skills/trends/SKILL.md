---
name: trends
description: >
  Analyze session records and generate trend reports. Use when the user asks to
  "看趨勢", "本週做了什麼", "generate weekly report", "trends", "週報",
  or wants to review work patterns over time.
---

# Trends — 三視角趨勢分析

讀取所有 handoff 紀錄的 YAML frontmatter 與內文，產出趨勢報告。本 skill 僅讀取資料，不寫入或修改任何檔案。

---

## Step 1 — 讀取設定

讀取 `.claude/project-config.json`，取得：

- `handoff_dir`（預設：`文檔`）
- `story_dir`（預設：`文檔/stories`）

如果檔案不存在，使用預設值。

---

## Step 2 — 掃描 handoff 紀錄

在 `handoff_dir` 中掃描所有 `session-handoff-*.md` 檔案。

對每個檔案：
1. 解析開頭 `---` 標記之間的 YAML frontmatter
2. 如果檔案沒有 frontmatter（v0.1 格式），**靜默跳過**，不提及、不警告
3. 從 frontmatter 取得 `date`、`stories`、`session_id` 等欄位
4. 從內文取得「洞見」、「行動複盤」等段落

---

## Step 3 — 判定分析時間範圍

預設：最近 7 天。

用戶可指定：
- `--range 14d`、`--range 30d` — 往回推算天數
- `--from 2026-03-25 --to 2026-04-01` — 指定起訖日期

篩選出時間範圍內的紀錄。如果範圍內紀錄少於 3 份，輸出警告：

```
⚠️ 範圍內僅有 {N} 份紀錄，趨勢分析可能不夠充分。
```

仍然產出摘要，但註明資料有限。

---

## Step 4 — 資料範圍指示器

報告開頭**必定**顯示資料範圍指示器，格式如下：

```
📊 資料範圍：{起始日期} ~ {結束日期}（共 {N} 份紀錄）
```

只呈現實際分析的紀錄範圍。**不可**提及舊紀錄、技術債、v0.1 格式等內部細節。

---

## Step 5 — 產出報告

根據 `--format` 參數選擇輸出格式。未指定時使用預設格式。

### 預設格式（給自己）

適合快速回顧本週工作。

```
📊 資料範圍：{起始日期} ~ {結束日期}（共 {N} 份紀錄）

📋 本週摘要（{起始日期} ~ {結束日期}）
  完成 session: {數量}
  推進 story: {story ID 列表}
  完成 story: {story ID 列表，無則寫「無」}
  新增洞見: {數量} 條
  做對了: {從各 session 行動複盤彙總}
  需改進: {從各 session 行動複盤彙總}
```

彙總行動複盤時：
- 合併重複的項目
- 將相似的觀察歸為同一條
- 如果同一個改進點重複出現，標注出現次數（例如「避免跳步驟寫文案（x3）」）

### `--format=report`（給老闆/團隊）

適合週會報告、團隊同步。

```markdown
📊 資料範圍：{起始日期} ~ {結束日期}（共 {N} 份紀錄）

# 週報 — {ISO 週號，例如 2026-W14}

## 本週重點
- {高層級的完成事項，用業務語言描述}

## 進行中
- {仍在推進的 story，附進度估計百分比}

## 受阻
- {受阻項目，無則寫「無」}
```

注意事項：
- 用業務語言，避免技術術語
- 每個要點一行，簡潔明瞭
- 進度百分比根據 story 的已完成 task 數估算

### `--format=claude`（給 Claude session-start）

供 session-start.sh 自動注入上下文使用。

輸出內容：
1. **最近 3 個 session 的待辦清單** — 從各 handoff 的「下次待辦」段落擷取
2. **趨勢摘要** — 哪些 story 仍在活躍、行動複盤中是否有重複出現的模式
3. **注意事項** — 從行動複盤中提取需要持續注意的改進點

格式保持簡潔，適合作為 system prompt 的上下文注入。

---

## 解析規則

### Frontmatter 解析
讀取檔案開頭第一個 `---` 到第二個 `---` 之間的 YAML 內容。

### 內文段落解析
Frontmatter 之外的 markdown 內文，依 `##` 標題識別段落：
- `## 洞見` 或 `## Insights` — 本次 session 的洞見
- `## 行動複盤` 或 `## Retrospective` — 做對了什麼、需改進什麼
- `## 下次待辦` 或 `## Next Actions` — 待辦事項清單

### 資料不足處理
- 0 份紀錄：告知用戶尚無 handoff 紀錄，無法產出趨勢報告
- 1-2 份紀錄：產出摘要但註明資料有限，不做趨勢推斷
- 3 份以上：完整趨勢分析
