---
name: git-cleanup
description: Inspect repository state and suggest cleanup actions (stale branches, dangling stashes, large files)
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git stash list *) Bash(git branch *) Bash(git log *)
---

# git-cleanup

Inspect repository hygiene without making changes:

1. Run `git status --short` — flag any modified/untracked files.
2. Run `git stash list` — flag stashes older than 30 days.
3. Run `git branch --list` — flag local branches with no upstream.
4. Run `git log --oneline -20` — flag commits with `WIP`, `fixup`, `tmp` in subject.

## Constraints

- Pre-approved tools above cover only **read** subcommands of git.
- Do NOT run any modifying command (`git rm`, `git push`, `git reset`, `git stash drop`) — these will trigger approval prompts (or be blocked if deny rules set).
- Do NOT touch the filesystem outside git.
- Output a single markdown report with sections "Working tree", "Stashes", "Branches", "Recent commits".

## Note on permissions

`allowed-tools` is pre-approval, not a sandbox. To **block** other tools entirely,
add deny rules in `~/.claude/settings.json` — see `settings-snippet.json` next to this file.
