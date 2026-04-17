---
theme: seriph
background: https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1920
title: "Claude Code: Fundamentals"
info: |
  ## Claude Code: Fundamentals
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

# Claude Code: Fundamentals

<!--
Привіт! Сьогодні поговоримо про Claude Code — AI-асистент, який живе прямо у вашому терміналі і може кардинально змінити ваш робочий процес.
-->

---
transition: fade-out
---

# Про що поговоримо

<v-clicks>

- **Чому Claude Code** — хто вже використовує і чому
- **Установка та перший запуск** — від нуля до працюючого асистента
- **Середовище розробника** — термінал, shell, нотифікації, dotfiles
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
Ось наш план на наступні 30-45 хвилин. Пройдемо від базової установки до просунутих можливостей. Але спочатку — чому саме Claude Code, а не Copilot чи Cursor.
-->

---
layout: section
---

# Чому Claude Code?

---
hideInToc: true
---

# Хто вже використовує

<v-clicks>

### Великі корпорації

- **Cognizant** — 350 000 співробітників отримали Claude
- **Accenture** — 30 000 навчених
- **NYSE** — переписали engineering-процес на Claude Code + Agent SDK
- **Epic** (MyChart) — >50% використання Claude Code припадає на не-розробників
- **Altana** — швидкість розробки **×2–10**
- **Behavox** (compliance) — сотні девелоперів, default pair-programmer

### Масштаб ринку

- **Fortune 100**: ~70% equipment rate, adoption серед розробників **41–68%**
- **1 000+ клієнтів** платять Anthropic **>$1M/рік**
- Claude Code: **$1B ARR** за 6 міс, **$2.5B ARR** на лютий 2026 (×2 з січня)

</v-clicks>

<DocRef url="https://www.anthropic.com/news/claude-code-on-team-and-enterprise" label="anthropic.com/news/claude-code-on-team-and-enterprise" />

<!--
Коли менеджмент питає "чому не Copilot", ось аргументи цифрами. Cognizant та Accenture розгорнули на сотнях тисяч. NYSE — не просто користувач, а будує на Claude Agent SDK внутрішні агенти. Epic показує, що Claude Code виходить за межі розробників. Altana документує конкретний приріст 2-10x. Behavox (compliance, security-sensitive) не побоялися. По ринку: Fortune 100 покривається на 70%, з розробників — 41-68% користуються. Понад тисяча enterprise-клієнтів з чеком понад мільйон. Claude Code досяг мільярда ARR за півроку, за лютий — два з половиною, подвоївся за місяць.
-->

---
hideInToc: true
---

# Навіть Microsoft і AWS вибирають Claude Code

<v-clicks>

### Microsoft (попри власний Copilot)

- Підрозділи **Windows, Microsoft 365, Outlook, Teams, Bing, Edge, Surface** отримали директиву встановити Claude Code
- Інженери **тестують обидва** — Copilot та Claude Code — і шлють пряме порівняння
- "Companies regularly test and trial competing products" — Microsoft spokesperson
- **Copilot Cowork** (Microsoft 365) — побудований **на Claude**, не на власних моделях

### AWS-shops перемикаються з Amazon Q

- Context window: **1M токенів** (Claude Opus 4.7/Sonnet 4.6) vs ~200K Amazon Q
- Claude Code розуміє весь репозиторій відразу → refactorings, що реально працюють
- Код якісніший, документація точніша — навіть для команд з Enterprise Support кредитами AWS

</v-clicks>

<DocRef url="https://leaddev.com/ai/why-microsoft-engineers-are-using-claude-code" label="leaddev.com — Why Microsoft engineers use Claude Code" />

<!--
Найсильніший аргумент для менеджменту. Microsoft — власник GitHub і Copilot, OpenAI-партнер — офіційно попросив інженерів Windows, Microsoft 365, Teams, Bing, Edge, Surface встановити Claude Code і надсилати feedback порівняння. Це не витік, це офіційна позиція — "ми тестуємо конкурентів". Copilot Cowork для Microsoft 365 побудували не на своєму Copilot, а на Claude. AWS — схожа історія: команди на Enterprise Support кредитах, яким Amazon Q коштував би нуль доларів, перемикаються на Claude Code через платні підписки. Причина — 1M контекст замість 200K, плюс якість рефакторингу на великих кодобазах. Коли два з трьох cloud giants самі йдуть на Claude — це сигнал.
-->

---
hideInToc: true
---

# GitHub: **4%** комітів — Claude Code

<div class="grid grid-cols-2 gap-6">

<v-clicks>

<div>

### Exponential growth (SemiAnalysis)

| Коли | Комітів/тиждень | % GitHub |
|---|---:|---:|
| Вересень 2025 | 180K | 0.7% |
| Грудень 2025 | 370K | ~1.5% |
| Лютий 2026 | 1M+ | ~3% |
| Березень 2026 | **2.6M** | **4.5%** |

**15 березня 2026** — **326 731** комітів за один день, усі з `Co-authored-by: Claude`. Рекорд.

</div>

<div>

### Прогноз

> До кінця 2026 року Claude Code забезпечить **20%+ усіх щоденних комітів** на GitHub.
>
> — SemiAnalysis, "Claude Code is the Inflection Point"

### Що це означає

- Не експеримент, а **стандарт індустрії**
- Кожен 5-й комміт у світі — з Claude
- Компанії, що не адаптуються, **програють у швидкості** (2-10× за даними Altana)

</div>

</v-clicks>

</div>

<DocRef url="https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point" label="semianalysis.com — Claude Code is the Inflection Point" />
<DocRef url="https://coremention.com/blog/claude-code-tracker/" label="coremention.com — Claude Code Tracker (таблиця + 326K/день)" :offset="1" />

<!--
Ключова цифра — 4%. Кожен 25-й публічний комміт на GitHub зараз пише Claude Code. Зростання не лінійне — з вересня 2025 до березня 2026 це ×14. Особливо різкий злам у грудні 2025, потім до лютого — ще ×2.5. 15 березня 2026 — історичний рекорд, 326 тисяч комітів за один день, усі з тегом Co-authored-by: Claude. Прогноз SemiAnalysis — 20% усіх щоденних комітів до кінця 2026. Це означає, що кожен п'ятий комміт у світі буде писатися Claude Code. Для бізнесу: це не "ще один інструмент", а зсув платформи. Команди без AI-assist вже зараз відстають у delivery на 2-10x. Altana — задокументовано.
-->

---
hideInToc: true
---

# Чому обирають саме його

<div class="grid grid-cols-2 gap-6">

<v-clicks>

<div>

### Технічна перевага

- **№1 у benchmarks** серед AI coding agents
- **Agentic, не autocomplete** — сам планує, редагує, запускає тести
- **Terminal-first** — працює там, де ваш dev loop
- **1M context window** (Opus 4.7 / Sonnet 4.6)
- **Adaptive reasoning** — модель сама вирішує коли думати глибше

</div>

<div>

### Enterprise-ready

