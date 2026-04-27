# Solution — вправа 4

Локальний marketplace `vcdev-marketplace` з одним плагіном `git-toolkit`.

## Структура

```
vcdev-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── git-toolkit/
        ├── .claude-plugin/plugin.json
        ├── skills/status-summary/SKILL.md
        ├── commands/log-stats.md
        ├── agents/commit-message-reviewer.md
        ├── hooks/hooks.json
        └── scripts/log-edit.sh   (chmod +x)
```

## Install flow

```bash
chmod +x vcdev-marketplace/plugins/git-toolkit/scripts/log-edit.sh
claude plugin validate ./vcdev-marketplace
claude
# у сесії:
# /plugin marketplace add ./vcdev-marketplace
# /plugin install git-toolkit@vcdev-marketplace
```

## Тестування

- `/git-toolkit:status-summary`
- `/git-toolkit:log-stats`
- `/agents` → `git-toolkit:commit-message-reviewer`
- Edit будь-який файл → `cat ~/.claude/plugins/data/git-toolkit-vcdev-marketplace/edits.log`

## Ключові деталі

- `marketplace.json` `name` — public-facing: `/plugin install <plugin>@<marketplace-name>`
- `version` НЕ дубльовано: тільки в `plugin.json` (= 0.1.0)
- `source: "./plugins/git-toolkit"` — relative path всередині marketplace root
- Не reserved name: `vcdev-marketplace` ≠ `claude-plugins-official` etc.
