---
theme: seriph
background: https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1920
title: "Workshop 04 — Skills: від ідеї до продакшну"
info: |
  ## Workshop 04 — Skills
  Claude Code Skills: пишемо, тригеримо, debug-имо, пакуємо у плагін
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 04

## Skills: від ідеї до продакшну

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · `exercises/` репо паралельно</div>

<!--
Привіт. Це четвертий воркшоп серії — про Claude Code Skills. У fundamentals ми бачили, що skill-и є; сьогодні пишемо їх з нуля, тестуємо тригери, розбиваємо великі через progressive disclosure, пакуємо у плагін. Усе через 4 вправи в `exercises/`. Тримай терміналом — паралельно зі мною.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Написати свій skill** — SKILL.md + frontmatter, поставити в `~/.claude/skills/` і `/skill-name`
- **Затригерити автоматично** — description, що Claude підхоплює без явного `/`
- **Розбити велике** на SKILL.md + `references/` (progressive disclosure)
- **Спакувати у plugin** — `plugin.json`, namespaced invocation
- **Diagnose** — чому skill не тригериться, що подивитись першим

</v-clicks>

<!--
Це не теорія — після воркшопу в тебе свій робочий skill, опублікований локально, а в репо `exercises/` готові 4 кроки які пройшли разом.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` зі свого терміналу
- **Ти кодиш паралельно** — `git clone <repo>; cd workshops/04-skills/exercises`
- **4 вправи** — кожна 10–15 хв, у власній підтеці
- **`solutions/`** — готові розв'язки на випадок, якщо застрягнеш
- **`handout.pdf`** — пост-воркшоп референс, ввечері передивишся

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: Claude Code v1.x, термінал, доступ до <code>~/.claude/</code>
</div>

<!--
Дай хвилину на клон. Хто не встиг — пиши в чат, я зачекаю.
-->

---
layout: section
---

# Контекст

Що таке skill і нащо він тобі

---

# Skill у двох словах

<v-clicks>

- **Markdown-файл** з YAML-frontmatter
- Лежить у `~/.claude/skills/<name>/SKILL.md` (особистий) або `.claude/skills/<name>/SKILL.md` (проєкт)
- Claude бачить **`description`** усіх skill-ів — це тригер
- Коли description "збігається" з запитом — Claude підвантажує **тіло SKILL.md** у контекст
- Виконує інструкції з тіла, як ти написав

</v-clicks>

<v-click>

```yaml {1-4|5-}{lines:true}
---
name: git-status-summary
description: Use when the user asks for a summary of the
  current git working tree state, what changed, what's staged.
---
Run `git status --short` and present grouped by section.
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Skills" />

<!--
Просто markdown. Frontmatter каже коли тригерити. Тіло — що робити. Усе.
-->

---

# Skill vs slash-command vs hook vs agent

| Що | Коли | Тригер |
|---|---|---|
| **Skill** | Шаблон поведінки/процес | `description` авто або `/name` |
| **Slash-command** | (Старе) — тепер злите зі skill | `/name` явний |
| **Hook** | Реакція на подію (`PreToolUse` тощо) | Подія Claude Code, не запит юзера |
| **Subagent** | Ізольований контекст, паралелізм | Claude через `Task` tool |
| **Plugin** | Контейнер для всього вище | `/plugin install` |

<v-click>

**Skill ≠ subagent.** Skill виконується в основному контексті, якщо не вказано `context: fork`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#custom-commands-have-been-merged-into-skills" label="code.claude.com — Commands merged into Skills" />

<!--
Ключове: slash-команди тепер це skill-и, формат об'єднаний. Hook не тригериться запитом юзера — це реакція на подію. Subagent — окрема історія, окремий воркшоп.
-->

---

# Mental model: progressive disclosure

3 рівні завантаження. Кожен наступний — дорожче.

<v-clicks>

| Рівень | Що | Коли | Розмір |
|---|---|---|---|
| **1. Метадата** | `name` + `description` | Завжди в контексті | ~50–150 токенів/skill |
| **2. Тіло SKILL.md** | Інструкції | Коли тригериться | 200–2000 токенів |
| **3. Supporting files** | `references/`, `scripts/` | Тільки якщо `SKILL.md` посилається | За запитом |

</v-clicks>

<v-click>

**Чому важливо:** description бачать УСІ сесії. Тіло — лише ті, де skill спрацював. Тримай SKILL.md `<500 рядків`, важке виноси у `references/`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#skill-content-lifecycle" label="code.claude.com — Skill content lifecycle" />

