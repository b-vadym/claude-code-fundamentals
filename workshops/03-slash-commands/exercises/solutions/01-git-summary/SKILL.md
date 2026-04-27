---
name: git-summary
description: Summarize recent git commits, optionally filtered by --since, --author, or other git log flags
argument-hint: [--since=<duration>] [--author=<name>]
disable-model-invocation: true
allowed-tools: Bash(git log *)
---

# git-summary

Run the following command and present the output:

```bash
git log --oneline --no-merges $ARGUMENTS
```

Then:

1. Group commits by author (use `git log --oneline --pretty='%h %an %s' $ARGUMENTS` if you need author info).
2. For each author, list commit subjects.
3. Highlight any commit subjects matching `fix:`, `revert:`, or `hotfix` prefix.
4. End with a one-line total: `N commits, M authors`.

## Notes

- `$ARGUMENTS` expands to the full argument string as typed (verbatim, including quotes).
- If `$ARGUMENTS` is empty, default to `--since='1 week ago'`.
- Only `Bash(git log *)` is pre-approved — do NOT call other git subcommands without asking.
