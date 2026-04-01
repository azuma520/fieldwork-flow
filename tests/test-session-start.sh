#!/bin/bash
# fieldwork-flow session-start.sh 測試
# 用法: bash tests/test-session-start.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SESSION_START="$SCRIPT_DIR/scripts/session-start.sh"
PASS=0
FAIL=0
TOTAL=0

# ---------- 工具函式 ----------
setup_workspace() {
  local tmpdir
  tmpdir=$(mktemp -d)
  echo "$tmpdir"
}

cleanup() {
  rm -rf "$1"
}

run_test() {
  local name="$1"
  local workspace="$2"
  local expected_pattern="$3"
  TOTAL=$((TOTAL + 1))

  local output
  output=$(CLAUDE_PROJECT_DIR="$workspace" bash "$SESSION_START" 2>&1 || true)

  if echo "$output" | grep -q "$expected_pattern"; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name"
    echo "    Expected pattern: $expected_pattern"
    echo "    Got output:"
    echo "$output" | head -10 | sed 's/^/    /'
    FAIL=$((FAIL + 1))
  fi
}

run_test_absent() {
  local name="$1"
  local workspace="$2"
  local absent_pattern="$3"
  TOTAL=$((TOTAL + 1))
  local output
  output=$(CLAUDE_PROJECT_DIR="$workspace" bash "$SESSION_START" 2>&1 || true)
  if echo "$output" | grep -q "$absent_pattern"; then
    echo "  FAIL: $name (pattern '$absent_pattern' should NOT appear)"
    echo "    Got output:"
    echo "$output" | head -10 | sed 's/^/    /'
    FAIL=$((FAIL + 1))
  else
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  fi
}

echo "========== session-start.sh tests =========="
echo ""

# ---------- Test 1: 無 config、無 handoff、無 story ----------
echo "Test 1: 空工作區（無 config、無 handoff、無 story）"
WS=$(setup_workspace)
run_test "顯示 config 未找到提示" "$WS" "未找到.*project-config.json"
run_test "顯示無 handoff" "$WS" "無"
run_test "顯示 story 目錄不存在" "$WS" "不存在"
cleanup "$WS"

# ---------- Test 2: 有 config、無 handoff、無 story ----------
echo ""
echo "Test 2: 有 config 但目錄為空"
WS=$(setup_workspace)
mkdir -p "$WS/.claude"
cat > "$WS/.claude/project-config.json" <<'EOF'
{
  "handoff_dir": "docs",
  "story_dir": "docs/stories",
  "stop_guard": true
}
EOF
mkdir -p "$WS/docs/stories"
run_test "不顯示 config 未找到" "$WS" "開工摘要"
run_test "顯示無 handoff" "$WS" "無"
run_test "顯示無活躍 story" "$WS" "無"
cleanup "$WS"

# ---------- Test 3: 有 handoff ----------
echo ""
echo "Test 3: 有 handoff 檔案"
WS=$(setup_workspace)
mkdir -p "$WS/文檔"
cat > "$WS/文檔/session-handoff-20260331-s1.md" <<'EOF'
# Session Handoff — 2026-03-31 S1

## 本次完成
- 測試任務完成

## 開工前置
- 下次可以直接開始 Phase 2
EOF
run_test "找到 handoff 檔案" "$WS" "session-handoff-20260331-s1.md"
run_test "顯示 handoff 內容摘要" "$WS" "測試任務完成"
cleanup "$WS"

# ---------- Test 4: 有活躍 story ----------
echo ""
echo "Test 4: 有活躍 story"
WS=$(setup_workspace)
mkdir -p "$WS/文檔/stories"
cat > "$WS/文檔/stories/S001-測試任務.md" <<'EOF'
# S001 測試任務

| 欄位 | 值 |
|------|------|
| 優先級 | 🔴 高 |
| 狀態 | 進行中 |

## 子任務
- [x] 步驟一
- [ ] 步驟二
EOF
cat > "$WS/文檔/stories/S002-已完成任務.md" <<'EOF'
# S002 已完成任務

| 欄位 | 值 |
|------|------|
| 優先級 | 🟢 低 |
| 狀態 | ✅ 已完成 |

## 結案紀錄
Done.
EOF
run_test "列出活躍 story" "$WS" "S001 測試任務"
run_test "不列已完成 story" "$WS" "1 個"
cleanup "$WS"

# ---------- Test 5: config JSON 格式錯誤 ----------
echo ""
echo "Test 5: config JSON 格式錯誤"
WS=$(setup_workspace)
mkdir -p "$WS/.claude"
echo "{ broken json" > "$WS/.claude/project-config.json"
mkdir -p "$WS/文檔"
run_test "fallback 到預設路徑（不 crash）" "$WS" "開工摘要"
cleanup "$WS"

# ---------- Test 6: 中文目錄路徑 ----------
echo ""
echo "Test 6: 中文目錄路徑"
WS=$(setup_workspace)
mkdir -p "$WS/工作紀錄/stories"
mkdir -p "$WS/.claude"
cat > "$WS/.claude/project-config.json" <<'EOF'
{
  "handoff_dir": "工作紀錄",
  "story_dir": "工作紀錄/stories"
}
EOF
cat > "$WS/工作紀錄/session-handoff-20260331-s1.md" <<'EOF'
# Session Handoff
## 開工前置
- 中文路徑測試
EOF
run_test "中文目錄正常讀取" "$WS" "session-handoff-20260331-s1.md"
cleanup "$WS"

