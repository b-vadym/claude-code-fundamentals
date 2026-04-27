---
theme: seriph
background: https://images.unsplash.com/photo-1518770660439-4636190af475?w=1920
title: "Workshop 12 — Debugging Claude Code: коли ламається"
info: |
  ## Workshop 12 — Debugging
  Hook exit codes, skill triggers, MCP handshake, session transcripts, auto-compaction
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 12

## Debugging Claude Code: коли ламається

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · `exercises/` репо паралельно</div>

<!--
Останній воркшоп серії. Найважливіший — бо зламається все рано чи пізно. Сьогодні: hooks не блокують, skills не тригерять, MCP не стартує, контекст «забув» що ти казав 5 хвилин тому. Кожен симптом має конкретну діагностику. Кожна вправа — реальний баг, який ти знайдеш і виправиш.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Розшифрувати exit code 0/2/інше** — і знати чому `exit 1` НЕ блокує
- **Прочитати hook JSON output** — `permissionDecision`, `additionalContext`, `continue`
- **Пройти 6-крокову діагностику** skill-а який не тригериться
- **Дебажити MCP** — `/mcp`, `--debug mcp`, `.mcp.json` schema
- **Прочитати transcript** через jq — знайти де зламалося після compaction
- **Розрізнити що губиться при auto-compaction** і як митигейтити

</v-clicks>

