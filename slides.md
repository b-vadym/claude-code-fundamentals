---
theme: seriph
background: https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1920
title: Claude Code для розробників
info: |
  ## Claude Code для розробників
  Повний гайд по AI-асистенту в терміналі
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Claude Code

### Для розробників

<p class="text-lg opacity-80 mt-4">AI-асистент прямо у вашому терміналі</p>

<!--
Привіт! Сьогодні поговоримо про Claude Code — AI-асистент, який живе прямо у вашому терміналі і може кардинально змінити ваш робочий процес.
-->

---
transition: fade-out
---

# Про що поговоримо

<v-clicks>

- **Установка та перший запуск** — від нуля до працюючого асистента
- **Конфігурація** — CLAUDE.md, settings, memory
- **Режими роботи** — від обережного до автономного
- **MCP** — підключення до зовнішніх сервісів
- **Скіли** — вбудовані та кастомні слеш-команди
- **Плагіни** — розширення можливостей
- **IDE інтеграції** — VS Code, JetBrains
- **Hooks** — автоматизація робочого процесу
- **Субагенти** — делегування та паралелізм
- **RTK** — економія токенів на 60-90%
- **Просунуті можливості** — vision, browser, CI/CD

</v-clicks>

<!--
Ось наш план на наступні 30-45 хвилин. Пройдемо від базової установки до просунутих можливостей.
-->

---
layout: section
---

# Установка та перший запуск

---

# Способи установки

<v-clicks>

### Рекомендований спосіб (macOS / Linux / WSL)
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows PowerShell
```powershell
irm https://claude.ai/install.ps1 | iex
```

### Package Managers
```bash
brew install --cask claude-code    # Homebrew (macOS)
winget install Anthropic.ClaudeCode  # Windows
```

### npm (deprecated, але працює)
```bash
npm install -g @anthropic-ai/claude-code
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/setup" label="code.claude.com/docs/en/setup" />

<!--
Є кілька способів установки. Рекомендований — через curl скрипт, він автоматично оновлюється. npm варіант вже deprecated, але все ще працює.
-->

---

# Перший запуск

<v-clicks>

```bash
# Перевірка установки
claude --version

# Діагностика
claude doctor

# Авторизація
claude auth login

# Старт!
claude
```

```bash
# Або одразу з запитом
claude "поясни що робить цей файл"

# Print mode — для скриптів та SDK
claude -p "згенеруй SQL міграцію"

# Продовжити останню сесію
claude -c

# Назвати сесію
claude -n "refactoring-auth"
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/quickstart" label="code.claude.com/docs/en/quickstart" />

<!--
Після установки — перевіряємо, авторизуємось, і можна починати працювати. claude doctor покаже якщо щось не так з конфігурацією.
-->

---

# `powerup` — Швидкий старт для початківців

<v-click>

Інтерактивна команда, що допоможе налаштувати Claude Code за хвилину:

</v-click>

<v-click>

```bash
claude /powerup
```

</v-click>

<v-clicks>

- Крок за кроком проведе через базове налаштування
- Створить початковий `CLAUDE.md` для проєкту
- Налаштує основні параметри
- Ідеально для тих, хто тільки починає

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/quickstart" label="code.claude.com/docs/en/quickstart" />

<!--
powerup — це як wizard для налаштування. Особливо корисний для новачків — проведе через усі кроки і створить базову конфігурацію проєкту.
-->

---
layout: section
---

# Конфігурація

---

# CLAUDE.md — Мозок вашого проєкту

<v-clicks>

**Що це?** Файл з інструкціями, який Claude завантажує на початку кожної сесії.

**Навіщо?** Щоб Claude знав контекст вашого проєкту без повторних пояснень.

</v-clicks>

<v-click>

