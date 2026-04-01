# fieldwork-flow

Claude Code plugin for non-engineering project management workflows. Ensures session continuity and structured work tracking across workspaces.

## Problem

When using Claude Code to manage projects (SEO, events, content, etc.), each session starts fresh — the previous session's tools, methods, and gotchas are lost. This plugin enforces session handoff quality and provides lightweight story card management.

## Components

### Hooks

| Event | Type | Purpose |
|-------|------|---------|
| SessionStart | command | Read latest handoff + list active stories |
| Stop | prompt | Remind to write handoff if missing |

### Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| init | `/fieldwork-flow:init` | Initialize workspace config |
| handoff | `/fieldwork-flow:handoff` | Generate session handoff document |
| standup | `/fieldwork-flow:standup` | Daily standup summary |
| story-new | `/fieldwork-flow:story-new` | Create a new story card |
| story-list | `/fieldwork-flow:story-list` | List active stories |
| story-close | `/fieldwork-flow:story-close` | Close a completed story |
| file-audit | `/fieldwork-flow:file-audit` | Audit workspace file hygiene |

## Setup

1. Copy or symlink this directory to your Claude Code plugins location
2. Restart Claude Code
3. Run `/fieldwork-flow:init` in your workspace to create `project-config.json`

## Configuration

Each workspace uses `.claude/project-config.json`:

```json
{
  "handoff_dir": "文檔",
  "handoff_pattern": "session-handoff-*.md",
  "story_dir": "文檔/stories",
  "stop_guard": true
}
```

All fields are optional — defaults are used for missing fields. See `references/project-config-schema.md` for the full schema.

## Requirements

- `jq` (for config parsing in session-start.sh; falls back to defaults if missing)
- Claude Code with plugin support

## References

- `references/handoff-format.md` — Handoff document format and example
- `references/story-format.md` — Story card template and status definitions
- `references/project-config-schema.md` — Config schema and defaults
- `docs/design.md` — Original approved design document
