#!/bin/bash
# Hard-block variant: exit 2 erases the prompt and shows reason to the user.
# Use sparingly — annoys users for false positives.

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Tighter list — only block on clearly destructive phrases.
HARD_BLOCK=(
  'delete[[:space:]]+production[[:space:]]+(database|users|all)'
  'drop[[:space:]]+production[[:space:]]+(database|table|all)'
  'force[[:space:]]+push[[:space:]]+--force[[:space:]]+(origin[[:space:]]+)?(main|master)'
)

for re in "${HARD_BLOCK[@]}"; do
  if echo "$PROMPT" | grep -qiE "$re"; then
    echo "Refusing prompt: matches destructive pattern '$re'." >&2
    echo "Rephrase the request or run the command manually outside Claude Code." >&2
    exit 2
  fi
done

exit 0
