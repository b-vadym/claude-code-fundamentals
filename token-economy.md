---
theme: seriph
background: https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=1920
title: "Claude Code: Економіка токенів"
info: |
  ## Claude Code: Економіка токенів
  Як зекономити токени та поміститися в $20 Pro
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Claude Code: Економіка токенів

Як зекономити токени та поміститися в $20 Pro

<!--
Продовження презентації про Claude Code. Минулого разу проходили фундамент — установка, конфіги, MCP, скіли, плагіни, hooks. Сьогодні вузька, але болюча тема: як витрачати менше токенів. Бо коли ти починаєш активно користуватись, питання "скільки це коштує" стає реальним.
-->

---
transition: fade-out
---

# Про що сьогодні

<v-clicks>

- **Setup** — скріншоти у Claude Code + tmux для revdiff
- **Де ідуть токени** — анатомія сесії, startup 20%, діагностика
- **Контекст — головний бюджет** — CLAUDE.md, skills, `/clear`/`/compact`/`/rewind`, subagents
- **Prompt caching** — головний монетний важіль (92% економії)
- **Модель і effort** — Opus / Sonnet / Haiku, тонкощі Opus 4.7
- **Output-side** — plan mode, hooks, LSP, RTK
- **Checklist** — аудит власного setup-у

</v-clicks>

<!--
Шість секцій. Перші дві — як НЕ спалювати токени надаремно. Третя — як платити 10x менше за ті самі токени. Четверта — як вибрати модель під задачу. П'ята — як обрізати вхід у context до того, як він туди потрапить. Шоста — checklist для самоперевірки.
-->

---
layout: section
---

# Спершу — setup

---
hideInToc: true
---

# Вставка скріншотів у Claude Code (Ubuntu)

<div class="grid grid-cols-2 gap-6 text-sm">
<div>

### Clipboard-утиліта

```bash
# визначити сесію
echo $XDG_SESSION_TYPE

# Wayland
sudo apt install wl-clipboard

# X11
sudo apt install xclip
```

Перевірка — скріншот у буфер (Flameshot: виділити → `Ctrl+C`):

```bash
wl-paste --list-types    # має містити image/png
# або
xclip -selection clipboard -t TARGETS -o
```

</div>
<div>

### `~/.tmux.conf`

```bash
set -g allow-passthrough on
set -g set-clipboard on
```

Перезавантажити: `tmux source ~/.tmux.conf`

**Чому**:
- `allow-passthrough` — ескейп-послідовності OSC clipboard проходять через tmux
- `set-clipboard` — синхронізація tmux-буферу з системним

Без них бінарні дані скріншотів рвуться у tmux.

**Fallback**: drag-and-drop файлу у термінал або `@шлях/до/file.png`.

</div>
</div>

<DocRef url="https://man.openbsd.org/OpenBSD-current/man1/tmux.1#allow-passthrough" label="tmux — allow-passthrough" />

<!--
Якщо працюєш у tmux на Ubuntu — Ctrl+V часто рве скріншоти. Причина: tmux за замовчуванням не пропускає OSC-послідовності clipboard. Два рядки у tmux.conf вирішують. На Wayland — wl-clipboard, на X11 — xclip. Перевірка що clipboard містить image/png — wl-paste --list-types або xclip -t TARGETS. Якщо там тільки text/plain — проблема у screenshot-тулі, не в terminal. Flameshot кладе image/png після Ctrl+C у виділенні. Fallback — якщо clipboard не заведеться: drag-and-drop файлу у вікно термінала (шлях вставляється), або @path/to/file.png — Claude Code читає файл напряму з автокомплітом.
-->

---
hideInToc: true
---

# Tmux для revdiff і TUI-агентів

```bash
# truecolor — syntax highlight у diff
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

# mouse scroll у diff viewport
set -g mouse on

# Esc / n / N не залипають у Vim-style navigation
set -sg escape-time 10

# для скріншотів (з попереднього слайду)
set -g allow-passthrough on
set -g set-clipboard on
```

<v-clicks>

- **tmux ≥ 3.2** для `display-popup` (revdiff запускає popup всередині сесії). Ubuntu 22.04+ OK, 20.04 — треба PPA.
- revdiff auto-detect через `$TMUX` — жодних додаткових env не треба.
- `COLORTERM=truecolor` у зовнішньому терміналі (Ghostty/Alacritty/Kitty) — 24-bit пробрасується в tmux через `terminal-overrides`.
- Цей самий конфіг підходить для Codex, OpenCode, Zellij-aware TUI.

</v-clicks>

<DocRef url="https://github.com/umputun/revdiff" label="github.com/umputun/revdiff" />

<!--
Якщо плануєш юзати revdiff для in-terminal code review — tmux має бути 3.2+ (для display-popup). На Ubuntu 22.04 з коробки 3.2a, 24.04 — 3.4. На 20.04 — стара 3.0a, треба оновити з PPA або зібрати з source. Три ключові налаштування для якісного UX: truecolor (синтаксис-highlight у diff), mouse (скрол у viewport), escape-time 10 (інакше Vim-style n/N навігація залипає). revdiff сам детектить tmux через $TMUX, нічого додатково не треба. COLORTERM=truecolor — експортити у зовнішньому терміналі (Ghostty у моєму випадку), тоді кольори пробросяться у tmux через terminal-overrides. Цей же конфіг працює для інших TUI-агентів: Codex, OpenCode, Zellij.
-->

---
layout: section
---

# Де ідуть токени

---
hideInToc: true
---

# Анатомія сесії: baseline перед першим prompt-ом

Claude Code автоматично завантажує **при кожному старті**:

- **System prompt** — ядро поведінки
- **System tools** — built-in tool definitions
- **CLAUDE.md** — повністю, з усіх рівнів (home, project, subdirs)
- **Auto memory** (`MEMORY.md`) — перші 200 рядків або 25KB
- **Skill descriptions** — body on-demand, description завжди
- **Custom agents** / **MCP tool names**

Розмір baseline залежить від твого setup-у. Жодної "магічної цифри" — виміряй `/context`.

<DocRef url="https://code.claude.com/docs/en/context-window" label="code.claude.com/docs — Context window" />

