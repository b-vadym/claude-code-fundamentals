#!/bin/bash
# SessionStart hook — emits a project context summary to stdout.
# stdout is added to Claude's context as a system reminder.

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
  echo "[Project context] cwd unavailable, skipping"
  exit 0
fi

cd "$CWD"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "[Project context]"
  echo "cwd: $CWD (not a git repo)"
  echo "session source: $SOURCE"
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")

# ahead/behind upstream — silently ok if no upstream set
AHEAD_BEHIND=""
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  read -r BEHIND AHEAD < <(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
  if [ "${AHEAD:-0}" -gt 0 ] || [ "${BEHIND:-0}" -gt 0 ]; then
    AHEAD_BEHIND=" (ahead $AHEAD, behind $BEHIND)"
  fi
fi

COMMITS=$(git log --oneline -3 2>/dev/null | sed 's/^/  /')

TODO_COUNT=0
if [ -f CLAUDE.md ]; then
  TODO_COUNT=$(grep -cE '\b(TODO|FIXME|XXX)\b' CLAUDE.md || true)
fi

echo "[Project context]"
echo "cwd: $CWD"
echo "branch: $BRANCH$AHEAD_BEHIND"
echo "recent commits:"
echo "$COMMITS"
echo "todos: $TODO_COUNT (in CLAUDE.md)"
echo "session source: $SOURCE"

exit 0
