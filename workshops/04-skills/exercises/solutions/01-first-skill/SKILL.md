---
name: git-status-summary
description: Use when the user asks for the current git working tree
  state, what's staged, modified, or untracked, what changed locally,
  or wants a quick overview of git status.
allowed-tools: [Bash]
---

# git-status-summary

Run `git status --short --branch` and present grouped:

1. **Branch line** — name, ahead/behind, divergence from upstream
2. **Staged** (lines starting with `M `, `A `, `D `, `R `)
3. **Unstaged** (` M`, ` D`)
4. **Untracked** (`??`)

For each section:
- Group files by extension
- Highlight any file >100 KB with a ⚠️ warning (likely accidental commit)
- If a section is empty, write `(none)` rather than skipping it

## Edge cases

- **Empty repo** (no commits): say "no commits yet" and skip status sections
- **Detached HEAD**: prefix output with a clear warning line
- **Submodules dirty**: include in unstaged section with `(submodule)` suffix
