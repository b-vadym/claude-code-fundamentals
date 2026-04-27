---
theme: seriph
background: https://images.unsplash.com/photo-1518770660439-4636190af475?w=1920
title: "Workshop 06 — Plugins: глибоке занурення в авторство"
info: |
  ## Workshop 06 — Plugins
  Авторинг плагінів Claude Code: маніфест, multi-component bundling, marketplace, versioning
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 06

## Plugins: глибоке занурення в авторство

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · `git-toolkit` плагін з нуля до marketplace</div>

<!--
Привіт. Шостий воркшоп серії — авторство плагінів Claude Code. У workshop 04 ми вже бачили, що skill можна запакувати у плагін. Тут далі — як упакувати skill, command, hook і agent в один плагін, опублікувати через marketplace, обрати стратегію версіонування і не наступити на 10 граблів. Через 4 вправи паралельно зі мною. Тримай терміналом.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Згенерувати `plugin.json`** з повним маніфестом за специфікацією
- **Спакувати кілька компонентів** — skills + commands + hooks + agents в один плагін
- **Написати hook** з `${CLAUDE_PLUGIN_ROOT}` що логує `PostToolUse`
- **Створити `marketplace.json`** і встановити плагін через `/plugin install <name>@<marketplace>`
- **Обрати стратегію версіонування** — explicit semver vs commit-SHA свідомо
- **Уникнути 10 типових пасток** — `.claude-plugin/`-плутанини, version-pinning, path-traversal

</v-clicks>

<!--
Це не теорія — після воркшопу маєш `git-toolkit` плагін у git-репо, готовий до публікації. Workshop 04 закінчився мінімальним plugin.json — тут ми робимо повний цикл distribution.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` зі свого терміналу
- **Ти кодиш паралельно** — `git clone <repo>; cd workshops/06-plugins/exercises`
- **4 вправи** — кожна 10–15 хв, у власній підтеці
- **`solutions/`** — готові розв'язки на випадок, якщо застрягнеш
- **`handout.pdf`** — пост-воркшоп референс зі схемами і pitfalls

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: Claude Code v1.x (краще v2.1+), Workshop 04 пройдено, термінал, доступ до <code>~/.claude/</code>
</div>

<!--
Дай хвилину на клон. Хто не встиг — пиши в чат.
-->

---
layout: section
---

# Контекст

Що ми знаємо про плагіни і чого ще не знаємо

---

# Те, що було у Workshop 04

<v-clicks>

- **Plugin = тека з `.claude-plugin/plugin.json`** — мінімум `name`, інше опційне
- **`/plugin:skill`** — namespaced invocation
- **Локальний install:** `--plugin-dir ./path` (одна сесія), або через локальний marketplace: `/plugin marketplace add ./path` + `/plugin install <name>@<marketplace>`
- **Versioning** — semver vs commit-SHA згадували
- **Skills/** — теки з `SKILL.md`

</v-clicks>

<v-click class="mt-4 p-3 bg-amber-500/10 rounded text-sm">

**Що НЕ було:** як зібрати плагін з кількох компонентів, як написати `marketplace.json`, як hook у плагіні, як публікувати у git/marketplace, які поля у маніфесті крім `name`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/plugins" label="code.claude.com — Plugins overview" />

<!--
Workshop 04 показав мінімальну скриню. Тут ми її розкриваємо до кінця і додаємо marketplace flow.
-->

---

# Standalone vs Plugin: коли що

| Підхід | Skill name | Коли |
|---|---|---|
| **Standalone** (`.claude/skills/`) | `/hello` | Один проєкт, особисте, прототип |
| **Plugin** (з `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Команда, спільнота, версіонування, marketplace |

<v-clicks>

**Plugin** — коли:
- Шеришся з командою або ширше
- Той самий набір — у кількох проєктах
- Версіонування і простий update flow
- Дистриб'юється через marketplace
- Згоден на namespaced імена (`/my-plugin:hello`)

**Standalone** — коли проєктно-специфічне, експеримент, не потрібен share.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins#when-to-use-plugins-vs-standalone-configuration" label="code.claude.com — Plugins vs standalone" />

<!--
Класичний шлях: спочатку standalone у .claude/, доросло — конвертуєш у плагін. Anthropic так і радить.
-->

---

# Mental model: контейнер для всього

```
my-plugin/                       ← плагін = контейнер
├── .claude-plugin/plugin.json   ← маніфест (метадата)
├── skills/                      ← skill-и (директорії з SKILL.md)
├── commands/                    ← плоскі .md (legacy alias)
├── agents/                      ← subagent-и
├── hooks/hooks.json             ← реакції на події Claude Code
├── .mcp.json                    ← MCP-сервери
├── .lsp.json                    ← LSP-сервери
├── monitors/monitors.json       ← background-моніторінг
├── bin/                         ← виконувані файли у $PATH сесії
├── settings.json                ← дефолтні налаштування
└── scripts/                     ← скрипти, що використовуються hook-ами/MCP
```

<v-click>

**Плагін — це не тільки skill-и.** Bundle-иш будь-яку комбінацію компонентів. Сьогодні зробимо: skill + command + hook + agent.

</v-click>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#standard-plugin-layout" label="code.claude.com — Standard plugin layout" />

<!--
Бачиш — це повний buffet. У workshop 04 ми взяли тільки `skills/`. Сьогодні додаємо все інше.
-->

---
layout: section
---

