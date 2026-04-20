#!/bin/bash
# BANYAN SAVE HOOK — Auto-capture every N exchanges
#
# Claude Code "Stop" hook. After every assistant response:
# 1. Counts human messages in the session transcript
# 2. Every SAVE_INTERVAL messages, BLOCKS the AI
# 3. Returns a reason telling the AI to call banyan_capture
# 4. AI captures key insights as inbox drafts for human review
# 5. Next Stop fires with stop_hook_active=true → lets AI stop normally
#
# Unlike MemPalace (which auto-ingests everything), Banyan creates captures
# that go to your inbox for review. Deliberate authorship is preserved.
#
# Adapted from MemPalace's mempal_save_hook.sh (MIT License, 2026 MemPalace Contributors)
#
# === INSTALL ===
# Add to .claude/settings.local.json:
#
#   "hooks": {
#     "Stop": [{
#       "matcher": "*",
#       "hooks": [{
#         "type": "command",
#         "command": "/absolute/path/to/banyan-save-hook.sh",
#         "timeout": 30
#       }]
#     }]
#   }
#
# === CONFIGURATION ===

SAVE_INTERVAL=30  # Capture every N human messages (adjust to taste)
STATE_DIR="$HOME/.banyan/hook_state"
mkdir -p "$STATE_DIR"

# Read JSON input from stdin
INPUT=$(cat)

# Parse fields in a single Python call
eval $(echo "$INPUT" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
sid = data.get('session_id', 'unknown')
sha_raw = data.get('stop_hook_active', False)
tp = data.get('transcript_path', '')
safe = lambda s: re.sub(r'[^a-zA-Z0-9_/.\-~]', '', str(s))
sha = 'True' if sha_raw is True or str(sha_raw).lower() in ('true', '1', 'yes') else 'False'
print(f'SESSION_ID=\"{safe(sid)}\"')
print(f'STOP_HOOK_ACTIVE=\"{sha}\"')
print(f'TRANSCRIPT_PATH=\"{safe(tp)}\"')
" 2>/dev/null)

# Expand ~ in path
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"

# If we're already in a save cycle, let the AI stop normally
# This prevents infinite loops: block once -> AI captures -> tries to stop -> we let it through
if [ "$STOP_HOOK_ACTIVE" = "True" ] || [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    echo "{}"
    exit 0
fi

# Count human messages in the JSONL transcript
if [ -f "$TRANSCRIPT_PATH" ]; then
    EXCHANGE_COUNT=$(python3 - "$TRANSCRIPT_PATH" <<'PYEOF'
import json, sys
count = 0
with open(sys.argv[1]) as f:
    for line in f:
        try:
            entry = json.loads(line)
            msg = entry.get('message', {})
            if isinstance(msg, dict) and msg.get('role') == 'user':
                content = msg.get('content', '')
                if isinstance(content, str) and '<command-message>' in content:
                    continue
                count += 1
        except:
            pass
print(count)
PYEOF
2>/dev/null)
else
    EXCHANGE_COUNT=0
fi

# Track last save point for this session
LAST_SAVE_FILE="$STATE_DIR/${SESSION_ID}_last_save"
LAST_SAVE=0
if [ -f "$LAST_SAVE_FILE" ]; then
    LAST_SAVE_RAW=$(cat "$LAST_SAVE_FILE")
    if [[ "$LAST_SAVE_RAW" =~ ^[0-9]+$ ]]; then
        LAST_SAVE="$LAST_SAVE_RAW"
    fi
fi

SINCE_LAST=$((EXCHANGE_COUNT - LAST_SAVE))

# Log for debugging
echo "[$(date '+%H:%M:%S')] Session $SESSION_ID: $EXCHANGE_COUNT exchanges, $SINCE_LAST since last save" >> "$STATE_DIR/hook.log"

# Time to capture?
if [ "$SINCE_LAST" -ge "$SAVE_INTERVAL" ] && [ "$EXCHANGE_COUNT" -gt 0 ]; then
    echo "$EXCHANGE_COUNT" > "$LAST_SAVE_FILE"
    echo "[$(date '+%H:%M:%S')] TRIGGERING CAPTURE at exchange $EXCHANGE_COUNT" >> "$STATE_DIR/hook.log"

    cat << 'HOOKJSON'
{
  "decision": "block",
  "reason": "Banyan session checkpoint. Save a session handoff leaf to your role branch on the active trunk. Convention: each trunk has a branch per role (e.g. 'code-builder'). If the branch doesn't exist, create it with banyan_grow_branch. Then call banyan_add_leaf on that branch with a summary of key decisions, findings, what shipped, and what's next. This is for the next Claude session's continuity, not for human review. Keep it structured and concise. Then continue your work."
}
HOOKJSON
else
    echo "{}"
fi
