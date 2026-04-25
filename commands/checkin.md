---
description: Check in with Banyan — declare your role, see what changed, get your tasks.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

Call `banyan_checkin` with your agent_id, and optionally role + trunk_id. This orients you on the current state of the trunk you're working on. If you don't know your trunk_id yet, run `banyan_overview` first to discover the trunks you have access to.

Example: `banyan_checkin({ agent_id: "code-builder", role: "code-builder", trunk_id: "<your-trunk-id>" })`

Use `depth: 0` for a quick ~200 token summary, `depth: 1` (default) for standard context, or `depth: 2` for the full response with schemas and thread content.