<!--
Це фундамент решти воркшопу. Якщо забереш одне — забери це. Метадата завжди коштує. Тіло коштує лише при тригері.
-->

---

# Скільки коштує токенів

<v-clicks>

- **Метадата (завжди):** ~100 токенів × N skill-ів. Якщо у тебе 50 skill-ів — це 5K токенів **кожної** сесії
- **Тіло (при тригері):** одноразово завантажується як system message
- **Auto-compaction:** після стиснення re-injection skill-ів обмежений 25K токенів сумарно
- **Бюджет описів:** масштабується dynamically як 1% контекстного вікна, fallback ~8K символів. Перевищиш — обрізають description-и (імена лишаються)

</v-clicks>

<v-click class="mt-4 p-3 bg-amber-500/10 rounded text-sm">

**Практично:** 1 skill з 200-символьним description ≈ 50 токенів метадати. Не страшно. Страшно — 100 skill-ів з 1500-символьними «pushy» описами.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short" label="code.claude.com — Description budget" />

<!--
Це число пам'ятай: 1% контекстного вікна = ~8K символів за замовчуванням. Якщо описи раптом перестали тригерити — перевір кількість і розмір skill-ів.
-->

---
layout: section
---

# Anatomy

Що всередині `SKILL.md`

---

# Структура теки

```
~/.claude/skills/git-status-summary/
├── SKILL.md          ← обов'язковий entry
├── scripts/          ← (опційно) bash/python utility
│   └── format.sh
├── references/       ← (опційно) doc-и, які Claude читає за запитом
│   ├── git-cheatsheet.md
│   └── examples.md
└── assets/           ← (опційно) шаблони, ікони
```

<v-clicks>

- **Тільки `SKILL.md`** — мінімум. Усе інше опційне
- **Підтеки** — назви довільні. `scripts/`, `references/`, `assets/` — convention, не примус
- **Naming**: `kebab-case`, лише букви/цифри/дефіси, ≤64 символів
- Якщо `name` у frontmatter не вказано → береться з імені теки

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Skill structure" />

<!--
Розпакуй найпростіший skill в одному файлі. Розкладай на теки лише коли SKILL.md починає рости.
-->

---

# Frontmatter: критичні поля

```yaml {all|2|3-4|5}{lines:true}
---
name: git-status-summary
description: Use when the user asks about current git state,
  uncommitted changes, what's staged, modified, or untracked.
allowed-tools: [Bash, Read]
---
```

<v-clicks>

- **`name`** — для `/`-меню. Якщо нема → тека. Lowercase, kebab-case
- **`description`** — головне. **Тригер для авто-інвокації**. Перші слова — найважливіше
- **`allowed-tools`** — пре-апрув tool-ів поки skill активний (без per-use prompt). Не **обмежує**, тільки апрувить

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

`description` + `when_to_use` сумарно ≤ 1536 символів.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#frontmatter-reference" label="code.claude.com — Frontmatter reference" />

<!--
Description — серце skill-у. На наступних слайдах розберемо як писати, щоб тригерило надійно.
-->

---

# Frontmatter: контроль інвокації

```yaml
---
name: deploy-prod
description: Deploy to production
disable-model-invocation: true
user-invocable: true
paths: ["**/*.tf", "deploy/**"]
---
```

<v-clicks>

- **`disable-model-invocation: true`** — Claude НЕ може сам викликати. Лише `/deploy-prod` від юзера
  - Для side-effects: deploy, drop database, push без CI
- **`user-invocable: false`** — навпаки: Claude може, юзер не бачить у `/`-меню
  - Для довідкових скілів-підказок
- **`paths`** — glob-обмеження. Skill авто-тригерить лише коли активні файли матчать
  - "Rust skill" — `paths: ["**/*.rs"]`

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills#control-who-invokes-a-skill" label="code.claude.com — Invocation control" />

<!--
disable-model-invocation — обов'язково для всього з side-effects. Інакше Claude рано чи пізно спрацює сам.
-->

---

# Frontmatter: ізоляція

```yaml
---
name: deep-research
description: Research a topic thoroughly across many sources
context: fork
agent: Explore
model: claude-sonnet
---
```

<v-clicks>

- **`context: fork`** — skill виконується у subagent-і. Окремий контекст, нема історії розмови
  - Тіло SKILL.md → task prompt subagent-а (не в основний контекст)
- **`agent`** — який тип subagent-а: `Explore`, `Plan`, `general-purpose`, або кастомний
- **`model`** — override моделі лише поки skill активний
- **`effort`** — `low|medium|high|xhigh|max`