# Маніфест

`plugin.json` — повний reference

---

# `plugin.json` — мінімум

```json
{
  "name": "git-toolkit"
}
```

<v-clicks>

- **Маніфест опційний.** Якщо `.claude-plugin/plugin.json` нема — Claude Code бере ім'я з теки і авто-знаходить компоненти у дефолтних локаціях
- **Якщо маніфест є — `name` єдине обов'язкове поле**
- **`name`** — kebab-case, без пробілів. Стає префіксом інвокації: `/git-toolkit:status-summary`
- **Наслідок:** перейменуєш `name` — зламаєш існуючим юзерам shortcut-и

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#required-fields" label="code.claude.com — Manifest required fields" />

<!--
Опційний маніфест — корисна деталь. Для quick-and-dirty можна обійтись без plugin.json взагалі. Але для marketplace він потрібен.
-->

---

# `plugin.json` — реалістичний

```json
{
  "name": "git-toolkit",
  "version": "0.1.0",
  "description": "Git workflow plugin: status summary, bisect helper, commit logging",
  "author": {
    "name": "Vadym Bondarenko",
    "email": "vadym.bondarenko@vcdev.me"
  },
  "homepage": "https://github.com/vcdev-me/git-toolkit",
  "repository": "https://github.com/vcdev-me/git-toolkit",
  "license": "MIT",
  "keywords": ["git", "workflow", "logging"]
}
```

<v-clicks>

- **`version`** — пояснимо за 5 слайдів. TL;DR: `MAJOR.MINOR.PATCH` або взагалі без поля
- **`description`** — рядок у `/plugin` UI, marketplace-каталозі
- **`author`** — `{ name, email?, url? }` — для атрибуції
- **`homepage` / `repository`** — посилання у UI
- **`keywords`** — для пошуку у marketplace

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#metadata-fields" label="code.claude.com — Metadata fields" />

<!--
Це якраз manifest, який ми будемо писати у вправі 1.
-->

---

# Component-path поля

```json
{
  "name": "git-toolkit",
  "skills": ["./skills/", "./extras/"],
  "commands": "./custom/commands/",
  "agents": "./agents/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json",
  "lspServers": "./.lsp.json"
}
```

<v-clicks>

- **Опційні** — без них Claude Code сканує дефолтні локації (`skills/`, `commands/`, `agents/`, `hooks/hooks.json`, `.mcp.json`, …)
- **Кастомний шлях ЗАМІНЯЄ дефолт** — `"skills": "./extras/"` → стандартний `skills/` НЕ скануватиметься
- **Щоб залишити default + додати** → масив: `"skills": ["./skills/", "./extras/"]`
- **Усі шляхи відносні до root плагіна, мусять починатися з `./`**

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#path-behavior-rules" label="code.claude.com — Path behavior rules" />

<!--
Найпоширеніший факап: `"skills": "./extras/"` — і people дивуються, чому `skills/` не вантажиться. Заміняє, не додає.
-->

---

# Поля для просунутих

<v-clicks>

```json
{
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "Token for fetching commit metadata",
      "sensitive": true
    }
  },
  "dependencies": [
    "helper-lib",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

- **`userConfig`** — Claude Code запитає юзера при enable. Доступне як `${user_config.api_token}` у hook/MCP/LSP конфігах. `sensitive: true` → у keychain, не у `settings.json`
- **`dependencies`** — інші плагіни, від яких залежить твій. Semver constraints як у npm
- **`channels`** — для message-injection (Telegram/Slack/Discord) — рідкісне
- **`themes`, `outputStyles`, `monitors`** — окремі компоненти

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#user-configuration" label="code.claude.com — userConfig" />

<!--
Сьогодні ми ці поля не чіпаємо. Знаєш що існують — глянеш у docs коли треба буде. У dependencies колись потоне ціла окрема тема.
-->

---
layout: section
---

# Layout

`.claude-plugin/` vs plugin root — найчастіша пастка

---

# Правило #1: тільки `plugin.json` у `.claude-plugin/`

```
git-toolkit/
├── .claude-plugin/
│   └── plugin.json          ← ✅ ТІЛЬКИ маніфест тут
├── skills/                  ← ✅ компоненти на root level
├── commands/                ← ✅
├── agents/                  ← ✅
└── hooks/                   ← ✅
```

<v-clicks>

```
git-toolkit/
└── .claude-plugin/
    ├── plugin.json
    ├── skills/              ← ❌ Claude Code НЕ побачить
    ├── commands/            ← ❌
    └── hooks/               ← ❌
