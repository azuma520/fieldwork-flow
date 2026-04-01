#!/bin/bash
# fieldwork-flow: SessionStart hook script
# 讀 project-config.json → 找最新 handoff → 列活躍 story → 輸出開工摘要

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
CONFIG_FILE="$PROJECT_DIR/.claude/project-config.json"

# ---------- 預設值 ----------
HANDOFF_DIR="文檔"
HANDOFF_PATTERN="session-handoff-*.md"
STORY_DIR="文檔/stories"
STOP_GUARD="true"

# ---------- 讀 config ----------
if [ -f "$CONFIG_FILE" ]; then
  # 用 jq 讀取，缺少的欄位用預設值
  if command -v jq &>/dev/null; then
    HANDOFF_DIR=$(jq -r '.handoff_dir // "文檔"' "$CONFIG_FILE" 2>/dev/null || echo "文檔")
    HANDOFF_PATTERN=$(jq -r '.handoff_pattern // "session-handoff-*.md"' "$CONFIG_FILE" 2>/dev/null || echo "session-handoff-*.md")
    STORY_DIR=$(jq -r '.story_dir // "文檔/stories"' "$CONFIG_FILE" 2>/dev/null || echo "文檔/stories")
    STOP_GUARD=$(jq -r '.stop_guard // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
  else
    echo "[fieldwork-flow] jq 未安裝，使用預設路徑。"
  fi
else
  echo "[fieldwork-flow] 未找到 .claude/project-config.json，使用預設路徑。執行 /fieldwork-flow:init 可建立。"
fi

# 持久化環境變數（供 Stop prompt hook 參考）
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export FIELDWORK_HANDOFF_DIR=\"$HANDOFF_DIR\"" >> "$CLAUDE_ENV_FILE"
  echo "export FIELDWORK_STORY_DIR=\"$STORY_DIR\"" >> "$CLAUDE_ENV_FILE"
  echo "export FIELDWORK_STOP_GUARD=\"$STOP_GUARD\"" >> "$CLAUDE_ENV_FILE"
fi

# ---------- 找最新 handoff ----------
HANDOFF_FULL_DIR="$PROJECT_DIR/$HANDOFF_DIR"
LATEST_HANDOFF=""

if [ -d "$HANDOFF_FULL_DIR" ]; then
  LATEST_HANDOFF=$(ls -1 "$HANDOFF_FULL_DIR"/$HANDOFF_PATTERN 2>/dev/null | sort | tail -1 || true)
fi

echo ""
echo "========== [fieldwork-flow] 開工摘要 =========="

if [ -n "$LATEST_HANDOFF" ]; then
  HANDOFF_NAME=$(basename "$LATEST_HANDOFF")
  echo ""
  echo "📋 最近 handoff: $HANDOFF_NAME"
  # 顯示前 5 行作為摘要（v0.2: 後面有更具體的段落提取）
  head -5 "$LATEST_HANDOFF" 2>/dev/null | sed 's/^/   /'
  echo "   ..."
else
  echo ""
  echo "📋 最近 handoff: 無（$HANDOFF_DIR 下沒有符合 $HANDOFF_PATTERN 的檔案）"
fi

# ---------- v0.2: 提取 frontmatter stories ----------
if [ -n "$LATEST_HANDOFF" ]; then
  # Check if file starts with --- (has frontmatter)
  FIRST_LINE=$(head -1 "$LATEST_HANDOFF" 2>/dev/null || true)
  if [ "$FIRST_LINE" = "---" ]; then
    # Extract stories line from frontmatter
    STORIES_LINE=$(sed -n '/^---$/,/^---$/p' "$LATEST_HANDOFF" | grep "^stories:" || true)
    if [ -n "$STORIES_LINE" ]; then
      echo ""
      echo "📎 關聯 Story: $STORIES_LINE"
    fi
  fi
fi

# ---------- v0.2: 提取待辦清單 ----------
if [ -n "$LATEST_HANDOFF" ]; then
  TODO_SECTION=$(sed -n '/^## 四、待辦清單/,/^## [^#]/p' "$LATEST_HANDOFF" | head -n -1 || true)
  if [ -n "$TODO_SECTION" ]; then
    echo ""
    echo "📝 上次待辦："
    echo "$TODO_SECTION" | sed 's/^/   /'
  fi
fi

# ---------- 列活躍 story ----------
STORY_FULL_DIR="$PROJECT_DIR/$STORY_DIR"

echo ""
if [ -d "$STORY_FULL_DIR" ]; then
  ACTIVE_STORIES=()

  for story_file in "$STORY_FULL_DIR"/S*.md; do
    [ -f "$story_file" ] || continue
    # 讀取狀態——找 metadata table 中的「狀態」欄位
    STATUS=$(grep -oP '(?<=\| 狀態 \| ).*(?= \|)' "$story_file" 2>/dev/null || true)
    # 跳過已完成的
    if echo "$STATUS" | grep -q "已完成"; then
      continue
    fi
    # 讀取優先級和標題
    PRIORITY=$(grep -oP '(?<=\| 優先級 \| ).*(?= \|)' "$story_file" 2>/dev/null || echo "?")
    TITLE=$(head -1 "$story_file" | sed 's/^# //')
    ACTIVE_STORIES+=("  $PRIORITY $TITLE — $STATUS")
  done

  if [ ${#ACTIVE_STORIES[@]} -gt 0 ]; then
    echo "📌 活躍 Story（${#ACTIVE_STORIES[@]} 個）："
    for s in "${ACTIVE_STORIES[@]}"; do
      echo "$s"
    done
  else
    echo "📌 活躍 Story: 無（所有 story 已完成或 $STORY_DIR 為空）"
  fi
else
  echo "📌 活躍 Story: 目錄 $STORY_DIR 不存在"
fi

echo ""
echo "================================================"
