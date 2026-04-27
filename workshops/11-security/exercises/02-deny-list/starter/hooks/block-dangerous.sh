#!/bin/bash
# block-dangerous.sh — PreToolUse hook
# Reads JSON from stdin, blocks dangerous bash patterns.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Helper: emit deny decision and exit
deny() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# TODO 1: block kubectl delete *
# if echo "$COMMAND" | grep -qE '^\s*kubectl\s+delete\b'; then
#   deny "kubectl delete blocked by hook"
# fi

# TODO 2: block aws s3 rm * --recursive
# if echo "$COMMAND" | grep -qE 'aws\s+s3\s+rm\b.*--recursive'; then
#   deny "aws s3 recursive delete blocked by hook"
# fi

# TODO 3: block psql DROP / TRUNCATE
# if echo "$COMMAND" | grep -qiE 'psql.*-c.*\b(DROP|TRUNCATE)\b'; then
#   deny "psql destructive SQL blocked by hook"
# fi

# TODO 4: block terraform destroy
# if echo "$COMMAND" | grep -qE '^\s*terraform\s+destroy\b'; then
#   deny "terraform destroy blocked by hook"
# fi

exit 0