```

**Симптом:** `claude --debug` показує plugin loaded, але skill-ів/команд нема в `/`-меню.

**Фікс:** перенеси усе на root плагіна. Лиши `.claude-plugin/` тільки з `plugin.json`.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins#plugin-structure-overview" label="code.claude.com — Common mistake (warning)" />

<!--
Це найпоширеніший факап у власних плагінах. Бачив його у трьох з п'ятьох ревью на public marketplace. Якщо щось одне забереш зі слайду — забери це.
-->

---

# Дефолтні локації компонентів

| Компонент | Default | Альтернативи у `plugin.json` |
|---|---|---|
| Manifest | `.claude-plugin/plugin.json` | (немає — фіксована) |
| Skills | `skills/` | `"skills": "./..."` |
| Commands | `commands/` | `"commands": "./..."` |
| Agents | `agents/` | `"agents": "./..."` |
| Hooks | `hooks/hooks.json` | `"hooks": "./..."` |
| MCP servers | `.mcp.json` | `"mcpServers": "./..."` |
| LSP servers | `.lsp.json` | `"lspServers": "./..."` |
| Monitors | `monitors/monitors.json` | `"monitors": "./..."` |
| Output styles | `output-styles/` | `"outputStyles": "./..."` |
| Themes | `themes/` | `"themes": "./..."` |
| Executables | `bin/` | (фіксована — додається у `$PATH`) |
| Settings | `settings.json` | (фіксована) |

<DocRef url="https://code.claude.com/docs/en/plugins-reference#file-locations-reference" label="code.claude.com — File locations reference" />

<!--
Цю таблицю варто роздрукувати і покласти на стіл. Усе інше можна виводити з неї.
-->

---

# `commands/` vs `skills/` — обидва дають `/<name>:<x>`

<v-clicks>

```
my-plugin/
├── skills/
│   └── status-summary/
│       ├── SKILL.md         ← директорія з SKILL.md + опційні файли
│       └── scripts/
└── commands/
    └── log-stats.md          ← плоский .md
```

- **Обидва тригерять однаково:** `/my-plugin:status-summary` і `/my-plugin:log-stats`
- **`skills/`** — нова форма. Підтримує supporting files (`scripts/`, `references/`, `assets/`)
- **`commands/`** — legacy. Тільки плоский markdown. Лишилось для зворотньої сумісності
- **Для нових плагінів:** `skills/`. `commands/` — коли мігруєш старе

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#skills" label="code.claude.com — Skills vs commands" />

<!--
У workshop 04 ми вже бачили, що команди злиті зі skill-ами. У плагіні це означає: дві теки, один namespace, обираєш формат.
-->

---
layout: section
---

# Hands-on: вправа 1

Ініціалізуємо плагін з нуля

---

# Вправа 1 — структура з нуля

**Мета:** робочий каркас плагіна `git-toolkit` з валідним `plugin.json`

```bash
cd workshops/06-plugins/exercises/01-init-plugin
cat README.md
```

<v-clicks>

**Кроки:**
1. `mkdir -p git-toolkit/.claude-plugin`
2. Створи `git-toolkit/.claude-plugin/plugin.json` (мінімум: `name`, `version`, `description`, `author`)
3. Створи теки `skills/`, `commands/`, `agents/`, `hooks/` на root рівні (нехай порожні поки)
4. Завантаж локально: `claude --plugin-dir ./git-toolkit`
5. У сесії: `/plugin` → перевір що `git-toolkit` у списку
6. Запусти `claude plugin validate ./git-toolkit` — має пройти

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 10 хв. `solutions/01-init-plugin/` — готове.

</v-click>

<!--
Найпростіша вправа. Лиш каркас. Якщо validate червоніє — швидше за все JSON-синтаксис: trailing comma або unquoted ключ.
-->

---

# Live: створюємо `plugin.json`

```json {all|2|3|4|5-8|9-10|11}{lines:true}
{
  "name": "git-toolkit",
  "version": "0.1.0",
  "description": "Git workflow plugin: status, bisect, commit log",
  "author": {
    "name": "Vadym Bondarenko",
    "email": "vadym.bondarenko@vcdev.me"
  },
  "homepage": "https://github.com/vcdev-me/git-toolkit",
  "repository": "https://github.com/vcdev-me/git-toolkit",
  "license": "MIT"
}
```

<v-clicks>

- **`name`** — kebab-case. Стає префіксом `/git-toolkit:...`
- **`version: "0.1.0"`** — explicit semver. Будемо bump-ати при змінах
- **`description`** — рядок у `/plugin` UI
- **`author`** — атрибуція
- **`homepage`/`repository`** — для marketplace UI

</v-clicks>

<!--
Коментар: якщо version поставив "0.1.0" — пам'ятай що bump потрібен на кожен release. Альтернатива — взагалі прибрати поле, тоді commit SHA = version.
-->

---
layout: section
---

# Multi-component bundling

skill + command + hook + agent — у одному плагіні

---

# Skill у плагіні

```
git-toolkit/
└── skills/
    └── status-summary/
        ├── SKILL.md
        └── references/
            └── git-cheatsheet.md
```

```yaml
---
description: Use when user asks for current git working tree state,
  what's staged, modified, or untracked. Show grouped summary.
allowed-tools: [Bash]
---

Run `git status --short --branch` and present grouped by section.
For detailed flag reference, see [git-cheatsheet.md](references/git-cheatsheet.md).
```

<v-clicks>

- **Структура — як у standalone skill** (workshop 04). Все що працювало там — працює і у плагіні
- **`description`** — auto-trigger. Plugin namespace не впливає на матчинг
- **Інвокація:** `/git-toolkit:status-summary`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins#add-skills-to-your-plugin" label="code.claude.com — Skills in plugin" />

<!--
Skill як skill, тільки під префіксом. Workshop 04 — full skill deep-dive. Тут не повторюємось.
-->

---

# Command (легка форма)

```
git-toolkit/
└── commands/
    └── log-stats.md
```

```markdown
---
description: Show commit count by author for the last 30 days
allowed-tools: [Bash]
---

