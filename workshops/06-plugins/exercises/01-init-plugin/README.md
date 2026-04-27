# Вправа 1 — каркас плагіна `git-toolkit`

**Мета:** робочий каркас плагіна з валідним `plugin.json`, який Claude Code завантажує і `claude plugin validate` не свариться.

**Час:** 10 хв

## Кроки

### 1. Структура

У теці `starter/` створи:

```
git-toolkit/
├── .claude-plugin/
│   └── plugin.json
├── skills/         # порожня поки
├── commands/       # порожня поки
├── agents/         # порожня поки
└── hooks/          # порожня поки
```

```bash
cd starter
mkdir -p git-toolkit/.claude-plugin
mkdir -p git-toolkit/{skills,commands,agents,hooks}
```

### 2. `plugin.json`

`git-toolkit/.claude-plugin/plugin.json`:

```json
{
  "name": "git-toolkit",
  "version": "0.1.0",
  "description": "Git workflow plugin: status summary, log stats, commit reviewer",
  "author": {
    "name": "<your name>",
    "email": "<your email>"
  },
  "homepage": "https://github.com/<you>/git-toolkit",
  "license": "MIT"
}
```

Заміни плейсхолдери на свої.

### 3. Валідуй

```bash
claude plugin validate ./git-toolkit
```

Має написати щось на кшталт `Plugin manifest is valid`. Якщо є помилки — найчастіше `Invalid JSON syntax` (зайва кома) або `name: Required` (опечатка у ключі).

### 4. Завантаж локально

```bash
claude --plugin-dir ./git-toolkit
```

У сесії:

```text
/plugin
```

Знайди `git-toolkit` у списку плагінів. Поки skill-ів і команд нема — `/`-меню не показує нічого. Це нормально: ми додамо їх у вправі 2.

## Чек-перевірки

- [ ] `git-toolkit/.claude-plugin/plugin.json` існує і JSON валідний
- [ ] Тек `skills/`, `commands/`, `agents/`, `hooks/` є на rootі (не в `.claude-plugin/`)
- [ ] `claude plugin validate ./git-toolkit` проходить
- [ ] У `/plugin` UI бачиш `git-toolkit`

## Pitfalls

- ❌ `git-toolkit/.claude-plugin/skills/` — Claude Code не побачить
- ❌ `name: "Git Toolkit"` — має бути `name: "git-toolkit"` (kebab-case)
- ❌ Trailing comma у JSON — валідатор fail-не

## Doc-посилання

- https://code.claude.com/docs/en/plugins#create-the-plugin-manifest
- https://code.claude.com/docs/en/plugins-reference#plugin-manifest-schema
