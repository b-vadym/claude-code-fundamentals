#!/bin/bash
# UserPromptSubmit hook (no matcher — fires every prompt).
# Detects sensitive phrases and emits a warning via additionalContext.
# Always exits 0 — does not block.

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

if [ -z "$PROMPT" ]; then
  exit 0
fi

PATTERNS=(
  'delete[[:space:]]+production'
  'drop[[:space:]]+production'
  'truncate[[:space:]]+production'
  'force[[:space:]]+push.*(main|master)'
  'disable[[:space:]]+safety'
  'bypass[[:space:]]+review'
  'skip[[:space:]]+tests'
  '--no-verify'
  'rm[[:space:]]+-rf[[:space:]]+~'
)

WARNED=""
for re in "${PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qiE "$re"; then
    WARNED+="• matched: '$re'"$'\n'
  fi
done

if [ -n "$WARNED" ]; then
  CONTEXT=$'⚠️ Sensitive phrase detected in user prompt:\n'"$WARNED"$'\nProceed only with explicit confirmation from user. Do not infer intent for destructive actions.'
  jq -n --arg ctx "$CONTEXT" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'
fi

exit 0
