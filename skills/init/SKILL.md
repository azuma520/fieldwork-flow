---
name: init
description: >
  Initialize a workspace for fieldwork-flow. Use when the user asks to
  "initialize project config", "set up fieldwork-flow", "create project-config.json",
  or when starting fieldwork-flow in a new workspace for the first time.
---

Initialize this workspace for fieldwork-flow by creating `.claude/project-config.json`.

## Steps

1. Check if `.claude/project-config.json` already exists. If yes, show current config and ask if user wants to update it.

2. Scan the workspace for existing handoff and story files:
   - Look for `session-handoff-*.md` files in common directories (`文檔`, `docs`, root)
   - Look for `S*.md` story files in common directories (`文檔/stories`, `docs/stories`)

3. If existing files found, suggest paths based on where they are. If not, use defaults.

4. Present the proposed config to the user via AskUserQuestion:

```json
{
  "handoff_dir": "{detected or default}",
  "handoff_pattern": "session-handoff-*.md",
  "story_dir": "{detected or default}",
  "stop_guard": true
}
```

5. After user confirms, write `.claude/project-config.json`.

6. Create the directories if they don't exist (`handoff_dir`, `story_dir`).

7. Confirm: "Workspace initialized. Restart Claude Code to activate hooks."

## Reference

Read `references/project-config-schema.md` for the full schema and default values.
