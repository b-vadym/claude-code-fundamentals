#!/bin/bash
# PreToolUse hook for Bash matcher.
# Reads JSON on stdin, blocks dangerous commands with exit 2.
#
# Trust boundary: this hook runs with full user permissions.
# It only inspects tool_input.command — it does NOT execute it.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Empty command? Let it through (Claude probably misformatted).
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Extended-regex patterns. Tested against typical Claude tool_input.command values.
DANGEROUS=(
  # rm -rf / (and rm -rf /<some-system-dir>)
  'rm[[:space:]]+-[a-zA-Z]*[rR][a-zA-Z]*[fF]?[a-zA-Z]*[[:space:]]+/($|[[:space:]]|/(bin|etc|usr|home|var|lib)/?)'
  'rm[[:space:]]+-[a-zA-Z]*[fF][a-zA-Z]*[rR][a-zA-Z]*[[:space:]]+/($|[[:space:]]|/(bin|etc|usr|home|var|lib)/?)'

  # Fork bomb: :(){ :|:& };:
  ':[[:space:]]*\([[:space:]]*\)[[:space:]]*\{[[:space:]]*:'

  # dd writing to a block device root
  'dd[[:space:]]+.*of=/dev/[sh]d[a-z]'

  # mkfs on a block device
  'mkfs(\.[a-z0-9]+)?[[:space:]]+/dev/[sh]d[a-z]'

  # Recursive 777 chmod from a system root
  'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/($|[[:space:]])'

  # Overwrite system password files
  '>[[:space:]]*/etc/(passwd|shadow|sudoers)(\b|$)'

  # Curl-pipe-bash (untrusted code execution)
  'curl[[:space:]]+.*\|[[:space:]]*(bash|sh|zsh)([[:space:]]|$)'
  'wget[[:space:]]+.*-O-[[:space:]]+.*\|[[:space:]]*(bash|sh|zsh)([[:space:]]|$)'
)

for re in "${DANGEROUS[@]}"; do
  if echo "$COMMAND" | grep -qE "$re"; then
    echo "Blocked by check-bash.sh: command matches dangerous pattern" >&2
    echo "  command: $COMMAND" >&2
    echo "  pattern: $re" >&2
    echo "  If this is intentional, run it manually outside Claude Code." >&2
    exit 2
  fi
done

exit 0
