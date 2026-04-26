#!/bin/bash
# UserPromptSubmit hook (no matcher — fires every prompt).
# Detects sensitive phrases and emits a warning via additionalContext.

set -euo pipefail

INPUT=$(cat)

# TODO 1: extract the prompt text.
# Hint: jq -r '.prompt'
PROMPT=""

# TODO 2: list of patterns (case-insensitive grep -E).
PATTERNS=(
  # 'delete production'
  # 'force push.*(main|master)'
)

# TODO 3: collect matches into WARNED.
WARNED=""
# for re in "${PATTERNS[@]}"; do
#   if echo "$PROMPT" | grep -qiE "$re"; then
#     WARNED+="• matched: '$re'\n"
#   fi
# done

# TODO 4: if any match — emit JSON with hookSpecificOutput.additionalContext.
# if [ -n "$WARNED" ]; then
#   jq -n --arg ctx "..." '{ ... }'
# fi

exit 0