</v-clicks>

<v-click class="mt-2 p-2 bg-emerald-500/10 rounded text-sm">

**Use case:** дослідження, code-analysis з купою файлів — не засмічуй основний контекст.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#run-skills-in-a-subagent" label="code.claude.com — Skills in subagent" />

<!--
context: fork — найкорисніший для довгих research-задач. Subagent повертає лише summary, основний контекст лишається чистим.
-->

---

# Frontmatter: аргументи

```yaml
---
name: bisect-issue
description: Bisect a regression between two commits
argument-hint: [good-sha] [bad-sha]
arguments: [good, bad]
---

Run `git bisect start $bad $good` and...
```

<v-clicks>

- **`argument-hint`** — підказка автокомпліту: `/bisect-issue [good-sha] [bad-sha]`
- **`arguments`** — іменовані позиційні. Підставляються як `$name` у тіло
- **`shell`** — `bash` (default) або `powershell`. Для `` !`команда` `` ін'єкцій

</v-clicks>

<v-click class="mt-2">

```yaml
---
name: pwd-info
shell: bash
---
Current dir: !`pwd`
Latest commit: !`git log -1 --oneline`
```

Backticks-команди виконаються **до** того, як skill потрапить до Claude.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#inject-dynamic-context" label="code.claude.com — Dynamic context injection" />

<!--
Динамічна ін'єкція через !-backticks — потужно. Поточна гілка, статус, версія node — підкидаєш у контекст без зайвого tool-call.
-->

---

# Тіло SKILL.md

<v-clicks>

- **Markdown** — заголовки, списки, таблиці, code blocks
- **Імперативно**: «You MUST», «Always», «Never» — Claude слухає
- **Структура важлива**: чек-листи, нумеровані кроки, decision-flowchart
- **Можна вставляти graphviz/digraph** — Claude їх читає
- **Цільовий розмір**: до **500 рядків**. Більше — розбий на `references/`

</v-clicks>

<v-click>

```markdown
# Skill: git-status-summary

You MUST run `git status --short` first.

## Process
1. Parse output by section: staged, unstaged, untracked
2. Group files by extension
3. Highlight files >100 KB (likely accidental)

## Edge cases
- Empty repo → return "(clean)"
- Detached HEAD → prefix output with warning
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills" label="code.claude.com — Writing skill content" />

<!--
Тіло читається як інструкція колезі. Кроки — нумеровані. Edge cases — окремою секцією. Claude захопить структуру.
-->

---

# Розбиття на references/

Коли SKILL.md перетинає ~500 рядків — пора розбивати.

<v-clicks>

```
cloud-deploy/
├── SKILL.md             ← workflow + вибір платформи
└── references/
    ├── aws.md           ← деталі AWS
    ├── gcp.md           ← деталі GCP
    └── azure.md         ← деталі Azure
```

- **SKILL.md** — оверв'ю + decision tree («якщо AWS → див. `references/aws.md`»)
- **references/*.md** — деталі. Claude читає лише те, на що SKILL.md посилається
- **Економія токенів**: при invocation вантажиться лише оверв'ю, ~200 рядків замість 1500

</v-clicks>

<v-click class="mt-2 p-3 bg-blue-500/10 rounded text-sm">

**Важливо:** покликання у SKILL.md мусять бути **markdown-link-ами**: `[aws.md](references/aws.md)`. Інакше Claude не зрозуміє, що це підвантажуваний файл.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#add-supporting-files" label="code.claude.com — Supporting files" />

<!--
Це основа progressive disclosure. Скоро будемо робити це у вправі 3.
-->

---
layout: section
---

# Hands-on

4 вправи. Терміналом паралельно.

---

# Вправа 1 — пишемо першу

**Мета:** робочий skill `git-status-summary` у `~/.claude/skills/`

```bash
cd workshops/04-skills/exercises/01-first-skill
cat README.md
```

<v-clicks>

**Кроки:**
1. `mkdir -p ~/.claude/skills/git-status-summary`
2. Копіюємо `starter/SKILL.md` туди
3. Дивимось, що `/git-status-summary` з'явився у `/`-меню
4. Запускаємо явно: `/git-status-summary`
5. Закриваємо `/` — питаємо неявно: «який стан гіту в репо?»
6. Перевіряємо: чи спрацював skill

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 10 хв. `solutions/01-first-skill/` — готове.

</v-click>

<!--
Якщо `/`-меню не показало — перевір шлях `~/.claude/skills/<name>/SKILL.md` точно. Один з найчастіших факапів. Дай 10 хв.
-->

---

# Live: SKILL.md крок-за-кроком

```yaml {all|2-3|5-7|9-}{lines:true}
---
name: git-status-summary
description: Use when the user asks for the current git working
  tree state, what's staged, modified, or untracked.
