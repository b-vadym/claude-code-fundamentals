---
name: env-info
description: Print environment context (cwd, git branch, last commit, node version)
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
```

## Your task

Summarise the environment in 3 bullets. Flag detached HEAD, missing node, dirty tree.
End with: `Environment looks <healthy|degraded|broken>.`
