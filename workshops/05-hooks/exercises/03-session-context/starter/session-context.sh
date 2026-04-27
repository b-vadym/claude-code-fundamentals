#!/bin/bash
# SessionStart hook — emits context lines to stdout.
# stdout is added to Claude's context as a system reminder.

set -euo pipefail

INPUT=$(cat)

# TODO 1: extract cwd from $INPUT
CWD=""

# TODO 2: cd into CWD; if not a git repo, print a minimal context and exit 0.

# TODO 3: detect:
#   - current branch (git branch --show-current)
#   - ahead/behind upstream  (git rev-list --left-right --count @{u}...HEAD 2>/dev/null)
#   - last 3 commits oneline (git log --oneline -3)

# TODO 4: count TODO/FIXME lines in ./CLAUDE.md if it exists.

# TODO 5: print everything to stdout.
echo "[Project context]"
echo "cwd: $CWD"
# ...

exit 0
