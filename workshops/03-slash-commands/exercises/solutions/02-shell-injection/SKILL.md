---
name: env-info
description: Print environment context (cwd, git branch, last commit, node version, OS)
disable-model-invocation: true
allowed-tools: Bash(pwd) Bash(git *) Bash(node *) Bash(uname *)
---

# env-info

## Context

- Working directory: !`pwd`
- Current branch: !`git branch --show-current 2>/dev/null || echo "(not a git repo)"`
- Latest commit: !`git log -1 --oneline 2>/dev/null || echo "(no commits)"`
- Node version: !`node --version 2>/dev/null || echo "(node not installed)"`

## System

```!
uname -a
git status --short 2>/dev/null || echo "(not a git repo)"
```

## Your task

Summarise the environment in 3 bullet points. Flag anything unusual:

- **Detached HEAD** — branch output is empty or starts with `(`.
- **Dirty tree** — `git status --short` printed any lines.
- **Missing node** — version line is `(node not installed)`.

End with one line: `Environment looks <healthy|degraded|broken>.`
