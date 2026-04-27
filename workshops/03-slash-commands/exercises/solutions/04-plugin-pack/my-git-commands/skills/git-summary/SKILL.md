---
name: git-summary
description: Summarize recent git commits, optionally filtered by --since, --author
argument-hint: [--since=<duration>] [--author=<name>]
disable-model-invocation: true
allowed-tools: Bash(git log *)
---

# git-summary

Run `git log --oneline --no-merges $ARGUMENTS` and present the output:

1. Group commits by author.
2. Highlight `fix:`, `revert:`, `hotfix` prefixes.
3. End with: `N commits, M authors`.

If `$ARGUMENTS` is empty, default to `--since='1 week ago'`.
