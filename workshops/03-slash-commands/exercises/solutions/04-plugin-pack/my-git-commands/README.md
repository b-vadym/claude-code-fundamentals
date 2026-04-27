# my-git-commands

Two namespaced slash commands for git workflows.

## Install (local dev)

```bash
claude --plugin-dir ./my-git-commands
```

## Commands

- `/my-git-commands:git-summary [--since=<duration>] [--author=<name>]` — recent commit summary, grouped by author
- `/my-git-commands:env-info` — prints cwd, branch, last commit, node version

Reload after edits: `/reload-plugins`.