Run `git shortlog -sn --since="30 days ago"` and format as a table.
```

<v-clicks>

- **Плоский `.md` файл** — для простих, одношагових запитів без supporting files
- **Та ж YAML-frontmatter, що у `SKILL.md`** — `description`, `allowed-tools`, `argument-hint`, `arguments`, etc.
- **Інвокація:** `/git-toolkit:log-stats`
- **Коли command vs skill:** command — для дій-коротунів (один tool call). Skill — коли є scripts/, references/, decision-tree

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#skills" label="code.claude.com — Commands as flat markdown" />

<!--
Я використовую command для shortcut-ів типу /log-stats або /branch-cleanup. Skill — коли треба багатокроковість і файли поруч.
-->

---

# Agent у плагіні

```
git-toolkit/
└── agents/
    └── commit-message-reviewer.md
```

```yaml {all|2-3|4-5|6}{lines:true}
---
name: commit-message-reviewer
description: Reviews staged commit messages for clarity, length, and convention
tools: Bash, Read, Grep
model: sonnet
effort: low
---

You are a commit-message reviewer. Read the staged message via
`git log -1 --format=%B HEAD` and check: length ≤72 chars subject,
imperative mood, no WIP/junk markers.
```

<v-clicks>

- **`tools`** — whitelist. `disallowedTools` — blacklist
- **`model`, `effort`, `maxTurns`, `skills`, `memory`, `background`, `isolation`** — підтримуються
- **`isolation: "worktree"`** — єдине валідне значення (запуск у git worktree)
- **❌ Заборонено для plugin agents:** `hooks`, `mcpServers`, `permissionMode` — security

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#agents" label="code.claude.com — Agent frontmatter" />

<!--
Agents — окремий контекст, окремі tools. Як subagent у workshop 10. Тут — packaging-aspect: де лежить, який frontmatter, що заборонено.
-->

---

# Hook у плагіні

```
git-toolkit/
├── hooks/
│   └── hooks.json
└── scripts/
    └── log-edit.sh
