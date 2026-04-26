---
name: git-cleanup
description: Inspect repository state and suggest cleanup actions (stale branches, dangling stashes, large files)
disable-model-invocation: true
allowed-tools: TODO list git subcommands here
---

# git-cleanup

Inspect repository hygiene without making changes:

1. Run `git status --short` — flag any modified/untracked files.
2. Run `git stash list` — flag stashes older than 30 days.
3. Run `git branch --list` — flag local branches with no upstream.
4. Run `git log --oneline -20` — flag commits with `WIP`, `fixup`, `tmp`.

## Constraints

- Do NOT run any modifying command (`git rm`, `git push`, `git reset`, `git stash drop`).
- Do NOT touch the filesystem outside git.
- Output a single markdown report with sections "Working tree", "Stashes", "Branches", "Recent commits".
