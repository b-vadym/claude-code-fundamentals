---
theme: seriph
background: https://images.unsplash.com/photo-1531746790731-6c087fecd65a?w=1920
title: "Workshop 10 — Subagents & Agent Teams"
info: |
  ## Workshop 10 — Subagents & Agent Teams
  Коли спавнити, як визначати, як запускати паралельно, коли збирати у команду
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 10

## Subagents & Agent Teams

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · `exercises/` репо паралельно</div>

<!--
Привіт. Десятий воркшоп серії — про subagent-и та agent teams. У token-economy воркшопі ми попереджали: subagent коштує ×7. Сьогодні дивимось іншу сторону медалі — коли цей коефіцієнт виправданий і як організувати команди агентів. 4 вправи паралельно — тримай термінал відкритим.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Викликати built-in subagent** — `Explore` для пошуку без захаращення основного контексту
- **Написати свій subagent** — `.claude/agents/<name>.md` з frontmatter і tool-restrictions
- **Запустити 3 паралельно** — multiple `Agent` calls в одному message-і
- **Зчепити в ланцюг** — researcher → planner → reviewer через файли-артефакти
- **Вибрати правильно** — subagent vs agent team vs main conversation

</v-clicks>

<!--
Це не теорія — після воркшопу в тебе є робочий кастомний subagent, є відчуття коли спавнити, і є мікро-команда, що працює як ланцюг. Усе у репо exercises/.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` зі свого терміналу
- **Ти кодиш паралельно** — `cd workshops/10-subagents-and-teams/exercises`
- **4 вправи** — кожна 10–15 хв, у власній підтеці
- **`solutions/`** — готові розв'язки на випадок, якщо застрягнеш
- **`handout.pdf`** — пост-воркшоп референс, ввечері передивишся

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: Claude Code v2.1+ (для перейменованого <code>Agent</code> tool), термінал, доступ до <code>~/.claude/agents/</code>
</div>

<!--
Дай хвилину на клон. Хто не встиг — пиши в чат. Експерименти на живій сесії — вилетіти і перезапустити Claude Code не страшно, контекст легко відновити.
-->

---
layout: section
---

# Контекст

Що таке subagent і навіщо він тобі

---

# Subagent у двох словах

<v-clicks>

- **Окрема Claude-сесія** з власним контекстним вікном
- Має **свій system prompt**, **свій список tools**, **свої permissions**
- Викликається через **`Agent` tool** (раніше `Task`, перейменовано у v2.1.63)
- **НЕ бачить** історію основної розмови — отримує лише task prompt
- Повертає у головну розмову лише **summary**

</v-clicks>

<v-click>

```
[Main session: 50K tokens]
   │
   │ Agent("explore", "find auth.ts handlers")
   ↓
[Subagent: 8K tokens — search, read 30 files]
   │
   │ returns: "auth.ts:42-91, login.ts:12-44"
   ↓
[Main session: 50K + 200 tokens] ← лише summary, не вся розпашка
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/subagents" label="code.claude.com — Subagents" />

<!--
Ключове: subagent не телепатичний. Тільки те, що ти йому передав у task prompt. Це і обмеження, і дисципліна.
-->

---

# Subagent vs Skill vs Hook vs Plugin

| Що | Власний контекст? | Тригер | Use case |
|---|---|---|---|
| **Skill** | Ні (default) | description / `/name` | Шаблон поведінки в основній сесії |
| **Hook** | Ні | Подія Claude Code | Реакція на подію (PreToolUse тощо) |
| **Subagent** | **Так** | `Agent` tool / `@-mention` | Ізольовані задачі, паралелізм |
| **Agent team** | **Так**, кілька | Lead-сесія створює | Кілька агентів, що спілкуються між собою |
| **Plugin** | — | — | Контейнер для всього вище |

<v-click>

**Skill ≠ subagent.** Skill з `context: fork` — ось це уже виконується у subagent-і.

</v-click>

<DocRef url="https://code.claude.com/docs/en/subagents#choose-between-subagents-and-main-conversation" label="code.claude.com — When to choose what" />