<!--
Перша свята істина економії: починати з вимірювання. Claude Code кожну сесію платить "абонемент" за startup — system prompt, CLAUDE.md, скіли, tools. Розмір абонементу у тебе СВІЙ — залежить від плагінів, CLAUDE.md розміру, кількості скілів, MCP серверів. Не вгадуй, не копіюй чиїсь цифри. Запусти /context і побач свій baseline. На наступному слайді покажу що я бачу в своїй сесії, як reference.
-->

---
hideInToc: true
---

# Приклад: `/context` у моїй сесії

Opus 4.7 (1M context), активна сесія з deck-контентом + agents + skills:

```text
Context Usage: 210.8k / 1M (21%)

System prompt:   8.8k  (0.9%)
System tools:   14.9k  (1.5%)
Custom agents:  740    (0.1%)
Memory files:   1.3k   (0.1%)
Skills:         3.7k   (0.4%)
Messages:       191.1k (19.1%)  ← розмова
Free space:     746.5k (74.6%)
Autocompact:    33k    (3.3%)
```

**Baseline (без Messages): ~29k tokens ≈ 3% від 1M або 15% від 200k default context**.

Твій baseline залежить від розміру CLAUDE.md, кількості скілів, MCP серверів.

<DocRef url="https://code.claude.com/docs/en/context-window" label="code.claude.com/docs — Context window" />

<!--
Це реальний знімок мого /context прямо зараз у цій робочій сесії. Зверни увагу: більшість (19%) — це Messages, наша з Claude розмова. А startup-baseline — всього 3% на Opus 1M. Якби я був на 200k контексті — baseline був би ~15%. Саме тому коротка CLAUDE.md і обрані скіли так важливі для 200k контекстів: кожен токен startup — це 5x більша частка. На 1M стележ менш строгий, але принципи ті самі. Мораль: знай СВОЇ цифри. Наступним слайдом подивимось таблицю що саме чим контролюється.
-->

---
hideInToc: true
---

# Що auto-loadєся — таблиця

| Джерело | Завантажується | Контролюється |
|---------|----------------|---------------|
| System prompt | Повністю | — (built-in) |
| CLAUDE.md (всі рівні) | Повністю | розмір файлу, `claudeMdExcludes` |
| Auto memory `MEMORY.md` | Перші 200 рядків або 25KB | `autoMemoryEnabled: false` |
| `.claude/rules/*.md` | Без `paths:` — всі. З `paths:` — тільки matching | `paths:` у frontmatter |
| Skill descriptions | Так (body on-demand) | `disable-model-invocation: true` |
| MCP tool schemas | Deferred (імена тільки) | `ENABLE_TOOL_SEARCH=auto/false` |

Важливо: **body скілу грузиться тільки коли він викликаний** — це ключова перевага скілів над CLAUDE.md.

<DocRef url="https://code.claude.com/docs/en/memory" label="code.claude.com/docs — Memory" :offset="1" />
<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com/docs — Skills" />

<!--
Ось головна таблиця для розуміння. Що з лівого стовпця ти можеш зменшити — прямий виграш. CLAUDE.md — ти контролюєш розмір. Auto memory — можна вимкнути (я не раджу, вона корисна). Skills — description видно завжди, але body читається тільки при виклику. MCP tools — за замовчуванням deferred, тільки імена в контексті. Це означає: додавання MCP сервера з 20 інструментами не додає 20 схем у контекст — тільки 20 імен. Schemas підтягуються on-demand через tool search.
-->

---
hideInToc: true
---

# Діагностика: як побачити де токени

<v-clicks>

- **`/cost`** — токени/долари поточної сесії (для API). Pro/Max — використовують `/stats`
- **`/stats`** — щоденне використання, історія, streaks, model preferences
- **`/context`** — що саме займає context (головний діагностичний інструмент)
- **`/skills`** — список скілів; `t` сортує за token count
- **Status line** — налаштовується, може показувати context usage **постійно**