```

```json {all|3|4-5|6-12}{lines:true}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-edit.sh"
          }
        ]
      }
    ]
  }
}
```

<v-clicks>

- **Той самий формат, що у `~/.claude/settings.json`** під ключем `hooks`
- **`matcher`** — regex по tool-name (`Write|Edit|Bash`)
- **Тип `command`** — найчастіший. Інші: `http`, `mcp_tool`, `prompt`, `agent`
- **`${CLAUDE_PLUGIN_ROOT}`** — критично! Без нього шляхи у cache-копії плагіна не резолвляться

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#hooks" label="code.claude.com — Plugin hooks" />

<!--
Hook — це contract між Claude Code і твоїм скриптом. JSON структури hook input йде на stdin. У вправі 3 робимо такий PostToolUse-логер.
-->

---

# Hook events: повна таблиця

<div class="text-xs">

| Event | Коли |
|---|---|
| `SessionStart` | Початок або resume сесії |
| `UserPromptSubmit` | Юзер засабмітив промпт |
| `PreToolUse` | Перед tool call (можна заблокувати) |
| `PostToolUse` | Після успішного tool call |
| `PostToolUseFailure` | Після failed tool call |
| `PostToolBatch` | Після batch паралельних tool calls |
| `Stop` / `StopFailure` | Claude закінчив відповідь / зафейлив |
| `SubagentStart` / `SubagentStop` | Spawn / finish subagent-а |
| `PreCompact` / `PostCompact` | Перед / після auto-compaction |
| `FileChanged` | Відстежуваний файл змінився (matcher = filename) |
| `CwdChanged` | Робоча тека змінилась (Claude `cd` зробив) |
| `InstructionsLoaded` | CLAUDE.md / .claude/rules/*.md завантажились |
| `Notification` | Claude шле notification |
| `SessionEnd` | Сесія завершилась |

</div>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#hooks" label="code.claude.com — Hook events" />

<!--
~22 події всього у docs. Найчастіше юзаєш PostToolUse, SessionStart, Stop. Решта — для специфічних use-cases.
-->

---

# `${CLAUDE_PLUGIN_ROOT}` і `${CLAUDE_PLUGIN_DATA}`

<v-clicks>

- **`${CLAUDE_PLUGIN_ROOT}`** — абсолютний шлях до інстальованої копії плагіна. **Змінюється** при update. Файли, написані сюди, **не виживуть** оновлення
- **`${CLAUDE_PLUGIN_DATA}`** — персистентна тека за `~/.claude/plugins/data/{id}/`. **Виживає** оновлення. Туди — `node_modules`, кеші, згенерований код, стан між сесіями. Створюється при першому референсі
- **Експортуються як env vars** у hook-процеси, MCP-сервери, monitor-процеси
- **Substituted inline** у skill content, agent content, hook commands, monitor commands, MCP/LSP конфігах

</v-clicks>

<v-click class="mt-2 p-3 bg-blue-500/10 rounded text-sm">

**Pattern:** хочеш кешувати залежності між версіями плагіна → `${CLAUDE_PLUGIN_DATA}`. Хочеш викликати скрипт, що поставив у плагін → `${CLAUDE_PLUGIN_ROOT}`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#environment-variables" label="code.claude.com — Plugin env vars" />

<!--
Без ROOT твій hook буде шукати скрипт за абсолютним шляхом з твого dev-машини. Після install у юзера такого шляху нема — silently fail.
-->

---
layout: section
---

# Hands-on: вправи 2 і 3

Skill + command + agent → потім hook

---

# Вправа 2 — додаємо skill і command

**Мета:** мульти-компонентний плагін зі skill + command

```bash
cd ../02-multi-component
cat README.md
```

<v-clicks>

**Кроки:**

1. У `git-toolkit/skills/` створи `status-summary/SKILL.md` з frontmatter
2. У `git-toolkit/commands/` створи `log-stats.md` (плоский, для shortlog)
3. У `git-toolkit/agents/` створи `commit-message-reviewer.md` зі `tools: Bash, Read, Grep`
4. Перезавантаж: `claude --plugin-dir ./git-toolkit`
5. Перевір у `/`-меню:
   - `/git-toolkit:status-summary` ✅
   - `/git-toolkit:log-stats` ✅
   - У `/agents`: `git-toolkit:commit-message-reviewer` ✅

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 12 хв.

</v-click>

<!--
Найбільший факап — забути, що це окремі директорії на root level. skills/, commands/, agents/ — три теки. Не одна.
-->

---

# Вправа 3 — додаємо PostToolUse-hook

**Мета:** hook, що логує кожний `Write|Edit` у файл

```bash
cd ../03-add-hook
ls
# starter/git-toolkit/
```

<v-clicks>

**Кроки:**

1. Створи `git-toolkit/hooks/hooks.json` з PostToolUse матчером `"Write|Edit"`
2. Створи `git-toolkit/scripts/log-edit.sh`:
   ```bash
   #!/usr/bin/env bash
   FILE=$(jq -r '.tool_input.file_path' <&0)
   echo "[$(date -Iseconds)] edited: $FILE" >> "${CLAUDE_PLUGIN_DATA}/edits.log"
   ```
3. `chmod +x git-toolkit/scripts/log-edit.sh`
4. Hook command у JSON: `"${CLAUDE_PLUGIN_ROOT}/scripts/log-edit.sh"`
5. Перезавантаж, відредагуй файл — перевір `${CLAUDE_PLUGIN_DATA}/edits.log`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#hook-troubleshooting" label="code.claude.com — Hook troubleshooting" />

<!--
15 хв. Найчастіша помилка: забули chmod +x. Друга — використали ROOT замість DATA для логу, який мусить виживати update.
-->

---

# Розбір: чому DATA, а не ROOT для логу

```bash
# log-edit.sh
echo "[$(date -Iseconds)] edited: $FILE" >> "${CLAUDE_PLUGIN_DATA}/edits.log"
#                                            ^^^^^^^^^^^^^^^^^^^^^
#                                            не ${CLAUDE_PLUGIN_ROOT}!
```

<v-clicks>

- **`${CLAUDE_PLUGIN_ROOT}`** — змінюється при update. Логи, записані туди, **зникнуть** при наступному `/plugin update`
- **`${CLAUDE_PLUGIN_DATA}`** — персистентна. Резолвиться у `~/.claude/plugins/data/git-toolkit-<marketplace>/`
- **Auto-create:** теки `${CLAUDE_PLUGIN_DATA}` спочатку нема. Створюється при першому substitution

**Правило:**
- Скрипти, бінарі, шаблони → `${CLAUDE_PLUGIN_ROOT}` (read-only зі сторони плагіна)
- Логи, кеші, `node_modules` → `${CLAUDE_PLUGIN_DATA}` (persistent state)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#persistent-data-directory" label="code.claude.com — Persistent data directory" />

<!--
Це з різниці між package code і user data. Як між /usr/share і ~/.local/state у Linux.
-->

---
layout: section
---

# Marketplace

Розповсюдження через `marketplace.json`

---

# Marketplace = каталог плагінів

```
my-plugins-repo/                     ← це окремий repo
├── .claude-plugin/
│   └── marketplace.json             ← каталог
└── plugins/
    └── git-toolkit/                 ← твій плагін як subdir
        ├── .claude-plugin/plugin.json
        ├── skills/
        ├── commands/
        ├── agents/
        └── hooks/
```

<v-clicks>

- **Marketplace = repo з `.claude-plugin/marketplace.json`** на root
- **`plugins`-array** — список плагінів і де їх взяти (`source`)
- **Плагіни можуть жити:** у тому ж repo (relative path), у GitHub-репо, у git-URL, у git-subdir, у npm
- **Юзер додає marketplace, ставить плагін окремо:**
  ```
  /plugin marketplace add owner/repo
  /plugin install git-toolkit@my-plugins
  ```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces" label="code.claude.com — Plugin marketplaces" />

<!--
Розрізняй: marketplace.json — каталог. plugin.json — окремий плагін. Marketplace може містити чужі плагіни (через github source) — як npm registry, де ти не власник пакетів.
-->

---

# `marketplace.json` — мінімум

```json
{
  "name": "vcdev-plugins",
  "owner": {
    "name": "Vadym Bondarenko",
    "email": "vadym.bondarenko@vcdev.me"
  },
  "plugins": [
    {
      "name": "git-toolkit",
      "source": "./plugins/git-toolkit",
      "description": "Git workflow plugin: status, bisect, commit log"
    }
  ]
}
```

<v-clicks>

- **`name`** — kebab-case. Юзер бачить: `/plugin install git-toolkit@vcdev-plugins`
- **`owner.name`** — обов'язково. `email` — опційно
- **`plugins[].name` + `plugins[].source`** — мінімум на entry
- ⚠️ **Reserved imена:** `claude-plugins-official`, `anthropic-plugins`, `agent-skills` тощо. Не намагайся imitate Anthropic

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#marketplace-schema" label="code.claude.com — Marketplace schema" />

<!--
Це найпростіший marketplace, який можна зробити. Один плагін, локальний source. Цього досить для тестування. Production — додаси опис, version, керуєш channel-ами.
-->

---

# Plugin source: 5 варіантів

| Source | Тип | Приклад |
|---|---|---|
| **Relative** | string | `"./plugins/git-toolkit"` |
| **GitHub** | object | `{ "source": "github", "repo": "vcdev-me/git-toolkit" }` |
| **Git URL** | object | `{ "source": "url", "url": "https://gitlab.com/x/y.git" }` |
| **Git subdir** | object | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin" }` |
| **npm** | object | `{ "source": "npm", "package": "@acme/plugin" }` |

