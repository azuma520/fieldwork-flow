# project-config.json Schema

## 位置

每個工作區的 `.claude/project-config.json`。

## 完整 Schema

```json
{
  "handoff_dir": "文檔",
  "handoff_pattern": "session-handoff-*.md",
  "story_dir": "文檔/stories",
  "stop_guard": true
}
```

## 欄位說明

| 欄位 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| `handoff_dir` | string | `"文檔"` | 相對於工作區根目錄，handoff 檔案存放位置 |
| `handoff_pattern` | string | `"session-handoff-*.md"` | handoff 檔名的 glob pattern |
| `story_dir` | string | `"文檔/stories"` | 相對於工作區根目錄，story 卡片存放位置 |
| `stop_guard` | boolean | `true` | 是否啟用 Stop hook 的 handoff 品質提醒 |

## 行為規則

### 沒有 config 檔案時

使用所有預設值，**並在 SessionStart 輸出一行提示**：
```
[fieldwork-flow] 未找到 .claude/project-config.json，使用預設路徑。執行 /fieldwork-flow:init 可建立。
```

### config 檔案格式錯誤時

使用所有預設值，**並在 SessionStart 輸出警告**：
```
[fieldwork-flow] ⚠ .claude/project-config.json 格式錯誤，使用預設路徑。請檢查 JSON 格式。
```

### 部分欄位缺少時

缺少的欄位用預設值補齊，已填的欄位照用。

### stop_guard = false 時

Stop prompt hook 仍會執行（plugin hook 無法動態關閉），但 prompt 中會包含指示不輸出提醒。
實際上 session-start.sh 會把 stop_guard 的值寫入 `$CLAUDE_ENV_FILE`，Stop prompt hook 可以參考此環境變數決定是否提醒。

## 遷移：既有工作區

對於已經有 handoff 和 story 但沒有 config 的工作區：
1. Plugin 照常運作（用預設路徑）
2. 用 `/fieldwork-flow:init` 建立 config，它會：
   - 掃描工作區找現有的 handoff 和 story 目錄
   - 自動推斷正確路徑
   - 產生 config 並請用戶確認
