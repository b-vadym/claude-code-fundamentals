# Вправа 4 — marketplace + namespaced install

**Мета:** обернути `git-toolkit` у локальний marketplace і встановити через `/plugin install git-toolkit@vcdev-marketplace`. Перевірити, що namespaced invocation працює.

**Час:** 15 хв

**Передумова:** вправа 3 виконана. У `starter/` лежить `git-toolkit/` з skill + command + agent + hook + script.

## Кроки

### 1. Структура marketplace-репо

У теці `starter/` створи:

```
vcdev-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── git-toolkit/    ← перенеси сюди свій плагін
```

```bash
cd starter
mkdir -p vcdev-marketplace/.claude-plugin
mkdir -p vcdev-marketplace/plugins
mv git-toolkit vcdev-marketplace/plugins/
```

### 2. `marketplace.json`

`starter/vcdev-marketplace/.claude-plugin/marketplace.json`:

```json
{
  "name": "vcdev-marketplace",
  "owner": {
    "name": "Vadym Bondarenko",
    "email": "vadym.bondarenko@vcdev.me"
  },
  "metadata": {
    "description": "Personal Claude Code plugins by vcdev"
  },
  "plugins": [
    {
      "name": "git-toolkit",
      "source": "./plugins/git-toolkit",
      "description": "Git workflow plugin: status summary, log stats, commit reviewer",
      "category": "git",
      "tags": ["git", "workflow", "logging"]
    }
  ]
}
```

⚠️ **Не додавай `version` у marketplace entry.** `version` уже є у `plugin.json`. Дублювання → silent bug (`plugin.json` виграє).

### 3. Валідація

```bash
claude plugin validate ./vcdev-marketplace
```

Має написати щось на кшталт `Marketplace is valid`. Якщо ні — найчастіше:

- `Path contains '..'` → ти випадково написав `"../git-toolkit"` замість `"./plugins/git-toolkit"`
- `Duplicate plugin name` → дві entries з тим же `name`
- `Plugin name "X" is not kebab-case` → перейменуй на нижній регістр з дефісами

### 4. Install через marketplace flow

```bash
claude
```

У сесії:

```text
/plugin marketplace add ./vcdev-marketplace
/plugin install git-toolkit@vcdev-marketplace
```

Після install — перезапусти або `/reload-plugins`.

### 5. Тест namespaced invocation

```text
/git-toolkit:status-summary       ← skill
/git-toolkit:log-stats            ← command
/agents                           ← там видно git-toolkit:commit-message-reviewer
```

Зроби edit якогось файлу — hook має додати рядок у:

```bash
cat ~/.claude/plugins/data/git-toolkit-vcdev-marketplace/edits.log
```

### 6. Bonus — `--scope` для команди

```bash
claude plugin install git-toolkit@vcdev-marketplace --scope project
```

Перевір `.claude/settings.json` у твоєму проєкті — там з'явився `enabledPlugins` запис. Тепер коммітнеш — команда автоматично побачить плагін.

## Чек-перевірки

- [ ] `vcdev-marketplace/.claude-plugin/marketplace.json` валідний
- [ ] `git-toolkit/` лежить у `vcdev-marketplace/plugins/`, source=`"./plugins/git-toolkit"`
- [ ] `version` НЕ дубльовано (є тільки у `plugin.json`)
- [ ] `claude plugin validate ./vcdev-marketplace` проходить
- [ ] `/plugin install git-toolkit@vcdev-marketplace` спрацювало
- [ ] `/git-toolkit:status-summary` тригериться
- [ ] Hook пише у `${CLAUDE_PLUGIN_DATA}/edits.log` після Edit

## Pitfalls

- ❌ Marketplace `name` колізія з reserved (`claude-plugins-official`, `anthropic-plugins`, `agent-skills` тощо). Список повний у docs.
- ❌ `source: "../git-toolkit"` — `..` заборонено у source paths. Має бути `./` всередині marketplace root.
- ❌ Marketplace через raw URL + relative-path source → не спрацює. Тут OK, бо ми додаємо локально (path-based).
- ❌ Дублювання `version` у `plugin.json` І `marketplace.json` → `plugin.json` silently виграє.

## Як публікувати у GitHub (поза вправою)

```bash
cd vcdev-marketplace
git init
git add .
git commit -m "Initial marketplace with git-toolkit"
git remote add origin git@github.com:vcdev-me/marketplace.git
git push -u origin main
```

Тепер юзери:

```text
/plugin marketplace add vcdev-me/marketplace
/plugin install git-toolkit@vcdev-marketplace
```

## Doc-посилання

- https://code.claude.com/docs/en/plugin-marketplaces#walkthrough-create-a-local-marketplace
- https://code.claude.com/docs/en/plugin-marketplaces#marketplace-schema
- https://code.claude.com/docs/en/plugin-marketplaces#plugin-sources