- **SSO, audit logs, managed policy** (Teams / Enterprise)
- **Bedrock / Vertex / Foundry** — self-hosted inference
- **Sandboxing** — ізоляція на рівні OS
- **Prompt caching** — прогнозовані витрати
- 53% загального adoption — **лідер overall** (Copilot — 82% headcount, але Claude — #1 в deployments)

</div>

</v-clicks>

</div>

<v-click>

### Екосистема без vendor lock

**MCP** (відкритий стандарт) · **hooks** · **skills** · **plugins** · **subagents** · **Agent SDK** — усе конфігурується файлами в репо, рухається разом з командою.

</v-click>

<DocRef url="https://venturebeat.com/ai/github-leads-the-enterprise-claude-leads-the-pack-cursors-speed-cant-close" label="venturebeat.com — GitHub leads enterprise, Claude leads the pack" />

<!--
Три причини, чому не "просто ще один autocomplete". Перша — технічна: Claude Code виграє benchmarks, працює як агент (планує, робить, перевіряє), тримає мільйон токенів контексту, сам вирішує коли треба глибше reasoning. Друга — enterprise: SSO, audit, managed policy для Teams і Enterprise, можна гнати через Bedrock/Vertex/Foundry якщо політика забороняє SaaS, sandboxing ізолює на рівні ОС, prompt caching робить витрати прогнозованими. Цифра 53% adoption — ключова: по deployments це №1, хоч GitHub має 82% присутності по кількості сідалок (ринок просто старіший). Третя — відкрита екосистема: MCP — відкритий стандарт, не Anthropic-only. Hooks, skills, plugins, subagents — все markdown і JSON у репо. Переходите на іншу модель через Bedrock — ваші hooks і skills мігрують без змін. Це відрізняє від Cursor, де кастомізація через їхній UI.
-->

---
hideInToc: true
---

# Ціни та плани — що вибрати

<v-clicks>

| План | Ціна | Prompts / 5 год | Моделі | Для кого |
|---|---:|---:|---|---|
| **Pro** | $20/міс ($17 річно) | ~40–45 | Sonnet 4.6 | Ознайомлення, особиста робота |
| **Max 5x** | $100/міс | ~225 | Sonnet 4.6 + Opus 4.7 | Full-day coding, один розробник |
| **Max 20x** | $200/міс | ~900 | Sonnet + Opus + пріоритет | Heavy agents, subagents, паралель |
| **Team** | $25–125 /seat/міс | як Pro / Max | усі | SSO, central billing, 5–150 місць |
| **Enterprise** | seat + API usage | custom | усі | HIPAA, RBAC, audit, self-hosted |

</v-clicks>

<DocRef url="https://claude.com/pricing" label="claude.com/pricing" />

<!--
Коротко про ціни, бо це перше питання після "круто, беремо". Pro за двадцятку — це рівно $20 на місяць, або $17 якщо платити річно наперед. На Pro реально можна працювати, але ліміт близько сорока промптів за п'ятигодинне вікно — тобто одна інтенсивна сесія в день максимум. Max 5x за сотню — це вже full-day coding, близько 225 промптів за вікно, плюс доступ до Opus 4.7 для важких задач. Max 20x за двісті — це вже для тих, хто ганяє subagents паралельно і робить агентні pipeline, 900 промптів за вікно. Team — від $25 до $125 за місце, це B2B підписка з SSO, центральним білінгом, адмінкою. Enterprise — seat плюс usage по API-ставках, HIPAA, RBAC, може йти через Bedrock або Vertex. На наступному слайді — що вибрали ми.
-->

---
hideInToc: true
---

# Наш вибір — Team subscription

<v-clicks>

- Взяли **Team subscription** — SSO, централізований білінг, адмінка на всіх
- Зараз на **Team Standard** — ~$25 /seat/міс (місячний), $20 річний
  - usage рівня Pro — вистачає для перших кроків і одиночних сесій
- Розуміємо, що буде потрібен **Team Premium** — ~$125 /seat/міс, 5× usage проти Standard (рівень Max 5x)
  - для агентних workflows, subagents, паралельних задач
- **Плюс Team загалом** — ранній доступ до нових фіч: напр., **Auto Mode** вийшов як research preview спочатку для **Team**, потім Enterprise/API
- **Перехід на Premium** — коли команда адаптується і клієнт погодить бюджет
- Extra usage доступне на всіх платних планах — не впремось у стіну, продовжимо за API-ставками

</v-clicks>

<DocRef url="https://claude.com/pricing" label="claude.com/pricing" />
<DocRef url="https://claude.com/blog/auto-mode" label="claude.com/blog/auto-mode — Team-first rollout" :offset="1" />

<!--
Тепер про нас. Ми вибрали Team subscription — основне заради SSO, централізованого білінгу й адмінки, щоб не розгрібати індивідуальні підписки по кожному розробнику. Зараз на Team Standard, близько $25 за місце на місяць (або $20 якщо річно) — usage як Pro, одна інтенсивна сесія на день, цього вистачає для перших кроків і ознайомлення. Розуміємо, що коли почнемо активно використовувати subagents, hooks, паралельні задачі — Standard закінчиться за годину, і тоді треба Premium. Team Premium — $125 за місце, 5× usage проти Standard, рівень Max 5x. Ще один бонус Team підписки — ранній доступ до нових фіч для всього Team-тіру, не лише Premium. Наприклад, Auto Mode вийшов як research preview спочатку саме для Team-користувачів, а Enterprise і API отримали його вже через кілька днів — особисті Pro і Max взагалі пізніше. Тобто Team — це не тільки адмінка, а ще й раніший доступ до нового. Перейдемо на Premium, коли команда адаптується і клієнт погодить бюджет. І останнє — extra usage тепер доступне на всіх платних планах — якщо ліміт вичерпано, можна продовжити за API-ставками, не чекаючи reset вікна.
-->

---
layout: section
---

# Установка та перший запуск

---
hideInToc: true
---

# Системні вимоги

<v-clicks>

### Операційна система

- **macOS** 13.0+
- **Windows** 10 1809+ або Windows Server 2019+
- **Ubuntu** 20.04+ / **Debian** 10+ / **Alpine** 3.19+

### Залізо та мережа

- 4 GB+ RAM, x64 або ARM64
- Інтернет-з'єднання обов'язкове

### Shell

- Bash, Zsh, PowerShell або CMD
- Native Windows потребує [Git for Windows](https://git-scm.com/downloads/win) (WSL — ні)

### Локація

- [Країни, де доступний Anthropic](https://www.anthropic.com/supported-countries)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/setup#system-requirements" label="code.claude.com/docs/en/setup#system-requirements" />

<!--
Перед установкою — перевірте вимоги. Сучасна macOS, Windows 10+, основні Linux-дистрибутиви. 4 гіга оперативки мінімум. Для native Windows потрібен Git for Windows — він дає Bash середовище. WSL обходиться без нього. Також перевірте, що ваша країна в списку підтримуваних Anthropic — інакше авторизація не пройде.
-->

---

# Способи установки

<v-clicks>

### Native installer (рекомендовано — auto-update в фоні)

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Windows CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### Package managers (без auto-update)

```bash
brew install --cask claude-code        # Homebrew (macOS) — stable channel
brew install --cask claude-code@latest # latest channel
winget install Anthropic.ClaudeCode    # Windows
```

### npm (deprecated)

```bash
npm install -g @anthropic-ai/claude-code   # потребує Node.js 18+
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/setup#install-claude-code" label="code.claude.com/docs/en/setup#install-claude-code" />

<!--
Native installer — рекомендований, бо оновлюється сам у фоні. Три варіанти для Windows: PowerShell, CMD, або через WSL (там linux-скрипт). Homebrew і WinGet працюють, але оновлення руками: brew upgrade або winget upgrade. Homebrew має два cask: claude-code (stable, тиждень затримки) і claude-code@latest (свіжі релізи). npm варіант deprecated, але все ще працює — потребує Node 18+. Не використовуйте sudo npm install -g — проблеми з правами.
-->

---
hideInToc: true
---

# Перевірка установки — `claude doctor`

```text
Diagnostics
└ Currently running: native (2.1.111)
└ Path: /home/vadym/.local/share/claude/versions/2.1.111
└ Config install method: native
└ Search: OK (bundled)

Updates
└ Auto-updates: enabled
└ Auto-update channel: latest
└ Stable version: 2.1.97
└ Latest version: 2.1.111

Version locks
└ 2.1.111: PID 132548 (running)
└ 2.1.109: PID 113874 (running)
└ 2.1.110: PID 3385099 (running)
```

<DocRef url="https://code.claude.com/docs/en/troubleshooting#get-more-help" label="code.claude.com/docs/en/troubleshooting" />

<!--
claude doctor — діагностика установки. Показує три блоки. Diagnostics: яка версія запущена, де лежить, install method, чи ripgrep знайдено. Updates: auto-update канал (latest або stable), свіжі версії. Version locks: активні PID-и процесів на різних версіях — якщо бачите кілька, значить у вас відкрито кілька сесій. Якщо щось не так — спершу запускайте claude doctor, потім /feedback.
-->

---
hideInToc: true
---

# Авторизація — login або API key

<v-clicks>

### OAuth через браузер (Pro / Max / Team / Enterprise)

```bash
claude            # перший запуск → відкриває браузер
/login            # перелогінитись всередині сесії
/logout           # вийти
/status           # який метод авторизації активний
```

### API key (Console / pay-as-you-go)

```bash
export ANTHROPIC_API_KEY=sk-ant-...   # ключ з console.anthropic.com
```

### Long-lived token для CI / скриптів

```bash
claude setup-token                        # згенерувати OAuth-токен на рік
export CLAUDE_CODE_OAUTH_TOKEN=<token>    # використати у CI
```

</v-clicks>

<v-click>

> Порядок пріоритету: Bedrock/Vertex/Foundry → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → `apiKeyHelper` → `CLAUDE_CODE_OAUTH_TOKEN` → subscription OAuth.

</v-click>

<DocRef url="https://code.claude.com/docs/en/authentication" label="code.claude.com/docs/en/authentication" />

<!--
Три шляхи. Перший — OAuth через браузер: запускаєте claude, відкривається вкладка, логінитесь у Claude.ai. Працює для Pro, Max, Team, Enterprise. Другий — API key з Console: підходить для тих, хто платить по факту використання або хоче окремий білінг. Ключ в ANTHROPIC_API_KEY. Третій — long-lived token для CI: claude setup-token генерує OAuth-токен на рік, кладете в CLAUDE_CODE_OAUTH_TOKEN. Важливо: порядок пріоритету. Якщо у вас встановлений ANTHROPIC_API_KEY і підписка Pro — API key виграє. Якщо організація disabled — буде помилка. Розв'язання: unset ANTHROPIC_API_KEY, перевіряйте /status. Для хмарних провайдерів (Bedrock/Vertex/Foundry) — окремі env vars, browser login не потрібен.
-->

---

# Перший запуск

<v-clicks>

```bash
# Авторизація (або OAuth, або API key — див. попередній слайд)
claude

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

# `@` — Посилання на файли та теки

<v-click>

Прикріплюйте файли, теки або MCP-ресурси прямо в промпт — Claude підтягне їх у контекст без додаткового читання.

</v-click>

<v-clicks>

```bash
# Один файл — вміст повністю в контекст
> поясни @src/auth/login.ts

# Кілька файлів — порівняння
> порівняй @old-api.ts з @new-api.ts

# Тека — листинг файлів (не вміст)
> яка структура @src/components/

# MCP-ресурс — формат @server:resource
> покажи дані з @github:repos/owner/repo/issues
```

</v-clicks>

<v-clicks>

- Набір `@` одразу тригерить автокомпліт шляхів; `Tab` / `→` приймає підказку
- Шляхи відносні або абсолютні
- `@`-файл додає `CLAUDE.md` з його теки та батьківських у контекст
- Можна згадати кілька файлів в одному повідомленні: `@a.ts та @b.ts`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/common-workflows" label="code.claude.com/docs/en/common-workflows" />

<!--
@ — один з найчастіше вживаних механізмів. Замість копіпасти вмісту у промпт, просто згадайте файл через @ і Claude прочитає його сам. Автокомпліт тригериться самим символом @ — Tab або стрілка вправо приймає підказку. Важливо: посилання на теку повертає листинг файлів, а не їх вміст — якщо треба вміст, посилайтеся на конкретні файли. Для MCP-ресурсів формат @server:resource, наприклад @github:repos/owner/repo/issues. Ще одна зручність — @-файл автоматично підтягує CLAUDE.md з його теки та батьківських, що дозволяє мати контекстні інструкції для піддиректорій. До речі, зображення через Ctrl+V вставляються не як @-посилання, а як [Image #N] chip, на який можна посилатися в тексті.
-->

---

# Шорткати — навігація та редагування

<v-clicks>

**Autocomplete, історія, перервання**

| Клавіша | Дія |
|---|---|
| `Tab` / `→` | Прийняти підказку автокомпліту (`@`, `/`, prompt suggestion) |
| `↑` / `↓` | Навігація історією промптів |
| `Ctrl+R` | Reverse search по історії |
| `Ctrl+C` | Скасувати поточний ввід або генерацію |
| `Esc` + `Esc` | Rewind — відкотитися та відредагувати попереднє повідомлення |

</v-clicks>

<v-clicks>

**Редагування тексту**

| Клавіша | Дія |
|---|---|
| `Ctrl+U` / `Ctrl+K` | Видалити до початку / до кінця рядка |
| `Ctrl+Y` | Вставити раніше видалений текст |
| `Alt+B` / `Alt+F` | Рух курсором на слово назад / вперед |
| `Ctrl+L` | Очистити поточний ввід (історія діалогу лишається) |
| `Ctrl+G` | Відкрити промпт у зовнішньому редакторі (`$EDITOR`) |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/interactive-mode" label="code.claude.com/docs/en/interactive-mode" />

<!--
Шорткати значно пришвидшують роботу. Esc Esc — найкорисніший: повертає до попереднього промпту і дає його відредагувати, Claude перепише відповідь з нуля. Ctrl+R — reverse search по історії, як у bash. Ctrl+G — відкриває поточний промпт у $EDITOR (vim, nano, code) і після збереження підставляє назад — зручно для довгих промптів. Для Alt/Option-шорткатів на macOS треба в терміналі увімкнути "Option as Meta" (iTerm2 → Profiles → Keys, Terminal.app → Profiles → Keyboard). Натискання ? у сесії показує актуальний список шорткатів для вашого оточення.
-->

---
hideInToc: true
---

# Шорткати — багаторядковий ввід

<v-clicks>

| Клавіша | Умова |
|---|---|
| `\` + `Enter` | Працює у всіх терміналах — **найнадійніше** |
| `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty (інші — `/terminal-setup`) |
| `Option+Enter` | macOS default |
| `Ctrl+J` | Line feed — універсальна альтернатива |

</v-clicks>

<v-clicks>

**Поради**

- `Ctrl+Enter` **немає** в офіційному списку — не покладайтесь
- Для VS Code / Alacritty / Zed / Warp — запустіть `/terminal-setup`, щоб Shift+Enter запрацював
- На macOS перевірте "Option as Meta" у налаштуваннях термінала
- Натисніть `?` у сесії — покаже актуальний список шорткатів для вашого терміналу

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/interactive-mode" label="code.claude.com/docs/en/interactive-mode" />

<!--
Багаторядковий ввід — окрема історія, бо залежить від термінала. \+Enter — золотий стандарт, працює скрізь. Shift+Enter — ергономічніший, але треба або один з "хороших" терміналів (iTerm2, WezTerm, Ghostty, Kitty), або запустити /terminal-setup, який сконфігурує ваш термінал для підтримки Shift+Enter у VS Code, Alacritty, Zed, Warp. Option+Enter — macOS default. Ctrl+J — line feed, универсальна альтернатива. Ctrl+Enter — нема в офіційному списку, хоч подекуди й працює — не покладайтесь. І найкраща порада — натисніть знак питання прямо в сесії, Claude покаже актуальний список для вашого терміналу.
-->

---
hideInToc: true
---

# Slash commands — керування сесією

<v-clicks>

| Команда | Що робить |
|---|---|
| `/help` | Список усіх доступних команд та підказок |
| `/clear` | Почати нову розмову — скинути контекст повністю |
| `/compact` | Стиснути історію в підсумок (залишити ключове) |
| `/context` | Показати поточний розмір контексту та що в ньому |
| `/model` | Перемкнути модель (Opus / Sonnet / Haiku) |
| `/exit` | Вийти з сесії |

</v-clicks>

<v-click>

> `/clear` vs `/compact`: clear викидає все, compact зберігає підсумок — обирайте за ситуацією.

</v-click>

<DocRef url="https://code.claude.com/docs/en/slash-commands" label="code.claude.com/docs/en/slash-commands" />

<!--
Це базові вбудовані команди для керування сесією. /help — завжди під рукою, показує актуальний список. /clear — коли почали нову задачу і стара історія тільки заважає. /compact — коли в тій самій задачі, але контекст розрісся: Claude зробить summary і продовжить з ним. /context — покаже скільки токенів в контексті і що саме там: файли, tool calls, system prompt. Дуже корисно коли розумієте що відповіді стали повільні. /model — перемкнутись між Opus, Sonnet, Haiku прямо в сесії без перезапуску. /exit — вихід. Всі ці команди не треба пам'ятати — /help завжди покаже.
-->

---
layout: section
---

# Середовище розробника

---
hideInToc: true
---

# Термінал і шрифти

<v-clicks>

### Рекомендовані термінали (native `Shift+Enter`, multiline, OS-нотифікації)

- **Ghostty** — найшвидший, GPU, native multiline, нотифікації з коробки
- **WezTerm** — конфіг у Lua, multi-pane
- **Kitty** — GPU, image protocol (для vision-prev'ю)
- **iTerm2** (macOS) — де-факто стандарт

### Для інших (VS Code / Alacritty / Zed / Warp)

```bash
/terminal-setup          # налаштує Shift+Enter автоматично
```

### Щоб statusline, іконки і діаграми рендерились

- **Nerd Fonts** — JetBrainsMono Nerd, FiraCode Nerd, Hack Nerd
- Увімкнути у терміналі: `Font: JetBrainsMono Nerd Font Mono`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/terminal-guide" label="code.claude.com/docs/en/terminal-guide" />

<!--
Термінал — це ваш IDE, коли працюєте з Claude Code. Native multiline через Shift+Enter — must-have: без нього доводиться ставити зворотний слеш. Ghostty зараз найшвидший, з native нотифікаціями — я особисто перейшов на нього. WezTerm і Kitty — тверді альтернативи. iTerm2 — якщо на macOS і не хочеться експериментувати. Якщо ваш термінал не в списку — /terminal-setup налаштує VS Code, Alacritty, Zed або Warp. І не забудьте Nerd Fonts — без них не буде рендеритись statusline і багато іконок у Slidev/markdown.
-->

---
hideInToc: true
---

# Нотифікації та фокус

<v-clicks>

### Налаштування в `settings.json`

```json
{
  "notifications": {
    "mode": "system",
    "onPermissionRequest": true,
    "onTaskComplete": true
  }
}
```

- `system` — native OS notification (Ghostty / iTerm2 / macOS / Linux)
- `silent` — нічого не шле
- `terminal` — bell у терміналі

### Hook на закінчення довгої задачі

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "terminal-notifier -title 'Claude' -message 'Готово'" }]
    }]
  }
}
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com/docs/en/hooks" />