allowed-tools: [Bash]
---

# git-status-summary

Run `git status --short --branch` and present:

1. **Branch line** — name, ahead/behind
2. **Staged** (lines starting with `M `, `A `, `D `)
3. **Unstaged** (` M`, ` D`)
4. **Untracked** (`??`)

Group within each section by file extension.
Highlight files >100 KB with a ⚠️ note.
```

<!--
Розкладемо рядково. Frontmatter — три критичні поля. Тіло — 4 секції з нумерованими кроками. Готово до тестування.
-->

---

# Вправа 1: тестуємо тригер

```text
/                                                    ← бачимо у меню?
/git-status-summary                                  ← явний виклик
```

<v-clicks>

Тепер **неявний**:

```text
> який зараз стан гіту тут?
```

- Claude **бачить** description («the current git working tree state»)
- Якщо запит семантично збігається — авто-інвокація
- **Не спрацювало?** → ми про це у Section 5 (debug)

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **Caveat від Anthropic:** Claude свідомо НЕ тригерить skill-и для одношагових задач, які він тривіально вирішує сам. «Покажи статус» може не тригернути — занадто простий.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#troubleshooting" label="code.claude.com — Troubleshooting" />

<!--
Це ключовий момент. Не панікуй якщо неявний виклик не спрацював на простому запиті — це by design.
-->

---

# Вправа 2 — description tuning

**Мета:** зрозуміти, що в description тригерить, а що ні.

```bash
cd ../02-trigger-tuning
ls
# A-vague.md   B-specific.md   C-pushy.md
```

<v-clicks>

3 варіанти description для одного skill `bundle-size-check`:

- **A. Vague:** "Check bundle size"
- **B. Specific:** "Check JavaScript bundle size after a build. Use when user asks about bundle weight, bloat, dependency size impact, or wants to compare before/after build sizes."
- **C. Pushy:** "**MANDATORY:** invoke whenever user mentions bundle, weight, dependency size, dist size, build output, or any concern about JavaScript payload. Even subtle hints — trigger this."

</v-clicks>

<v-click>

**Завдання:** по черзі підмінити SKILL.md, перезапустити Claude (або `/reload-plugins`), задати 5 тестових запитів. Заповнити `tests-table.md` — що тригерило.

</v-click>

<!--
15 хв. Хто закінчить раніше — допоможи сусідові. Очікуваний результат: A не тригерить майже нічого, B тригерить на явні запити, C — навіть на дотичні.
-->

---

# Розбір вправи 2

| Тип description | Тригер на «який стан bundle?» | На «чи багато залежностей?» |
|---|---|---|
| A. Vague | ❌ | ❌ |
| B. Specific | ✅ | ⚠️ іноді |
| C. Pushy | ✅ | ✅ |

<v-clicks>

**Висновки:**

- **Action verbs** + **конкретні контексти** > загальні слова
- **«Pushy» description** свідомо борить тенденцію Claude недо-тригерити
- **Перерахуй синоніми** — як юзер може сказати: «bundle», «weight», «size», «bloat»
- **Назви WHAT і WHEN** — не лише що skill робить, а **коли** його юзати

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills#frontmatter-reference" label="code.claude.com — Description tips" :offset="1" />
<DocRef url="https://code.claude.com/docs/en/skills#troubleshooting" label="code.claude.com — Why skills don't trigger" />

<!--
Pushy не означає «брехливий». Означає — явно вказати «MUST use», «whenever», «even when subtle». Anthropic у docs про це прямо пише.
-->

---

# Red flags для description

<v-clicks>

❌ **Занадто загально:** «Helpful tips for code»
✅ Конкретно: «Use when working with REST API endpoint design...»

❌ **Без action verb:** «Code explanations»
✅ З дієсловом: «Explains code with diagrams. Use when user asks how X works»

❌ **Занадто вузько:** «Fix bugs in TypeScript files only»
✅ Узагальнено: «Diagnose and fix runtime errors in TypeScript or JavaScript»

❌ **Закопаний use case:** description починається з «This skill provides...»
✅ Front-load: перші 50 символів — найважливіший trigger

❌ **Дублювання назви:** description повторює `name`
✅ Description розкриває **коли** і **навіщо**

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills#troubleshooting" label="code.claude.com — Description red flags" />

<!--
П'ять red flag-ів, які бачу найчастіше при ревью чужих skill-ів. Кожен має фікс.
-->

---

# Вправа 3 — progressive disclosure

**Мета:** розбити роздутий skill на SKILL.md + references/

```bash
cd ../03-progressive-disclosure
wc -l starter/SKILL.md
# 612 starter/SKILL.md   ← забагато
```

<v-clicks>

**Кроки:**

1. Відкрий `starter/SKILL.md` — це skill для деплою на 3 хмари (AWS/GCP/Azure)
2. Виділи **спільний** workflow і **специфічну** частину для кожної хмари
3. Залиш у SKILL.md:
   - Опис, decision-tree (яку хмару)
   - **Markdown-посилання** на `references/<cloud>.md`
4. Створи `references/aws.md`, `gcp.md`, `azure.md`
5. Перевір: SKILL.md тепер ≤ 200 рядків
6. Тригерни skill — перевір що Claude читає лише потрібний reference

</v-clicks>

<!--
15 хв. Це найскладніша вправа. Якщо застрягнеш на decision-tree — підглянь у solutions/.
-->

---

# Чому це працює

```markdown {all|6-9}{lines:true}
# Cloud Deploy Skill

