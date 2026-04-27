# Solution — вправа 1

Готовий каркас плагіна `git-toolkit`.

## Структура

```
git-toolkit/
├── .claude-plugin/
│   └── plugin.json   # name=git-toolkit, version=0.1.0, license=MIT
├── skills/           # порожня — додамо у вправі 2
├── commands/         # порожня — додамо у вправі 2
├── agents/           # порожня — додамо у вправі 2
└── hooks/            # порожня — додамо у вправі 3
```

## Перевірка

```bash
claude plugin validate ./git-toolkit
# → Plugin manifest is valid

claude --plugin-dir ./git-toolkit
# у сесії: /plugin → бачимо git-toolkit
```