<!--
Claude Code часто працює хвилинами на складних задачах. Замість того щоб дивитися на екран — дайте йому вас ткнути. Базова опція — notifications.mode: system у settings, і термінал буде слати native нотифікацію, коли потрібен дозвіл або задача завершилась. Якщо хочете більше контролю — Stop hook з terminal-notifier (macOS) або notify-send (Linux). А про voice — окрема розмова на наступному слайді.
-->

---
hideInToc: true
---

# Voice Dictation — Голосовий ввід

<v-clicks>

### 🔥 Свіже — березень 2026 (v2.1.69+)

### Як працює:
```bash
/voice              # Увімкнути голосовий режим
# Тримай Space — говори — відпусти
```

- 💰 **Безкоштовно** — токени транскрипції не рахуються в ліміт
- 🇺🇦 **Українська** + 20 інших мов (код `uk` в офіційних доках)
- Оптимізовано для **коду** — розпізнає regex, OAuth, JSON, localhost
- Waveform-індикатор і транскрипція в реальному часі
- Можна **змішувати** голос і текст в одному промпті

### Ідеально для:
- Довгих контекстних промптів (30+ секунд набору)
- Пояснення архітектури та опису багів
- Hands-free кодування

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/voice-dictation" label="code.claude.com/docs/en/voice-dictation" />

<!--
Voice — свіжа фіча, вийшла 3 березня 2026 разом з Claude Code 2.1.69. Ще мало хто знає. Тримаєш Space, говориш, відпускаєш — і отримуєш текст. Транскрипція оптимізована для програмування, розуміє regex, OAuth, JSON, localhost. Головні понти: безкоштовно — токени транскрипції не рахуються в жодному плані, і підтримує українську з коробки (код мови uk). У Copilot і Cursor такого з коробки немає. Ідеально для довгих промптів, де руки втомлюються друкувати.
-->

---
layout: section
---

# Режими роботи

---

# Permission Modes

<div class="text-sm">

| Режим | Що виконує без запиту | Коли використовувати |
|---|---|---|
| `default` | Тільки читання | Початок, чутлива робота |
| `acceptEdits` | Читання, редагування файлів, FS-команди (`mkdir`, `mv`, `cp`…) | Ітерації над кодом, який ревʼюєте |
| `plan` | Тільки читання, збирає план без змін | Дослідження кодбази перед правками |
| `auto` 🆕 | **Все, з фоновим класифікатором безпеки** | Довгі задачі, менше переривань |
| `dontAsk` | Лише заздалегідь дозволені інструменти | Закритий CI, скрипти |
| `bypassPermissions` | Все, крім [захищених шляхів](https://code.claude.com/docs/en/permission-modes#protected-paths) | **Тільки** контейнери/VM |

</div>

<v-click>

> **Перемикання:** `Shift+Tab` циклить `default → acceptEdits → plan` · `--permission-mode <mode>` на старті · `defaultMode` у `settings.json`

</v-click>

<DocRef url="https://code.claude.com/docs/en/permission-modes" label="code.claude.com/docs/en/permission-modes" />

<!--
Шість режимів — від повного контролю до повної автономії. Таблиця показує, що виконується БЕЗ запиту дозволу в кожному режимі. Shift+Tab циклить між трьома базовими (default, acceptEdits, plan) — auto, dontAsk і bypassPermissions не в циклі, їх треба вмикати явно. Починайте з default, переходьте на acceptEdits коли звикнете. auto — новинка, зараз у research preview — про нього окремо на наступному слайді. bypassPermissions — тільки в ізольованих середовищах, контейнерах, VM. Далі будемо конфігурувати Claude — і частина тієї конфігурації керує саме цими режимами.
-->

---
hideInToc: true
---

# `auto` — режим, що прибирає промпти

Окрема модель-класифікатор ревʼює кожну дію перед виконанням. Блокує все, що виходить за межі вашого запиту або виглядає підозріло.

<div class="grid grid-cols-2 gap-6 text-sm">
<div>

### ✅ Дозволяє за замовчуванням

- Локальні операції в робочій директорії
- Встановлення залежностей з lock-файлів
- Читання `.env` + відправка креденшлів у відповідний API
- Read-only HTTP запити
- Push у бранч, який ви стартували

</div>
<div>

### 🚫 Блокує за замовчуванням

- `curl | bash` — виконання стороннього коду
- Відправка sensitive data у зовнішні ендпоінти
- Production-деплої та міграції
- Force push, push у `main`
- Зміна shared infrastructure
- Безповоротне видалення файлів

</div>
</div>

<div class="mt-4 text-xs opacity-80">

**Вимоги:** Claude Code v2.1.83+ · плани Max / Team / Enterprise / API (не Pro) · моделі Sonnet 4.6, Opus 4.6/4.7 · Anthropic API (не Bedrock / Vertex). Після 3 блокувань поспіль або 20 разом — auto пауза, повертаються промпти.

</div>

<DocRef url="https://claude.com/blog/auto-mode" label="claude.com/blog/auto-mode" />

<!--
auto mode — це research preview, ключова новинка 2025–2026. Замість запиту на кожну дію — окремий класифікатор (серверна модель) ревʼює заплановану дію і блокує потенційно небезпечне. Класифікатор бачить ваші повідомлення, tool calls і CLAUDE.md, але НЕ бачить результати tool calls — це захист від prompt injection через файли чи веб-контент. Важливо: кордони які ви задаєте у розмові (наприклад "не пушити в main") теж блокують відповідні дії. Не доступно на Pro-плані. Якщо класифікатор щось блокує 3 рази підряд — auto пауза, Claude повертається до звичайних промптів.
-->

---
hideInToc: true
---

# Permissions — Синтаксис правил

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Bash(* --version)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)"
    ]
  }
}
```

<v-clicks>

- **Bash:** wildcard `*` на початку, в середині або в кінці — `Bash(npm:*)` = `Bash(npm *)`
- **Read/Edit:** gitignore-синтаксис — `/path`, `~/path`, `./path`
- **WebFetch:** `WebFetch(domain:example.com)` — фільтр по домену
- **MCP:** `mcp__server` або `mcp__server__tool` — контроль MCP-інструментів

</v-clicks>

<v-click>

> **Порядок обчислення:** `Deny → Ask → Allow`. Deny завжди перемагає, перше співпадіння виграє.

</v-click>

<DocRef url="https://code.claude.com/docs/en/permissions" label="code.claude.com/docs/en/permissions" />

<!--
Правила дозволів підтримують wildcards та специфікатори. Для Bash — glob-патерни. Для файлів — gitignore-синтаксис. Compound-команди (&&, ||, ;) розбираються автоматично. Порядок обчислення критичний: deny завжди перемагає — це основа безпеки в auto та bypassPermissions режимах. Перше співпадіння виграє, тому порядок правил у масиві має значення. Куди саме кладеться цей JSON — settings.json — подивимось у наступній секції.
-->

---
hideInToc: true
---

# Sandboxing — Ізоляція на рівні ОС

<v-clicks>

- **Permissions** = що Claude **може спробувати**
- **Sandboxing** = що Bash **реально може дістати** (OS-level enforcement)

</v-clicks>

<v-click>

```mermaid {scale: 0.65}
graph LR
    CC[Claude Code] --> SB{Sandbox}
    SB -->|✅ Дозволено| CWD["📁 Робоча директорія"]
    SB -->|✅ Дозволено| NET["🌐 Дозволені домени"]
    SB -->|❌ Заблоковано| SYS["⚙️ Системні файли"]
    SB -->|❌ Заблоковано| EXT["🔒 Зовнішні сервери"]
    style CC fill:#8B5CF6,color:#fff
    style SB fill:#F59E0B,color:#fff
    style CWD fill:#10B981,color:#fff
    style NET fill:#10B981,color:#fff
    style SYS fill:#EF4444,color:#fff
    style EXT fill:#EF4444,color:#fff