Decide platform from project files:
- `terraform/aws/` → AWS
- `gcloud-config.yaml` → GCP
- `bicep/` or `.azure/` → Azure

For AWS: read [aws.md](references/aws.md)
For GCP: read [gcp.md](references/gcp.md)
For Azure: read [azure.md](references/azure.md)
```

<v-clicks>

- **Markdown links** — Claude розпізнає як supporting файли
- **Не вантажить усі** — тільки той, на який decision-tree вказав
- **Економія**: 612 рядків → 60 в SKILL.md + 200 рядків AWS-reference (потрібного)

</v-clicks>

<v-click class="mt-2 p-3 bg-emerald-500/10 rounded text-sm">

**Перевірка економії:** до — 4K токенів кожен trigger. Після — ~600 токенів + (за потреби) 1.4K у reference. Виграш ×2–3.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#add-supporting-files" label="code.claude.com — Progressive disclosure" />

<!--
Magic тут — не у складності. У дисципліні. Один файл, один рівень абстракції.
-->

---

# Вправа 4 — пакуємо у plugin

**Мета:** зробити з твоїх skill-ів встановлюваний плагін

```bash
cd ../04-package-skill
tree starter/
```

<v-clicks>

```
my-git-toolkit/
├── .claude-plugin/
│   └── plugin.json          ← маніфест
└── skills/
    ├── git-status-summary/
    │   └── SKILL.md
    └── git-bisect-helper/
        └── SKILL.md