<v-clicks>

- **Relative path** — плагін у тому ж repo. Лише при git-based marketplace add (clone усього repo)
- **GitHub** — пінити можна `ref` (branch/tag) або `sha` (40-char commit)
- **Git URL** — для GitLab/Bitbucket/self-hosted
- **Git subdir** — sparse clone монорепо. Чудово для великих компаній з одним plugins-monorepo
- **npm** — для команд, що вже мають npm-pipeline

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#plugin-sources" label="code.claude.com — Plugin sources" />

<!--
GitHub-source — найчастіший. Але git-subdir дає елегантний моноrepo. У робочих проєктах — `tools/claude-plugins/` у моноrepo, marketplace.json там же.
-->

---

# Marketplace source vs plugin source

<v-clicks>

**Marketplace source** — звідки взяти `marketplace.json`:
```bash
/plugin marketplace add vcdev-me/plugins-repo       # GitHub shorthand
/plugin marketplace add https://gitlab.com/x/y.git  # git URL
/plugin marketplace add ./local-repo                # local
/plugin marketplace add https://example.com/marketplace.json  # raw URL
```

**Plugin source** — звідки взяти **окремий плагін** з marketplace:
```json
"source": { "source": "github", "repo": "vcdev-me/git-toolkit" }
```

**Різниця:** marketplace.json — каталог. Окремі плагіни **можуть бути в інших repo**.

⚠️ **Marketplace through raw URL → relative-path plugin sources не працюють** (тільки JSON завантажиться, не репо). Use `github`/`url`/`git-subdir`/`npm`.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#plugin-sources" label="code.claude.com — Marketplace vs plugin sources" />

<!--
Це часта плутанина. Marketplace.json — це index. У нього свої координати. Кожен плагін у списку — свої координати. Не обов'язково один git-repo.
-->

---
layout: section
---

# Hands-on: вправа 4

Marketplace + install через namespace

---

# Вправа 4 — marketplace із локального path

**Мета:** робочий marketplace flow для свого плагіна

```bash
cd ../04-marketplace
ls
# starter/vcdev-marketplace/
```

<v-clicks>

**Кроки:**

1. Створи `vcdev-marketplace/.claude-plugin/marketplace.json`:
   - `name`, `owner.name`, `plugins: [{ name, source, description }]`
2. Перенеси `git-toolkit/` у `vcdev-marketplace/plugins/git-toolkit/`
3. Source у marketplace.json: `"./plugins/git-toolkit"`
4. У Claude Code: `/plugin marketplace add ./vcdev-marketplace`
5. `/plugin install git-toolkit@vcdev-marketplace`
6. Тригерни: `/git-toolkit:status-summary` — namespaced!
7. Bonus: `claude plugin validate ./vcdev-marketplace`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#walkthrough-create-a-local-marketplace" label="code.claude.com — Local marketplace walkthrough" />

<!--
15 хв. Це останній крок distribution-flow. Усе після цього — push у GitHub і змінити "./vcdev-marketplace" на "vcdev-me/plugins-repo".
-->

---

# Live: marketplace.json крок-за-кроком

```json {all|2|3-6|7-12}{lines:true}
{
  "name": "vcdev-plugins",
  "owner": {
    "name": "Vadym Bondarenko",
    "email": "vadym.bondarenko@vcdev.me"
  },
  "plugins": [
    {
      "name": "git-toolkit",
      "source": "./plugins/git-toolkit",
      "description": "Git workflow plugin: status, bisect, commit log",
      "version": "0.1.0",
      "category": "git",
      "tags": ["git", "workflow"]
    }
  ]
}
```

<v-clicks>

- **`metadata.pluginRoot`** (опційно) — `"./plugins"` дозволив би писати `"source": "git-toolkit"` без префіксу
- **`category` / `tags`** — для пошуку у `/plugin` UI
- **`version` дублює `plugin.json`** ⚠️ — не роби так. На наступному слайді чому

</v-clicks>

<!--
Спойлер для наступного слайда: version в обох місцях — silently bug. Plugin.json виграє, marketplace.json може бути stale.
-->

---
layout: section
---

# Versioning

Стратегія, яку треба обрати свідомо

---

# Як Claude Code резолвить версію

Перше, що знайшлося:

<v-clicks>

1. **`version`** у `plugin.json`
2. **`version`** у marketplace entry
3. **Git commit SHA** (для `github`/`url`/`git-subdir` і relative paths у git-hosted marketplace)
4. **`unknown`** (для npm sources або local dirs не в git)

</v-clicks>

<v-click class="mt-2 p-3 bg-amber-500/10 rounded text-sm">

**Кешування:** Claude Code порівнює resolved version з закешованою. Збігається → `/plugin update` пропускає. Не збігається → оновлює.

