# my-git-toolkit

Two git workflow skills bundled as a Claude Code plugin.

## Skills

- `/my-git-toolkit:git-status-summary` — grouped, prioritized git status
- `/my-git-toolkit:git-bisect-helper` — guided bisect with edge-case handling

## Install

```bash
# One-shot dev session:
claude --plugin-dir ./my-git-toolkit

# Persistent install via local marketplace (see workshop 06):
# /plugin marketplace add ./parent-dir-with-marketplace.json
# /plugin install my-git-toolkit@<marketplace-name>
```

## Verify

```text
/my-git-toolkit:git-status-summary
/my-git-toolkit:git-bisect-helper <good-sha> <bad-sha>
```

## Versioning

Bump `version` in `.claude-plugin/plugin.json` for breaking changes; otherwise users get rolling updates by commit SHA.
