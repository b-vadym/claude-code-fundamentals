#!/bin/bash
# PreToolUse hook for Bash matcher.
# Reads JSON on stdin, blocks dangerous commands with exit 2.

set -euo pipefail

INPUT=$(cat)

# TODO 1: extract the bash command from $INPUT.
# Hint: jq -r '.tool_input.command'
COMMAND=""

# TODO 2: list of dangerous patterns (extended POSIX regex).
# Add at least: rm -rf /, fork bomb, dd of=/dev/{sd,hd}.
DANGEROUS=(
  # 'rm[[:space:]]+-rf?[[:space:]]+/($|[[:space:]])'
  # ':\(\)\s*\{[[:space:]]*:'
  # 'dd[[:space:]]+.*of=/dev/[sh]d'
)

# TODO 3: loop over DANGEROUS, on match write to stderr and exit 2.
# Hint:
#   for re in "${DANGEROUS[@]}"; do
#     if echo "$COMMAND" | grep -qE "$re"; then
#       echo "Blocked: ..." >&2
#       exit 2
#     fi
#   done

exit 0
