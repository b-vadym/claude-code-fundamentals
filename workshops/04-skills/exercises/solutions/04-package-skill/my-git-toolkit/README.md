# my-git-toolkit

Two git workflow skills bundled as a Claude Code plugin.

## Skills

- `/my-git-toolkit:git-status-summary` — grouped, prioritized git status
- `/my-git-toolkit:git-bisect-helper` — guided bisect with edge-case handling

## Install

```bash
claude plugin install ./my-git-toolkit
# or, after publishing to git:
claude plugin install github:your-name/my-git-toolkit
```

## Verify

```text
/my-git-toolkit:git-status-summary
/my-git-toolkit:git-bisect-helper <good-sha> <bad-sha>
```

## Versioning

Bump `version` in `.claude-plugin/plugin.json` for breaking changes; otherwise users get rolling updates by commit SHA.