```

**Кроки:**

1. Створи `plugin.json` з `name`, `description`, `version`, `author`
2. Перенеси два skill-и під `skills/`
3. Локально встанови: `claude --plugin-dir ./my-git-toolkit` (одна сесія)
4. Тригерни: `/my-git-toolkit:git-status-summary` ← namespaced!
5. (Бонус) Опублікуй у git-репо, додай до marketplace

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins#create-your-first-plugin" label="code.claude.com — Create plugin" />

<!--
15 хв. Namespacing — `/plugin-name:skill-name` — конфлікти імен між плагінами не страшні.
-->

---

# plugin.json — мінімум

```json
{
  "name": "my-git-toolkit",
  "description": "Git workflow skills: status summary, bisect helper",
  "version": "0.1.0",
  "author": {
    "name": "Vadym Bondarenko"
  }
}
```

<v-clicks>

- **`name`** — обов'язково. Кебаб-кейс. Стає префіксом інвокації
- **`version`** — опційно. Якщо нема — Claude бере commit SHA
  - **Set explicit** для semver (`0.1.0` → `0.2.0` коли ламаєш API)
  - **Skip** для rolling updates (юзер бачить кожен коміт)
- **`description`, `author`** — для marketplace UI

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

⚠️ Не клади `commands/`, `agents/`, `skills/`, `hooks/` всередину `.claude-plugin/`. Тільки `plugin.json`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/plugins#create-plugins" label="code.claude.com — Plugin manifest" />

<!--
Найчастіший факап — `skills/` у `.claude-plugin/`. Не працює. Skills/ на рівні плагіна, не всередині .claude-plugin/.
-->

---
layout: section
---

# Debug

Skill не працює. Що першим перевірити.

---

# Skill не тригериться: 6 кроків

<v-clicks>

1. **`/`-меню видно?**
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

6. **Запит надто простий?** Claude не тригерить skill для one-step тривіальностей

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills#troubleshooting" label="code.claude.com — Troubleshooting" />

<!--
Я використовую цей чек-ліст уже два роки. 90% проблем — на кроках 1–2.
-->

---

# Skill у меню але «disabled»

<v-clicks>

**Причини:**

- **`disable-model-invocation: true`** — by design, Claude не може. Лише `/name` від тебе. Це не баг
- **`user-invocable: false`** — навпаки: ти не бачиш, Claude бачить. Тоді skill **не з'являється у меню взагалі**, а не disabled
- **Conflict з іншим skill** — однакова `name` у проєкті й користувача. Дивимось precedence:

```
Enterprise > Personal (~/.claude/) > Project (.claude/)
```

Plugin skills — окремий namespace (`/plugin:skill`), тому **не конфліктують** з ланцюгом вище.

</v-clicks>

<v-click class="mt-2 p-3 bg-blue-500/10 rounded text-sm">

**Найчастіше:** проєктний skill **перебивається** твоїм personal-skill з тією ж назвою. Перейменуй один.

</v-click>

<DocRef url="https://code.claude.com/docs/en/skills#where-skills-live" label="code.claude.com — Skills hierarchy" />

<!--
Precedence я плутав довго. Запам'ятай: ентерпрайз > personal > project > plugin. Project НЕ перебиває personal.
-->

---

# Бюджет описів і `/reload-plugins`

<v-clicks>

**Бюджет descriptions:**

- 1% контекстного вікна (fallback ~8K символів)
- 100+ skill-ів з довгими description — description-и обрізаються (імена завжди в контексті)
- Підняти: `SLASH_COMMAND_TOOL_CHAR_BUDGET=16000` env var
- Або: коротші description, особливо для рідко-юзаних skill-ів

**`/reload-plugins`:**

- Зміна skill-а у `~/.claude/skills/` чи `.claude/skills/` — **auto-reload**, без перезапуску
- Зміна **plugin** skill — потрібен `/reload-plugins`
- Створив сам `.claude/skills/` (вперше у проєкті) → restart обов'язковий. Нова підтека skill-а в існуючій — auto

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short" label="code.claude.com — Description budget" />

<!--
Цей бюджет — найрідше згаданий під капотом. Якщо у тебе 100+ skill-ів, неминуче упрешся.
-->

---
layout: section
---

# Production-готовність

---

# Чек-ліст перед публікацією

<v-clicks>

- [ ] **`name`** — kebab-case, унікальний у твоєму неймспейсі
- [ ] **`description`** — front-load trigger, action verb, синоніми
- [ ] **SKILL.md ≤ 500 рядків**, важке у `references/`
- [ ] **Markdown-links** на supporting файли (не plain text)
- [ ] **`allowed-tools`** — пре-апрув лише потрібного, не all
- [ ] **`disable-model-invocation: true`** для всього з side-effects
- [ ] **Тестовано неявно** — не лише `/skill-name`, а й семантичні запити
- [ ] **README.md** у репо — як встановити, що робить
- [ ] **`version`** у plugin.json якщо semver

</v-clicks>

<!--
Якщо хоча б один пункт не виконано — не публікуй. Чужі люди використають.
-->

---

# Distribution: 3 шляхи

| Спосіб | Локація | Кому | Інвокація |
|---|---|---|---|
| **Project** | `.claude/skills/` (commit) | Команді | `/skill-name` |
| **Personal** | `~/.claude/skills/` | Тільки собі | `/skill-name` |
| **Plugin** | git-репо + marketplace | Усім бажаючим | `/plugin:skill` |

<v-clicks>

**Коли що:**

- **Project skill** → команді треба той самий workflow. Commit, code review, версіонування разом з кодом
- **Personal** → твої утиліти, які не хочеш у репо. Або ще не дозріло до плагіна
- **Plugin** → продаєш ідею ширше. Marketplace, namespace, semver

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/plugins" label="code.claude.com — Plugins" />

<!--
Personal — найшвидший прототип. Зріє до plugin-у, коли кілька друзів попросили.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
- [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)
- [agentskills.io](https://agentskills.io)

</div>

<div>

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — готові розв'язки
- `handout.pdf` — повний референс
- Plan: workshop 06 = plugins deep

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Наступний воркшоп серії — 05-hooks. Schedule зараз. Дякую!
-->
