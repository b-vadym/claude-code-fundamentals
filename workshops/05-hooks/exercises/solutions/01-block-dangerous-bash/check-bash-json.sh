#!/bin/bash
# Bonus variant: returns structured JSON instead of exit 2.
# Output schema: hookSpecificOutput.permissionDecision = "deny" | "allow"
#
# This version is preferable when you want Claude to see a clean
# structured reason rather than parse stderr.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [ -z "$COMMAND" ]; then
  exit 0
fi

DANGEROUS=(
  'rm[[:space:]]+-[a-zA-Z]*[rR][a-zA-Z]*[fF]?[a-zA-Z]*[[:space:]]+/($|[[:space:]]|/(bin|etc|usr|home|var|lib)/?)'
  ':[[:space:]]*\([[:space:]]*\)[[:space:]]*\{[[:space:]]*:'
  'dd[[:space:]]+.*of=/dev/[sh]d[a-z]'
  'mkfs(\.[a-z0-9]+)?[[:space:]]+/dev/[sh]d[a-z]'
  'curl[[:space:]]+.*\|[[:space:]]*(bash|sh|zsh)([[:space:]]|$)'
)

for re in "${DANGEROUS[@]}"; do
  if echo "$COMMAND" | grep -qE "$re"; then
    REASON="Blocked by check-bash.sh: pattern '$re' matched in command. Run manually outside Claude Code if intentional."
    jq -n --arg reason "$REASON" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
    exit 0
  fi
done

exit 0
