# Workshop 06 — Plugins: вправи

4 вправи. Кожна — окрема підтека з `README.md` і `starter/`. У `solutions/` лежать готові розв'язки на випадок, якщо застрягнеш.

## Передумови

- Claude Code v1.x встановлений (краще v2.1+, бо `monitors`/деякі CLI-команди потребують свіжої версії)
- `git`, `jq`, `bash` у `$PATH`
- Доступ до `~/.claude/`
- Workshop 04 пройдено АБО розумієш що таке skill з YAML-frontmatter

## План

| # | Назва | Що робиш | Час |
|---|---|---|---|
| 1 | `01-init-plugin` | Каркас плагіна `git-toolkit` з валідним `plugin.json` | 10 хв |
| 2 | `02-multi-component` | Додаєш skill + command + agent | 12 хв |
| 3 | `03-add-hook` | Додаєш `PostToolUse`-hook що логує редагування | 15 хв |
| 4 | `04-marketplace` | Робиш `marketplace.json` і ставиш через `/plugin install` | 15 хв |

**Workflow:**

```bash
cd workshops/06-plugins/exercises/01-init-plugin
cat README.md           # інструкції
cd starter              # сюди клади свій код
# … зроби вправу …
diff -r . ../../solutions/01-init-plugin/   # перевір себе
```

Кожна наступна вправа продовжує плагін з попередньої. Якщо застрягнеш — скопіюй з `solutions/` і йди далі.

## Doc-посилання

- https://code.claude.com/docs/en/plugins
- https://code.claude.com/docs/en/plugin-marketplaces
- https://code.claude.com/docs/en/plugins-reference
