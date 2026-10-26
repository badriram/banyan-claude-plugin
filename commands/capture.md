---
description: Capture insights from this session to your Banyan diary.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

Call `banyan_checkin` with `agent_id`, `trunk_id`, and a `diary_entry` capturing the key insight, decision, or finding from this conversation. Diary entries are append-only, scoped to your (user, agent_id, trunk_id), and resurface on the next `banyan_checkin({ session_start: true })`.

Keep each entry specific and under 4KB (the server rejects oversize entries). Use the trunk you've been working on — omitting `trunk_id` writes nothing. Do not pass `handoff` here; that is the end-of-session summary.