# ---------- Test 6.5: Handoff with YAML frontmatter — stories line ----------
echo ""
echo "Test 6.5: Handoff with YAML frontmatter — stories line"
WS=$(setup_workspace)
mkdir -p "$WS/文檔"
cat > "$WS/文檔/session-handoff-20260401-s1.md" <<'HEREDOC'
---
date: 2026-04-01
stories: [S002, S013]
story_updates:
  - story: S002
    subtask: "測試任務完成"
    action: complete
tags: [test]
---

# Session Handoff — 2026-04-01 S1

## 一、本次工作摘要

測試用 handoff，驗證 frontmatter 抽取。

## 二、完成事項明細

- [S002] 測試任務完成
- [S013] 另一個測試

## 三、洞見紀錄

- 測試洞見

## 四、待辦清單

### 開工前置

- [ ] CMS session 需重新登入

### 後續工作

- [ ] 下一個任務

## 五、行動複盤

- 做得好：測試寫得快
- 可改進：無

## 六、檔案異動紀錄

| 路徑 | 說明 |
|------|------|
| test.md | 測試檔案 |
HEREDOC
run_test "grep frontmatter stories 行" "$WS" "關聯 Story"
run_test "顯示 story ID" "$WS" "S002"
cleanup "$WS"

# ---------- Test 6.6: Handoff with YAML frontmatter — 待辦清單 block ----------
echo ""
echo "Test 6.6: Handoff with YAML frontmatter — 待辦清單 block"
WS=$(setup_workspace)
mkdir -p "$WS/文檔"
cat > "$WS/文檔/session-handoff-20260401-s1.md" <<'HEREDOC'
---
date: 2026-04-01
stories: [S002, S013]
story_updates:
  - story: S002
    subtask: "測試任務完成"
    action: complete
tags: [test]
---

# Session Handoff — 2026-04-01 S1

## 一、本次工作摘要

測試用 handoff，驗證 frontmatter 抽取。

## 二、完成事項明細

- [S002] 測試任務完成
- [S013] 另一個測試

## 三、洞見紀錄

- 測試洞見

## 四、待辦清單

### 開工前置

- [ ] CMS session 需重新登入

### 後續工作

- [ ] 下一個任務

## 五、行動複盤

- 做得好：測試寫得快
- 可改進：無

## 六、檔案異動紀錄

| 路徑 | 說明 |
|------|------|
| test.md | 測試檔案 |
HEREDOC
run_test "提取待辦清單" "$WS" "上次待辦"
run_test "顯示待辦項目" "$WS" "開工前置"
cleanup "$WS"

# ---------- Test 6.7: Handoff WITHOUT frontmatter (v0.1 format) ----------
echo ""
echo "Test 6.7: Handoff WITHOUT frontmatter (v0.1 format) — graceful skip"
WS=$(setup_workspace)
mkdir -p "$WS/文檔"
cat > "$WS/文檔/session-handoff-20260401-s1.md" <<'HEREDOC'
# Session Handoff — 2026-04-01 S1

## 本次完成
- 測試任務完成

## 開工前置
- 下次可以直接開始 Phase 2
HEREDOC
run_test "無 frontmatter 不 crash" "$WS" "開工摘要"
run_test "不顯示關聯 Story" "$WS" "session-handoff"
run_test_absent "確認關聯 Story 不出現" "$WS" "關聯 Story"
cleanup "$WS"

# ---------- Test 6.8: Empty stories array ----------
echo ""
echo "Test 6.8: Empty stories array"
WS=$(setup_workspace)
mkdir -p "$WS/文檔"
cat > "$WS/文檔/session-handoff-20260401-s1.md" <<'HEREDOC'
---
date: 2026-04-01
stories: []
tags: [test]
---

# Session Handoff — 2026-04-01 S1

## 一、本次工作摘要

測試用 handoff，空 stories 陣列。
HEREDOC
run_test "空 stories 不 crash" "$WS" "開工摘要"
run_test "空 stories 仍顯示 stories 行" "$WS" "關聯 Story"
cleanup "$WS"

# ---------- Test 7: 用真實 SEO 工作區測試 ----------
echo ""
SEO_DIR="$HOME/OneDrive/桌面/1141212網站SEO 優化"
if [ -d "$SEO_DIR/文檔/stories" ]; then
  echo "Test 7: 真實 SEO 工作區（唯讀驗證）"
  run_test "找到 handoff" "$SEO_DIR" "session-handoff"
  run_test "列出活躍 story" "$SEO_DIR" "活躍 Story"
else
  echo "Test 7: SKIP（SEO 工作區不存在）"
fi

# ---------- 結果 ----------
echo ""
echo "========================================="
echo "  結果: $PASS/$TOTAL passed, $FAIL failed"
echo "========================================="

if [ $FAIL -gt 0 ]; then
  exit 1
fi
