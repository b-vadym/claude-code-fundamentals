#!/bin/bash
# PostToolUse hook (no matcher — fires on every tool call).
# Append a JSONL line to ~/.claude/tool-log.jsonl.

set -euo pipefail

LOG="$HOME/.claude/tool-log.jsonl"
INPUT=$(cat)

# TODO 1: build a compact JSON object with these fields:
#   ts          — ISO 8601 timestamp (jq: now | todate)
#   session     — .session_id
#   cwd         — .cwd
#   tool        — .tool_name
#   input       — .tool_input
#   success     — .tool_response.success (or null if missing)
#   duration_ms — .duration_ms (or null if missing)
#
# Hint: pipe $INPUT into jq -c with object construction.

# TODO 2: append the result to $LOG.

# Always exit 0 — observability hooks never block.
exit 0
