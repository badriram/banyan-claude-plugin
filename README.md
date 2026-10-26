# Banyan Claude Code Plugin

> **Source of truth** for plugin development. The main Banyan repo pins this repo as a git submodule at `banyan-claude-plugin/`.

Collaborative knowledge graph for teams and AI agents. This plugin provides:

- **The Banyan MCP server** for reading, writing, and navigating the knowledge graph
- **Diary hooks** that save session insights before they're lost
- **Slash commands** for quick access to common operations

## Installation

1. Install the plugin in Claude Code (when plugin marketplace is available)
2. Authenticate with your Banyan account via OAuth
3. The plugin auto-registers the MCP server and hooks

## Manual Setup

Add to your `.mcp.json`:

```json
{
  "mcpServers": {
    "banyan": {
      "type": "url",
      "url": "https://api.banyan.vamitra.com/mcp/auth"
    }
  }
}
```

To enable the diary hooks, add to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "bash /path/to/banyan-claude-plugin/hooks/banyan-save-hook.sh",
        "timeout": 30
      }]
    }],
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "bash /path/to/banyan-claude-plugin/hooks/banyan-precompact-hook.sh",
        "timeout": 30
      }]
    }]
  }
}
```

## Commands

- `/banyan:checkin` — Check in with Banyan, get context for your session
- `/banyan:capture` — Save an insight from this conversation to your diary
- `/banyan:status` — Overview of your knowledge graph

## Hooks

- **Startup Hook** (SessionStart event): prompts the AI to check in and read its diary.
- **Save Hook** (Stop event): Every 30 human messages, prompts the AI to call `banyan_checkin` with a `diary_entry`. Diary entries are append-only, scoped to (user, agent_id, trunk_id), and resurface on the next session start.
- **Pre-Compact Hook** (PreCompact event): Before context window compression, prompts for a final `diary_entry` plus a `handoff` summary.

The hooks preserve Banyan's deliberate authorship model — the AI writes each entry itself; nothing is auto-ingested into the graph.