<!--
Skill — інструкція в основному контексті. Subagent — окремий контекст. Це різні речі, навіть якщо синтаксично схожі (markdown + frontmatter).
-->

---

# Built-in subagents

| Agent | Model | Tools | Коли |
|---|---|---|---|
| **Explore** | Haiku | Read-only | Пошук файлів, аналіз кодової бази |
| **Plan** | Inherit | Read-only | Дослідження у `plan mode` |
| **General-purpose** | Inherit | Усі | Багатокрокові задачі з explore + дією |
| **statusline-setup** | Sonnet | (обмежені) | Викликається `/statusline` |
| **Claude Code Guide** | Haiku | (обмежені) | Питання про сам Claude Code |

<v-clicks>

- **Explore** — найкорисніший. Швидкий і дешевий. Claude передає `thoroughness`: `quick` / `medium` / `very thorough`
- **Plan** — лише з plan-mode. Існує спеціально, щоб запобігти infinite-nesting (subagent не може спавнити іншого subagent-а)
- **general-purpose** — catch-all для довільних задач

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#built-in-subagents" label="code.claude.com — Built-in subagents" />

<!--
Explore — твій робочий кінь. Замість прямого grep/read у основній сесії, кажеш «explore the auth module» — і Claude делегує, не засмічуючи контекст.
-->

---

# Рекап з token-economy: ×7

<v-clicks>

У workshop 02 ми виміряли: **subagent ≈ ×7 токенів** проти прямого пошуку в основній сесії.

**Причина** — subagent щоразу вантажить:

- Усі tool-описи
- Усі MCP-схеми, не виключені
- Метадату skill-ів (description budget)
- CLAUDE.md / project memory
- Свій system prompt + task prompt

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

**Сьогодні** ми йдемо в інший бік: **коли ця ціна виправдана**.
Економія в **основному контексті** ≠ загальна економія.

</v-click>

<!--
Workshop 02 був попередженням: «обережно з subagent-ами». Workshop 10 — баланс: «ось коли вони того варті». Tradeoff: платиш більше всього, але звільняєш дорогий main context, де компакція вже маячить.
-->

---

# Коли subagent виправданий

<v-clicks>

| Сценарій | Subagent? | Чому |
|---|---|---|
| Пошук функції в репо 200 файлів | ✅ Explore | Великий grep-output не засмічує main |
| Читання 5K-рядкового логу | ✅ | Verbose output ізольований |
| Швидкий fix в одному файлі | ❌ Main | Латентність + overhead > користь |
| Test suite з failing-summary | ✅ | Output verbose, повертається лише фейл-зведення |
| 3 незалежні investigation-и | ✅ паралельно | Wall-clock економія, кожна гілка чиста |
| Взаємна дискусія між агентами | ✅ Agent team | Subagent → main only, не peer-to-peer |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#choose-between-subagents-and-main-conversation" label="code.claude.com — Choosing patterns" />

<!--
Правило: subagent економить main context ціною загального overhead. Виправдано, коли verbose output більше не знадобиться. Якщо ти захочеш повернутись до тих файлів через 10 хв — краще читати у main.
-->

---
layout: section
---

# Anatomy

Як визначити кастомний subagent

---

# Розташування файлів

```
.claude/agents/code-reviewer.md          ← project (commit у репо)
~/.claude/agents/commit-writer.md        ← personal (всі проєкти)
<plugin>/agents/<name>.md                ← через plugin
--agents '{...}' (CLI)                   ← одноразово, не зберігається
```

<v-clicks>

**Precedence (хто перебиває кого):**

```
Managed > --agents flag > .claude/agents/ > ~/.claude/agents/ > Plugin
```

- **Project** (`.claude/agents/`) — командні subagent-и, коммітимо у репо
- **Personal** (`~/.claude/agents/`) — твої утиліти, всі проєкти
- **CLI `--agents`** — JSON, одноразово, для headless / CI
- **Plugin** — distribution, namespaced

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#choose-the-subagent-scope" label="code.claude.com — Subagent scope" />

<!--
Один файл — один subagent. Не SKILL.md як у skills. Немає підтек і references/.
-->

---

# Frontmatter: критичні поля

