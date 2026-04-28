#!/bin/bash
# BANYAN STARTUP HOOK — Prompt checkin on session start
#
# Claude Code "SessionStart" hook. Fires when a new session begins.
# Blocks and tells the AI to call banyan_checkin to orient itself.

cat << 'HOOKJSON'
{
  "decision": "block",
  "reason": "New session. Call banyan_checkin with your agent_id (and optionally role + trunk_id) to orient. The response includes what changed since your last session and any handoff notes from the previous session. If you don't yet know which trunk you're on, run banyan_list_trunks first to discover trunks you have access to. Example: banyan_checkin({ agent_id: 'code-builder', role: 'code-builder', trunk_id: '<your-trunk-id>' })"
}
HOOKJSON
