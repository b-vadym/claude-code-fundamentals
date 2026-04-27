#!/bin/bash
# PreToolUse hook: block dangerous rm commands.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if echo "$COMMAND" | grep -qE 'rm\s+-rf|rm\s+-fr'; then
    # stderr is what Claude sees on exit 2.
    echo "Blocked: rm -rf is dangerous. Use a more specific path or remove the -r flag." >&2
    exit 2
fi

exit 0
