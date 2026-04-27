# Solution — вправа 2

Мульти-компонентний `git-toolkit`: skill + command + agent.

## Структура

```
git-toolkit/
├── .claude-plugin/plugin.json
├── skills/
│   └── status-summary/SKILL.md
├── commands/
│   └── log-stats.md
├── agents/
│   └── commit-message-reviewer.md
└── hooks/  (порожня — у вправі 3)
```

## Перевірка

```bash
claude plugin validate ./git-toolkit
claude --plugin-dir ./git-toolkit
```

У сесії:
- `/git-toolkit:status-summary`
- `/git-toolkit:log-stats`
- `/agents` → `git-toolkit:commit-message-reviewer`
