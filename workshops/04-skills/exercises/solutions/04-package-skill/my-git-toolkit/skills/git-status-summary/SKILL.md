---
name: git-status-summary
description: Use when the user asks for the current git working tree
  state, what's staged, modified, or untracked.
allowed-tools: [Bash]
---

# git-status-summary

Run `git status --short --branch` and present grouped:

1. **Branch line** — name, ahead/behind
2. **Staged** (lines starting with `M `, `A `, `D `)
3. **Unstaged** (` M`, ` D`)
4. **Untracked** (`??`)

Group within each section by file extension. Highlight files >100 KB.
