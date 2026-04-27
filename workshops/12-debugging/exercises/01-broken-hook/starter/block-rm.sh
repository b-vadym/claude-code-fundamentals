#!/bin/bash
# PreToolUse hook: block dangerous rm commands.
# BUG: this script does not actually block. Find why.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if echo "$COMMAND" | grep -qE 'rm\s+-rf|rm\s+-fr'; then
    # We want Claude to know the command was blocked.
    echo "Blocked: rm -rf is dangerous"
    exit 1
fi

exit 0