```yaml {all|2|3|4|5|6}{lines:true}
---
name: code-reviewer
description: Expert code review. Use proactively after writing code.
tools: Read, Grep, Glob, Bash
model: sonnet
color: blue
---

You are a code reviewer. When invoked, run `git diff` first, then ...
```

<v-clicks>

- **`name`** (обов'язково) — kebab-case, унікальний
- **`description`** (обов'язково) — коли Claude делегує. Фрази «use proactively», «immediately after» — push для авто-делегування
- **`tools`** — allowlist. Якщо опущено — успадковує усі з main
- **`model`** — `sonnet` / `opus` / `haiku` / full ID / `inherit` (default)
- **`color`** — кольорова мітка в UI: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#supported-frontmatter-fields" label="code.claude.com — Frontmatter reference" />

<!--
Тіло markdown — це system prompt subagent-а. ЗАМІНЯЄ default Claude Code system prompt. Тільки твоя інструкція + базові env-деталі.
-->

---

# Frontmatter: контроль доступу

```yaml
---
name: db-reader
description: Read-only database queries
tools: Bash
disallowedTools: Write, Edit
permissionMode: dontAsk
maxTurns: 10
---
```

<v-clicks>

- **`tools` / `disallowedTools`** — denylist застосовується **першим**, потім allowlist
- **`permissionMode`** — `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan`
  - Якщо parent у `acceptEdits` чи `bypassPermissions` — це **перебиває** і не змінити
- **`maxTurns`** — стелиш від running-amok (default нескінченно)
- **`isolation: worktree`** — окрема git-копія репо, automatic cleanup якщо без змін

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#control-subagent-capabilities" label="code.claude.com — Tool restrictions" />

<!--
permissionMode у frontmatter ігнорується якщо parent — auto-mode. У плагінах поля hooks/mcpServers/permissionMode взагалі ігноруються (security).
-->

---

# Frontmatter: розширені поля

```yaml
---
name: api-developer
description: Implement API endpoints
skills: [api-conventions, error-handling-patterns]
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
memory: project
background: true
effort: high
---
```

<v-clicks>

- **`skills`** — preload skill-контенту у subagent на старті (не успадковує з parent!)
- **`mcpServers`** — inline-MCP лише для цього subagent-а. Не засмічує main context
- **`memory`** — `user` / `project` / `local` — persistent dir між сесіями
- **`background: true`** — завжди у фоні (concurrent з main)
- **`effort`** — `low` / `medium` / `high` / `xhigh` / `max`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#preload-skills-into-subagents" label="code.claude.com — Skills + MCP scope" />

<!--
Subagent НЕ успадковує skills з parent. Якщо subagent потребує skill — листуй у `skills:`. Це обернений напрям до `context: fork` у skill-і.
-->

---

# Тіло subagent-а

<v-clicks>

- **Markdown** — стає **system prompt-ом**, замінює default Claude Code system prompt
- **Імперативно**: «You are X. When invoked, do Y. Focus on Z»
- **Self-contained** — subagent не знає історії
- **Workflow з нумерованими кроками** працює краще, ніж абстрактний опис
- Цільовий розмір — компактно. Не забивай: subagent-у не потрібна довідка з tools, він її уже має

</v-clicks>

<v-click>

```markdown
You are a senior code reviewer.

When invoked:
1. Run `git diff` to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Clear naming, no duplication
- Proper error handling
- No exposed secrets
- Test coverage

Provide feedback by priority:
- Critical / Warnings / Suggestions
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/subagents#example-subagents" label="code.claude.com — Example subagents" />

<!--
Тіло — це system prompt колеги, який сів за твій репо вперше. Дай йому workflow, чек-ліст, формат виводу. Він не імпровізує добре.
-->

---
layout: section
---

# Hands-on

4 вправи. Терміналом паралельно.

---

# Вправа 1 — built-in Explore

**Мета:** викликати `Explore` для пошуку у кодовій базі без захаращення main.

```bash
cd workshops/10-subagents-and-teams/exercises/01-explore-subagent
cat README.md
```

<v-clicks>

**Кроки:**

1. Заходимо у будь-який середній репо (можна цей)
2. Кажемо Claude: **«Use the Explore subagent to find all places where DocRef is used»**
3. Спостерігаємо — Claude робить **один** `Agent` call
4. Перевіряємо: лише summary повертається в main (а не вся пашка з grep-у)
5. Експеримент: додай **«thoroughly»** у запит — Explore сам обере `very thorough`

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 10 хв. `solutions/01-explore-subagent/` — приклади запитів і очікуваних transcript-ів.

</v-click>

<!--
Це найпростіша вправа — просто щоб відчути що відбувається. У transcript-і побачиш окрему «Agent» секцію — це і є subagent у власному контексті.
-->

---

# Live: Explore у дії

```text {all|1|2|3-5|6-7}{lines:true}
> Use the Explore subagent to find DocRef usage

⏵ Agent(Explore): "Find all uses of <DocRef> component, return file:line refs"
  ↳ [grep, read 12 files...]

⏴ Returns: "DocRef used in 47 places across 3 dirs:
            workshops/01-fundamentals/slides.md (32 refs), ..."

> [main now has summary, not 12 file contents]
```

<v-clicks>

- Один Agent-виклик у transcript = один subagent
- **Thoroughness** Claude обирає сам з фрази запиту (`quick`, `medium`, `very thorough`)
- Якщо у `solutions/` неявний запит «де DocRef?» — спрацює; «прочитай DocRef.vue» — швидше за все ні (просте, main візьметься сам)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#built-in-subagents" label="code.claude.com — Explore" />

<!--
Зверни увагу: Claude НЕ завжди делегує Explore. Якщо задача проста — обходиться сам. Це by design, як зі skill-ами.
-->

---

# Вправа 2 — кастомний subagent

**Мета:** написати `commit-message-writer` у `.claude/agents/`

```bash
cd ../02-custom-subagent
cat starter/commit-message-writer.md
```

<v-clicks>

**Кроки:**

1. Створи `.claude/agents/commit-message-writer.md` (project-scope) або в `~/.claude/agents/` (personal)
2. Frontmatter: `name`, `description` («write conventional commit messages from staged diff»), `tools: Bash, Read`, `model: haiku`
3. Тіло — інструкція: запусти `git diff --cached`, побудуй conventional commit, поверни лише message-текст
4. Перезапусти Claude Code (або `/agents` для load)
5. Поклади якісь зміни у staging (`git add ...`)
6. Тест: `@commit-message-writer (agent)` — згенерує message

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#write-subagent-files" label="code.claude.com — Writing subagent files" />

<!--
15 хв. Це — твій перший власний agent. Залиш його — буде корисний усім командам.
-->

---

# Live: commit-message-writer

```yaml {all|2-3|4-5|7-}{lines:true}
---
name: commit-message-writer
description: Generate a Conventional Commit message from staged
  changes. Use proactively when user asks to commit.
tools: Bash, Read
model: haiku
---

You write Conventional Commit messages.

When invoked:
1. Run `git diff --cached --stat` to see scope
2. Run `git diff --cached` to see content
3. Determine type: feat, fix, refactor, docs, test, chore
4. Optional scope from path (auth, api, ui, ...)
5. Subject ≤ 50 chars, imperative ("add X", not "added X")
6. Body: only if change is non-obvious

Return ONLY the commit message, no preamble.
```

<DocRef url="https://code.claude.com/docs/en/subagents#example-subagents" label="code.claude.com — Subagent examples" />

<!--
Haiku — навмисно. Швидкий і дешевий, повертає короткий текст. Перфектно для рутини.
-->

---

# Способи виклику

<v-clicks>

**1. Natural language** — Claude вирішує сам:
```
> Use commit-message-writer to draft my next commit
```

**2. `@-mention`** — гарантує цей subagent:
```
> @commit-message-writer (agent) staged changes
```

**3. Whole session as subagent** — main thread «стає» subagent-ом:
```bash
claude --agent commit-message-writer
```

**4. Default for project** — `.claude/settings.json`:
```json
{ "agent": "commit-message-writer" }
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#invoke-subagents-explicitly" label="code.claude.com — Invocation patterns" />

<!--
@-mention найжорсткіший: гарантовано спавне саме цей subagent. Plugin-агенти у typeahead як `<plugin>:<name>`.
-->

---

# Вправа 3 — паралельний dispatch

**Мета:** 3 subagent-и в одному message-і

```bash
cd ../03-parallel-dispatch
cat README.md
```

<v-clicks>

**Кроки:**

1. У будь-якому репо з достатньо різних областей коду
2. Скажи Claude:
   > «Use 3 separate Explore subagents **in parallel** to investigate:
   > 1) where authentication lives,
   > 2) which tests exist,
   > 3) what build tooling is configured.»