```

</v-click>

<v-click>

| Платформа | Технологія |
|---|---|
| macOS | Seatbelt (вбудований) |
| Linux / WSL2 | bubblewrap + socat |

</v-click>

<DocRef url="https://code.claude.com/docs/en/sandboxing" label="code.claude.com/docs/en/sandboxing" />

<!--
Sandboxing — це другий рівень захисту після permissions. Permissions вирішує чи дозволити спробу. Sandbox обмежує що процес реально може зробити на рівні ОС. Файлова система — запис лише в робочу директорію. Мережа — тільки дозволені домени через проксі.
-->

---
hideInToc: true
---

# Sandboxing — Конфігурація

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyRead": ["~/.ssh"]
    },
    "network": {
      "allowedDomains": ["github.com", "registry.npmjs.org"]
    }
  }
}
```

<v-clicks>

- **Filesystem:** за замовчуванням запис тільки в робочу директорію
- **Network:** нові домени — запит дозволу, `allowedDomains` — без промптів
- **Auto-allow:** з увімкненим sandbox Bash-команди виконуються без підтвердження

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/sandboxing" label="code.claude.com/docs/en/sandboxing" />

<!--
Конфігурація sandbox дозволяє тонко налаштувати межі. allowWrite — додаткові директорії для запису. denyRead — заборонити читання чутливих файлів. Network — whitelist доменів. Коли sandbox увімкнений, Bash-команди всередині меж виконуються автоматично — менше промптів, така ж безпека. Далі подивимось на найсильнішу форму ізоляції — готовий devcontainer від Anthropic.
-->

---
hideInToc: true
---

# Devcontainer — готова ізоляція від Anthropic

<div class="grid grid-cols-2 gap-6 text-sm">
<div>

### Що всередині

- **Node.js 20** + git, ZSH, fzf
- **Firewall** (`init-firewall.sh`): default-deny, whitelist лише `npm`, `github.com`, Anthropic API
- **VS Code Dev Containers** інтеграція
- Збереження history між рестартами

### Навіщо?

У контейнері можна безпечно запускати:

```bash
claude --dangerously-skip-permissions
```

без ризику для хостової системи.

</div>
<div>

### Старт за 4 кроки

1. VS Code + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Клонувати [референсний репо](https://github.com/anthropics/claude-code/tree/main/.devcontainer)
3. Відкрити у VS Code
4. **"Reopen in Container"** (Cmd+Shift+P)

### Use cases

- 🔐 Клієнтська робота — проєкти не змішуються
- 🚀 Онбординг команди — готове середовище за хвилини
- 🔄 Дзеркалити в CI/CD

<div class="mt-3 text-xs opacity-70">
⚠️ Не захищає від malicious repo — credentials з контейнера можуть витекти. Використовуйте лише з довіреними репозиторіями.
</div>

</div>
</div>

<DocRef url="https://code.claude.com/docs/en/devcontainer" label="code.claude.com/docs/en/devcontainer" />

<!--
Devcontainer — це найсильніша форма ізоляції, яку пропонує Anthropic з коробки. Готовий образ із Node 20, firewall-ом і всіма DX-плюшками. Ключова фіча — можна безпечно запускати --dangerously-skip-permissions: контейнер ізольований від хостової системи, firewall рубає все крім whitelist. Для команд — ідеально для онбордингу: нова людина клонує репо, "Reopen in Container" — і за хвилини має повне середовище. Важливе застереження з доки: devcontainer не захищає від malicious проєктів — якщо скачаєте якусь дичину і запустите там --dangerously-skip-permissions, credentials з контейнера можуть витекти. Використовуйте тільки з довіреними репо.
-->

---
layout: section
---

# Моделі та reasoning

---
hideInToc: true
---

# `/effort` — Рівень адаптивного reasoning

<v-clicks>

| Рівень | Коли вмикати |
|---|---|
| `low` | Короткі, латенсі-чутливі задачі, без складних рішень |
| `medium` | Баланс ціни та якості для cost-sensitive роботи |
| `high` | Мінімум для intelligence-sensitive задач |
| `xhigh` | **Default на Opus 4.7** — найкраще для кодингу / агентики |
| `max` | Максимум reasoning — тільки поточна сесія, ризик overthinking |

### Підтримка моделями

- **Opus 4.7** — `low / medium / high / xhigh / max` (default: `xhigh`)
- **Opus 4.6, Sonnet 4.6** — `low / medium / high / max` (default: `high`, або `medium` на Pro/Max)

</v-clicks>

<v-click>

> Для разового "подумай глибше" — додайте слово **ultrathink** у промпт, ефорт не змінюючи.

</v-click>

<!--
/effort керує адаптивним reasoning — модель сама вирішує, скільки думати на кожному кроці. П'ять рівнів: low, medium, high, xhigh, max. На Opus 4.7 доступні всі п'ять, дефолт — xhigh. На Opus 4.6 та Sonnet 4.6 — чотири рівні без xhigh, дефолт high (або medium на Pro/Max). max — без обмежень по токенам, тільки поточна сесія, легко в overthinking. Лайфхак: якщо хочете разово поглибити міркування — напишіть "ultrathink" у промпт. Воно додасть in-context інструкцію, але не змінить виставлений рівень. На наступному слайді — де і як виставляти рівень.
-->

---
hideInToc: true
---

# `/effort` — Як встановити

<div class="grid grid-cols-2 gap-6">
<div>

### Інтерактивно в сесії

```bash
/effort             # відкриває слайдер
/effort xhigh       # виставити напряму
/effort auto        # скинути до default
```

### На старті CLI

```bash
claude --effort high
```

### Env-змінна (виграє над settings)

```bash
export CLAUDE_CODE_EFFORT_LEVEL=high
```

</div>
<div>

### У `settings.json`

```json
{ "effortLevel": "high" }
```

### У frontmatter скіла / субагента

```yaml
---
name: reviewer
effort: high
---
```

<div class="mt-4 text-sm opacity-80">

**Пріоритет:** `env` → session (`/effort`, `--effort`) → `settings.json` → model default

</div>

</div>
</div>

<DocRef url="https://code.claude.com/docs/en/model-config#adjust-effort-level" label="code.claude.com/docs/en/model-config#adjust-effort-level" />

<!--
Шість місць, де можна виставити effort — від разового в сесії до проєктних налаштувань. Пріоритет важливий: env-змінна перемагає все, потім session-рівень (слеш-команда або --effort прапор), далі settings.json, і нарешті дефолт моделі. Для скілів і субагентів можна окремо задавати рівень у frontmatter — наприклад, для рев'ю коду виставити high, для швидких утиліт — low. Практично: /effort у сесії коли треба тут і зараз, settings.json для проєктного дефолту, env для CI.
-->

---
hideInToc: true
---

# Model opusplan — Opus планує, Sonnet виконує

<v-clicks>

### Ідея:
**Opus 4.6** — найрозумніший, але повільніший і дорожчий. **Sonnet 4.6** — швидкий і дешевий. А якщо поєднати?

```bash
claude --model opusplan
# або в сесії:
/model opusplan
```

### Як працює:

```mermaid {scale: 0.65}
graph LR
    T[Твій запит] --> O[Opus 4.6<br/>🧠 Планує та рев'юїть]
    O --> S[Sonnet 4.6<br/>⚡ Виконує код]
    S --> O
    O --> R[Результат]
    style O fill:#8B5CF6,color:#fff
    style S fill:#10B981,color:#fff
    style T fill:#F59E0B,color:#fff
    style R fill:#3B82F6,color:#fff
```

> **Найкраще з двох світів:** якість планування Opus + швидкість виконання Sonnet

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/model-configuration" label="code.claude.com/docs/en/model-configuration" />

<!--
opusplan — це гібридний режим. Opus робить те, що він робить найкраще — думає, планує, рев'юїть. А Sonnet швидко виконує код за цим планом. Ти отримуєш якість Opus за ціною ближчу до Sonnet. Для великих задач — ідеальний варіант.
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
CLAUDE.md — це як README, але для AI. Тут ви описуєте правила, архітектуру, команди — все, що Claude повинен знати про ваш проєкт. Писати з нуля не обов'язково — на наступному слайді побачимо, як /init згенерує стартову версію з вашого репо.
-->

---
hideInToc: true
---

# `/init` — Не пишіть CLAUDE.md з нуля

<v-clicks>

```bash
claude
> /init                              # читає репо → генерує CLAUDE.md

# Інтерактивний флоу — також налаштує skills, hooks, personal memory
CLAUDE_CODE_NEW_INIT=1 claude
> /init
```

### Що витягнув `/init` з реального проєкту `zipstay`

- **Docker-середовище** — `make rebuild`, `make up`, shell в `app` контейнер
- **Команди** — `composer psalm`, `./vendor/bin/phpunit`, `yarn dev`, `bin/console …`
- **Порти сервісів** — API `54400`, Postgres `54401`, Redis `54403`, Mercure `54408`
- **Архітектура** — monorepo `backend/` (Symfony 7.4) + `frontend/` (Vue 3.5) + `api-proxy/`
- **DDD-структура модулів** — `src/{Module}/{ApiResource,Controller,Entity,...}`

</v-clicks>

<v-click>

> Згенероване — це чернетка. Допилюйте руками під правила команди.

</v-click>

<DocRef url="https://code.claude.com/docs/en/commands" label="code.claude.com/docs/en/commands" />

<!--
Щойно подивилися, як виглядає CLAUDE.md. Тепер — як його не писати руками. /init аналізує репозиторій: читає package.json, composer.json, Makefile, docker-compose, README — і складає стартовий CLAUDE.md. На прикладі zipstay: він витяг make-команди, composer-скрипти, yarn-команди фронта, порти з docker-compose, і навіть зрозумів DDD-структуру модулів. CLAUDE_CODE_NEW_INIT=1 вмикає інтерактивний флоу — проходить також по skills, hooks, персональній памʼяті. Важливо: це чернетка, не фінал. Допилюйте під правила команди, специфічні conventions, gotchas — те, чого Claude не побачить зі структури коду.
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

# Settings — JSON-конфігурація

<v-clicks>

### Три рівні, зверху вниз перекриваються

```bash
~/.claude/settings.json         # User — ваші глобальні налаштування
.claude/settings.json           # Project — для команди (в git)
.claude/settings.local.json     # Project Local — тільки ви (gitignored)
```

### Що туди кладуть

- `permissions` — allow / deny / ask для інструментів і команд
- `env` — змінні оточення (`DISABLE_AUTOUPDATER`, `USE_BUILTIN_RIPGREP`…)
- `hooks` — автоматика на події `PreToolUse`, `PostToolUse`, `SessionStart`…
- `model`, `autoUpdatesChannel`, `attribution` — поведінка сесії
- `mcpServers` — через `.mcp.json` (про це окремий слайд)

</v-clicks>

<v-click>

> Все, що у `settings.local.json`, **не** комітиться — секрети, особисті tweak-и.

</v-click>

<DocRef url="https://code.claude.com/docs/en/settings" label="code.claude.com/docs/en/settings" />

<!--
Settings — це JSON-файли, які керують поведінкою Claude Code. Три рівні: user (глобальні, ~/.claude), project (спільні для команди, комітяться), local (ваші приватні — в gitignore). Перекриття іде від user → project → local, тобто локальні налаштування виграють. В одному файлі — permissions, env, hooks, вибір моделі, канал оновлень, MCP-сервери. Приклади settings подивимось через слайд, а зараз переходимо до Rules — це вже не JSON, а markdown-правила, що підключаються лише коли Claude торкається певних файлів.
-->

---
hideInToc: true
---

# Rules — Markdown-правила під path-патерни

<v-clicks>

### Навіщо окремо від CLAUDE.md?

- **Ледачо завантажуються** — тільки коли Claude відкриває відповідні файли
- **Економлять контекст** — не замусолюють сесію нерелевантним
- **Точкові інструкції** — різні правила для frontend, backend, міграцій

### Приклад: правила лише для UI

```markdown
<!-- .claude/rules/frontend.md -->
---
paths: ["src/components/**", "src/pages/**"]
---
- Functional components, хуки — не classes
- Стилі через Tailwind, без inline style
- Кожен компонент має unit-тест
```

### Приклад: правила лише для API

```markdown
<!-- .claude/rules/api.md -->
---
paths: ["src/api/**", "src/services/**"]
---
- Валідація вхідного через Zod
- Обробка помилок — завжди `try/catch` + лог
- Логування — winston, не `console.log`
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/memory#path-specific-rules" label="code.claude.com/docs/en/memory#path-specific-rules" />

<!--
Rules — це path-scoped markdown-інструкції. Відрізняються від CLAUDE.md тим, що завантажуються тільки коли Claude працює з файлами, що підпадають під glob з frontmatter. Контекст не роздувається. Типова структура — окремий файл на зону відповідальності: frontend.md, api.md, migrations.md, tests.md. Всередині — правила, які мають сенс саме там. Приклад: правила верстки нічого не роблять, коли Claude редагує SQL-міграцію.
-->

---
hideInToc: true
---

# Settings — Корисні приклади

<v-clicks>

### Вимкнути Co-Authored-By в комітах
```json
// ~/.claude/settings.json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

### Дозволити команди без підтвердження
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(git:*)",
      "Bash(npx:*)"
    ]
  }
}
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/settings" label="code.claude.com/docs/en/settings" />

