---
description: Use when user asks for current git working tree state, what's staged, modified, or untracked. Show grouped summary.
allowed-tools: [Bash]
---

# git-toolkit:status-summary

Run `git status --short --branch` and present:

1. **Branch line** — name, ahead/behind
2. **Staged** (lines starting with `M `, `A `, `D `)
3. **Unstaged** (` M`, ` D`)
4. **Untracked** (`??`)

Group within each section by file extension.
Highlight files >100 KB with a ⚠️ note.
