# fieldwork-flow

Claude Code plugin，給非工程師用的專案管理工作流。解決 session 間的知識斷層——上個 session 知道的工具、方法、已知的坑，下個 session 不知道。

## 定位

現有 plugin（gstack、sd0x-dev-flow、superpowers）都是給軟體開發者設計的。fieldwork-flow 給用 Claude Code 管專案的人用——SEO 優化、食品展、社群經營等非純 code 工作。

## 核心機制

1. **SessionStart hook**（command）— 自動讀 handoff + 活躍 story，列開工摘要
2. **Stop hook**（prompt）— 目的導向提醒：下個 session 能不能無縫接手？只 warn 不 block
3. **Story 卡片管理** — /story-new、/story-list、/story-close
4. **Session handoff** — /handoff 產生標準格式交接文檔
5. **專案初始化** — /init 產生 project-config.json
6. **檔案稽核** — /file-audit 掃描散落檔、舊版本、工作紀錄斷層
7. **站會摘要** — /standup 讀 handoff + story 產生每日簡報

## 技術架構

```
fieldwork-flow/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   └── hooks.json           # SessionStart(command) + Stop(prompt)
├── scripts/
│   └── session-start.sh     # 唯一的 script：讀 config → handoff → story
├── skills/
│   ├── init/SKILL.md
│   ├── handoff/SKILL.md
│   ├── standup/SKILL.md
│   ├── story-new/SKILL.md
│   ├── story-list/SKILL.md
│   ├── story-close/SKILL.md
│   └── file-audit/SKILL.md
├── references/
│   ├── handoff-format.md     # handoff 格式規範 + 範例
│   ├── story-format.md       # story 卡片格式規範 + 模板
│   └── project-config-schema.md  # config schema + 預設值 + 遷移策略
├── docs/
│   └── design.md             # APPROVED 設計文檔 (2026-03-31)
└── README.md
```

## 設計決策（Eng Review 2026-03-31）

| 決策 | 選擇 | 原因 |
|------|------|------|
| Stop hook 類型 | prompt（不是 command） | Claude 有 session 上下文，判斷比 grep 更智能；避開 Windows 相容性 |
| Stop 行為 | 只 warn，不 block | Claude Code Stop hook 技術上無法真的阻止結束 |
| file-audit | skill（不是 hook script） | 通用工具，按需執行比每次 session 自動跑更合理 |
| Script 位置 | scripts/（不是 hooks/scripts/） | 統一放，簡單直覺 |
| Hook 共存 | 精簡輸出 + config 開關 | [fieldwork-flow] 前綴 3-5 行，stop_guard 可關閉 |
| Config fallback | 用預設值 + 顯示警告 | 不靜默 fallback，讓用戶知道 config 沒讀到 |
| Prompt 風格 | 目的導向 | 「下個 session 能不能無縫接手？」而非逐項 checklist |
| 資料契約 | 先定格式再建系統 | Codex review 建議：handoff/story 規範在 references/ |

## 專案配置

每個工作區放 `.claude/project-config.json`：

```json
{
  "handoff_dir": "文檔",
  "handoff_pattern": "session-handoff-*.md",
  "story_dir": "文檔/stories",
  "stop_guard": true
}
```

所有欄位可選，缺少的用預設值。完整 schema 見 `references/project-config-schema.md`。

## 開發原則

- 先自用驗證，有效果再考慮開源
- 跟現有 plugin（sd0x-dev-flow、superpowers）共存，不衝突
- 用 `${CLAUDE_PLUGIN_ROOT}` 引用 plugin 內路徑，不硬寫絕對路徑
- Plugin 結構遵循 Claude Code plugin 規範（`.claude-plugin/plugin.json` 必要）
- Skills 用 `skills/*/SKILL.md` 格式，不用 legacy `commands/`
- 先定義資料格式（references/），再建處理邏輯（scripts/、skills/）

## 開發進度

### Phase 1：骨架 + 格式規範
- [x] plugin.json
- [x] hooks.json（SessionStart command + Stop prompt）
- [x] references/（handoff-format、story-format、project-config-schema）
- [x] scripts/session-start.sh
- [x] skills/（7 個 SKILL.md）
- [x] README.md
- [x] CLAUDE.md 更新

### Phase 2：驗證
- [ ] session-start.sh 本地測試（mock config + handoff + story）
- [ ] 在 SEO 優化工作區安裝測試
- [ ] 連續 3 個 session 驗證 handoff 品質
- [ ] 食品展工作區也能用

## 參考資源

- Plugin 開發規範：`cowork-plugin-management` plugin 的 `create-cowork-plugin` skill
- Hook 開發規範：`Hook Development` skill
- 食品展 hook 腳本：`~/.claude/scripts/file-audit.sh`、`data-check.sh`
- SEO 工作區 story 卡片：`文檔/stories/` 下的現有 story
