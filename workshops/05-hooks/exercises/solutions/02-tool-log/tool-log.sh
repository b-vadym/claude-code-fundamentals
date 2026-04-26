#!/bin/bash
# PostToolUse hook (no matcher — fires on every tool call).
# Append a JSONL line to ~/.claude/tool-log.jsonl.
#
# Always exits 0: observability hooks never block.

set -euo pipefail

LOG="$HOME/.claude/tool-log.jsonl"
mkdir -p "$(dirname "$LOG")"

INPUT=$(cat)

echo "$INPUT" | jq -c '{
  ts:          (now | todate),
  session:     .session_id,
  cwd:         .cwd,
  tool:        .tool_name,
  input:       .tool_input,
  success:     (.tool_response.success // null),
  duration_ms: (.duration_ms // null),
  tool_use_id: .tool_use_id
}' >> "$LOG"

exit 0
