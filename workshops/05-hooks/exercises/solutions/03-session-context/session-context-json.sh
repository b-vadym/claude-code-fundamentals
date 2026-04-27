#!/bin/bash
# Variant: emits structured JSON instead of plain stdout.
# Uses hookSpecificOutput.additionalContext.

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
  exit 0
fi

cd "$CWD"

CONTEXT="[Project context]
cwd: $CWD"

if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
  COMMITS=$(git log --oneline -3 2>/dev/null)
  CONTEXT+="
branch: $BRANCH
recent commits:
$COMMITS"
fi

jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