<!--
Кілька практичних прикладів. Attribution — щоб не було Co-Authored-By у кожному коміті. Permissions — щоб не натискати Enter на кожну npm/git команду.
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

# MCP — Model Context Protocol

---

# Що таке MCP?

<v-click>

Стандартизований протокол для підключення Claude до зовнішніх сервісів та інструментів.

</v-click>

<v-click>

```mermaid {scale: 0.55}
graph LR
    CC[Claude Code] --> MCP{MCP Protocol}
    MCP --> GH[GitHub]
    MCP --> JR[Jira]
    MCP --> PG[PostgreSQL]
    MCP --> Custom[Your API]
    style CC fill:#8B5CF6,color:#fff
    style MCP fill:#F59E0B,color:#fff
```

</v-click>

<v-click>

> ⚠️ У 2026 MCP **вже не срібна куля**. Для простих інтеграцій `Skill + CLI` часто виграє — легше, без сервера, дешевше по токенах. MCP лишається сильним там, де **OAuth / stateful / realtime**.

</v-click>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
MCP — стандартизований протокол для підключення зовнішніх інструментів. Як USB для AI. Але у 2026 з появою Skills екосистема переосмислила роль MCP. Для багатьох задач — дістати дані з API, згенерувати artifact, запустити скрипт — простіше написати скіл з CLI-утилітою, ніж піднімати MCP-сервер. Anthropic самі пушили цей напрямок. MCP лишається дефолтним вибором там, де потрібна OAuth-сесія (Linear, Atlassian, GitHub), stateful підключення (DB, Redis), або realtime-дані (context7 для свіжих доків). На наступному слайді — коли що обирати.
-->

---

# MCP vs Skill + CLI — коли що

<div class="grid grid-cols-2 gap-6 text-sm">

<v-click>

### ✅ Бери MCP коли
- **OAuth-сесія** — Linear, Atlassian, GitHub, Notion
- **Stateful підключення** — PostgreSQL, MongoDB, Redis
- **Realtime / свіжі дані** — `context7` (live docs бібліотек)
- **Офіційний сервер існує** і його підтримують
- Протокол дає tools **+ resources + prompts** разом

</v-click>

<v-click>

### 🪶 Бери Skill + CLI коли
- Є робочий CLI (`gh`, `stripe`, `vercel`, `aws`)
- Одноразова операція без сесії
- Хочеться легко шарити через git (`.claude/skills/`)
- Немає часу піднімати MCP-сервер
- Не хочеться платити токени за tool-descriptions у кожній сесії

</v-click>

</div>

<v-click>

> Мій реальний сетап: **`context7`** (MCP — свіжі доки бібліотек) + `gh` CLI у скілах замість GitHub MCP.

</v-click>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
У 2026 питання не "який MCP-сервер поставити", а "MCP це чи скіл з CLI". Skills + CLI виграють для більшості простих кейсів: gh працює з GitHub краще за GitHub MCP, stripe CLI легший за Stripe MCP, aws CLI — очевидно. Якщо вже є робочий CLI і вам треба одноразова операція — скіл з bash-прикладами швидше запрацює і легше шариться через .claude/skills/ в репо. Токени теж економите: MCP-сервер інжектить tool-descriptions у кожну сесію, скіл підвантажується лише коли потрібен. Де MCP реально незамінний: OAuth-flow (Linear, Atlassian, Notion — авторизуєтесь раз, далі агент сам ходить), stateful підключення до DB, realtime-дані типу context7 де документація з офіційного джерела і завжди актуальна. Мій особистий сетап — context7 MCP для свіжих доків React/Next/Prisma і решти бібліотек, GitHub через gh CLI у скіл — без потреби в GitHub MCP.
-->

---

# Конфігурація MCP — `context7` і Postgres

<v-click>

### `.mcp.json` — мій реальний приклад:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y", "@anthropic-ai/mcp-server-postgres",
        "postgresql://postgres:****@localhost:54401/app"
      ]
    }
  }
}
```

> `context7` — свіжі доки React, Next.js, Prisma, AWS SDK, Spring Boot без halluзинацій про застарілі API. Postgres — schema introspection + запити.

</v-click>

<v-click>

### `.mcp.json.dist` — шаблон для команди:
```bash
# .mcp.json → .gitignore (credentials!)
# .mcp.json.dist → git (плейсхолдери замість паролів)
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com/docs/en/mcp" />

<!--
Два MCP, які реально виправдані у моєму сетапі. Context7 — локальний npx-процес, підключається до Upstash'івського сервісу, повертає актуальну документацію бібліотек прямо в контекст. Без нього агент може галюцинувати застарілі API React 17 чи Next 13. З ним — питає свіжу версію і пише код під поточні доки. Postgres — для роботи з локальною базою проєкту: агент дивиться схему, робить запити валідації, пише міграції на основі реальної структури. Безпека: .mcp.json з реальними credentials обов'язково в .gitignore. У git лежить .mcp.json.dist з плейсхолдерами — онбординг нового інженера зводиться до копії файлу і підставки пароля.
-->

---
layout: section
---

# Скіли та слеш-команди

---

# Вбудовані команди + bundled-скіли

<div class="grid grid-cols-2 gap-6 text-sm">
<div>

### 🛠 Built-in команди

Фіксована логіка всередині Claude Code.

| Команда | Що робить |
|---|---|
| `/help` | Список команд |
| `/clear` | Нова сесія |
| `/compact` | Стиснути контекст |
| `/memory` | Керування CLAUDE.md |
| `/model` · `/effort` | Модель і reasoning |
| `/mcp` · `/hooks` · `/agents` | Управління розширеннями |
| `/cost` · `/config` | Статистика, налаштування |
| `/init` · `/review` · `/security-review` | Спеціальні workflow |

</div>
<div>

### 🎯 Bundled-скіли

Markdown-плейбуки, які Claude оркеструє через свої інструменти.

| Скіл | Що робить |
|---|---|
| `/simplify` | Рев'ю + оптимізація змін |
| `/batch` | Масштабні паралельні правки |
| `/debug` | Debug logging + діагностика |
| `/loop <інтервал> <cmd>` | Повтор з інтервалом |
| `/claude-api` | Довідка по Anthropic SDK |