</v-click>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#version-management" label="code.claude.com — Version management" />

<!--
Це cache-key. Якщо версія не змінилась — нічого не оновлюється. Це не баг, це спеціально для optimization.
-->

---

# Дві стратегії

| Стратегія | Як | Update behavior | Для |
|---|---|---|---|
| **Explicit semver** | `"version": "2.1.0"` у `plugin.json` | Юзери оновлюються лише при bump-і поля | Публічні плагіни, стабільні release-cycles |
| **Commit-SHA** | Опустити `version` всюди | Кожен новий commit → нова версія, юзери оновлюються авто | Internal, team-плагіни, активна розробка |

<v-clicks>

**Explicit semver:**
- Контроль над release-cycle
- Юзери не отримують нічого, поки ти готовий
- ⚠️ **Не забудь bump-нути.** Push без bump = nothing happens у юзерів

**Commit-SHA:**
- Zero-overhead. Push → юзер отримав
- Підходить для активного розвитку
- ⚠️ Кожен fix-up commit → юзер оновився. Не комітуй work-in-progress

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#version-management" label="code.claude.com — Two versioning strategies" />

<!--
Я для personal-плагінів — commit-SHA. Для public — explicit semver, бо мусиш могти зафіксувати breaking changes.
-->

---

# Pitfall: version у двох місцях

```json
// plugin.json
{ "name": "git-toolkit", "version": "0.1.0" }
```

```json
// marketplace.json
{
  "plugins": [
    { "name": "git-toolkit", "source": "...", "version": "0.2.0" }
  ]
}
```

<v-clicks>

**Що станеться:** `plugin.json` тихо виграє. Юзери побачать `0.1.0`, не `0.2.0`.

**Симптом:** ти бамп-нув у marketplace.json, юзери не оновлюються.

**Фікс:** обери ОДНЕ місце. Зазвичай `plugin.json`. У marketplace entry лиши `name` + `source` без `version`.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#version-resolution-and-release-channels" label="code.claude.com — Version pitfall" />

<!--
Це silent bug. Validate не warn-ує. Лиш юзер скаже: «у мене не оновилось». Я раз вліз так — поки спіймав.
-->

---

# Release channels (advanced)

```json
// stable-marketplace.json
{
  "plugins": [{
    "name": "git-toolkit",
    "source": { "source": "github", "repo": "vcdev-me/git-toolkit", "ref": "stable" }
  }]
}
```

```json
// latest-marketplace.json
{
  "plugins": [{
    "name": "git-toolkit",
    "source": { "source": "github", "repo": "vcdev-me/git-toolkit", "ref": "latest" }
  }]
}
```

<v-clicks>

- **Два marketplaces** на той самий repo, різні `ref`
- **Призначаєш різним групам** через managed settings
- **⚠️ Кожен channel мусить резолвитись у різну версію** — або різні explicit `version`, або різні SHA. Збіг → Claude Code вважає identical і пропускає

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#set-up-release-channels" label="code.claude.com — Release channels" />

<!--
Beta-канал — стандарт для будь-якого SaaS. Тут — просто два marketplaces. Дешево.
-->

---
layout: section
---

# Distribution на практиці

Локально → GitHub → marketplace add

---

# Path-чарт: від локального до публічного

```mermaid {scale: 0.7}
graph LR
  A[mkdir git-toolkit] --> B[plugin.json]
  B --> C[claude --plugin-dir ./git-toolkit<br/>локальний test]
  C --> D[git init + push до GitHub]
  D --> E[mkdir vcdev-marketplace<br/>marketplace.json]
  E --> F[/plugin marketplace add ./...<br/>локальний test]
  F --> G[git push marketplace до GitHub]
  G --> H[/plugin marketplace add vcdev-me/marketplace-repo<br/>публічно]
```

<v-clicks>

**Кожен крок — окремий комміт.** Локальний test → push → marketplace test → publish. Між кожним — `claude plugin validate`.

</v-clicks>

<!--
Mermaid тут малює реальний шлях. Я роблю так саме.
-->

---

# Installation scopes

| Scope | Settings file | Use case |
|---|---|---|
| `user` | `~/.claude/settings.json` | Особисті плагіни, всі проєкти (default) |
| `project` | `.claude/settings.json` | Команді через git |
| `local` | `.claude/settings.local.json` | Локально, gitignored |
| `managed` | Managed settings | Org-адміни, read-only |

```bash
claude plugin install git-toolkit@vcdev-plugins --scope project
```

<v-clicks>

- **`--scope project`** — додає у `.claude/settings.json` → у git → команда автоматично
- **`--scope local`** — личне у проєкті (gitignored), не передається команді
- **Cache:** усі плагіни лежать у `~/.claude/plugins/cache/` незалежно від scope

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#plugin-installation-scopes" label="code.claude.com — Installation scopes" />

<!--
Project-scope = договір команди. Один скоммітив `.claude/settings.json` — усім стане доступно при clone-і.
-->

---
layout: section
---

# Pitfalls

10 граблів з production досвіду

---

# Топ-5 граблів (1/2)

<v-clicks>

**1. Компоненти всередині `.claude-plugin/`**
Move usе на root. Тільки `plugin.json` у `.claude-plugin/`.

**2. Set `version` і не bump-нути**
Юзери побачать update лише при зміні рядка. Bump or omit.

