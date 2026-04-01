# Session Handoff 格式規範 v0.2

## 檔名

`session-handoff-{YYYYMMDD}-s{N}.md`

- `{YYYYMMDD}` — 日期
- `s{N}` — 當日第幾個 session（s1, s2, s3...）

範例：`session-handoff-20260401-s1.md`

## 存放位置

由 `project-config.json` 的 `handoff_dir` 決定，預設 `文檔`。

---

## YAML Frontmatter

每份 handoff 開頭必須包含 YAML frontmatter，提供結構化 metadata 供趨勢分析與 story 交叉引用使用。

```yaml
---
date: 2026-04-01
stories: [S002, S013]
story_updates:
  - story: S002
    subtask: "GTM Alt text Tag 34 加 ID 289"
    action: complete
  - story: S013
    subtask: "Plugin 骨架建立"
    action: complete
tags: [seo, cms, fieldwork-flow]
---
```

### 欄位說明

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `date` | `YYYY-MM-DD` | 是 | Session 日期 |
| `stories` | string array | 是 | 本次 session 涉及的 story ID，沒有則填 `[]` |
| `story_updates` | object array | 否 | 建議的 story 更新（使用者確認後才寫入 story 檔案） |
| `story_updates[].story` | string | 是 | Story ID（如 `S002`） |
| `story_updates[].subtask` | string | 是 | 子任務描述 |
| `story_updates[].action` | enum | 是 | `complete`、`progress`、`block` 三選一 |
| `tags` | string array | 否 | 自由分類標籤 |

> **注意：** `story_updates` 是建議性質——使用者確認後才會寫入對應的 story 檔案。

---

## 六大區塊

Handoff 本體由六個區塊組成，同時兼具工作紀錄與交接兩個用途。順序固定如下：

### 一、本次工作摘要

2-3 句話概述本次 session 做了什麼、達成了什麼。

### 二、完成事項明細

詳細列出完成的工作項目。涉及 story 時用 `[SXXX]` 前綴標注來源。

### 三、洞見紀錄

本次 session 發現的關鍵資訊、模式、學到的東西。包含踩過的坑、workaround、需要記住的行為差異（取代 v0.1 的「技術備註」區塊）。

### 四、待辦清單

下一步工作，以 checkbox 格式列出。包含一個必要子區段：

#### `### 開工前置` 子區段

放在待辦清單內部，列出下一個 session 開始前需要的準備事項：
- 環境狀態（哪些工具 / session / 登入是活的）
- 需要先確認的資訊
- 可以直接開始的下一步

### 五、行動複盤

回顧本次 session：哪些做法有效、哪些需要改進。

### 六、檔案異動紀錄

以表格列出本次 session 異動的檔案，包含路徑與變更說明。

---

## 品質判斷規則

### session-start.sh 檢查

讀取最近一份 handoff，grep 以下兩個 pattern：
1. frontmatter 中的 `stories:` 行 — 確認有結構化 metadata
2. `## 四、待辦清單` 標題 — 確認有待辦事項可以接手

### Stop prompt 檢查

檢查本次 session 是否有執行過 `/handoff`（不是「今天」，是「這個 session」）。

### 向下相容

沒有 frontmatter 的舊版 handoff（v0.1）跳過 frontmatter 相關檢查，不報錯。

---

## 向下相容說明

v0.1 格式的 handoff（沒有 YAML frontmatter、四區塊結構）仍然是合法檔案。差異在於：
- 不會有 frontmatter 資料可供趨勢分析
- 不會有 story 交叉引用
- session-start.sh 的 frontmatter 檢查會被跳過（graceful skip）

不需要回溯轉換舊檔案。

---

## 完整範例

```markdown
---
date: 2026-04-01
stories: [S002, S013]
story_updates:
  - story: S002
    subtask: "GTM Alt text Tag 34 加 ID 289"
    action: complete
  - story: S013
    subtask: "Plugin 骨架建立"
    action: complete
tags: [seo, cms, fieldwork-flow]
---

# Session Handoff — 2026-04-01 S1

## 一、本次工作摘要

完成 S002 最後一個子任務（GTM Alt text Tag 34 補上 ID 289），S002 正式結案。同時建立 fieldwork-flow plugin 骨架，完成 handoff 格式規範 v0.2 升級。

## 二、完成事項明細

- [S002] GTM Alt text Tag 34 加入 ID 289，publish v28
- [S002] 追蹤表更新：ID 289 圖片檔名欄位已填入
- [S013] fieldwork-flow plugin 骨架建立（project-config.json + hooks）
- [S013] handoff-format.md 升級至 v0.2（6 區塊 + YAML frontmatter）

## 三、洞見紀錄

- GTM Custom HTML tag 的 Alt text 注入需要等圖片 load 完成，用 MutationObserver 比 setTimeout 穩定
- Plugin 的 bash hook 只做簡單 grep（stories: 行、待辦標題），YAML 完整解析交給 Claude

## 四、待辦清單

### 開工前置

- [ ] CMS session 已過期，開工前需重新登入（`cms_login.py`，需手動驗證碼）
- [ ] Chrome CDP 需要重啟（user-data-dir: `C:/tmp/chrome-debug`）

### 後續工作

- [ ] [S013] 實作 session-start.sh 讀取最近 handoff
- [ ] [S013] 實作 stop prompt hook 檢查 /handoff 執行狀態
- [ ] [S006] SEO baseline 跑一次（等 Google 索引完成）
- [ ] [S011] 分類頁 Meta Description 撰寫

## 五、行動複盤

- 做得好：先定 handoff 格式規範再寫 hook，避免來回修改
- 可改進：GTM tag 測試花了太多時間在手動驗證，下次可以先寫 E2E 檢查腳本

## 六、檔案異動紀錄

| 路徑 | 說明 |
|------|------|
| `references/handoff-format.md` | v0.1 → v0.2 升級（6 區塊 + frontmatter） |
| `project-config.json` | 新增 plugin 設定檔 |
| `官網自動化/data/gtm-seo-alt-text.html` | Tag 34 加入 ID 289 |
| `鉦旺樂商品頁SEO分析_修正版.xlsx` | ID 289 圖片檔名更新 |
```