3. Спостерігай у transcript: **три `Agent` tool-call-и в одному assistant turn**
4. Усі повернуть results незалежно — Claude синтезує

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#run-parallel-research" label="code.claude.com — Parallel research" />

<!--
15 хв. Магія тут не у синтаксисі — а у тому, що Claude робить кілька tool-call-ів в одному turn. Як і будь-які паралельні tool-call-и, але кожен — окремий агент.
-->

---

# Live: 3 Agent calls в одному turn

```text {all|1-3|5-9|11-14}{lines:true}
> Use 3 Explore subagents in parallel: auth, tests, build tooling

⏵ Agent(Explore, "find auth handlers and middleware")
⏵ Agent(Explore, "list test runners and test files")
⏵ Agent(Explore, "identify build/bundler configuration")

  ↳ subagent A: 18 sec, returns auth summary
  ↳ subagent B: 14 sec, returns test summary
  ↳ subagent C: 22 sec, returns build summary

⏴ Claude synthesizes:
   "Auth: JWT in src/auth/.
    Tests: vitest, 142 specs.
    Build: Vite, 3 config files."
```

<v-click class="mt-2 p-2 bg-amber-500/10 rounded text-sm">

⚠️ **Caveat:** «Running many subagents that each return detailed results can consume significant context» — кажуть docs. 3 — нормально, 10 — задумайся.