```bash
# Приклад /cost
Total cost:            $0.55
Total duration (API):  6m 19.7s
Total duration (wall): 6h 33m 10.2s
Total code changes:    0 lines added, 0 lines removed
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/costs" label="code.claude.com/docs — Manage costs" :offset="1" />
<DocRef url="https://code.claude.com/docs/en/commands" label="code.claude.com/docs — Commands" />

<!--
Без вимірювання — немає економії. Перший інструмент: /context. Запусти його через 20-30 turn-ів і побач, що в тебе там сидить. Часто половина — це accidental reads файлів, які Claude прочитав і забув. /skills з сортуванням за token count — щоб знайти скіл-монстра серед твоїх скілів. Status line — мій улюблений: налаштуй один раз, і цифра контексту завжди перед очима. На docs є секція про Statusline, де можна описати словами — Claude сам згенерує.
-->

---
layout: section
---

# Контекст — головний бюджет

---
hideInToc: true
---

# CLAUDE.md: менший = дешевший

<v-clicks>

- **Цільовий розмір: < 200 рядків** (adherence падає на довших)
- CLAUDE.md завантажується **повністю** на кожну сесію — ціна за кожен рядок × кожна сесія × кожен turn
- CLAUDE.md на project root **виживає `/compact`** — заново ін'єктується після стиснення
- Subdirectory CLAUDE.md — завантажується тільки коли Claude читає файл у тому каталозі
- `CLAUDE.local.md` — personal, додай у `.gitignore`
- `claudeMdExcludes` у `settings.local.json` — пропустити чужі CLAUDE.md у monorepo
- Все що "процедура" (а не факт) → **винести у skill**

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/memory" label="code.claude.com/docs — Memory" />

<!--
Правило 200 рядків — пряма цитата з docs. Над нею — не "не буде працювати", а "adherence падає" — Claude гірше дотримується інструкцій у великому CLAUDE.md. Перевір свій прямо зараз: wc -l CLAUDE.md. Якщо більше 200 — час рефакторити. Все що "коли робиш X, зроби Y, потім Z" — це не факт, це процедура, винеси у skill. У monorepo буває, що вище по дереву лежить CLAUDE.md від іншої команди — claudeMdExcludes у settings.local.json це вирішує.
-->

---
hideInToc: true
---

# Skills: progressive loading замість CLAUDE.md-монстра

<v-clicks>

**Skills економлять токени через progressive loading:**

- На старт сесії: завантажується **тільки description** скілу (+ `when_to_use`)
- Description + when_to_use: cap **1,536 символів** на скіл у listing
- Full body SKILL.md завантажується **тільки при виклику** скілу (тобою або Claude)
- Після `/compact`: recent-invoked скіли re-attachяться, **25k tokens combined budget, 5k per skill**
- `SKILL.md` target: **< 500 рядків** (supporting files — окремо)

Порівняй: CLAUDE.md — 1,000 рядків × завжди vs. Skill — 50-рядкова description + 500-рядковий body on-demand.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com/docs — Skills" />

<!--
Це головна концепція. CLAUDE.md — факти які треба ЗАВЖДИ. Skills — процедури, які треба КОЛИ ПОТРІБНО. Приклад з доповіді fundamentals: у мене був 2000-рядковий CLAUDE.md із деталями git workflow, testing conventions, PR checklist. Виніс їх у три скіли — /commit, /test, /pr. Розмір CLAUDE.md впав до 180 рядків, але вся поведінка збереглася — просто тепер body процедур вантажиться тільки коли викликаю скіл. Кожна сесія економить сотні токенів на кожному turn.
-->

---
hideInToc: true
---

# Path-scoped rules: лише коли релевантно

<v-clicks>

`.claude/rules/*.md` з frontmatter `paths:`:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Development Rules
- All API endpoints must include input validation
- Use the standard error response format
```

- Без `paths:` — завжди в контексті (як CLAUDE.md)
- З `paths:` — вантажиться **тільки коли Claude читає matching файл**
- Підтримує brace expansion: `src/**/*.{ts,tsx}`
- Symlinks підтримуються → shared rules між проектами

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/memory#organize-rules-with-claude-rules-" label="code.claude.com/docs — Memory: rules" />

<!--
Path-scoped rules — недооцінений механізм. Приклад: у тебе monorepo з backend (TypeScript) і mobile (Swift). Якщо правила "використовуй tsconfig strict" завантажуються коли працюєш у mobile — це витрата токенів даремно. Винеси у .claude/rules/typescript.md з paths: "**/*.ts" — тепер це правило з'явиться у контексті ТІЛЬКИ коли Claude відкрив TypeScript-файл. Симлінки дозволяють шерити одні й ті ж rules між кількома репами — один файл шаблон, кілька посилань.
-->

---
hideInToc: true
---

# `/clear` vs `/compact` vs `/rewind`

<v-clicks>

- **`/clear`** — почати з нуля. Stale context = витрати на кожен turn. Використовуй між незв'язаними задачами.
- **`/rename` → `/clear` → `/resume`** — зберегти сесію під ім'ям, очистити, повернутись пізніше.
- **`/compact <instruction>`** — ручний summarize з фокусом. Приклад: `/compact Focus on code samples and API usage`.
- **Single Esc** — зупинити Claude mid-response, зберегти контекст (ти просто хочеш його перебити).
- **`/rewind` або double-Esc** — повернутися до checkpoint. 3 опції: (1) restore conversation only, (2) restore code only, (3) restore both. Коли пішло не туди — не продовжуй, відмотай + перепиши prompt.
- **Кастомна інструкція стиснення** у CLAUDE.md:
  ```markdown
  # Compact instructions
  When you are using compact, please focus on test output and code changes.
  ```

**Ранній поріг auto-compaction** через settings.json:

```json
{
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "60"
  }
}
```

Default ~95%. Recommendation 60-75%. Hard cap ~83% (більше не підніме).

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/costs#manage-context-proactively" label="code.claude.com/docs — Manage context" :offset="1" />
<DocRef url="https://github.com/anthropics/claude-code/issues/31806" label="github — CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" />

<!--
Три різні інструменти для трьох різних ситуацій. /clear — коли контекст уже не про твою поточну задачу. Не жалій його, це не "втрачаєш прогрес", це звільняєш бюджет. /compact — коли контекст про твою задачу, але треба звільнити місце. КЛЮЧОВЕ: завжди давай /compact інструкцію, що саме зберегти, інакше він викидає важливі деталі. /rewind — коли помилився. Не продовжуй на поганому фундаменті — кожен наступний turn закріплює помилку. Відмотай і перепиши prompt.
-->

---
hideInToc: true
---

# `/btw` — запитати не засмічуючи контекст

<v-clicks>

`/btw` ("by the way") — **ephemeral** query:

- Spawn-ить тимчасовий read-only agent
- Має повну видимість поточної розмови
- **Не додає у головну історію** — зникає після закриття
- Reuse батьківський **prompt cache** → мінімальна додаткова ціна

Коли юзати:
- "поясни що тут відбувається" під час роботи
- "а як би це написати на Rust"
- будь-яке питання до Claude, яке **не повинно стати частиною майбутнього контексту**

Альтернативи:
- `/btw` — запитати про **те що Claude вже знає** (у цьому контексті)
- `subagent` — піти **шукати щось нове**

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/commands" label="code.claude.com/docs — Commands" />

<!--
Недооцінена команда. Раніше якщо ти хотів щось спитати під час роботи — це повідомлення потрапляло у контекст і жило там до кінця сесії. Кожний наступний turn платив за токени цього side-питання. /btw створює ефемерний фокусований query — Claude відповідає, використовуючи твій контекст, але відповідь не зберігається в історію. Корисно для швидких "а що це", "а як би", "а чому". Ключова різниця від subagent: /btw для того що Claude ВЖЕ ЗНАЄ у контексті; subagent — для того що ТРЕБА ПІТИ ДОСЛІДИТИ.
-->

---
hideInToc: true
---

# Auto-compaction: що виживає, що ні

<v-clicks>

Коли контекст приблизно заповнений, **Claude Code автоматично** стискає conversation history.

**Виживає**:
- Project-root CLAUDE.md (re-injected з диска)
- Recent-invoked skills (25k combined budget, **5k per skill**, last N)
- Summary попередньої частини розмови

**Не виживає**:
- Nested CLAUDE.md (перезавантажуються коли Claude знову читає subdir)
- Повні tool outputs (summarize-нуті)
- Старі skill-invocations (викинуті першими якщо багато виклиав)

**Висновок**: краще **свідомо `/compact`** із focus instruction, ніж чекати auto.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/context-window" label="code.claude.com/docs — Context window" :offset="1" />
<DocRef url="https://code.claude.com/docs/en/skills#skill-content-lifecycle" label="code.claude.com/docs — Skill lifecycle" />

<!--
Auto-compaction — це safety net, не перевага. Так, воно рятує сесію від exhaust, але губить деталі. Керована компакція завжди краще. Два нюанси, про які люди не знають. Перший: після компакції Claude РЕ-ІНЖЕКТУЄ CLAUDE.md з диска. Тобто якщо ти редагував CLAUDE.md посеред сесії — зміни підхопляться після компакції, не раніше. Другий: старі скіли викидаються з budget 25k first-in-first-out. Якщо ти активно юзаєш 10 скілів у сесії, після компакції частина з них "зникне" з контексту. Рішення — re-invoke скіл, якщо бачиш що Claude перестав його застосовувати.
-->

---
hideInToc: true
---

# Subagents: ізоляція verbose operations

<v-clicks>

**Проблема**: Claude читає 10k-рядковий лог → половина контексту спалена на текст, який більше не потрібен.

**Рішення**: делегуй subagent-у.

- Subagent працює у **власному** context window
- Повертає **лише summary** у main conversation
- Модель можна override-нути: `model: haiku` для simple tasks (**5x дешевше** за Opus)
- Built-in типи: `Explore`, `Plan`, `general-purpose`
- Custom subagents: `.claude/agents/*.md`

**Use cases**: дослідження кодбази, fetching docs, обробка логів, прогін тестів з великим виводом.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/sub-agents" label="code.claude.com/docs — Subagents" />

<!--
Subagent — це окремий Claude зі своїм контекстом. Коли ти кажеш "дослідити кодбазу і знайти де викликається функція foo", у main conversation повертається лише summary з файлами і рядками, а не сотні KB grep-виводу та прочитаних файлів. Плюс — можна вказати дешевшу модель. Для пошуку по грепу не потрібен Opus, Haiku справляється відмінно. На docs є Explore агент — built-in, оптимізований саме для read-only exploration. Використовуй для будь-якої задачі "піди подивись що там" — не треба main conversation брудити.
-->

---
hideInToc: true
---

# Agent teams: обережно, ×7 токенів

<v-clicks>

Agent teams — це **кілька Claude Code інстансів паралельно**. Кожен teammate має **свій context window**.

**Ціна**:
- У plan mode: **~7× більше токенів** ніж стандартна сесія
- Кожен teammate окремо завантажує CLAUDE.md, MCP servers, skills
- Idle teammates продовжують споживати токени

**Поради з docs**:
- Sonnet для teammates (баланс ціна/капабіліті)
- Тримай команди малими (token usage лінійно пропорційний)
- Spawn prompts — фокусовані
- Cleanup коли робота завершена
- Feature-flag за замовчуванням: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/costs#agent-team-token-costs" label="code.claude.com/docs — Agent team costs" />

<!--
Сюрприз для багатьох: agent teams — це потужно, але дорого. 7x — не перебільшення, це з docs. Чому 7 а не 2-3? Бо кожен teammate окремо "оплачує startup" (CLAUDE.md, skills desc, MCP tool names — повторно), і в plan mode кожен думає "расширено". Якщо в тебе 5 teammates — це 5 паралельних сесій, кожна зі своїм 20% startup. Plan mode зверху додає thinking tokens. Підсумок: не запускай agent teams для простих задач. Для 80% роботи — subagent достатньо.
-->

---
layout: section
---

# Prompt caching: головний важіль

---
hideInToc: true
---

# Як працює prompt caching

<v-clicks>

- Prefix промпту **кешується** після першого запиту
- Наступні запити з тим самим prefix → **cache hit** замість повторної обробки
- Ієрархія кешування: **`tools` → `system` → `messages`**
- Зміна на рівні N **інвалідує N і все нижче**
- До **4 cache breakpoints** на запит

**Cache-able**: tool definitions, system messages, text messages (user/assistant), images, tool results.

**Not cache-able**: thinking blocks, empty text blocks, citations.

</v-clicks>

<DocRef url="https://platform.claude.com/docs/en/build-with-claude/prompt-caching" label="platform.claude.com/docs — Prompt caching" />

<!--
Ключова механіка: cache — це зафіксований prefix. Якщо перші 50k токенів твоїх промптів ідентичні — вони кешуються. Далі кожен наступний запит "докидає" 50-200 нових токенів замість повторного надсилання 50k. Ієрархія важлива: якщо ти змінюєш system prompt — інвалідуються і повідомлення. Якщо змінюєш tools — інвалідується ВСЕ. Практичний висновок: тримай tools та system стабільними протягом сесії.
-->

---
hideInToc: true
---

# Математика: 92% економії

Приклад для Claude Opus 4.7 ($5 input / $25 output per 1M токенів):

| Операція | Ціна (per 1M tokens) | Множник |
|----------|---------------------|---------|
| Base input | **$5** | 1.0× |
| Cache write (5m) | $6.25 | 1.25× |
| Cache write (1h) | $10 | 2.0× |
| **Cache hit / refresh** | **$0.50** | **0.1×** |
| Output | $25 | — |

**Для 100k-токенного cached prefix:**
- Перший запит: 100,000 × $6.25 = **$0.625** (write at 1.25×)
- Наступні в межах TTL: 100,000 × $0.50 = **$0.05** (read at 0.1×)
- **Економія на повторному turn: 92%**

<DocRef url="https://platform.claude.com/docs/en/build-with-claude/prompt-caching" label="platform.claude.com/docs — Prompt caching" />

<!--
Ось головна цифра. 0.1× — кеш-рід у 10 разів дешевший за звичайний input. 92% економії на КОЖНОМУ наступному turn у сесії. Це не "в ідеальних умовах" — це стандартна поведінка, якщо ти тримаєш prefix стабільним. І це причина, чому CLAUDE.md розміром стабільно корисний: він стає частиною cache prefix. Якщо його не чіпати протягом сесії — його токени сплачуються дешево на 10x.
-->

---
hideInToc: true
---

# Коли кеш інвалідується

<v-clicks>

Інвалідує prefix-cache (ціна — повторний write at 1.25×):

- Редагував `CLAUDE.md` посеред сесії
- Додав/забрав MCP-сервер
- Додав/вимкнув скіл
- Змінив system prompt
- Додав новий tool

Інвалідує **частково** (останнє повідомлення):
- Стандартна природна розмова (новий user turn — завжди append)

**Правило**: у великих сесіях тримай tools + CLAUDE.md стабільними. Якщо треба редагувати — заплануй і зроби одним "push"-ем, не інкрементами через 10 turn-ів.

</v-clicks>

<DocRef url="https://platform.claude.com/docs/en/build-with-claude/prompt-caching" label="platform.claude.com/docs — Prompt caching" />

<!--
Не очевидна пастка: ти відкрив 10-hour Claude Code сесію, попрацював годину, потім вирішив "додам бюджетний скіл". Додав. Наступний turn — full cache write ціною $0.625 (якщо 100k prefix). Ти заплатив повну ціну prefix. Якби ти спершу закінчив задачу, потім створив скіл у новій сесії — економія. Поради: редагуй інфраструктуру сесії НА ПОЧАТКУ або між задачами, не посеред roundtrip-а.
-->

---
hideInToc: true
---

# TTL і мінімуми кешування

<v-clicks>

**TTL опції**:
- **5 хвилин (default, ephemeral)**: write 1.25×, refresh на hit безкоштовний
- **1 година (`ttl: 1h`)**: write 2×, читати за 0.1× (так само)

**Зміна у Claude Code (березень–квітень 2026)**: default TTL тихо скоротили до **5 хвилин** для всіх сесій (раніше частина deployments сиділа на 1h). Офіційного анонсу не було — docs просто оновили. Наслідок: перерва > 5 хв → наступний turn платить **full cache write**. Користувачі репортують помітний зріст витрат.

**Мінімуми cacheable prefix** (менше — кеш не активується):
- Opus 4.7 / 4.6 / 4.5: **4,096 токенів**
- Sonnet 4.6: **2,048 токенів**
- Sonnet 4.5 / 4: 1,024
- Haiku 4.5: **4,096 токенів**

Маленький CLAUDE.md + нуль скілів = можеш не дотягти до мінімуму і **не отримати caching взагалі**.

</v-clicks>

<DocRef url="https://platform.claude.com/docs/en/build-with-claude/prompt-caching#cache-limitations" label="platform.claude.com/docs — Cache limitations" :offset="1" />
<DocRef url="https://github.com/anthropics/claude-code/issues/46829" label="github — Cache TTL regression #46829" />

<!--
Два важливих нюанси. Перший — TTL: за замовчуванням 5 хвилин. Навесні 2026 Anthropic тихо переключив дефолт з 1 години на 5 хвилин — без формального анонсу, просто оновили docs. GitHub issue 46829 на anthropics/claude-code, The Register і XDA писали. Співробітники Anthropic (Boris Cherny, Jarred Sumner) визнали зміну у соц-мережах — дефолт 5m офіційно задекларований, 1h тепер треба явно вказувати через ttl параметр. Наслідок: якщо ти між turn-ами зробив чай-перекур на 10 хвилин — наступний turn платить full write, бо кеш протух. Практично: активні сесії (turn кожні 1-3 хв) не страждають; переривчасті (meeting, чай) — cache bust кожні 5+ хв. У самому Claude Code 1h TTL напряму не exposed — юзай Claude API/SDK якщо треба 1h. Другий нюанс — мінімум 4096 токенів для Opus. Твій CLAUDE.md у 100 рядків може не доповзти до цього порогу, і ти не отримаєш caching взагалі. Іронія: у цьому випадку збільшення CLAUDE.md може здешевити сесію. Правильний шлях — додати скіли з description у prefix.
-->

---
layout: section
---

# Модель і effort

---
hideInToc: true
---

# Ціни моделей 2026

| Модель | Input / 1M | Output / 1M | Коли |
|--------|------------|-------------|------|
| **Opus 4.7** | $5 | $25 | Архітектура, складне reasoning, plan mode |
| Opus 4.6 | $5 | $25 | Те саме + старий tokenizer (дешевше на тексті) |
| **Sonnet 4.6** | $3 | $15 | Default. 1M context window за standard pricing |
| Sonnet 4.5 | $3 | $15 | |
| **Haiku 4.5** | $1 | $5 | Subagents, фільтрація, прості trivia |

- **Batch API: −50%** на input і output (async <24h)
- Cache read: **0.1×** base input (всі моделі)

<DocRef url="https://platform.claude.com/docs/en/build-with-claude/prompt-caching" label="platform.claude.com/docs — Prompt caching" :offset="1" />
<DocRef url="https://claude.com/pricing" label="claude.com/pricing" />

<!--
Pricing на 2026 рік. Haiku 4.5 — $1/$5, це найдешевша production-модель. Sonnet 4.6 — sweet spot для coding: $3/$15, плюс 1M контекст без доплати. Opus 4.7 — дорожче, для складних речей. Batch API — 50% знижка, якщо можеш почекати до 24 годин. Для CI-пайплайнів, нічних прогонів, bulk-задач — очевидний вибір. У Claude Code Batch API напряму не використовується, але якщо у тебе свій Agent SDK — варто знати.
-->

---
hideInToc: true
---

# Opus 4.7: нюанс із tokenizer

<v-clicks>

Anthropic про Opus 4.7 (цитата):

> "Opus 4.7 uses an updated tokenizer that improves how the model processes text. The tradeoff is that the same input can map to more tokens—roughly **1.0–1.35×** depending on the content type."

**Наслідок**: той самий код на Opus 4.7 може коштувати **до +35%** порівняно з Opus 4.6 при однаковій $/1M-тарифікації.

**Коли 4.6 вигідніший**:
- Великий repetitive prefix (cache prefix)
- Обробка великої кількості HTML/markdown/тексту
- Коли ти НЕ потребуєш нових 4.7-специфічних вдосконалень

Перевіряй `/cost` або `/stats` — реальна різниця видима відразу.

</v-clicks>

<DocRef url="https://www.anthropic.com/news/claude-opus-4-7" label="anthropic.com — Opus 4.7 release" />

<!--
Цікавий нюанс, про який мало хто знає. Opus 4.7 має оновлений tokenizer — він ефективніший для моделі, але токенізує той самий текст у до 35% більше токенів. Офіційна цитата з анонсу 4.7. Наслідок: якщо твої задачі — великий префікс коду (cache), багато HTML/markdown, а ти не використовуєш фічі саме 4.7 — Opus 4.6 може бути на 20-30% дешевший на тих самих задачах. Це не теорія: прогони один день на 4.7, другий на 4.6 з /cost — побачиш різницю.
-->

---
hideInToc: true
---

# Effort level та thinking budget

<v-clicks>

Extended thinking **увімкнений за замовчуванням** — thinking tokens білінгуються як **output**.

Default budget: **десятки тисяч токенів per request**.

**Як знизити**:
- `/effort low` — мінімальний thinking (або `medium`, `high`, `xhigh`, `max`)
- `/model` → вибрати рівень без thinking
- `/config` → вимкнути thinking глобально
- `MAX_THINKING_TOKENS=8000` — env var з жорстким cap

**Правило**: для простих CRUD/рефакторів — `/effort low`. Для архітектурних рішень — default або `high`.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/model-config#adjust-effort-level" label="code.claude.com/docs — Effort level" />

<!--
Thinking tokens — тихий вбивця бюджету. Вони НЕ відображаються у видимому output, але білінгуються як output tokens ($25/1M для Opus). Default thinking budget — десятки тисяч. Тобто на простій задачі, де видимий output 500 токенів, ти платиш за 20k thinking. Рішення: для задач де ти точно знаєш, що treba зробити — /effort low. Для складних — залиш default. Environment variable MAX_THINKING_TOKENS=8000 корисно на CI, де ти не хочеш сюрпризів.
-->

---
hideInToc: true
---

# Pattern: Plan в Opus → Execute в Sonnet

<v-clicks>

**Подія 1**: складна задача → потрібне глибоке обмірковування

```
/model opus
# або утримуй Opus за замовчуванням
# натисни Shift+Tab для plan mode
```

Plan mode explore-ує, формує підхід. **Approve** план.

**Подія 2**: виконання плану (механічне)

```
/model sonnet
```

Sonnet у 1.5-2× дешевший, виконує план якісно.

**Economics**: Opus тільки там, де потрібен. Sonnet виконує 80% робочого дня.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/common-workflows#use-plan-mode-for-safe-code-analysis" label="code.claude.com/docs — Plan mode" />

<!--
Паттерн який я використовую щодня. Opus для складних питань — "як структурувати цю міграцію", "як розбити сервіс на модулі", "що з цим дизайном не так". Коли план сформовано — перемикаюсь на Sonnet і він виконує кожен крок. Sonnet абсолютно справляється з implementation, якщо завдання сформоване. А Opus за думання заплатив один раз, не на кожен крок. Перемикання /model mid-session — instant, без перестарту.
-->

---
layout: section
---

# Output side: фільтрація перед входом

---
hideInToc: true
---

# Plan mode: не спалюй токени на неправильному шляху

<v-clicks>

**Shift+Tab** → Plan mode.

Claude:
1. Досліджує кодбазу
2. Пропонує підхід
3. Чекає твого **approve**

Тільки після approve — починає писати код.

**Чому економить**:
- Без plan mode: Claude угадує → пише 500 рядків → ти кажеш "не те" → все викинуто → 500 рядків токенів даремно
- З plan mode: Claude питає → ти корегуєш → 500 рядків одразу правильних

**Перерва неправильного шляху**: `Esc` зупиняє, `/rewind` або double-`Esc` повертає до checkpoint.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/common-workflows#use-plan-mode-for-safe-code-analysis" label="code.claude.com/docs — Plan mode" />

<!--
Plan mode — це найдешевший insurance. Затрати: 5-10k токенів на формування плану. Виграш: не писати 50k токенів коду, який ти відкинеш. ROI очевидний на задачах складніших за "додай getter". Додатково — plan mode є природнім checkpoint-ом: ти можеш перечитати те, що задумав Claude, до того як він це зробив. Це економить не лише токени, а й твій час на read-review.
-->

---
hideInToc: true
---

# Специфічні промпти vs туманні

<v-clicks>

**Туманні** → broad scanning → тисячі токенів марно:

```
improve this codebase
```

→ Claude читає 50 файлів, "щоб зрозуміти контекст".

**Специфічні** → точні операції → десятки токенів:

```
Add input validation to the login function in src/auth/login.ts
```

→ Claude читає 1 файл, робить правку.

**Правило**: вкажи файл, функцію, й очікуваний результат. Якщо не можеш бути специфічним — **скористайся plan mode**, хай Claude спитає.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/costs#write-specific-prompts" label="code.claude.com/docs — Specific prompts" />

<!--
Одна з найпростіших технік, яку всі ігнорують. "Зроби щось із цим проектом" — Claude почне "розвідку" і витратить 10-20k токенів на читання. Специфічний промпт економить миттєво. Якщо сам не знаєш де — plan mode розвідає точково і ЗАПИТАЄ у тебе, замість самовільного expand scope. Правило для себе: якщо не можеш вказати файл або функцію — ти не готовий давати Claude задачу, готуйся краще.
-->

---
hideInToc: true
---

# Батчинг: один великий prompt > три малих

<v-clicks>

Кожен roundtrip платить:
- Startup baseline (уже обговорено)
- Cache refresh / write
- Thinking tokens (якщо enabled)
- Output tokens

**Три окремі turn-и** → ×3 overhead.

**Один продуманий prompt з N підкроками**:

```
1. Add input validation to auth.ts login function
2. Add matching unit test in auth.test.ts
3. Update CHANGELOG.md with the change
```

Claude виконує як послідовність у **одному** turn-і. Prompt cache reuse — усе в межах одного контексту.

**Коли НЕ батчити**: кроки залежать від результату попереднього (нетривіально → треба подивитись). Тоді plan mode + approve.

</v-clicks>

<!--
Класичний помилка новачка: окремі повідомлення для кожної дрібниці. Claude перечитує весь контекст перед кожним повідомленням. Якщо ти пишеш три окремі "додай валідацію", "додай тест", "онови CHANGELOG" — це три проходи через увесь контекст, три роздуми, три overhead-и. Один prompt з нумерованим списком — один прохід. Економія на simple додаваннях — 2-3x. Але: якщо наступний крок залежить від того що Claude побачив у попередньому — не батч, дай йому думати покроково або використовуй plan mode.
-->

---
hideInToc: true
---

# Мова промптів: english cheaper

<v-clicks>

Claude токенізатор (BPE):
- Тренувальні дані: **57.5% код + 38.8% англ + 3.7% інші мови**
- Кирилиця / українська — **низько-ресурсна**

Академічний бенчмарк (Frontiers in AI, 2025):
- Англійська: **~1.3 tokens per word**
- Українська (Claude): **3+ tokens per word**

Практично: тривіальний bug report англійською — 50 tokens. Той самий зміст українською — 110+ tokens. На сесії за день — відчутна різниця.

**Рекомендація**:
- Пиши **промпти англійською**
- **Відповідь/pояснення** можна просити українською, якщо треба (тільки output ×1, не ×2+)

</v-clicks>

<DocRef url="https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2025.1538165/full" label="frontiersin.org — Ukrainian tokenization efficiency" />

<!--
Неприємна технічна правда. Claude навчений майже на чистій англійській — 38.8% проти 3.7% на всі інші мови разом. Токенізатор BPE "знає" англійські морфеми добре, кирилицю — погано. Академічна робота з Frontiers за 2025 рік порівнює — українська в Claude топить на 2-3 рази гірше ніж англійська. Тобто той самий bug report українською буквально коштує в 2x більше токенів. Рекомендую писати промпти англійською. Output можна в українській якщо треба — output платиться тільки раз, input завантажується в cache і повторюється на кожен turn.
-->

---
hideInToc: true
---

# Hooks і LSP: фільтруй до того, як потрапить у context

<v-clicks>

**PreToolUse hook** — перехопити команду до виконання, додати фільтр:

```bash
# filter-test-output.sh: тільки FAIL/ERROR
filtered_cmd="$cmd 2>&1 | grep -A 5 -E '(FAIL|ERROR)' | head -100"
```

Результат з docs: **з десятків тисяч токенів — у сотні**.

**LSP / Code intelligence plugins**:
- Go-to-definition замість `grep` + `Read` 5 файлів
- Автоматичне type checking → Claude ловить помилки без запуску компілятора
- Typed-language плагіни: TypeScript, Rust, Go, Python

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com/docs — Hooks" :offset="1" />
<DocRef url="https://code.claude.com/docs/en/discover-plugins#code-intelligence" label="code.claude.com/docs — Code intelligence plugins" />

<!--
Два різних механізми, той самий принцип: зменши вхід до того, як він стане токенами у контексті. Hook — це shell-script, який перехоплює bash-команди через PreToolUse event, фільтрує вивід, повертає Claude тільки потрібне. Приклад з docs: замість 10,000 рядків test output — тільки рядки з FAIL і 5 контекстних навколо. Claude бачить сотні токенів замість десятків тисяч. LSP — це язик-сервер для типізованих мов. Замість "грепни по проекту і прочитай 5 файлів щоб знайти визначення" — один go-to-definition і Claude отримує точну відповідь. Плагіни встановлюються через /discover-plugins.
-->

---
hideInToc: true
---

# RTK: 92.5% економії на shell output

<v-clicks>

**RTK (Rust Token Killer)** — CLI-проксі, що фільтрує shell output перед тим, як Claude його побачить.

Install: `rtk init -g` → restart Claude Code → transparent rewriting (`git status` → `rtk git status`).

**Реальний `rtk gain` з моєї установки**:

```
Total commands:    4753
Input tokens:      23.8M
Output tokens:     1.8M
Tokens saved:      22.0M (92.5%)

Top by savings:
 1. rtk read           284 cmds  10.0M saved  (20.8% avg)
 2. rtk curl ...         7 cmds   7.4M saved  (100%)
 3. rtk find           442 cmds 502.7K saved  (57.1%)
 4. rtk ls            1543 cmds 264.5K saved  (65.5%)
```

</v-clicks>

<DocRef url="https://github.com/rtk-ai/rtk" label="github.com/rtk-ai/rtk" />

<!--
RTK — open-source проект rtk-ai на GitHub. Це мої власні цифри: 4753 команд, 22 мільйони токенів заощаджено — 92.5%. Топ-1 — rtk read, файлові читання. Коли Claude читає файл через свій Read tool — у контекст іде повний вміст. RTK grep/truncate-ує великі файли до релевантних секцій. rtk curl — http-запити, де тільки заголовки + перші N рядків тіла потрібні. Після install через rtk init -g — нічого не треба робити, hook прозоро переписує всі bash-команди. Нюанс: економія — це НЕ токени Claude-моделі напряму, а shell-output, який був би завантажений у context. Реальна економія в доларах залежить від того, на якій моделі ти працюєш.
-->

---
hideInToc: true
---

# `settings.json` env — preset для економії

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
    "CLAUDE_CODE_DISABLE_BACKGROUND_TASKS": "1",
    "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS": "8000",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8192",
    "MAX_THINKING_TOKENS": "8000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70"
  }
}
```

<v-clicks>

- `DISABLE_AUTO_MEMORY` — не читати/писати `MEMORY.md` (trade-off: cross-session learning off)
- `DISABLE_BACKGROUND_TASKS` — вимикає `run_in_background`, Ctrl+B, auto-backgrounding (**<$0.04/session → 0**)
- `FILE_READ_MAX_OUTPUT_TOKENS=8000` — truncate великих файлів раніше (default щедріший)
- `MAX_OUTPUT_TOKENS=8192` — cap per-turn output. **Менший value = більший auto-compact buffer** (docs)
- `MAX_THINKING_TOKENS=8000` — cap thinking замість повного `DISABLE_THINKING=1` (не вбиває якість на складних задачах)
- `AUTOCOMPACT_PCT_OVERRIDE=70` — компакція при 70% замість ~95%

</v-clicks>

**Обережно з цими** (в інтернеті часто радять, але коштує якості):
- `CLAUDE_CODE_DISABLE_THINKING=1` — занадто жорстко на Opus 4.7 (xhigh default)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — вмикає feature що = **7× tokens**
- `LOG_LEVEL=warn`, `NODE_ENV=production` — **не існують у Claude Code env**

<DocRef url="https://code.claude.com/docs/en/env-vars" label="code.claude.com/docs — Environment variables" />

<!--
Балансований preset. Auto memory і background tasks — низький risk, чистий виграш. FILE_READ_MAX_OUTPUT_TOKENS — 25k default (занадто щедро для аудиту), 8k вистачає на 99% файлів, великі truncate-нуться і Claude все одно побачить попередження. MAX_OUTPUT_TOKENS — цікавий нюанс з docs: менший cap означає більше місця для auto-compact buffer, тобто auto-compaction спрацює пізніше. MAX_THINKING_TOKENS=8000 замість DISABLE_THINKING — компроміс: thinking обмежений, але не вбитий. CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70 — агресивна компакція на 70% (default ~95, hard cap ~83). Червоний список: DISABLE_THINKING = якість впаде на архітектурних задачах. EXPERIMENTAL_AGENT_TEAMS = просто прапор що вмикає feature яка з'їдає 7x токенів. LOG_LEVEL і NODE_ENV — це популярні галюцинації з блогів/гайдів: Claude Code їх не знає, шум у конфігу. Правильна назва для debug логу — CLAUDE_CODE_DEBUG_LOG_LEVEL.
-->

---
hideInToc: true
---

# Thinking budget — per-model nuance

Три env vars для thinking, **поведінка відрізняється за моделлю**:

| Var | Opus 4.7 | Opus 4.6 / Sonnet 4.6 |
|-----|----------|----------------------|
| `CLAUDE_CODE_DISABLE_THINKING=1` | ✅ kills all thinking | ✅ kills all thinking |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` | ❌ **no effect** | ✅ fallback на fixed budget |
| `MAX_THINKING_TOKENS=8000` | ❌ **ignored** | ✅ fixed budget (коли adaptive off) |

<v-clicks>

**Opus 4.7** — завжди adaptive. Контроль — через `/effort low/medium/high/xhigh/max` (default `xhigh`). `MAX_THINKING_TOKENS` **ігнорується**.

**Opus 4.6 / Sonnet 4.6** — default adaptive, можна opt-out:
```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING": "1",
    "MAX_THINKING_TOKENS": "8000"
  }
}
```
→ fixed thinking budget 8k замість adaptive.

**Практичне правило**: на 4.7 не ставити `MAX_THINKING_TOKENS` — це шум. Замість — `/effort low` для простих tasks, default для складних.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/model-config#adaptive-reasoning-and-fixed-thinking-budgets" label="code.claude.com/docs — Adaptive reasoning" />

<!--
Гадський нюанс, якого немає у більшості гайдів. На Opus 4.7 thinking завжди adaptive — модель сама вирішує скільки думати на кожному turn-і. MAX_THINKING_TOKENS на 4.7 буквально ігнорується — це не bug, це by design. Хочеш знизити thinking на 4.7 — /effort low, medium, high, xhigh, max. Default — xhigh (багато thinking на кожну дрібницю). /effort low — швидкі задачі. Якщо ти на Opus 4.6 або Sonnet 4.6 — там навпаки: default також adaptive, але можна вимкнути через CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1, і тоді активується старий fixed budget через MAX_THINKING_TOKENS. DISABLE_THINKING=1 — nuclear варіант для всіх моделей, thinking виключається взагалі. Min Claude Code version для DISABLE_ADAPTIVE_THINKING — 2.1.111.
-->

---
layout: section
---

# Checklist

---
hideInToc: true
---

# Аудит твого setup-у

<v-clicks>

- [ ] `wc -l CLAUDE.md` < 200. Якщо ні — винеси процедури у skills.
- [ ] `/skills t` — відсортуй за token count. Великі скіли — кандидати на split або supporting files.
- [ ] `/context` після 20 turn-ів — що займає? Де перевищення?
- [ ] Status line з context usage — ввімкнений?
- [ ] MCP servers: `/mcp` — вимкни невикористовувані.
- [ ] Default `/model sonnet` — вмикай Opus свідомо.
- [ ] Default `/effort low` на простих, підіймай коли треба.
- [ ] RTK: встановлений? `rtk gain` через тиждень — що саме економить.
- [ ] Plan mode (Shift+Tab) на задачах > 1 файл.
- [ ] Subagents для будь-якого "піди подивись" чи verbose.

</v-clicks>

<!--
Пробіжись по цьому списку у свій наступний робочий день. Це не "зроби все разом" — це 10 незалежних галочок, кожна з яких дає 5-20% економії. Разом — реально в 3-5 разів. І ще важливе: не женись за "100% optimized". Кращий баланс: зроби 6 з 10 і забудь. Інші 4 — для тих випадків, коли біллінг починає кусатись.
-->

---
hideInToc: true
---

# Глибше у prompt engineering — 1.5h безкоштовно

<v-clicks>

**"ChatGPT Prompt Engineering for Developers"** — DeepLearning.AI short course

- Автори: **Isa Fulford** (OpenAI) + **Andrew Ng** (DeepLearning.AI / Coursera)
- Формат: **9 відеоуроків + 7 code examples**, ~**1.5 години**
- Ціна: **безкоштовно** (під час beta learning platform)
- Prereq: базовий Python
- Використовує OpenAI API, але **принципи prompting — model-agnostic** (Claude, Gemini — те саме)

**Що дає для economy токенів** (з нашого checklist):
- Iterative prompt development → менше дрібних turn-ів
- Summarizing / Inferring / Transforming — patterns, які можна обмежити у scope → коротший output
- "Guidelines and two key principles" — специфічність і структура = менше re-reading

</v-clicks>

<DocRef url="https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/" label="deeplearning.ai — ChatGPT Prompt Engineering for Developers" />

<!--
Коротше за цю доповідь — курс Isa Fulford і Andrew Ng, 9 уроків по 5-15 хвилин. Так, в назві ChatGPT — курс використовує OpenAI API в прикладах, але принципи promptingу universalні: специфічні інструкції, iterative refinement, chain-of-thought, structured output. Все працює один-в-один для Claude Code. Безкоштовно, не треба certificate, можна дивитись на швидкості 1.5x — разом 1 година. Після нашої доповіді — це найкоротший шлях щоб почати застосовувати checklist ефективно.
-->

---
layout: center
class: text-center
---

# Дякую

**Посилання:**
- [code.claude.com/docs/en/costs](https://code.claude.com/docs/en/costs)
- [code.claude.com/docs/en/context-window](https://code.claude.com/docs/en/context-window)
- [platform.claude.com/docs/en/build-with-claude/prompt-caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk)
- [deeplearning.ai — Prompt Engineering for Developers](https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/)

Перша частина: **Claude Code: Fundamentals** → `/claude-code-fundamentals/`

<!--
Коротко: три важелі — startup context, prompt caching, model selection. Перша частина презентації — Fundamentals — за посиланням. Питання?
-->