```markdown
# Правила проєкту
- Використовуємо TypeScript strict mode
- Тести пишемо з Vitest
- Коміти в стилі Conventional Commits
- API endpoints документуємо з JSDoc

# Архітектура
- Monorepo з Turborepo
- packages/api — NestJS backend
- packages/web — Next.js frontend
- packages/shared — спільні типи

# Команди
- `npm run test` — запуск тестів
- `npm run lint` — перевірка коду
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/memory" label="code.claude.com/docs/en/memory" />

<!--
CLAUDE.md — це як README, але для AI. Тут ви описуєте правила, архітектуру, команди — все, що Claude повинен знати про ваш проєкт.
-->

---

# Рівні конфігурації

```mermaid {scale: 0.55}
graph LR
    A[Enterprise<br/>Managed Policy] --> B[User Global<br/>~/.claude/CLAUDE.md]
    B --> C[Project Shared<br/>.claude/CLAUDE.md]
    C --> D[Project Local<br/>CLAUDE.local.md]
    D --> E[Rules<br/>.claude/rules/*.md]
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
    style D fill:#f39c12,color:#fff
    style E fill:#9b59b6,color:#fff
```

<v-clicks>

| Рівень | Файл | Для кого |
|--------|------|----------|
| Enterprise | Managed policy | Вся організація |
| User | `~/.claude/CLAUDE.md` | Особисті правила |
| Project | `.claude/CLAUDE.md` | Команда (в git) |
| Local | `CLAUDE.local.md` | Тільки ви (gitignored) |
| Rules | `.claude/rules/*.md` | По path-паттернах |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/memory" label="code.claude.com/docs/en/memory" />

<!--
Конфігурація має ієрархію — від глобальної enterprise до локальних правил. Project-рівень комітиться в git і шариться з командою.
-->

---

# Settings та Rules

<v-clicks>

### Settings файли
```bash
~/.claude/settings.json         # Глобальні налаштування
.claude/settings.json           # Проєктні (в git)
.claude/settings.local.json     # Локальні (gitignored)
```

### Rules — умовні правила по шляхах

```markdown
<!-- .claude/rules/frontend.md -->
---
paths: ["src/components/**", "src/pages/**"]
---
- Використовуй React functional components
- Стилі через Tailwind CSS
- Кожен компонент має мати тести
```

```markdown
<!-- .claude/rules/api.md -->
---
paths: ["src/api/**", "src/services/**"]
---
- Валідація через Zod schemas
- Обов'язково обробляй помилки
- Логування через winston
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/settings" label="code.claude.com/docs/en/settings" />

<!--
Rules — потужна фіча. Правила завантажуються тільки коли Claude працює з файлами, що підпадають під path-паттерн. Це економить контекст і дає точніші інструкції.
-->

---

# Memory — Автоматичне запам'ятовування

<v-clicks>

Claude автоматично зберігає важливі речі між сесіями:

```
~/.claude/projects/<project>/memory/
├── MEMORY.md           # Індекс (перші 200 рядків завантажуються)
├── user_role.md        # Хто ви і ваші преференції
├── feedback_testing.md # Як ви хочете тестувати
├── project_auth.md     # Контекст поточної роботи
└── reference_jira.md   # Де шукати інформацію
```

### Типи пам'яті:
- **user** — ваша роль, знання, преференції
- **feedback** — як ви хочете працювати (що робити / не робити)
- **project** — контекст поточних задач
- **reference** — посилання на зовнішні ресурси

### Управління:
```bash
claude /memory        # Переглянути та редагувати
"запам'ятай що..."    # Явно зберегти
"забудь про..."       # Видалити
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/memory" label="code.claude.com/docs/en/memory#auto-memory" />

<!--
Memory — це довгострокова пам'ять Claude між сесіями. Він запам'ятовує ваші преференції, контекст проєкту, і з кожною сесією стає все кориснішим.
-->

---
layout: section
---

# Режими роботи

---

# Permission Modes

<div class="grid grid-cols-2 gap-4">

<v-click>

### Default Mode
```
🔒 Запитує дозвіл на кожну дію
```
- Повний контроль
- Ідеально для початківців
- Найбезпечніший варіант

</v-click>

<v-click>

### Plan Mode
```
📋 Спочатку план, потім дія
```
- Claude створює план
- Ви переглядаєте та схвалюєте
- Для складних задач

</v-click>

<v-click>

### Auto-Accept Mode
```
⚡ Автоматично приймає зміни
```
- Швидкий робочий процес
- Поважає deny-правила
- Для досвідчених користувачів

</v-click>

<v-click>

### Bypass Mode
```
🚀 Пропускає всі промпти
```
- Тільки deny-правила працюють
- Для скриптів та CI/CD
- ⚠️ Обережно!

</v-click>

</div>

<v-click>

> **Перемикання:** `Shift+Tab` або `--permission-mode plan`

</v-click>

<DocRef url="https://code.claude.com/docs/en/permission-modes" label="code.claude.com/docs/en/permission-modes" />

<!--
Чотири режими — від повного контролю до повної автономії. Shift+Tab перемикає між ними прямо в сесії. Починайте з Default, переходьте на Auto коли будете впевнені.
-->

---
layout: section
---

# MCP — Model Context Protocol

---

# Що таке MCP?

<v-click>

Стандартизований протокол для підключення Claude до зовнішніх сервісів та інструментів.

</v-click>

<v-click>

```mermaid {scale: 0.7}
graph LR
    CC[Claude Code] --> MCP{MCP Protocol}
    MCP --> GH[GitHub]
    MCP --> LN[Linear]
    MCP --> NT[Notion]
    MCP --> PG[PostgreSQL]
    MCP --> FG[Figma]
    MCP --> SL[Slack]
    MCP --> ST[Sentry]
    MCP --> Custom[Your API]
    style CC fill:#8B5CF6,color:#fff
    style MCP fill:#F59E0B,color:#fff
```

</v-click>

<v-clicks>

### Типи транспорту:
- **stdio** — локальний процес (найпоширеніший)
- **HTTP/SSE** — віддалений сервер
- **Streamable HTTP** — нова версія протоколу

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
MCP — це як USB для AI. Стандартний інтерфейс для підключення будь-яких інструментів. Один раз налаштував — і Claude може працювати з GitHub, Jira, базами даних і чим завгодно.
-->

---

# Популярні MCP-сервери

<div class="grid grid-cols-2 gap-4 text-sm">

<v-clicks>

### Source Control
- **GitHub** — PR, issues, reviews
- **GitLab** — MR, pipelines

### Project Management
- **Linear** — tasks, issues, projects
- **Jira** — tickets, sprints
- **Notion** — docs, databases
- **Asana** — tasks, projects

### Databases
- **PostgreSQL** — queries, schema
- **MongoDB** — collections, documents
- **Supabase** — full stack

### DevOps & Monitoring
- **Sentry** — errors, performance
- **Vercel** — deployments
- **Firebase** — cloud functions

### Communication
- **Slack** — messages, channels
- **Discord** — bots, messages

### Design
- **Figma** — components, designs

</v-clicks>

</div>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
Екосистема MCP серверів постійно росте. Ось найпопулярніші. Ви також можете створити свій MCP сервер для внутрішнього API.
-->

---

# Конфігурація MCP

<v-click>

### `.mcp.json` в корені проєкту:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/mydb"
      }
    }
  }
}
```

</v-click>

<v-click>

### Управління:
```bash
claude /mcp                          # Переглянути сервери
claude /mcp add github -- npx -y @modelcontextprotocol/server-github
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
Конфігурація через .mcp.json — просто JSON з описом серверів. Змінні оточення можна підставляти. Команда /mcp допоможе додати сервер інтерактивно.
-->

---
layout: section
---

# Скіли та слеш-команди

---

# Вбудовані скіли

<v-clicks>

| Команда | Опис |
|---------|------|
| `/commit` | Створити git commit з осмисленим повідомленням |
| `/batch` | Масштабні зміни в кодовій базі паралельно |
| `/simplify` | Переглянути та оптимізувати недавні зміни |
| `/debug` | Увімкнути debug logging та діагностику |
| `/loop 5m "prompt"` | Повторювати команду з інтервалом |
| `/claude-api` | Завантажити довідку по Claude API |
| `/powerup` | Інтерактивне налаштування для початківців |
| `/memory` | Перегляд та редагування пам'яті |
| `/mcp` | Управління MCP серверами |
| `/hooks` | Перегляд та управління hooks |
| `/agents` | Створення та управління агентами |
| `/compact` | Стиснути контекст розмови |
| `/model` | Переключити модель |
| `/effort` | Рівень глибини міркування |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/commands" label="code.claude.com/docs/en/commands" />

<!--
Це вбудовані скіли — slash-команди які доступні в кожній сесії. /commit — мабуть найпопулярніший, а /batch — найпотужніший для масштабних рефакторингів.
-->

---

# Створення власних скілів

<v-click>

### Структура:

```
.claude/skills/deploy-check/
├── SKILL.md           # Головний файл з інструкціями
├── template.md        # Шаблон для Claude
├── examples/          # Приклади використання
└── scripts/           # Допоміжні скрипти
```

</v-click>

<v-click>

### SKILL.md:

```markdown
---
name: deploy-check
description: Перевірка готовності до деплою
allowed-tools: Bash Read Grep Glob
---

## Інструкції
1. Перевір що всі тести проходять: `npm test`
2. Перевір що немає TODO/FIXME в коді
3. Перевір що версія в package.json оновлена
4. Перевір що CHANGELOG.md оновлений
5. Виведи звіт у форматі:
   - ✅ / ❌ для кожного пункту
   - Загальний статус: READY / NOT READY
```

</v-click>

<v-click>

```bash
claude /deploy-check    # Використання
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com/docs/en/skills" />

<!--
Свої скіли — це просто markdown файли з інструкціями. Дуже потужний механізм для стандартизації процесів в команді. Один раз написав — вся команда використовує.
-->

---

# Приклад: скіл для код-рев'ю

```markdown
---
name: review
description: Детальний код-рев'ю поточних змін
context: fork
allowed-tools: Bash Read Grep Glob
---

## Інструкції для код-рев'ю

Проаналізуй зміни в `git diff` та перевір:

### Безпека
- SQL injection, XSS, command injection
- Хардкодовані секрети та credentials
- Небезпечні десеріалізації

### Якість
- Чи покриті зміни тестами?
- Чи немає дублювання коду?
- Чи зрозумілі назви змінних та функцій?

### Продуктивність
- N+1 запити до БД
- Відсутні індекси
- Великі об'єкти в пам'яті

Результат: список знайдених проблем з severity (critical/warning/info)
та рекомендаціями по виправленню.
```

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com/docs/en/skills" />

<!--
Ось практичний приклад — скіл для код-рев'ю. context: fork означає що він працює в ізольованому контексті і не забруднює основну розмову.
-->

---
layout: section
---

# Плагіни

---

# Плагін-система

<v-clicks>

Плагіни розширюють Claude Code **скілами, агентами, hooks, MCP серверами та LSP**.

### Установка:
```bash
/plugin install github@claude-plugins-official
/plugin marketplace list
/plugin marketplace add owner/repo
```

### Категорії:
- **Code Intelligence** — LSP для мов (Rust, Python, TS, Go, Java...)
- **Integrations** — MCP сервери (GitHub, Figma, Slack...)
- **Workflows** — спеціалізовані агенти
- **Output Styles** — формати відповідей

### Управління:
```bash
/plugin list                    # Список встановлених
/plugin disable plugin-name     # Вимкнути
/reload-plugins                 # Перезавантажити
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins" label="code.claude.com/docs/en/plugins" />

<!--
Плагіни — це пакети, що можуть містити скіли, агентів, hooks та MCP сервери. Маркетплейс постійно росте.
-->

---

# Code Intelligence (LSP)

<v-clicks>

Плагіни з Language Server Protocol дають Claude **глибше розуміння коду**:

### Можливості:
- Реальна діагностика після змін (не тільки syntax)
- Go to definition — навігація по коду
- Find references — де використовується
- Type information on hover
- Автодоповнення типів

### Підтримувані мови:
```
TypeScript  Python  Rust  Go  Java  C#
PHP  Ruby  Kotlin  Swift  C++  Zig
```

### Як це працює:
```mermaid {scale: 0.6}
graph LR
    CC[Claude Code] --> LSP[LSP Plugin]
    LSP --> TS[TypeScript Server]
    LSP --> PY[Pyright]
    LSP --> RS[rust-analyzer]
    CC --> |Edit файл| LSP
    LSP --> |Діагностика| CC
    style CC fill:#8B5CF6,color:#fff
    style LSP fill:#10B981,color:#fff
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/discover-plugins" label="code.claude.com/docs/en/discover-plugins" />

<!--
LSP плагіни — це game changer. Claude отримує реальну діагностику від language server, а не просто читає код. Це значно покращує якість рефакторингів.
-->

---
layout: section
---

# IDE інтеграції

---

# VS Code Extension

<div class="grid grid-cols-2 gap-8">

<div>

<v-clicks>

### Установка:
`Cmd+Shift+X` → "Claude Code"

### Можливості:
- Inline diff перегляд
- Вибір коду → контекст для Claude
- `@`-згадки файлів
- Історія розмов з пошуком
- Перемикання моделей
- Extended thinking toggle

</v-clicks>

</div>

<div>

<v-clicks>

### Шорткати:

| Дія | Mac | Win/Linux |
|-----|-----|-----------|
| @-mention | `Option+K` | `Alt+K` |
| Focus toggle | `Cmd+Esc` | `Ctrl+Esc` |
| New tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |

### Налаштування:
```json
{
  "claudeCode.initialPermissionMode": "plan",
  "claudeCode.autosave": true,
  "claudeCode.useTerminal": false
}
```

</v-clicks>

</div>

</div>

<DocRef url="https://code.claude.com/docs/en/vs-code" label="code.claude.com/docs/en/vs-code" />

<!--
VS Code extension — повна інтеграція. Inline diff, контекст з виділеного коду, @-mentions для файлів. Дуже зручно для review та навігації.
-->

---

# JetBrains Extension

<v-clicks>

### Підтримувані IDE:
IntelliJ IDEA • PyCharm • WebStorm • GoLand • PhpStorm • Android Studio

### Установка:
Settings → Plugins → Marketplace → "Claude Code"

### Можливості:
- Diff viewing прямо в IDE
- Контекст з виділеного коду
- Діагностика з IDE → Claude
- Remote Development підтримка

### Шорткати:

| Дія | Mac | Win/Linux |
|-----|-----|-----------|
| File reference | `Cmd+Option+K` | `Ctrl+Alt+K` |
| Focus Claude | `Esc` (в терміналі) | `Esc` |

### Порада:
Налаштуйте шлях до Claude binary в Settings → Tools → Claude Code

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/jetbrains" label="code.claude.com/docs/en/jetbrains" />

<!--
JetBrains extension трохи менш фічастий ніж VS Code, але основне працює. Diff viewing та шарінг контексту — must have.
-->

---
layout: section
---

# Hooks — Автоматизація

---

# Hook Events

<v-clicks>

Hooks виконуються на певних етапах життєвого циклу:

| Event | Коли | Приклад |
|-------|------|---------|
| `SessionStart` | Початок сесії | Завантажити .env |
| `PreToolUse` | Перед інструментом | Заблокувати файл |
| `PostToolUse` | Після інструменту | Автоформат |
| `Notification` | Потребує уваги | Desktop нотифікація |
| `ConfigChange` | Зміна конфігу | Перезавантажити |
| `CwdChanged` | Зміна директорії | Оновити контекст |

### Типи hooks:
- **command** — shell скрипт
- **http** — POST на webhook
- **prompt** — LLM оцінка
- **agent** — multi-turn верифікація

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com/docs/en/hooks" />

<!--
Hooks — це event-driven автоматизація. Можна виконувати дії на будь-якому етапі роботи Claude. PreToolUse може навіть заблокувати дію.
-->

---

# Приклади Hooks

### Автоформат після редагування:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs prettier --write"
      }]
    }]
  }
}
```

<v-click>

### Блокування захищених файлів:

```bash
#!/bin/bash
# .claude/hooks/protect-files.sh
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path')
if [[ "$FILE" =~ (.env|package-lock.json|pnpm-lock.yaml) ]]; then
  echo "Цей файл захищений від змін!" >&2
  exit 2  # Block action
fi
exit 0  # Allow action
```

</v-click>

<v-click>

### Desktop нотифікації:

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "permission_prompt",
      "hooks": [{
        "type": "command",
        "command": "notify-send 'Claude Code' 'Потрібен дозвіл'"
      }]
    }]
  }
}
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks-guide" label="code.claude.com/docs/en/hooks-guide" />

<!--
Три найпопулярніші приклади hooks. Автоформат зберігає код чистим, захист файлів запобігає випадковим змінам, нотифікації нагадують коли Claude чекає.
-->

---
layout: section
---

# Субагенти

---

# Що таке субагенти?

<v-clicks>

Спеціалізовані AI-асистенти з **ізольованим контекстом** для конкретних задач.

```mermaid {scale: 0.7}
graph TD
    Main[Claude Code<br/>Головна сесія] --> E[Explore Agent<br/>🔍 Дослідження коду]
    Main --> P[Plan Agent<br/>📋 Планування]
    Main --> B[Bash Agent<br/>⚙️ Виконання]
    Main --> C[Custom Agent<br/>🎯 Ваша задача]
    E --> |Результат| Main
    P --> |План| Main
    B --> |Вивід| Main
    C --> |Звіт| Main
    style Main fill:#8B5CF6,color:#fff
```

### Вбудовані типи:
- **Explore** — read-only дослідження коду
- **Plan** — планування реалізації
- **Bash** — виконання команд
- **general-purpose** — повні можливості

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/sub-agents" label="code.claude.com/docs/en/sub-agents" />

<!--
Субагенти працюють паралельно в окремих контекстних вікнах. Головна сесія делегує задачі і отримує результати. Дуже ефективно для складних задач.
-->

---

# Кастомні агенти

<v-click>

### `.claude/agents/code-reviewer/AGENT.md`:

```markdown
---
description: Reviews code for quality and security
model: claude-sonnet-4-6
allowed-tools: Read Grep Glob Bash
isolation: worktree
---

You are a code reviewer. Analyze changes and provide feedback on:
1. Security vulnerabilities (OWASP Top 10)
2. Performance issues
3. Code style and best practices
4. Test coverage gaps

Output format: structured report with severity levels.
```

</v-click>

<v-click>

### Паралельні сесії з worktrees:

```bash
# Кожна сесія працює в ізольованій копії репо
claude --worktree feature-auth
claude --worktree feature-payments
claude --worktree bugfix-login

# Файли для копіювання в worktree
echo ".env" > .worktreeinclude
echo ".env.local" >> .worktreeinclude
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/sub-agents" label="code.claude.com/docs/en/sub-agents" />

<!--
Кастомні агенти — AGENT.md файли з описом ролі та обмежень. Worktrees дозволяють запускати кілька Claude паралельно, кожен у своїй копії репозиторію.
-->

---
layout: section
---

# Просунуті можливості

---

# Extended Thinking та Git

<div class="grid grid-cols-2 gap-8">

<div>

<v-clicks>

### Extended Thinking
```bash
# Toggle в сесії
Option+T / Alt+T

# Рівень глибини
/effort low      # Швидко, просто
/effort medium   # Збалансовано
/effort high     # Глибоко
/effort max      # Максимум

# Адаптивне на Opus/Sonnet 4.6
# Автоматично обирає глибину
```

</v-clicks>

</div>

<div>

<v-clicks>

### Git інтеграція
```bash
# Комміт з осмисленим повідомленням
/commit

# Створити PR
/pr create

# Робота в ізольованій гілці
claude --worktree feat-1

# Прив'язка до PR
claude --from-pr 123
```

### Формат коміту:
```
feat: add user authentication

Implement JWT-based auth with refresh tokens.
Includes middleware, tests, and migration.

Co-Authored-By: Claude ...
```

</v-clicks>

</div>

</div>

<DocRef url="https://code.claude.com/docs/en/common-workflows" label="code.claude.com/docs/en/common-workflows" />

<!--
Extended thinking — Claude думає глибше перед відповіддю. На складних задачах — обов'язково. Git інтеграція — /commit і /pr це must-have для щоденної роботи.
-->

---

# Vision, Browser та CI/CD

<v-clicks>

### Vision — аналіз зображень
```bash
# Вставити скріншот
Ctrl+V / Cmd+V

# Claude бачить:
# - Скріншоти UI → знаходить баги
# - Дизайн-макети → пише код
# - Діаграми → розуміє архітектуру
# - Error screenshots → діагностує
```

### Chrome Browser
```bash
claude --chrome    # Увімкнути browser mode
# Тестує веб-додатки, заповнює форми,
# читає console.log, робить скріншоти
```

### CI/CD інтеграція
```yaml
# GitHub Actions
- uses: anthropics/claude-code-action@v1
  with:
    prompt: "Review this PR for security issues"

# GitLab CI
claude -p "run tests and report" --permission-mode bypass
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/chrome" label="chrome · github-actions" />

<!--
Vision дозволяє Claude бачити скріншоти та макети. Chrome mode — тестування веб-додатків. CI/CD — Claude як частина вашого pipeline.
-->

---
layout: section
---

# RTK — Rust Token Killer

---

# Що таке RTK?

<v-clicks>

**RTK** — CLI-проксі, що економить **60-90% токенів** на операціях розробки.

### Проблема:
Claude Code витрачає багато токенів на виводи команд (`git status`, `ls`, `npm test`...)

### Рішення:
RTK перехоплює команди і фільтрує непотрібний output.

```bash
# Без RTK: git status → 500+ токенів шуму
# З RTK:   git status → тільки важливе (50 токенів)
```

### Установка:
```bash
curl -fsSL https://rtk.sh/install | bash
# або
cargo install rtk-cli
```

</v-clicks>

<v-click>

> **GitHub:** https://github.com/rtk-ai/rtk

</v-click>

<!--
RTK — must have для будь-кого хто використовує Claude Code щодня. 60-90% економії токенів — це суттєво, особливо на великих проєктах.
-->

---

# RTK — Як це працює

<v-clicks>

### Hook-based — прозоро для користувача:
```bash
# Ви пишете як зазвичай:
git status
# Hook автоматично переписує на:
rtk git status
# Claude отримує стислий, оптимізований вивід
```

### Мета-команди RTK:
```bash
rtk gain              # Аналітика економії токенів
rtk gain --history    # Історія використання з savings
rtk discover          # Знайти команди де ще можна заощадити
rtk proxy <cmd>       # Виконати без фільтрації (debug)
```

### Приклад `rtk gain`:
```
╭──────────────────────────────────────────╮
│ Total tokens saved: 1,247,832            │
│ Sessions analyzed: 47                    │
│ Average savings: 78%                     │
│ Top saver: git diff (91% reduction)      │
╰──────────────────────────────────────────╯
```

</v-clicks>

<!--
RTK працює через hooks — повністю прозоро. Ви нічого не міняєте у workflow, а токени економляться автоматично. rtk gain показує скільки ви заощадили.
-->

---

# Шпаргалка

<div class="grid grid-cols-2 gap-8">
<div>

### Команди

```bash
claude              # Старт
claude -c            # Продовжити
claude -n "name"     # Назвати сесію
claude update        # Оновити
claude doctor        # Діагностика
```

```bash
/commit     /compact    /memory
/mcp        /hooks      /agents
/model      /effort     /debug
/batch      /powerup    /loop
```

</div>
<div>

### Шорткати

```bash
Ctrl+C       # Скасувати
Ctrl+R       # Пошук в історії
Ctrl+G       # Відкрити в редакторі
Ctrl+B       # Background task
```

```bash
Shift+Tab    # Режим permissions
Option+T     # Extended thinking
Option+P     # Модель
Esc Esc      # Rewind/summarize
```

</div>
</div>

<DocRef url="https://code.claude.com/docs/en/cli-reference" label="code.claude.com/docs/en/cli-reference" />

<!--
Ось найважливіші команди та шорткати. Рекомендую роздрукувати цю шпаргалку поки не запам'ятаєте.
-->

---
layout: center
class: text-center
---

# Дякую! Запитання?

<v-clicks>

### Корисні посилання:

📖 **Документація:** [code.claude.com](https://code.claude.com)

💻 **GitHub:** [github.com/anthropics/claude-code](https://github.com/anthropics/claude-code)

🚀 **RTK:** [github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk)

📦 **MCP Servers:** [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)

</v-clicks>

<div class="pt-8">
  <span class="text-sm opacity-50">Створено за допомогою Claude Code + Slidev</span>
</div>

<!--
Дякую за увагу! Готовий відповісти на будь-які питання. Посилання на екрані — там знайдете все необхідне для початку роботи.
-->