</v-click>

<!--
Wall-clock економія — велика: всі три йдуть разом. Token-overhead — 3× проти послідовно. Tradeoff на користь швидкості, якщо ти спостерігаєш.
-->

---

# Ізольований контекст: дисципліна

<v-clicks>

Subagent **не отримує**:

- Історію основної розмови
- Результати інших subagent-ів
- Skills, завантажені у parent (треба `skills:` у frontmatter)
- CLAUDE.md? **Так, читає** — те саме working directory

Subagent **отримує**:

- Свій system prompt (тіло md)
- Task prompt від main (точний, як написано)
- Базові env-деталі (working dir)
- Доступ до файлів (якщо tools дозволяють)

</v-clicks>

<v-click class="mt-2 p-3 bg-blue-500/10 rounded text-sm">

**Правило:** task prompt має бути **самодостатнім**. Не «продовж те, що ми обговорювали» — subagent цього не знає.

</v-click>

<DocRef url="https://code.claude.com/docs/en/subagents#context-and-communication" label="code.claude.com — Context isolation" />

<!--
Найчастіша помилка: «fix the bug» — subagent отримує лише ці слова, без контексту. Треба «fix the off-by-one in src/parser.ts:42 reported in test parser.spec.ts».
-->

---

# State sharing: 2 шляхи

<v-clicks>

**A. Summary returns** — default

```
[main] Agent("explore", "find tests")
       ↓
[subagent] does work, returns "found 142 specs in tests/"
       ↓
[main] reads summary, decides next step
```

**B. File-based artifacts** — для структурованих даних

```
[main] Agent("research", "investigate X, write findings to research.md")
       ↓
[subagent] writes research.md, returns "done, see research.md"
       ↓
[main] reads research.md, spawns next agent з reference на цей файл
```

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Subagent-и **діляться working directory** з main — файли видимі обом.
**Одночасних редагувань уникай:** немає file-locking між subagent-ами і main.

</v-click>

<!--
Цей патерн — основа exercise 4. Researcher пише, planner читає, reviewer читає обидва. Файли як shared memory.
-->

---

# Resume subagent

<v-clicks>

Кожен `Agent` call — **новий instance, чистий контекст**.
Щоб **продовжити** конкретного subagent-а:

- Claude отримує **agent ID** після завершення subagent-а
- Resumption через `SendMessage` tool з ID
- **`SendMessage` доступний лише при увімкнених agent teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

```text
> Use code-reviewer to review src/auth/
[Agent finishes, agent ID stored]

> Continue that review and now look at src/api/
[Claude resumes the subagent — full history preserved]
```

Транскрипти зберігаються:
```
~/.claude/projects/{project}/{sessionId}/subagents/agent-{id}.jsonl
```

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#resume-subagents" label="code.claude.com — Resuming subagents" />

<!--
Без agent teams увімкнених — кожен виклик starts fresh. Це by design, бо ізоляція. Якщо хочеш послідовність зі станом — використовуй файли або agent teams.
-->

---

# Foreground vs Background

| | Foreground | Background |
|--|---|---|
| **Блокує main?** | Так | Ні (concurrent) |
| **Permission prompts** | Передаються тобі через main | Pre-approved при спавні; auto-deny решти |
| **Clarifying questions** | Передаються тобі | Tool-call падає, subagent продовжує |
| **Default для default mode** | Так | Лише з `background: true` чи Ctrl+B |

<v-clicks>

**Як перейти у фон вручну:**
- Скажи: «run this in the background»
- Або **Ctrl+B** на запущеній задачі
- Вимкнути всі background: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#run-subagents-in-foreground-or-background" label="code.claude.com — Foreground vs background" />

<!--
Background — для тривалих задач, де ти хочеш продовжити чатитись. Foreground — коли результат потрібен прямо зараз.
-->

---

# Обмеження subagent-ів

<v-clicks>

1. **Не можуть спавнити інших subagent-ів** — flat hierarchy. Для вкладеного — Skill чи chain з main
2. **Немає mid-flight user interaction** — background subagent не може попросити дозвіл, який не пре-апрувлений
3. **Permissions фіксуються при спавні** — не міняються налету
4. **Не успадковують skills з parent** — `skills:` у frontmatter явно
5. **Plugin-subagent-и втрачають `hooks`, `mcpServers`, `permissionMode`** — security
6. **Forks (наслідування історії) — лише interactive** — не у `claude -p` headless
7. **Working dir shared, але `cd` не персистить між Bash-викликами**

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#fork-the-current-conversation" label="code.claude.com — Fork limitations" />

<!--
Ці шість обмежень — пастки, в які я падав на кожен. Закладай у дизайн. Особливо: "subagent не питає про permissions у фоні" — забудеш, кодор почне рефакторити те, що не можна.
-->

---
layout: section
---

# Agent Teams

Коли субагент-чейну стає замало

---

# Agent teams ≠ subagents

<v-clicks>

| | Subagents | Agent teams |
|--|---|---|
| **Контекст** | Свій, summary назад до main | Свій, повністю незалежний |
| **Комунікація** | Лише з main | Teammate ↔ teammate напряму |
| **Координація** | Main керує усім | Shared task-list, self-coordination |
| **Кому це для** | Сфокусовані задачі, де важливий результат | Складна робота з обговоренням, debate-ом |
| **Token cost** | Менше | Значно більше (кожен — повна сесія) |
| **Активація** | Завжди | Експериментальна, потребує env var |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/agent-teams#compare-with-subagents" label="code.claude.com — Compare" />

<!--
Subagent — твій підручний. Agent team — twoja проєктна команда зі своїм task-board-ом і чатом.
-->

---

# Вмикаємо agent teams

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

<v-clicks>

**Vergeissues:**
- Claude Code **v2.1.32+**
- Експериментально, поведінка може змінитися
- Split-pane mode потребує **tmux** або **iTerm2 + `it2` CLI**
- Не працює у VS Code terminal, Windows Terminal, Ghostty (split mode)
- Default mode — `auto` (split якщо в tmux, інакше in-process)
- Forc-нути in-process: `claude --teammate-mode in-process`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/agent-teams#enable-agent-teams" label="code.claude.com — Enable" />

<!--
Якщо ти на Linux/Mac — tmux уже є чи легко встановити. Спробуй split panes — наочніше. Windows Terminal не підтримує — там in-process.
-->