**3. Version у двох місцях** (`plugin.json` + marketplace entry)
`plugin.json` silently виграє. Лиши одне місце.

**4. Hard-coded paths замість `${CLAUDE_PLUGIN_ROOT}`**
Cache-копія плагіна має інший абсолютний шлях. Без ROOT — silent fail.

**5. Path-traversal `../shared-utils`**
Файли поза плагіном НЕ копіюються в cache. Use symlinks (preserved) або restructure.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#directory-structure-mistakes" label="code.claude.com — Directory mistakes" />
<DocRef url="https://code.claude.com/docs/en/plugins-reference#path-traversal-limitations" label="code.claude.com — Path traversal" :offset="1" />

<!--
Це з реальних PR-ревью. Кожен з цих факапів я бачив у public плагінах.
-->

---

# Топ-5 граблів (2/2)

<v-clicks>

**6. Hook script не executable**
`chmod +x scripts/your-hook.sh` + shebang `#!/usr/bin/env bash`.

**7. Marketplace через raw URL + relative-path plugin sources**
Тільки JSON завантажиться, не репо. Use `github`/`url`/`git-subdir`/`npm`.

**8. Plugin agent з `hooks`/`mcpServers`/`permissionMode`**
Заборонено security-wise. Silently ignored.

**9. Marketplace `name` колізія з reserved**
`claude-plugins-official`, `anthropic-plugins` etc. — заблоковані. Перейменуй.

**10. Plugin не з'являється** — спершу `claude plugin validate .`
Покаже помилки у JSON, frontmatter, hooks.json. `claude --debug` — для loading-issues.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#troubleshooting" label="code.claude.com — Marketplace troubleshooting" />

<!--
10-й — найважливіший. Validate перед debug. 90% проблем validate ловить за секунду.
-->

---

# Debug toolkit

```bash
claude plugin validate .                    # JSON + frontmatter + hooks.json
claude plugin list --json                   # що встановлено + версії
claude plugin list --json --available       # + доступне у marketplaces
claude --debug                              # детальний loading log
```

<v-clicks>

**В сесії:**
```text
/plugin                # UI menu: enable/disable, errors tab
/plugin validate .     # те саме що CLI
/reload-plugins        # після зміни компонентів — без restart
```

**Що шукати в `/plugin` Errors tab:**
- "Executable not found in $PATH" → LSP language server не встановлений
- "Path contains '..'" → path-traversal у source
- "YAML frontmatter failed to parse" → SKILL.md / agent.md broken

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins-reference#debugging-and-development-tools" label="code.claude.com — Debugging tools" />

<!--
/reload-plugins — мій best friend під час розробки. Без нього restart-аєш Claude Code на кожен edit.
-->

---
layout: section
---

# Production-готовність

---

# Чек-ліст перед публікацією

<v-clicks>

- [ ] **`name`** — kebab-case, унікальний у твоєму неймспейсі, не reserved
- [ ] **`description`** і **`author`** заповнені (UI без них убогий)
- [ ] **`license`** — SPDX (MIT, Apache-2.0, etc.)
- [ ] **Стратегія version обрана** — explicit semver АБО omit (не обидва, не дубльовано)
- [ ] **`.claude-plugin/` містить ТІЛЬКИ `plugin.json`**
- [ ] **`${CLAUDE_PLUGIN_ROOT}`** у всіх hook commands і MCP/LSP configs
- [ ] **`${CLAUDE_PLUGIN_DATA}`** для логів/кешів/state, не ROOT
- [ ] **`chmod +x`** + shebang на всіх hook scripts
- [ ] **Жодного `..` у paths** (path-traversal break-ається після install)
- [ ] **`README.md`** — install instructions, що робить, які scopes
- [ ] **`claude plugin validate .`** проходить без помилок
- [ ] **Тестовано через marketplace flow** — не лише `--plugin-dir`

</v-clicks>

<!--
12 пунктів. Якщо хоч один не виконано — не публікуй у public marketplace. Особисте — інша справа.
-->

---

# Distribution: 3 шляхи

| Спосіб | Команда | Кому |
|---|---|---|
| **Локальний dev** | `claude --plugin-dir ./git-toolkit` | Тобі (одна сесія) |
| **Локальний marketplace** | `/plugin marketplace add ./vcdev-marketplace` | Тестування distribution |
| **GitHub marketplace** | `/plugin marketplace add vcdev-me/plugins` | Усім бажаючим |

<v-clicks>

**Бонус — `extraKnownMarketplaces` у `.claude/settings.json`:**
```json
{
  "extraKnownMarketplaces": {
    "vcdev-plugins": {
      "source": { "source": "github", "repo": "vcdev-me/plugins" }
    }
  },
  "enabledPlugins": {
    "git-toolkit@vcdev-plugins": true
  }
}
```
→ команда clone-нула репо проєкту → marketplace додано автоматом, плагін enabled.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugin-marketplaces#require-marketplaces-for-your-team" label="code.claude.com — Team marketplaces" />

<!--
extraKnownMarketplaces — найкорисніша річ для команд. Один файл у repo проєкту, усі підхоплюють.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)
- [code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [code.claude.com/docs/en/plugins-reference](https://code.claude.com/docs/en/plugins-reference)

</div>

<div>

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — готові розв'язки
- `handout.pdf` — повний референс
- Наступне: 07-mcp-servers

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Дякую! Наступний воркшоп — MCP-сервери у плагінах. Schedule зараз.
-->
