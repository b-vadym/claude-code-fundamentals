#!/bin/bash
# block-dangerous.sh — PreToolUse hook.
# Reads JSON from stdin, blocks dangerous bash patterns.
# Exit 0 with JSON deny → blocks. Exit 0 silently → allows.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

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

# kubectl delete *
if echo "$COMMAND" | grep -qE '(^|[ ;&|])kubectl[ ]+delete\b'; then
  deny "kubectl delete blocked by hook (production guard)"
fi

# aws s3 rm * --recursive
if echo "$COMMAND" | grep -qE 'aws[ ]+s3[ ]+rm\b.*--recursive'; then
  deny "aws s3 recursive delete blocked by hook"
fi

# psql destructive SQL via -c
if echo "$COMMAND" | grep -qiE 'psql.*-c[ ]*["\x27].*\b(DROP|TRUNCATE|DELETE FROM)\b'; then
  deny "psql destructive SQL blocked by hook"
fi

# mysql destructive too
if echo "$COMMAND" | grep -qiE 'mysql.*-e[ ]*["\x27].*\b(DROP|TRUNCATE|DELETE FROM)\b'; then
  deny "mysql destructive SQL blocked by hook"
fi

# terraform destroy
if echo "$COMMAND" | grep -qE '(^|[ ;&|])terraform[ ]+destroy\b'; then
  deny "terraform destroy blocked by hook"
fi

# helm uninstall / delete
if echo "$COMMAND" | grep -qE '(^|[ ;&|])helm[ ]+(uninstall|delete)\b'; then
  deny "helm uninstall blocked by hook"
fi

# Direct git push --force to main/master
if echo "$COMMAND" | grep -qE 'git[ ]+push.*--force.*[ ](main|master)\b'; then
  deny "git push --force to main/master blocked by hook"
fi

exit 0