---

# Архітектура team

| Компонент | Роль |
|---|---|
| **Team lead** | Main session, що створила команду; координує |
| **Teammates** | Окремі Claude Code instances, кожен зі своїм context |
| **Task list** | Shared список робіт; teammate-и клеймлять |
| **Mailbox** | Inter-agent messaging (`SendMessage` tool) |

<v-clicks>

Зберігається локально:
```
~/.claude/teams/{team-name}/config.json
~/.claude/tasks/{team-name}/
```

- Lead **фіксований** на час життя team
- Lead не можна перекинути на teammate
- Teammate-и **не можуть створити вкладений team**
- Один lead — одна команда (no nested teams)

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/agent-teams#architecture" label="code.claude.com — Architecture" />

<!--
Файли team config-у не редагуй вручну — Claude їх перезапише. Це runtime state: session IDs, tmux pane IDs.
-->

---

# Use-case: parallel review

```text
> Create an agent team to review PR #142. Spawn three reviewers:
  - One focused on security implications
  - One checking performance impact
  - One validating test coverage
  Have them each review and report findings.
```

<v-clicks>

- Кожен reviewer працює незалежно з власним фокусом
- Lead синтезує наприкінці
- Якби один agent — застряг би на security, performance залишилось би сухо

</v-clicks>

<v-click class="mt-3">

**Use-case 2: competing hypotheses**

```text
> Spawn 5 teammates to investigate why the app exits after one message.
  Have them debate each other's theories scientifically. Update findings.md
  with whatever consensus emerges.
```

Дебат як механізм проти **anchoring** — одного теорема знайшов, далі біас.

</v-click>

<DocRef url="https://code.claude.com/docs/en/agent-teams#use-case-examples" label="code.claude.com — Use cases" />

<!--
Debate-pattern — мій улюблений. Один Claude знаходить ймовірну причину і зупиняється. Кілька Claude-ів сваряться — виживає правильна теорія.
-->

---

# Reuse subagent definitions

```text
> Spawn a teammate using the security-reviewer agent type to audit src/auth/
```

<v-clicks>

Як це працює:

- Lead може посилатися на існуюче subagent-визначення (project / user / plugin / CLI)
- Teammate **успадковує** `tools` і `model` з визначення
- Тіло визначення **дописується** до teammate-system-prompt-а (не замінює)
- **Не успадковуються:** `skills` і `mcpServers` — teammate вантажить їх з project + user settings нормально

</v-clicks>

<v-click class="mt-2 p-2 bg-emerald-500/10 rounded text-sm">

**Pattern:** одне визначення — і subagent, і teammate. Не дублюй.

</v-click>

<DocRef url="https://code.claude.com/docs/en/agent-teams#use-subagent-definitions-for-teammates" label="code.claude.com — Reuse definitions" />

<!--
Це чудово — пишеш `code-reviewer.md` один раз, використовуєш як `Agent`-call і як teammate.
-->

---

# Вправа 4 — мікро-команда як ланцюг

**Мета:** chain subagent-ів через файли (без agent-teams flag-а)

```bash
cd ../04-agent-team-chain
ls
# README.md  agents/  workdir/
```

<v-clicks>

**Кроки:**

1. Скопіюй `agents/` у `.claude/agents/`: 3 subagent-и — `researcher`, `planner`, `reviewer`
2. Поклади test-кейс у `workdir/task.md` (наприклад: «add caching to fetchUser»)
3. Скажи Claude:
   > «Use the researcher subagent to read task.md and write findings to research.md.
   > Then use the planner to read research.md and write plan.md.
   > Then use the reviewer to read both and write review.md.»
4. Спостерігай **3 послідовних `Agent` calls** через файли
5. Перевір артефакти у `workdir/`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/subagents#chain-subagents" label="code.claude.com — Chain pattern" />

<!--
15 хв. Це не agent teams — це imitation через subagent-chain. Простіше за teams, працює без experimental flag-а.
-->

---

# Live: chain через файли