<!--
Це не теорія — кожна тема має робочий приклад у exercises/. Хто ще не клонував — клонуй зараз, бо зараз на терміналі будуть конкретні баги.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` зі свого терміналу
- **Ти кодиш паралельно** — `cd workshops/12-debugging/exercises`
- **4 вправи** — кожна 10–15 хв, у власній підтеці. Кожен `starter/` зламаний навмисне
- **`solutions/`** — готові розв'язки якщо застрягнеш
- **`handout.pdf`** — пост-воркшоп референс з усіма jq-запитами і JSON-схемами

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: <code>jq</code> встановлений (<code>brew install jq</code> / <code>apt install jq</code>), CC v1.x.
</div>

<!--
Дай хвилину на клон. Хто без jq — встанови зараз, він знадобиться у вправі 4.
-->

---
layout: section
---

# Підхід

Що першим робити, коли «не працює»

---

# Mental model: 3 причини

<v-clicks>

Майже кожна проблема конфігурації — одна з трьох:

1. **Файл не завантажився** — нема в очікуваному шляху, неправильна назва
2. **Завантажився звідки не очікував** — інший scope перебив (managed > user > project > local)
3. **Інший scope override-ить** — те ж саме поле в `settings.local.json` перебиває `settings.json`

</v-clicks>

<v-click class="mt-4 p-3 bg-amber-500/10 rounded text-sm">

Перш ніж лізти у логи — **перевір що завантажилось**. Це 80% випадків.

</v-click>

<DocRef url="https://code.claude.com/docs/en/debug-your-config" label="code.claude.com — Debug your configuration" />

<!--
Я це повторюю з кожним джуном: спочатку питаєш — чи воно взагалі тут? Потім — звідки? Потім — чи нічого не перебиває? Лише потім лізеш у --debug.
-->

---

# Diagnostic surface — 8 команд

| Команда | Що показує |
|---|---|
| `/context` | Усе що в контекстному вікні: system, memory, skills, MCP tools |
| `/doctor` | Конфіг-валідація: invalid keys, schema errors, MCP misconfigs |
| `/status` | Active settings sources (managed/user/project/local), auth |
| `/memory` | Які `CLAUDE.md` і rules завантажились |
| `/skills` | Available skills + source (project/user/plugin) |
| `/hooks` | Зареєстровані хуки згруповані за event |
| `/mcp` | MCP-сервери: connection status, tools count |
| `/permissions` | Resolved allow/deny rules |

<v-click class="mt-2 text-sm opacity-70">

**Порядок дій:** `/context` → побачити загальну картину → відкрити конкретну команду для детального view.

</v-click>

<DocRef url="https://code.claude.com/docs/en/debug-your-config" label="code.claude.com — Debug your configuration" />

<!--
Якщо забереш одне зі слайду — забери цей. Це пульт ваших операцій. /doctor — найпотужніший, бо валідовує JSON і ловить schema errors які тихо дропають entries.
-->

---

# `/doctor` — що ловить

<v-clicks>

- **Installation type, version, search** — чи `ripgrep` доступний
- **Auto-update status**
- **Invalid settings files** — malformed JSON, wrong types для полів
- **MCP server config errors** — у т.ч. та ж назва у різних scope-ах з різними endpoint-ами
- **Keybinding configuration problems**
- **Context usage warnings** — великий CLAUDE.md, високий MCP token usage, unreachable permission rules
- **Plugin and agent loading errors**

</v-clicks>

<v-click class="mt-2 p-3 bg-emerald-500/10 rounded text-sm">

**Запускай при першому ж «дивно поводиться»** — швидше ніж grep і часто фінальна відповідь.

</v-click>

<DocRef url="https://code.claude.com/docs/en/troubleshooting" label="code.claude.com — Troubleshooting (claude doctor)" />

<!--
/doctor мовчить — добра ознака. Каже про unreachable permission rules — у тебе `Bash(*)` allow стоїть до більш специфічного deny. Перевір порядок.
-->

---
layout: section
---

# Hooks debug

Найпопулярніше джерело сюрпризів

---

# Exit codes — канон

| Code | Поведінка | JSON оброблюється? |
|---|---|---|
| **0** | Success — дія дозволена | ✅ stdout JSON парситься як рішення |
| **2** | **Blocking error** — дія заблокована, stderr видно Claude | ❌ |
| Інше (1, 3, …) | Non-blocking error — дія проходить, перший рядок stderr → юзеру | ❌ |

<v-click class="mt-4 p-3 bg-red-500/10 rounded text-sm">

⚠️ **Найчастіший hook-баг у світі:**
`exit 1` НЕ блокує. Це non-blocking error. Для блокування — **`exit 2`**.

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — Hook exit codes" />

<!--
Цитую docs дослівно: "Claude Code treats exit code 1 as a non-blocking error and proceeds with the action, even though 1 is the conventional Unix failure code." Запам'ятай: 2 блокує, не 1.
-->

---

# Exit 2 — ефект залежить від event

<v-clicks>

```text
PreToolUse              → блокує tool call
UserPromptSubmit        → блокує prompt, стирає його з контексту
UserPromptExpansion     → блокує expansion
PermissionRequest       → denies permission
Stop                    → не дає Claude зупинитись
WorktreeCreate          → будь-який non-zero валить creation
```

</v-clicks>

<v-click class="mt-4">

**Non-blockable events** (`PostToolUse`, `SessionEnd`, …) — exit 2 лише показує stderr юзеру. Заблокувати не може, бо дія вже сталась.

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — Exit code semantics by event" />

<!--
Класична помилка: пишеш PostToolUse hook який «забороняє запис» — не вийде, файл вже записався. Для блокування пиши PreToolUse.
-->

---

# Stderr/stdout — куди що йде

<v-clicks>

| Сценарій | Куди йде |
|---|---|
| Exit 0, plain text stdout | debug log only (НЕ у transcript) |
| Exit 0, JSON stdout | парситься як decision |
| Exit 2, stderr | **Claude бачить як error** |
| Exit 1+, stderr | перший рядок у transcript як `<hook> hook error`, повний — у debug log |

</v-clicks>

<v-click class="mt-4">

**3 події що ВКИДАЮТЬ stdout у контекст** як additional context:

```text
SessionStart, UserPromptSubmit, UserPromptExpansion
```

Plain text → context. Cap: **10,000 символів**.

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — Hook output handling" />

<!--
Якщо хочеш ВКИНУТИ контекст — пиши на stdout у SessionStart. До 10K символів вистачить навіть для довгого state.json.
-->

---

# JSON-вивід — universal fields

```json
{
  "continue": true,                    // false → Claude зупиняється
  "stopReason": "Build failed",        // показується коли continue: false
  "suppressOutput": false,             // не логувати stdout
  "systemMessage": "Warning to user"   // показати юзеру
}
```

<v-clicks>

- **`continue: false`** — найжорсткіший варіант. Claude зупинить ВСЕ, не лише поточний tool call
- **`stopReason`** — обов'язковий якщо `continue: false`, інакше юзер не зрозуміє що сталось
- **`suppressOutput: true`** — корисно для гучних hook-ів (formatter, linter) які щось пишуть постійно

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — JSON output schema" />

<!--
continue: false — це emergency brake. Юзай рідко, лише при критичних помилках (CI failed, secret detected).
-->

---

# JSON-вивід — `hookSpecificOutput`

PreToolUse — спеціальна структура:

```json {all|3-5|6|7}{lines:true}
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Pre-approved by linter",
    "updatedInput": { "command": "npm run lint:fix" },
    "additionalContext": "Auto-fixed before tool call"
  }
}
```

<v-clicks>

- **`permissionDecision`** — `allow | deny | ask | defer`
- **`updatedInput`** — переписати tool input. Можна санітизувати команду перед запуском
- **`additionalContext`** — додатковий контекст для Claude (не для юзера)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — PreToolUse JSON" />

<!--
updatedInput — потужно. Hook бачить, що Claude хоче `rm -rf /`, переписує на `rm -rf /tmp/foo`, повертає updatedInput. Tool виконується з виправленим вводом.
-->

---

# Hook не запускається — `/hooks`

```bash
/hooks   # show all registered hooks, grouped by event
```

<v-clicks>

**Не з'явилось у `/hooks`?** Причини за частотою:

1. **`matcher` — JSON array** замість string. Має бути `"Edit|Write"`, не `["Edit", "Write"]`
2. **`matcher` — lowercase** (`"bash"` замість `"Bash"`). Case-sensitive, **обов'язково з великої**: `Bash`, `Edit`, `Write`, `Read`
3. **Конфіг у `.claude/hooks.json`** — нема такого файлу. Hook-и пишуть у `settings.json` під ключем `"hooks"`
4. **Schema error** → `/doctor` репортує, entry дропається тихо

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/debug-your-config" label="code.claude.com — Common causes" />

<!--
Випадки 1 і 2 — новачки. Випадок 3 — досвідчені, які бачили `~/.claude/agents.json`, `~/.claude/skills/` і думають що для hooks теж є окремий файл. Нема. Тільки settings.json.
-->

---

# `claude --debug hooks`

```bash
claude --debug hooks
```

<v-clicks>

Live трасування подій per tool call:

- **Кожен event evaluated**
- **Які matcher-и перевірились**
- **Hook exit code**
- **Повний output** (не лише перший рядок stderr)

**Коли юзати:** hook у `/hooks` є, але мовчить. `--debug hooks` покаже або «matcher не зматчив», або «exit 1, stderr: ...».

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **Шум.** `--debug hooks` пише дуже багато. Запускай у спеціальній сесії, не в робочій.

</v-click>

<DocRef url="https://code.claude.com/docs/en/hooks" label="code.claude.com — Debug hooks" />

<!--
Я тримаю окремий tmux pane з claude --debug hooks коли пишу новий hook. Бачу одразу все — exit code, час виконання, чи matcher зматчив.
-->

---

# Pitfall: shell profile pollution

> "Your hook's stdout must contain only the JSON object."

<v-clicks>

Якщо твій `~/.bashrc` echo-ить щось при старті — JSON не запарситься.

```bash {all|2-4}{lines:true}
#!/bin/bash
exec 2>/dev/null      # silence stderr from profile
source ~/.profile      # load env
exec 2>&1              # restore stderr

