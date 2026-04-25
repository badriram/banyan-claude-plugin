#!/bin/bash
# BANYAN PRE-COMPACT HOOK — Emergency capture before context compaction
#
# Claude Code "PreCompact" hook. Fires RIGHT BEFORE the conversation
# gets compressed to free up context window space.
#
# This is the safety net. When compaction happens, the AI loses detailed
# context. This hook forces one final capture of everything important.
#
# Unlike the save hook (which triggers every N exchanges), this ALWAYS
# blocks — because compaction is always worth saving before.
#
# Adapted from MemPalace's mempal_precompact_hook.sh (MIT License, 2026 MemPalace Contributors)
#
# === INSTALL ===
# Add to .claude/settings.local.json:
#
#   "hooks": {
#     "PreCompact": [{
#       "hooks": [{
#         "type": "command",
#         "command": "/absolute/path/to/banyan-precompact-hook.sh",
#         "timeout": 30
#       }]
#     }]
#   }

STATE_DIR="$HOME/.banyan/hook_state"
mkdir -p "$STATE_DIR"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','unknown'))" 2>/dev/null)

# One-shot block per session: first /compact attempt forces a checkin handoff,
# subsequent attempts pass through. Without this gate the user gets stuck —
# /compact blocks → checkin happens → user retries → blocks again forever.
MARKER="$STATE_DIR/${SESSION_ID}_precompact_warned"

if [ -f "$MARKER" ]; then
    echo "[$(date '+%H:%M:%S')] PRE-COMPACT pass-through for session $SESSION_ID (already warned)" >> "$STATE_DIR/hook.log"
    echo "{}"
    exit 0
fi

touch "$MARKER"
echo "[$(date '+%H:%M:%S')] PRE-COMPACT first-block for session $SESSION_ID" >> "$STATE_DIR/hook.log"

cat << 'HOOKJSON'
{
  "decision": "block",
  "reason": "Context compaction imminent. Call banyan_checkin NOW with the handoff parameter containing everything the next session needs: what shipped, what's in progress, what's blocked, open questions, and what to do first. Example: banyan_checkin({ agent_id: 'code-builder', handoff: '...' }). This is your last chance before context is compressed. Re-run /compact after the checkin completes — this hook lets the second attempt through."
}
HOOKJSON
