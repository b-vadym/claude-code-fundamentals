# Solution — вправа 3

`git-toolkit` з усіма компонентами + hook.

## Структура

```
git-toolkit/
├── .claude-plugin/plugin.json
├── skills/status-summary/SKILL.md
├── commands/log-stats.md
├── agents/commit-message-reviewer.md
├── hooks/hooks.json                    ← новий
└── scripts/log-edit.sh                 ← новий, chmod +x
```

## Перевірка

```bash
chmod +x git-toolkit/scripts/log-edit.sh   # після клонування repo
claude plugin validate ./git-toolkit
claude --plugin-dir ./git-toolkit
```

У сесії попроси Claude зробити edit. Потім:

```bash
cat ~/.claude/plugins/data/git-toolkit-*/edits.log
```

## Ключові моменти

- `${CLAUDE_PLUGIN_ROOT}` у `hooks.json` (підставляється Claude Code-ом)
- `${CLAUDE_PLUGIN_DATA}` у скрипті (експортується як env var)
- Hook input — JSON на stdin, `jq` для парсингу