jq -n '{ "continue": true }'
```

</v-clicks>

<v-click class="mt-3 p-3 bg-blue-500/10 rounded text-sm">

**Як ловити:** запусти hook руками з тим же stdin що подаватиме CC. Якщо `jq` каже «parse error» — значить є левий вивід.

</v-click>

<!--
Класика. Хук на сервері, де `.bashrc` показує MOTD або welcome message. JSON-парсер давиться. exec 2>/dev/null рятує.
-->

---
layout: section
---

# Вправа 1 — broken hook

15 хв. Зламаний hook у starter/. Знайди і полагодь.

---

# Вправа 1: умова

```bash
cd workshops/12-debugging/exercises/01-broken-hook
cat README.md
```

<v-clicks>

**Що дано:**

- `starter/settings.json` з PreToolUse hook
- `starter/block-rm.sh` — намагається блокувати `rm -rf`
- Hook не блокує. Claude спокійно виконує `rm -rf /tmp/test`

**Завдання:**

1. Скопіюй `starter/` у тестову теку
2. Спробуй у Claude Code: `Run rm -rf /tmp/test-debug`
3. Помітиш — `rm` виконався (тестова тека стерта)
4. **Знайди ВСІ баги** (їх 2 або 3)
5. Виправ. Перевір що `rm` блокується

</v-clicks>

<v-click class="mt-3 text-sm opacity-70">

Час: 15 хв. Підказки в `README.md`. Solution — `solutions/01-broken-hook/`.

</v-click>

<!--
Не дивись solution одразу. Пройди по 6-крокам діагностики. Hook у /hooks? Так. Спрацював? Запусти --debug hooks і дивись output.
-->

---

# Вправа 1: spoilers попереду

<v-click>

Не читай далі поки не знайшов хоча б один баг сам.

</v-click>

<v-clicks>

**Баги (всі 3):**

1. **`exit 1` замість `exit 2`** — non-blocking. Дія проходить
2. **`matcher: "bash"`** — lowercase. Має бути `"Bash"`. Hook не зматчиться взагалі
3. **stderr відсутній** — навіть з `exit 2`, без `echo "..." >&2` Claude не побачить пояснення

</v-clicks>

<v-click class="mt-2 p-3 bg-emerald-500/10 rounded text-sm">

**Eureka момент:** після `matcher: "Bash"` + `exit 2` + `>&2` повідомлення — hook нарешті блокує.

</v-click>

<!--
Три баги в 10 рядках — реальна щільність помилок у боксі який бачив у production. Кожен сам по собі легкий, разом — дають симптом «нічого не блокується».
-->

---
layout: section
---

# Skills debug

Skill не тригериться. Що першим перевірити.

---

# Skill не тригериться: 6 кроків

<v-clicks>

1. **`/`-меню видно skill?**
   - Ні → шлях/назва. Перевір `~/.claude/skills/<name>/SKILL.md` існує
   - Видно але «disabled» → `disable-model-invocation: true` (це може бути правильно)

2. **Перефразуй запит точно під description**
   - Спрацювало → description треба тюнити
   - Не спрацювало → крок 3

3. **`disable-model-invocation` чи `user-invocable`?**
   ```bash
   grep -E "disable-model-invocation|user-invocable" ~/.claude/skills/X/SKILL.md
   ```

4. **`paths` glob?** Може skill активується лише на `**/*.rs`

5. **Manual `/skill-name`** — працює? Тоді skill loaded, проблема в matching

6. **Запит надто простий?** Claude НЕ тригерить skill для one-step тривіальностей

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Skills troubleshooting" />

<!--
Цей чек-ліст — копія зі workshop 04. Канонічний. 90% проблем — на кроках 1-2.
-->

---

# Description budget — `SLASH_COMMAND_TOOL_CHAR_BUDGET`

<v-clicks>

- **Усі імена skill-ів — завжди в контексті**
- **Description — обрізається** якщо багато skill-ів
- Бюджет: **1% контекстного вікна**, fallback **8,000 символів**
- Cap per entry: **1,536 символів** (description + when_to_use)

**Підняти ліміт:**

```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=16000
```

**Або:** обрізати description у рідко-юзаних skill-ах.

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **Симптом:** skill раптом перестає тригерити після додавання N-го skill-а у систему. Description обрізалось — ключові слова зникли.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Description budget" />

<!--
Цей бюджет — найрідше згаданий під капотом. Якщо у тебе 100+ skill-ів, неминуче упрешся.
-->

---

# Skill content lifecycle — після compaction

<v-clicks>

> Цитата з docs:
> «When the conversation is summarized, Claude Code re-attaches the most recent invocation of each skill, keeping the **first 5,000 tokens** of each. Re-attached skills share a combined budget of **25,000 tokens**.»

</v-clicks>

<v-click>

**Практично:**

- Останні 5K токенів кожного skill-а — збережено
- 25K токенів сумарного бюджету
- Якщо за сесію викликав 10 skill-ів — **старі дропаються** після compaction

</v-click>

<v-click class="mt-3 p-3 bg-emerald-500/10 rounded text-sm">

**Mitigation:** якщо skill «перестав працювати» після compaction — **просто re-invoke його**. Контент завантажиться заново, повний.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Skill content lifecycle" />

<!--
Це найкорисніший факт сесії. Як починаєш помічати «Claude більше не дотримується мого процесу» — re-invoke процесний skill.
-->

---

# Live change detection

<v-clicks>

| Що змінив | Чи треба restart |
|---|---|
| `~/.claude/skills/X/SKILL.md` (edit) | ❌ Auto-reload |
| `.claude/skills/X/SKILL.md` (edit) | ❌ Auto-reload |
| Створив **нову** теку skill-а | ✅ Restart обов'язково |
| Plugin skill (edit) | ⚠️ `/reload-plugins` |

</v-clicks>

<v-click class="mt-3">

**Чому restart для нової теки:** Claude Code watch-ить **існуючі** теки. Нова — не у списку watcher-ів. Restart підбере.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Live change detection" />

<!--
Дріб'язок але економить хвилини. Edit існуючого SKILL.md — просто збереги і випробовуй. Створив новий skill — рестартни.
-->

---
layout: section
---

# Вправа 2 — skill не тригериться

10 хв. Skill у `starter/` — description занадто vague. Полагодь.

---

# Вправа 2: умова

```bash
cd ../02-skill-trigger
cat starter/SKILL.md
```

<v-clicks>

**Що дано:**

- `starter/SKILL.md` — skill `bundle-size-check`
- Description: `"Check bundle size"`
- Skill встановлений у `~/.claude/skills/bundle-size-check/`
- Запит «check the bundle size of this app» — **не тригерить**

**Завдання:**

1. Встанови skill
2. Спробуй 3-4 формулювання — переконайся що не тригерить
3. Пройди 6-крокову діагностику
4. **Перепиши description** так, щоб тригерило надійно
5. Re-test ті ж 3-4 формулювання

</v-clicks>

<v-click class="mt-3 text-sm opacity-70">

Час: 10 хв. Solution — `solutions/02-skill-trigger/`.

</v-click>

<!--
Класична помилка — занадто короткий і generic description. Solution показує «pushy» варіант з action verb-ами і синонімами.
-->

---
layout: section
---

# MCP debug

Сервер не стартує. Або стартує, але 0 tools.

---

# `/mcp` — статуси

```text
/mcp

  github         ✅ connected (12 tools)
  postgres       ⚠️ pending approval
  custom-bot     ❌ failed: spawn ENOENT
  internal-api   ⏳ reconnecting (3/5)
```

<v-clicks>

- **`pending approval`** — `.mcp.json` сервер чекає твого approve. `/mcp` → Approve
- **`failed`** — стартував і помер. Найчастіше: relative path у `command`/`args`
- **`reconnecting`** — HTTP/SSE розрив, exp backoff: 1s → 2s → 4s → 8s → 16s, max 5 спроб
- **`connected (0 tools)`** — стартував але `tools/list` порожній. Reconnect → ще раз. Якщо 0 — `--debug mcp`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/debug-your-config" label="code.claude.com — Check MCP servers" />

<!--
Stdio сервери НЕ перепідключаються автоматично. Помер процес — статус failed назавжди до restart. HTTP — реконектиться сам.
-->

---

# `.mcp.json` — schema

Лежить у **корені проєкту** (НЕ у `.claude/`).

```json {all|2|3-7|8-13}{lines:true}
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GH_TOKEN}" }
    },
    "api": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

<v-clicks>

- **stdio:** `command` + `args` + `env`. Default тип — stdio
- **HTTP:** `type: "http"` + `url` + `headers`
- **`${VAR}` / `${VAR:-default}`** — env expansion. Required без default → fail to parse

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com — MCP configuration" />

<!--
Найчастіша помилка - кладуть .mcp.json у .claude/. Не працює. Корінь проєкту, поряд з package.json.
-->

---

# MCP failures — топ-5

| Симптом | Причина | Фікс |
|---|---|---|
| `.mcp.json` ігнорується | Файл у `.claude/` або Claude Desktop format | Корінь проєкту, NOT `.claude/` |
| Сервер не з'являється у `/mcp` | Approval prompt було dismissed | `/mcp` → Approve |
| Fail у деяких теках, ОК в інших | Relative path у `command`/`args` | Абсолютний шлях; `npx`/`uvx` ОК |
| Server starts, але env vars missing | Vars у `settings.json` `env` (не propagate-ять) | Per-server `env` у `.mcp.json` |
| `Failed to parse config` | Required `${VAR}` not set, no default | Set env або `${VAR:-default}` |

<DocRef url="https://code.claude.com/docs/en/debug-your-config" label="code.claude.com — Common causes" />

<!--
Третій рядок болить найчастіше. Запускаєш CC з ~/projects/foo — ОК. З ~/projects/bar — fail. Бо args мають ./mcp-server.py відносно cwd.
-->

---

# `claude --debug mcp`

<v-clicks>

```bash
claude --debug mcp
```

Що бачиш:

- **Handshake** — `initialize`, `initialized` повідомлення
- **Сервер stderr** — повний, не зрізаний
- **`tools/list` response** — JSON з усіма tools
- **Reconnect attempts** з тимінгом

**Коли юзати:**

- Сервер shows `failed` у `/mcp` без зрозумілої причини
- Connected але 0 tools
- Tools є але не викликаються (permission issue)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com — MCP debugging" />

<!--
Як і --debug hooks — шумно. Окрема сесія. Але це єдиний спосіб побачити stderr stdio-сервера, бо інакше він губиться.
-->

---

# OAuth-failures

<v-clicks>

**`Incompatible auth server: does not support dynamic client registration`**

→ Сервер не підтримує DCR. Треба зареєструвати OAuth-app вручну на сервері, потім подати credentials при `claude mcp add`.

**Browser redirect failed**

→ Скопіюй callback URL з браузера → встав у Claude Code prompt що з'явиться.

**Internal SSO / Kerberos / short-lived tokens?**

→ `headersHelper` у `.mcp.json` — runs a command per connection, виводить headers.

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/mcp" label="code.claude.com — MCP authentication" />

<!--
headersHelper - не дуже відома фіча. Підходить коли тобі треба генерувати свіжий JWT перед кожним конектом. Скрипт виводить заголовки на stdout, CC мерджить.
-->

---
layout: section
---

# Вправа 3 — broken `.mcp.json`

10 хв. Конфіг є, сервер не стартує. Знайди.

---

# Вправа 3: умова

```bash
cd ../03-mcp-config
ls starter/
# .mcp.json   echo-server.py   README.md
```

<v-clicks>

**Що дано:**

- `echo-server.py` — простий MCP-сервер, який повертає 1 tool `echo`
- `starter/.mcp.json` — конфіг з 2 проблемами

**Завдання:**

1. Скопіюй `starter/` у тестовий проєкт
2. Запусти `claude` у тій теці
3. `/mcp` — побачиш сервер failed або відсутній
4. `claude --debug mcp` — прочитай stderr
5. Знайди обидва баги, виправ
6. `/mcp` має показати `connected (1 tool)`

</v-clicks>

<v-click class="mt-3 text-sm opacity-70">

Час: 10 хв. Solution — `solutions/03-mcp-config/`.

</v-click>

<!--
Класичні баги. Один — relative path. Другий — env var без default.
-->

---
layout: section
---

# Session transcripts

Де живуть, як читати, коли потрібні

---

# Де живуть transcripts

```text
~/.claude/projects/<project-slug>/<session-id>.jsonl
```

<v-clicks>

- **`<project-slug>`** — sanitized cwd path
  - Для `/home/vadym/projects/foo` слаг буде `-home-vadym-projects-foo`
- **`<session-id>`** — UUID
- **JSONL** — кожен рядок один JSON-event сесії
- **Що там:** user prompts, assistant responses, tool calls, tool results, hook outputs, system messages, compact boundaries

</v-clicks>

<v-click>

```bash
ls ~/.claude/projects/-home-vadym-projects-foo/
# 7e3a...jsonl  9b2c...jsonl  ce41...jsonl
```

</v-click>

<v-click class="mt-3 text-sm opacity-60">

⚠️ Schema формально не задокументована (UNVERIFIED). Поля `.type`, `.message.content`, `.subtype` спостережено в реальних transcripts але не у specs.

</v-click>

<!--
Один transcript = одна сесія. Якщо `/clear` робив — сесія залишилась та сама. Restart — нова сесія, новий файл.
-->

---

# jq queries — основні

```bash
# Усі user prompts
jq 'select(.type == "user") | .message.content' session.jsonl

# Усі tool calls
jq 'select(.type == "assistant") | .message.content[]?
    | select(.type == "tool_use")' session.jsonl

# Compaction boundaries
jq 'select(.type == "system" and .subtype == "compact_boundary")' session.jsonl

# Hook outputs
jq 'select(.type == "system") | select(.subtype // ""
    | contains("hook"))' session.jsonl

# Останні 10 events
tail -10 session.jsonl | jq .
```

<v-clicks>

**Use cases:**

- Знайти момент coмpaction-у
- Подивитись що Claude бачив до compaction (vs що бачить після)
- Audit hook outputs — спрацював hook, що повернув

</v-clicks>

<!--
Це основні. У вправі 4 будемо юзати їх для розслідування. Pro tip: tee у файл коли експериментуєш.
-->

---
layout: section
---

# Auto-compaction

Що губиться, як митигейтити

---

# Auto-compaction — preserved vs lost

<v-clicks>

**Preserved (стискається у summary):**

- Сесійний context summary (Claude-generated)
- Останні N turn-ів verbatim
- System prompt + memory (re-injected fresh)
- **Skills** — most recent invocation each, first 5K tokens, sum 25K budget

**Lost:**

- Старі tool outputs verbatim
- Earlier file reads (тільки summary references)
- Skills не invoked недавно АБО витіснені 25K-бюджетом
- Детальні code chunks середини сесії

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Skill content lifecycle" />

<!--
25K budget — означає десь 6-10 повних skill-ів. Якщо у сесії 20 — половина дропнеться. Найновіші priority.
-->

---

# Mitigation — 5 тактик

<v-clicks>

1. **Re-invoke skill** — якщо процесний skill «забувся» після compaction
2. **`/recap`** (silent injection) — підкидає state перед заповненням контексту
3. **Subagents** — `context: fork` у skill виносить у окрему сесію
4. **`/compact <focus>`** — manual compact з directive: `/compact keep only the plan and the diff`
5. **`/clear`** якщо стара частина не потрібна — звільняє все

</v-clicks>

<v-click class="mt-4 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **«Autocompact is thrashing»** — файл або tool output постійно перезаповнює контекст після кожного compact. Симптом: «context refilled to the limit». Фікс: читай файл chunks, drop large output, або `/clear`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/troubleshooting" label="code.claude.com — Compaction thrashing" />

<!--
Thrashing бачив один раз: Claude читав 200K-токенний log file. Після кожного compact знов читав. Зупинило `/clear` і потім читання chunks по 10K.
-->

---
layout: section
---

# Вправа 4 — read transcript via jq

15 хв. Знайди де сесія втратила контекст.

---

# Вправа 4: умова

```bash
cd ../04-transcript-jq
ls starter/
# session.jsonl   investigation.md   README.md
```

<v-clicks>

**Що дано:**

- `starter/session.jsonl` — справжній transcript-приклад (45 events)
- У сесії був auto-compaction. Після нього Claude «забув» план з початку
- `investigation.md` — 4 питання для розслідування

**Завдання:**

1. **Знайди compact_boundary** — на якому line він?
2. **Що було перед compaction** — який план дав юзер?
3. **Що Claude робить після** — чи дотримується плану?
4. **Виведи всі hook outputs** через jq

</v-clicks>

<v-click class="mt-3 text-sm opacity-70">

Час: 15 хв. Solution — `solutions/04-transcript-jq/` з готовими jq-запитами.

</v-click>

<!--
Це не про «знайти баг». Це про вміння розслідувати. У реальному житті: «Чому CC не зробив що я попросив?» → читаєш transcript і бачиш точку розходження.
-->

---
layout: section
---

# Common errors catalog

---

# Топ-7 повідомлень

| Error | Причина | Фікс |
|---|---|---|
| `Hook X exited with code 1` (не блокує, а ти хотів) | exit 1 замість 2 | `exit 2` |
| `Hook X JSON parse error` | non-JSON у stdout | `exec 2>/dev/null` для shell profile |
| `Skill X not found` | flat `.md` замість теки | `<name>/SKILL.md` |
| `MCP server X failed to start` | relative path / missing exec | абсолютний шлях; `--debug mcp` |
| `MCP X: Connection refused` | endpoint мертвий / stdio process помер | test endpoint manually |
| `Autocompact is thrashing` | файл reflood-ить контекст | chunks; `/compact <focus>`; `/clear` |
| `spawn claude ENOENT` (CC як MCP) | Wrong path to `claude` binary | абсолютний шлях у `command` |

<DocRef url="https://code.claude.com/docs/en/troubleshooting" label="code.claude.com — Error reference" />

<!--
Скрин цей. Допомагає 70% часу. Якщо твоя помилка не тут — `/doctor` + research.md.
-->

---

# Production debug-checklist

<v-clicks>

- [ ] **`/doctor`** — перевір спочатку
- [ ] **`/context`** — що завантажилось у window
- [ ] **`/hooks`** / **`/skills`** / **`/mcp`** — конкретний компонент
- [ ] **Перевір scope precedence** — managed > user > project > local
- [ ] **`--debug <category>`** — у нову сесію (шумно)
- [ ] **Transcript** — `~/.claude/projects/<slug>/*.jsonl` через jq
- [ ] **Re-invoke skill** якщо post-compaction
- [ ] **Restart CC** для нових тек skill / новий plugin

</v-clicks>

<!--
Цим списком закриваєш 95% сценаріїв. Решта — реальні bug у CC, де `/feedback` і GitHub Issue.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [code.claude.com/docs/en/troubleshooting](https://code.claude.com/docs/en/troubleshooting)
- [code.claude.com/docs/en/debug-your-config](https://code.claude.com/docs/en/debug-your-config)
- [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)
- [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp)

</div>

<div>

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — готові розв'язки
- `handout.pdf` — повний референс
- Кінець серії — дякую що пройшли всі 12

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Це фінальний воркшоп серії з 12. Якщо було корисно — share. /feedback в CC, issue на GitHub. Дякую!
-->
