#!/usr/bin/env bash
# Plugin hook: PostToolUse(Write|Edit) → log to ${CLAUDE_PLUGIN_DATA}/edits.log

set -euo pipefail

# Hook input arrives on stdin as JSON. Extract file_path from tool_input.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // "<unknown>"')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "<unknown>"')

# CLAUDE_PLUGIN_DATA is exported as an env var by Claude Code.
mkdir -p "${CLAUDE_PLUGIN_DATA}"
echo "[$(date -Iseconds)] $TOOL $FILE" >> "${CLAUDE_PLUGIN_DATA}/edits.log"