<div class="mt-4 text-xs opacity-80">
Скіли можна викликати явно (<code>/simplify</code>) або Claude підтягне сам за description.
</div>

</div>
</div>

<DocRef url="https://code.claude.com/docs/en/commands" label="code.claude.com/docs/en/commands" />

<!--
Важливо розрізняти: команди — це фіксована логіка всередині Claude Code (наприклад /compact реально стискає контекст). Bundled-скіли — це markdown-плейбуки з інструкціями, Claude їх виконує своїми звичайними інструментами. У доці їх чітко розділяють, хоча викликаються однаково через слеш. /simplify — переглянути останні зміни. /batch — робити масштабні правки паралельно. /debug — зібрати діагностику. /loop — поставити повтор задачі за інтервалом. /claude-api — розгорнута довідка по Anthropic SDK. Next slide — як писати свої.
-->

---

# Створення власних скілів

<div class="grid grid-cols-2 gap-4 text-sm">
<div>

### Структура

```text
.claude/skills/deploy-check/
├── SKILL.md      # обов'язковий
├── reference.md  # детальна довідка
├── examples/     # зразки
└── scripts/      # виконувані скрипти
```

### Де зберігати

- `~/.claude/skills/…` — особисті
- `.claude/skills/…` — проєктні (у git)
- Плагіни — `plugin:skill`

### Як викликати

- **Автоматично** — Claude матчить за `description`
- **Явно** — `/deploy-check` у сесії

</div>
<div>

### SKILL.md

```markdown
---
name: deploy-check
description: Перевірка готовності до релізу.
  Трігер: "чи готово до деплою?", "reliability check".
allowed-tools: Bash(npm test) Bash(git status) Read Grep
---

## Інструкції
1. `npm test` — всі тести проходять
2. `grep -r TODO\|FIXME src/` — немає
3. `package.json` версія оновлена
4. `CHANGELOG.md` має запис
5. Звіт: ✅/❌ + READY / NOT READY
```

</div>
</div>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com/docs/en/skills" />

<!--
Скіл — це директорія з SKILL.md всередині. У frontmatter обов'язковий name і рекомендований description — за ним Claude вирішує, коли підтягнути скіл автоматично. allowed-tools — інструменти, які не питатимуть підтвердження під час роботи скіла. Додаткові файли — reference.md, examples/, scripts/ — завантажуються тільки коли скіл активний, тому reference-матеріал не з'їдає токени у звичайних сесіях. Три рівні зберігання: ~/.claude/skills — особисті для всіх ваших проєктів, .claude/skills у репо — команді через git, плагіни — через неймспейс plugin:skill.
-->

---

# Приклад: скіл для код-рев'ю

```markdown
---
name: review
description: Детальний код-рев'ю поточних змін.
  Використовуй на запити "зроби рев'ю", "перевір diff", перед PR.
context: fork
agent: general-purpose
allowed-tools: Bash(git diff*) Bash(git log*) Read Grep
---

## Інструкції для код-рев'ю

Проаналізуй `git diff` проти main. Перевір:

**Безпека** — SQL injection, XSS, command injection, захардкоджені credentials

**Якість** — покриття тестами, дублювання, зрозумілі назви

**Продуктивність** — N+1 запити, відсутні індекси, великі об'єкти в пам'яті

Результат: список проблем із severity `critical` / `warning` / `info`
і рекомендацією по виправленню.
```

<DocRef url="https://code.claude.com/docs/en/skills#run-skills-in-a-subagent" label="code.claude.com/docs/en/skills" />

<!--
Практичний приклад. Ключове: context: fork — скіл запускається у форкнутому субагенті з ізольованим контекстом. Основна розмова не забруднюється великим рев'ю-аутпутом, повертається тільки підсумок. agent: general-purpose задає тип субагента (можна Explore, Plan, або кастомний з .claude/agents/). allowed-tools — read-only git і пошук, без Write чи Edit. description з тригер-фразами підвищує ймовірність auto-invocation: Claude побачить "зроби рев'ю" і підтягне скіл сам.
-->

---
hideInToc: true
---

# `skills.sh` — екосистема готових скілів

<div class="grid grid-cols-2 gap-6 text-sm">
<div>

### Open Agent Skills standard

```bash
npx skills add anthropics/skills           # офіційні від Anthropic
npx skills add vercel-labs/next-best-practices
```