```text {all|1-3|5-7|9-11|13}{lines:true}
> Use researcher → planner → reviewer chain on workdir/task.md

⏵ Agent(researcher, "read workdir/task.md, write workdir/research.md")
  ↳ writes research.md, returns "done"

⏵ Agent(planner, "read workdir/research.md, write workdir/plan.md")
  ↳ reads research.md, writes plan.md, returns "done"

⏵ Agent(reviewer, "read research.md and plan.md, write review.md")
  ↳ reads both, writes review.md, returns priorities

⏴ Main: reads review.md, presents to user
```

<v-click class="mt-2 p-2 bg-blue-500/10 rounded text-sm">

Chain працює бо **working directory shared**. Subagent-и не бачать одне одного, але бачать одні й ті самі файли.

</v-click>

<!--
Це повторно-використовуваний pattern. Researcher може бути загальним; ти підставляєш task.md.
-->

---

# Limitations agent teams (поточні)

<v-clicks>

- **Експериментальні** — поведінка може змінитися
- **`/resume` не відновлює in-process teammate-ів** — після resume lead може писати неіснуючим
- **Task status може лагати** — teammate забув mark-completed → блокує залежні
- **Shutdown повільний** — teammate завершує current request, тільки потім вимикається
- **Одна team на сесію** — не можна вкласти team в team
- **Permissions фіксуються при спавні** — змінити можна тільки після

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/agent-teams#limitations" label="code.claude.com — Limitations" />

<!--
Усе ще experimental — використовуй на playground-ах, не на prod-критичній сесії. У стабільному релізі — subagent chain (вправа 4) надійніший.
-->

---
layout: section
---

# Decision

Subagent / Team / Main

---

# Decision tree

<v-clicks>

```
Задача переді мною
 ├─ Швидкий цільовий fix у відомих файлах? → Main conversation
 ├─ Verbose output, який не знадобиться (логи, search)? → Explore subagent
 ├─ Multi-step research + дія? → general-purpose subagent
 ├─ 3+ незалежних investigation-ів? → Parallel subagent dispatch
 ├─ research → plan → implement → review послідовно? → Subagent chain (file-based)
 ├─ Workers мають дискутувати, challenge-ити одне одного? → Agent teams (експеримент.)
 └─ Те саме що минулий subagent, але з повним контекстом? → Fork (експеримент.)
```

</v-clicks>

<v-click class="mt-3 p-3 bg-emerald-500/10 rounded text-sm">

**Heuristic:** старт з main. Subagent — коли verbose output загрожує main-context-у. Team — коли координація між workers і є цінність.

</v-click>

<DocRef url="https://code.claude.com/docs/en/subagents#choose-between-subagents-and-main-conversation" label="code.claude.com — Choosing patterns" />

<!--
Не починай зі складного. Subagent — інструмент, не самоціль. Якщо main справляється, не треба ускладнювати.
-->

---

# Production-чек-ліст

<v-clicks>

Перед тим як коммітити subagent у `.claude/agents/`:

- [ ] **`name`** — kebab-case, унікальний
- [ ] **`description`** — front-load trigger, фрази «use proactively / immediately after»
- [ ] **`tools`** — мінімально-достатній allowlist (не все підряд)
- [ ] **`model`** — обираєш свідомо: `haiku` для простого, `sonnet` для аналізу
- [ ] **System prompt** — workflow з нумерованими кроками + формат виводу
- [ ] **Self-contained task prompt** — задокументовано що subagent очікує отримати
- [ ] **Test взаємодії** — і `@-mention`, і natural-language викликають правильно
- [ ] **`README.md`** у `.claude/agents/README.md` — для команди

</v-clicks>

<!--
Якщо хоча б один пункт пропустив — не публікуй. Особливо tools — найчастіша помилка «inherit all» рознесе тобі prod.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [code.claude.com/docs/en/subagents](https://code.claude.com/docs/en/subagents)
- [code.claude.com/docs/en/agent-teams](https://code.claude.com/docs/en/agent-teams)
- [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless)

</div>

<div>

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — готові розв'язки
- `handout.pdf` — повний референс
- Plan: workshop 11 = security

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Наступний воркшоп серії — 11-security. Будемо дивитися як НЕ дати subagent-у з bypassPermissions знести prod. Дякую!
-->