- Формат [agentskills.io](https://agentskills.io) — єдиний
- Працює з **Claude Code, Codex, Cursor, Gemini CLI, Copilot, Windsurf** та ін.
- Переносите скіли між інструментами **без змін**

</div>
<div>

### Де шукати

| Реєстр | Що там |
|---|---|
| [anthropics/skills](https://github.com/anthropics/skills) | Офіційні від Anthropic |
| [skills.sh](https://skills.sh) | Ledger від Vercel Labs |
| [awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | Community-каталог |

</div>
</div>

<v-click>

### Приклад — Next.js Skills від Vercel

`next-best-practices` автоматично вмикається на Next.js-коді: Server Components, caching, metadata, middleware, routing. Виміряно підвищення pass rate на [nextjs.org/evals](https://nextjs.org/evals).

</v-click>

<DocRef url="https://vercel.com/changelog/introducing-skills-the-open-agent-skills-ecosystem" label="vercel.com — skills ecosystem" />

<!--
Скіли переросли Claude Code і стали крос-тул-форматом. Vercel Labs пушать skills.sh — ledger + leaderboard. Спільнота підхопила — awesome-agent-skills агрегує community-скіли. Anthropics/skills — офіційний пакет, на який можна дивитись як на референс. Встановлення одна команда: npx skills add <org>/<pack>, і скіл лягає в потрібне місце для вашого агента. Головний бенефіт — vendor-neutral: переходите з Claude Code на Cursor, скіли їдуть з вами. Next-best-practices від Vercel — хороший приклад продуктового скіла: не просто інструкція, а контекст який автоматично підтягується і реально покращує якість Next.js коду, виміряно на evals.
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
hideInToc: true
---

# Automation Recommender — З чого почати?

<v-clicks>

Не знаєте які hooks, MCP, агенти потрібні вашому проєкту? **Claude сам підкаже.**

```bash
/plugin install github@claude-plugins-official
# Потім просто скажіть:
"recommend automations for this project"
```

### Що аналізує:
- Package managers, фреймворки, бази даних
- Тестові фреймворки, CI/CD, зовнішні API
- Існуючу конфігурацію Claude Code

### Що рекомендує (top 1-2 на категорію):

| Категорія | Приклад рекомендації |
|---|---|
| **MCP сервери** | PostgreSQL, context7, Playwright |
| **Hooks** | Auto-format, type-check, захист файлів |
| **Субагенти** | code-reviewer, security-reviewer |
| **Skills** | Scaffolding, міграції, тести |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins" label="code.claude.com/docs/en/plugins" />

<!--
Automation Recommender — офіційний плагін від Anthropic. Аналізує ваш проєкт і рекомендує конкретні автоматизації. Це ідеальна точка входу — замість того щоб самому вигадувати які hooks чи MCP потрібні, Claude подивиться на ваш стек і запропонує найкорисніше. Read-only — нічого не змінює, тільки аналізує.
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
hideInToc: true
---

# Офіційні та спільнотні плагіни

<div class="grid grid-cols-2 gap-6">

<div>

<v-clicks>

### 🏢 Від Anthropic

- **claude-code-setup** — аналіз проєкту та рекомендації автоматизацій
- **claude-md-management** — аудит та покращення CLAUDE.md (знаходить дублі, застарілі секції)
- **code-simplifier** — ревʼю недавніх змін на простоту, рефакторить без втрати функціоналу
- **skill-creator** — створення, benchmarks, variance analysis скілів
- **session-report** — HTML-звіт витрат, cache hit rate, топ-промптів
- **Playwright** — browser automation (MCP)
- **php-lsp** — PHP Language Server для Symfony / Laravel

</v-clicks>

</div>

<div>

<v-clicks>

### 🌍 Від спільноти

- **visual-explainer** — інтерактивні HTML-артефакти (plan, diagrams, recap)
- **claude-hud / ccstatusline** — statusline з метриками
- **revdiff** — інтерактивне code review в терміналі (TUI overlay)
- **slidev** — створення презентацій 😉
- **caveman** — ультра-стислий режим (×75% економії токенів на діалозі)
- **mytets** — режим Подерв'янського 🎭

</v-clicks>

</div>

</div>

<v-click>

```bash
/plugin install github@claude-plugins-official    # Офіційний маркетплейс
/plugin marketplace add owner/repo                # Спільнотний плагін
```

</v-click>

<!--
Екосистема плагінів ділиться на офіційні від Anthropic та спільнотні. Session-report показує скільки токенів витратили і на що. Skill-creator допомагає створювати власні скіли з евалюаціями. Про superpowers — наступного разу, це окрема велика тема.
-->

---
hideInToc: true
---

# Когнітивний борг — нова реальність 2026

<v-clicks>

**Технічний борг** — позика у майбутніх себе, коли робиш не найкращим шляхом.

**Когнітивний борг** — позика у майбутніх себе, коли **не розумієш що і як було зроблено**.

</v-clicks>

<v-click>

> З агентами ми генеруємо код **швидше**, ніж наша когнітивна система встигає засвоїти структуру, патерни та прийняті рішення.

</v-click>

<v-clicks>

### Як зменшити:
- **ADR наприкінці сесії** — попроси агента сформувати Architecture Decision Record
- **Перевіряй документи** — переконайся що **ти** розумієш, а не лише агент
- **Інструменти осмислення** — далі подивимось плагіни, що допомагають це робити 👇

</v-clicks>

<!--
Технічний борг всі знають. Але у 2026 з'явився новий тип — когнітивний борг. Раніше ми працювали інкрементально, маленькими кроками, і знання про проєкт встигали засвоюватися. Тепер з агентами можна вибухово згенерувати код, навіть інкрементна робота йде швидше. Виникає борг розуміння — повернешся до коду через баг чи розширення і не зрозумієш що було зроблено. ADR наприкінці сесії — один з прийомів. Наступні кілька слайдів — конкретні плагіни, що допомагають тримати борг під контролем: Visual Explainer для відновлення mental-model, Session Report для аналітики, Skill Creator для структурування процесів, Statusline для контролю контексту.
-->

---
hideInToc: true
---

# Visual Explainer — AI генерує інтерактивні HTML

<v-clicks>

### 6 команд, що перетворюють контекст у готовий артефакт

| Команда | Що генерує |
|---|---|
| `/visual-explainer:project-recap` | HTML mental-model поточного проєкту (decisions, hotspots) |
| `/visual-explainer:generate-visual-plan` | Детальний plan: state machines, edge cases, snippets |
| `/visual-explainer:generate-slides` | Magazine-quality slide deck у single HTML |
| `/visual-explainer:generate-web-diagram` | Standalone HTML diagram, відкривається у браузері |
| `/visual-explainer:diff-review` | Before/after architecture + code review як HTML |
| `/visual-explainer:plan-review` | Поточний стан vs запропонований план |
| `/visual-explainer:fact-check` | Верифікує документ проти кодобази, коригує неточності |

### Приклад

```bash
> /visual-explainer:project-recap
# → зберігає recap.html з інтерактивною mental-model'ю
# → collapsible секції, code refs, візуалізація dependencies
```

</v-clicks>

<DocRef url="https://github.com/nicobailon/visual-explainer" label="github.com/nicobailon/visual-explainer" />

<!--
Ось перший інструмент проти когнітивного боргу. Visual Explainer — про виходи, які можна показати людині, щоб вона зрозуміла те, що зробив агент. Project-recap — моя улюблена: відновлює mental-model великого проєкту після відпустки. Коли ревʼюверу треба зрозуміти тиждень роботи — generate-visual-plan або diff-review зробить інтерактивну сторінку з діаграмами, before/after, edge cases. Fact-check перевіряє, чи документ ще відповідає кодобазі, і коригує розходження. Все у HTML, без залежностей — шлеш колезі, відкриває у браузері, розуміє за хвилини замість годин. Встановлення: /plugin marketplace add nicobailon/visual-explainer.
-->

---
hideInToc: true
---

# Session Report — аналітика ваших сесій

<v-clicks>

### HTML-звіт із `~/.claude/projects/<project>/sessions/`

```bash
/session-report:session-report
# → session-report-YYYYMMDD-HHMM.html
```

### Що в звіті

- **Токени** — input / output / cache read / cache write (відсотки, тренди)
- **Витрати** — cost по моделях, по сесіях, найдорожчі промпти
- **Скіли та субагенти** — які підхоплювались, скільки разів, у яких сесіях
- **Hooks** — скільки разів виконались, fail rate
- **Cache hit rate** — ключова метрика економії, 70-90% на "теплому" проєкті
- **Найдорожчі промпти** — топ-10 повідомлень за токенами + context

### Для кого корисно

- Ліди — аргумент для бюджету ("ми заекономили $X через cache")
- Інженери — знайти патерни, що ламають cache (часті модифікації великих файлів)
- Фінанси — прогноз місячних витрат по команді

</v-clicks>

<DocRef url="https://github.com/anthropics/claude-code-plugins" label="github.com/anthropics/claude-code-plugins" />

<!--
Session Report парсить транскрипти ваших сесій і робить HTML-звіт. Метрики все, що важить: токени по категоріях — дуже важливий cache read/write, бо саме кеш економить гроші. Витрати: по моделях (Opus vs Sonnet), по сесіях — знайти, куди пішли основні кошти. Які скіли та субагенти підхопилися автоматично, чи спрацювали хуки. Топ-10 найдорожчих промптів — якщо бачите там однотипні задачі, це сигнал винести в скіл. Я користуюся раз на тиждень: зрозуміти, де гроші пішли, і куди спланувати оптимізацію. На сусідньому слайді покажу session-report з моєї сьогоднішньої сесії.
-->

---
hideInToc: true
---

# Skill Creator — скіли з **benchmarks** та **evals**

<v-clicks>

### Не просто генератор — evaluator

```bash
/skill-creator:skill-creator
# → інтерактивний flow: опис → сгенерувати SKILL.md → запустити evals
```

### Функції

- **Create** — сгенерувати SKILL.md із опису задачі
- **Optimize description** — покращити trigger accuracy (щоб Claude сам вмикав скіл коли треба)
- **Run evals** — запустити тест-кейси проти скіла
- **Benchmark** — кілька прогонів з variance analysis (щоб не було false positives)
- **Compare versions** — A/B старої та нової версії SKILL.md

### Чому це круто

> Скіл, якого Claude **не вмикає**, коли треба — **марний**. Description — найважливіша частина.
> Skill Creator перевіряє trigger accuracy на наборі prompt-ів, що імітують реальних користувачів.

</v-clicks>

<DocRef url="https://github.com/anthropics/claude-code-plugins" label="github.com/anthropics/claude-code-plugins" />

<!--
Skill Creator — це не просто "згенеруй markdown". Це інструмент розробника скілів з метриками. Головна проблема скілів — trigger accuracy. Ви пишете description, а Claude його не підхоплює, коли треба, або підхоплює, коли не треба. Skill Creator прогоняє набір тестових prompts через вашу description і каже: у 80% випадків скіл активується, коли потрібно, і в 5% — коли не потрібно. Далі ви tweak-аєте description, запускаєте benchmark ще раз, порівнюєте версії. Variance analysis — кілька прогонів, щоб виключити випадковість. Якщо робите скіли для команди — must-have.
-->

---
hideInToc: true
---

# Statusline — Інформація на виду

<div class="grid grid-cols-2 gap-6">

<v-click>

### 📊 ccstatusline

**Кастомізований форматер** рядка стану

- **40+ віджетів** (Git, токени, таймер, директорія...)
- Powerline стиль зі стрілками-розділювачами
- Багаторядкова конфігурація
- Інтерактивний **TUI** для налаштування

```bash
npx ccstatusline@latest
```

</v-click>

<v-click>

### 🖥️ Claude HUD

**Контекст сесії** в реальному часі

- Візуальний **рядок контексту** (наскільки заповнений)
- Активні інструменти та субагенти
- Прогрес завдань
- 3 пресети: Full / Essential / Minimal

```bash
/plugin marketplace add jarrodwatts/claude-hud
/claude-hud:setup
```

</v-click>

</div>

<v-click>

> Обидва працюють через `settings.json` → `"statusLine"` — обирайте за стилем!

</v-click>

<DocRef url="https://code.claude.com/docs/en/status-line" label="code.claude.com/docs/en/status-line" />

<!--
Два підходи до statusline. ccstatusline — максимальна кастомізація через TUI, 40+ віджетів, Powerline стиль. Claude HUD — фокус на контексті сесії: скільки контексту залишилось, що зараз робить агент. Обирайте що більше підходить вашому workflow.
-->

---
hideInToc: true
---

# RevDiff — Код-рев'ю без виходу з терміналу

<v-clicks>

Переглядай діфи, файли та документи **прямо в терміналі** — не перемикаючись в IDE.

### Workflow:
```
Навігація (vim-style) → Анотація рядків → Вихід → Claude отримує структуровані нотатки
```

### Можливості:
- Syntax-highlighted діфи з blame gutter
- Inline анотації на будь-якому рядку
- Git branch порівняння: `/revdiff main`, `/revdiff HEAD~3`
- Overlay в tmux, kitty, wezterm, ghostty, iTerm2
- **7 кольорових тем** з live preview

### Установка:
```bash
/plugin marketplace add umputun/revdiff
# Використання:
/revdiff              # Uncommitted changes
/revdiff main         # Diff з main
/revdiff --staged     # Тільки staged
```

</v-clicks>

<DocRef url="https://revdiff.com" label="revdiff.com" />

<!--
RevDiff — це code review прямо в терміналі. Не треба перемикатися в IDE. Навігація vim-style, анотуєш рядки, виходиш — і Claude автоматично отримує твої нотатки у структурованому форматі. Реально пришвидшує review workflow.
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

# Приклади Hooks — з реального проєкту

### PostToolUse — автоформат PHP після кожної зміни:

```json
{
  "PostToolUse": [{
    "matcher": "Edit|Write",
    "hooks": [{
      "type": "command",
      "command": "php-cs-fixer fix --quiet",
      "timeout": 15000
    }]
  }]
}
```

<v-click>

### PreToolUse — блокування auto-generated файлів:

```json
{
  "PreToolUse": [{
    "matcher": "Edit|Write",
    "hooks": [{
      "type": "command",
      "command": "# Блокує: generated API client, міграції, .env.local"
    }]
  }, {
    "matcher": "Read",
    "hooks": [{
      "type": "command",
      "command": "# Блокує: .env.local (credentials)"
    }]
  }]
}
```

</v-click>

<v-click>

> **Навіщо?** Міграції — тільки через `doctrine:migrations:diff`. API client — тільки через Orval. Credentials — ніколи.

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks-guide" label="code.claude.com/docs/en/hooks-guide" />

<!--
Реальні hooks з нашого проєкту. PostToolUse запускає php-cs-fixer після кожної зміни — код завжди відформатований. PreToolUse блокує файли які не можна міняти вручну: згенерований API клієнт, міграції, credentials. Це не абстрактні приклади — це те що ми використовуємо щодня.
-->

---
hideInToc: true
---

# `git-safety.sh` — hook, що рятує від катастроф

<v-clicks>

### Що блокує (PreToolUse на Bash)

- `git push --force` / `-f` на **protected гілки** (main, master, dev, staging, prod)
- `git reset --hard` — може знищити незакомічені зміни
- `git clean -f` — незворотне видалення untracked файлів
- `git branch -D <protected>` — видалення захищеної гілки

### Як виглядає блок

```bash
Claude: git push --force origin main
Hook:   🛑 BLOCKED: force-push to protected branch.
        Use a regular push or ask the user explicitly.
```

### Як це працює

```bash
# .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "~/.claude/hooks/git-safety.sh" }]
    }]
  }
}
```

Hook повертає JSON з `permissionDecision: "block"` + `permissionDecisionReason` — Claude не виконає команду і покаже причину.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com/docs/en/hooks" />

<!--
Чому цей hook критичний — Claude іноді надто впевнений у собі на destructive операціях. git push --force, reset --hard, clean -f — усе це може за секунду знищити роботу. git-safety перехоплює ці команди на PreToolUse, перевіряє гілку через regex, і блокує з зрозумілим поясненням. Claude бачить reason і або переформулює (regular push замість force), або явно питає вас. Це рядовий шаблон для будь-якої команди: напишіть hook, який перевіряє небезпечні патерни і блокує їх за дефолтом. Власний скрипт — кілька десятків рядків bash + jq, повністю під вашим контролем.
-->

---
layout: section
---

# RTK — Hooks в дії

---

# RTK — Rust Token Killer

<v-clicks>

**RTK** — CLI-проксі, що економить **60-90% токенів** на операціях розробки.

### Проблема:
Claude Code витрачає багато токенів на виводи команд (`git status`, `ls`, `npm test`...)

### Рішення:
RTK перехоплює команди через **hook** і фільтрує непотрібний output.

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
RTK — must have для будь-кого хто використовує Claude Code щодня. Це реальний приклад hooks у дії — PreToolUse hook перехоплює Bash-команди і підміняє на rtk-версії. 60-90% економії токенів.
-->

---
hideInToc: true
---

# RTK — Hook під капотом

<v-clicks>

### Це просто PreToolUse hook:
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
RTK працює через PreToolUse hook — повністю прозоро. Ви нічого не міняєте у workflow, а токени економляться автоматично. rtk gain показує скільки ви заощадили. Це ідеальний приклад потужності hook-системи.
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

# Кастомні агенти — з реального проєкту

<v-click>

### Три агенти для паралельного рев'ю:

```
.claude/agents/
├── code-reviewer.md       # Якість коду, патерни, N+1
├── security-reviewer.md   # Auth, платежі, SQL injection
└── migration-reviewer.md  # Повнота міграції з legacy
```

</v-click>

<v-click>

### Запуск всіх трьох паралельно:

```bash
/run-reviews          # Кастомна команда
# → Аналізує зміни на бранчі
# → Розподіляє файли між агентами
# → Запускає 3 агенти паралельно
# → Збирає результати в таблицю
```

</v-click>

<v-click>

### migration-reviewer — порівнює з legacy:

```markdown
---
model: claude-sonnet-4-6
---
Порівняй з legacy кодом в /projects/ziprent/:
- @legacy анотації покривають весь старий код?
- Бізнес-логіка повністю перенесена?
- Строкові ідентифікатори збережені?
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/sub-agents" label="code.claude.com/docs/en/sub-agents" />

<!--
Реальний приклад — три спеціалізовані агенти. Code-reviewer перевіряє патерни та N+1 запити. Security-reviewer — авторизацію, платежі, input validation. Migration-reviewer порівнює з legacy Laravel кодом. Команда /run-reviews запускає всіх трьох паралельно і збирає результати.
-->

---
hideInToc: true
---

# Dotfiles — `~/.claude/` для всієї команди

<v-clicks>

### Проблема

`~/.claude/` містить: `settings.json`, `agents/`, `commands/`, `skills/`, `CLAUDE.md`. Новий інженер заходить у команду — і все це треба відтворити.

### Рішення — dotfiles менеджер

```bash
# chezmoi — популярний, cross-platform
chezmoi add ~/.claude/settings.json
chezmoi add ~/.claude/agents/code-reviewer.md
chezmoi cd && git push

# На новій машині:
chezmoi init --apply git@github.com:team/dotfiles.git
```

### Що тримати в команді (через git)

| Файл | Де | Хто оновлює |
|---|---|---|
| `~/.claude/settings.json` | dotfiles | особисті tweaks |
| `~/.claude/agents/*.md` | **dotfiles команди** | team leads |
| `.claude/agents/*.md` | **репо проєкту** | команда (в git) |
| `.claude/commands/*.md` | **репо проєкту** | команда (в git) |
| `.claude/skills/*/SKILL.md` | **репо проєкту** | команда (в git) |

</v-clicks>

<!--
Коли ваш setup розростається — агенти, скіли, нетривіальні settings — ви хочете, щоб новачок у команді не починав з нуля. Тепер ви вже знаєте що живе в ~/.claude/: settings, agents, commands, skills, CLAUDE.md. Два рівні шарингу. Проектний рівень — все що в .claude/ всередині репо — автоматично комітиться і всі отримують. Персональний рівень — ~/.claude/ — треба керувати через dotfiles менеджер. chezmoi найпопулярніший, але yadm або stow теж підходять. Команда може тримати shared-dotfiles репо з базовими агентами на кшталт code-reviewer, migration-reviewer, які хочеться мати всім, але персональні налаштування кожен допилює локально.
-->

---
layout: section
---

# Плани та ціни

---

# Claude Code — Плани

| План | Ціна | Claude Code | Ліміти |
|---|---|---|---|
| **Free** | $0 | Обмежений | Мінімум |
| **Pro** | $20/міс | ✅ Повний | ~45 msg / 5 год |
| **Max 5x** | $100/міс | ✅ Повний | 5× більше за Pro |
| **Max 20x** | $200/міс | ✅ Повний | 20× більше за Pro |
| **Team** | $25/user/міс | ✅ + SSO, адмін | Як Pro на кожного |
| **Enterprise** | Custom | ✅ + SCIM, audit | Custom |

<v-click>

### Наш вибір: Team ($25/user)

- SSO та централізоване управління
- Зараз — базовий план за **~$20-25/user**
- Якщо ростемо в цьому напрямку і клієнт погодить — переходимо на **Max $100/user** для 5× більше лімітів

</v-click>

<v-click>

> 💡 **Pro $20** — ідеально для старту. **Max $100** — коли Claude стає основним інструментом розробки.

</v-click>

<DocRef url="https://www.anthropic.com/pricing" label="anthropic.com/pricing" />

<!--
Важливо розуміти ціноутворення. Pro за 20 долларів — це вхідний квиток, достатньо щоб спробувати. Max за 100 — це для тих, хто активно працює з Claude щодня і впирається в ліміти. Ми обрали Team підписку — SSO, централізоване управління. Поки що базовий план, але якщо будемо рости і клієнт погодить, перейдемо на Max для більших лімітів.
-->

---
layout: section
---

# Просунуті можливості

---
hideInToc: true
---

# Git інтеграція — `/commit`, `/pr`, worktree

<v-clicks>

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

### Формат коміту

```text
feat: add user authentication

Implement JWT-based auth with refresh tokens.
Includes middleware, tests, and migration.

Co-Authored-By: Claude ...
```

### Extended thinking у сесії

- `Option+T` / `Alt+T` — toggle thinking на поточному повідомленні
- "ultrathink" у тексті промпту — разове поглиблення reasoning

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/common-workflows" label="code.claude.com/docs/en/common-workflows" />

<!--
/commit аналізує staged зміни і пише conventional-style повідомлення. /pr create відкриває PR через gh і теж генерує опис. Worktree-флаг створює ізольовану робочу копію в окремій директорії — зручно для паралельних фіч. --from-pr підтягує контекст відкритого PR. Attribution (Co-Authored-By у коміті) вимикається через settings.json.
-->



---
hideInToc: true
---

# Claude in Chrome — Браузерний агент

<v-clicks>

### Установка:
```
Chrome Web Store → "Claude" → Add to Chrome → Sign in
```

### Можливості:
- **Live debugging** — читає console errors, DOM стан → фіксить код
- **Дизайн верифікація** — Figma макет → код → порівняння в браузері
- **Автоматизація** — навігація, кліки, заповнення форм, витяг даних
- **Multi-tab** — перетягни таби в групу Claude для паралельної роботи
- **Заплановані задачі** — щоденні, щотижневі browser tasks

### Активація:
```bash
claude --chrome     # З CLI
/chrome             # В сесії — увімкнути / підключити
```

> ⚠️ Beta: Chrome / Edge · Потрібен Pro/Max/Team план

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/chrome" label="code.claude.com/docs/en/chrome" />

<!--
Chrome extension — це повноцінний браузерний агент. Claude бачить що у вас в браузері, може клікати, заповнювати форми, читати console.log. Працює з вашими логінами — не треба окремої авторизації на сайтах.
-->

---
hideInToc: true
---

# Vision та CI/CD

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

<DocRef url="https://code.claude.com/docs/en/github-actions" label="code.claude.com/docs/en/github-actions" />

<!--
Vision дозволяє Claude бачити скріншоти та макети. CI/CD — Claude як частина вашого pipeline. GitHub Actions та GitLab CI — автоматичний код-рев'ю та тестування на кожен PR.
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

# Де вчитися далі

<div class="grid grid-cols-2 gap-6">
<div>

### Офіційні курси Anthropic

🎓 **Claude Code in Action** — практичний курс від команди Anthropic
[anthropic.skilljar.com](https://anthropic.skilljar.com/claude-code-in-action)

📚 **Anthropic Learn** — хаб усіх курсів: промпт-інжиніринг, API, Claude Code
[anthropic.com/learn](https://www.anthropic.com/learn)

</div>
<div>

### Безкоштовні курси

🆓 **DeepLearning.AI** — короткі курси від Andrew Ng у партнерстві з Anthropic
[learn.deeplearning.ai](https://learn.deeplearning.ai/)

<div class="mt-6 text-sm opacity-70">
Шукайте курси <code>Claude</code>, <code>MCP</code>, <code>Agentic AI</code> — оновлюються кожні кілька місяців.
</div>

</div>
</div>

<!--
Anthropic має безкоштовний курс Claude Code in Action — рекомендую пройти після цієї презентації, там глибше розбирають workflow. На anthropic.com/learn — хаб усіх навчальних матеріалів. DeepLearning.AI тримає короткі безкоштовні курси від Andrew Ng — там є окремі модулі по MCP та агентному AI.
-->

---
layout: section
---

# Про що поговоримо наступного разу

---
hideInToc: true
---

# Наступного разу

<div class="grid grid-cols-2 gap-6 mt-6">
<div>

<v-clicks>

### 🦸 Superpowers — senior-процес у плагіні

- **brainstorming** — обовʼязкове перед кожною фічею
- **writing-plans / executing-plans** — структурований план + checkpoints
- **test-driven-development** — tест → fail → код → pass
- **systematic-debugging** — verify → isolate → hypothesize
- **subagent-driven-development** — паралельні незалежні таски
- **verification-before-completion** — "готово" лише з evidence

</v-clicks>

</div>
<div>

<v-clicks>

### 🦣 Caveman — ультра-стиснутий режим

- −75% токенів на діалозі, без втрати технічного сенсу
- Рівні: `lite` / `full` / `ultra` + wenyan-варіанти
- Code, commits, security — пишуться як є
- `/caveman:compress` — стиснення CLAUDE.md і memory-файлів
- `/caveman-commit`, `/caveman-review` — стислі commit-и та PR review

</v-clicks>

</div>
</div>

<v-click>

<div class="mt-8 text-center text-lg opacity-80">
Плюс: власні skills, hooks-рецепти, MCP-сервери продакшн-рівня, subagent-оркестрація.
</div>

</v-click>

<DocRef url="https://github.com/obra/superpowers" label="github.com/obra/superpowers" />
<DocRef url="https://github.com/jwalsh/caveman" label="github.com/jwalsh/caveman" :offset="1" />

<!--
Superpowers заслуговує окремої лекції — це не просто "ще один плагін", а цілий senior-процес у 20+ скілах: brainstorming перед кожною фічею, структуровані плани з checkpoints, TDD як стиль життя, систематичний debug замість гадань, subagent-driven development для паралельних задач. Jesse Vincent (ex-Anthropic) зробив те, чого не вистачало дефолтному Claude — дисципліну. Caveman — інший підхід: економія токенів ×75% за рахунок стислої мови без втрати технічної точності. Є режими під різну інтенсивність, є окремі команди для commit-ів, review, стиснення memory-файлів. Обидва плагіни разом — це вже не "помічник", а інженерний партнер з власним процесом. Поговоримо детально наступного разу — з практикою, прикладами реальних workflow, міряннями економії.
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
