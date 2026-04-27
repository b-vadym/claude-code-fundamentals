---
theme: seriph
background: https://images.unsplash.com/photo-1518770660439-4636190af475?w=1920
title: "Workshop 08 — Headless / CI/CD: Claude Code у пайплайні"
info: |
  ## Workshop 08 — Headless / CI/CD
  Productionizing `claude -p`: output formats, permission allowlists, auth у CI, GitLab/GitHub templates, cost ceilings.
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 08

## Headless / CI/CD: Claude Code у пайплайні

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · `exercises/` репо паралельно</div>

<!--
Привіт. Восьмий воркшоп — продакшн серії «Claude Code in Production». У token-economy ми бачили `claude -p "review MR"` як трюк для економії — сьогодні робимо це нормальним пайплайном: stream-json, allowlist-и, OIDC-auth, обмеження вартості. Тримай терміналом — паралельно зі мною.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Запустити `claude -p`** з парсингом `--output-format json` через `jq`
- **Спроєктувати allowlist** для headless: що тригерить, що блокувати
- **Налаштувати auth у CI** без браузера: API key, OAuth token, OIDC
- **Написати `.gitlab-ci.yml`** для AI-ревʼю MR — від нуля до робочого джоба
- **Поставити стелю** на витрати: `--max-turns`, `--max-budget-usd`, безпечні дефолти

</v-clicks>

<!--
Це не теорія. Після воркшопу в тебе робочий job у `.gitlab-ci.yml`, який ревʼює MR і коментує діф. Усе через 4 вправи в exercises/.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` із свого терміналу
- **Ти кодиш паралельно** — `cd workshops/08-headless-ci/exercises`
- **4 вправи** — кожна 10–20 хв, у власній підтеці
- **`solutions/`** — готові розвʼязки на випадок, якщо застрягнеш
- **`handout.pdf`** — пост-воркшоп референс

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: Claude Code v1.x, термінал, <code>jq</code>, доступ до GitLab/GitHub репо для вправ 3–4
</div>

<!--
Дай хвилину на клон і перевірку `claude --version`. Хто не встиг — пиши в чат, я зачекаю.
-->

---
layout: section
---

# Контекст

`claude -p` — і чому це не просто «без UI»

---

# Що таке headless

<v-clicks>

- **`claude -p "<prompt>"`** — non-interactive mode, exit після відповіді
- Раніше називалося «headless» — тепер просто `-p` flag
- **Працює в одному ряду з усім CLI:** хоч `--add-dir`, хоч `--mcp-config`
- **Призначене для скриптів і CI** — там, де нема людини на іншому кінці

</v-clicks>

<v-click>

```bash {1|3-4|6-7}{lines:true}
claude -p "What does the auth module do?"

# З парсингом JSON:
claude -p "Summarize this project" --output-format json | jq -r '.result'

# З обмеженням ітерацій:
claude -p "Fix the failing tests" --max-turns 5 --allowedTools "Bash,Read,Edit"
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless" label="code.claude.com — Run Claude Code programmatically" />

<!--
Quote з docs: «The CLI was previously called headless mode. The -p flag and all CLI options work the same way.» Усе CLI — у твоєму розпорядженні. Сьогодні зосередимось на тих flag-ах, які матерять у пайплайні.
-->

---

# Headless ≠ interactive: що зникає

<v-clicks>

- **Permission prompts** → нема. Тригернеш `Bash` без allowlist — просто впаде
- **Skills `/commit` тощо** — недоступні в `-p`. Описуй задачу прозою
- **Auto mode** — повторні блоки (3-in-a-row або 20-total) пауза, у `-p` пауза = abort, бо нема кого спитати
- **Plan mode interactivity** — нема UI «approve plan»; працює лише як readonly-режим
- **`@claude` mention listeners** — це окрема надбудова (GitLab MCP / GitHub Action), не сам `-p`

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **Quote:** «User-invoked skills like `/commit` and built-in commands are only available in interactive mode. In `-p` mode, describe the task you want to accomplish instead.»

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#create-a-commit" label="code.claude.com — Headless examples" />

<!--
Це з власного досвіду — багато людей переносять інтерактивний workflow у CI і дивуються, чому skill-и не працюють. Опиши прозою — Claude розбереться.
-->

---

# `--bare`: окремий режим для CI

<v-clicks>

- **`claude --bare -p "..."`** — пропускає auto-discovery
- **Що пропускає:** hooks, skills, plugins, MCP servers, auto memory, `CLAUDE.md`
- **Чому корисне:** однаковий результат на будь-якій машині — нема впливу `~/.claude/` колеги
- **Інструменти за замовчуванням:** Bash, file Read, file Edit (інші — додавай явно)

</v-clicks>

<v-click>

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

</v-click>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

⚠️ **Caveat:** bare mode **не читає** `CLAUDE_CODE_OAUTH_TOKEN`. Тільки `ANTHROPIC_API_KEY` або `apiKeyHelper`. Bedrock/Vertex — як зазвичай.

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#start-faster-with-bare-mode" label="code.claude.com — Bare mode" />

<!--
Quote: «Bare mode is the recommended mode for scripted and SDK calls, and will become the default for -p in a future release.» Уже зараз — best practice для CI.
-->

---
layout: section
---

# Output formats

text → json → stream-json

---

# Три формати, три кейси

```bash {all|1|3|5}{lines:true}
claude -p "Explain auth.py" --output-format text          # default
claude -p "Explain auth.py" --output-format json
claude -p "Explain auth.py" --output-format stream-json --verbose
```

<v-clicks>

| Формат | Коли | Парсинг |
|---|---|---|
| **`text`** | Локально дивишся в термінал | `cat`/глаз |
| **`json`** | CI: один результат, метадані | `jq -r '.result'` |
| **`stream-json`** | UI з real-time прогресом, моніторинг подій | newline-delimited events + `jq` |

</v-clicks>

<v-click class="mt-3 p-3 bg-blue-500/10 rounded text-sm">

**Для CI:** використовуй `json`, якщо треба фінальний результат + метадані. `stream-json` — якщо хочеш ловити проміжні події (retry, plugin errors, partial deltas).

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#get-structured-output" label="code.claude.com — Output formats" />

<!--
Це найважливіший вибір у CI. Більшість job-ів — json + jq. Stream-json — коли потрібен моніторинг прогресу або обробка retry-подій.
-->

---

# `--output-format json`: що всередині

```json {all|2|3}{lines:true}
{
  "result": "The auth module handles JWT validation...",
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "structured_output": null
}
```

<v-clicks>

- **`result`** — текстова відповідь Claude (те, що в interactive ти бачиш на екрані)
- **`session_id`** — UUID сесії; зберігай для `--resume`
- **`structured_output`** — заповнюється якщо передано `--json-schema`
- Документовані поля — лише ці. Решта metadata (usage, model, cost) еволюціонує — звіряй з `claude -p ... --output-format json | jq` поточної версії

</v-clicks>

<v-click class="mt-3">

```bash
result=$(claude -p "Review this MR" --output-format json)
text=$(echo "$result" | jq -r '.result')
echo "::notice::$text"
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#get-structured-output" label="code.claude.com — JSON output" />

<!--
Точна структура JSON — у docs. Я кладу в research.md лінк. У моніторингу витрат `total_cost_usd` критичний — звідти будеш робити alarm-и.
-->

---

# Schema-validated output: `--json-schema`

```bash {all|3-4}{lines:true}
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{
    "functions":{"type":"array","items":{"type":"string"}}},
    "required":["functions"]}' \
  | jq '.structured_output'
```

<v-clicks>

- **Гарантія типу** — Claude поверне валідну JSON-схему або помилку
- **Поле `.structured_output`** — окремо від `.result` (не плутай)
- **Use case:** скрипти, де ти будуєш downstream-логіку на масиві `functions`
- **Альтернатива JSON Schema** — Agent SDK (Python/TypeScript) з нативними типами

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/headless#get-structured-output" label="code.claude.com — Structured outputs" />

<!--
Якщо обробляєш результат у shell — `--json-schema` рятує від «ну зазвичай Claude повертає список». Гарантія, не сподівання.
-->

---

# `stream-json`: події

```bash
claude -p "Write a poem" --output-format stream-json --verbose | jq .
```

<v-clicks>

| Тип події | Коли | Корисно для |
|---|---|---|
| `system/init` | Перша подія сесії | Перевірка `plugin_errors` → fail CI якщо плагін не завантажився |
| `system/api_retry` | Retryable error → retry | Моніторинг rate-limit-ів, кастомний backoff |
| `system/plugin_install` | З `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` | UI прогрес встановлення |
| `stream_event` | З `--include-partial-messages` | Token-by-token UI |

</v-clicks>

<v-click>

```bash
# Filter just the streaming text deltas:
claude -p "..." --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type=="stream_event" and .event.delta.type?=="text_delta") | .event.delta.text'
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#stream-responses" label="code.claude.com — Stream events" />

<!--
Stream-json — коли треба будувати UI або CI-моніторинг. system/init з plugin_errors — недооцінений лайфхак: без нього silent-fail плагінів проґавиш.
-->

---
layout: section
---

# Permissions у headless

Allowlist, deny, mode — без людини на іншому кінці

---

# Чому це болить у `-p`

<v-clicks>

- В interactive: Claude хоче запустити `Bash(rm -rf node_modules)` → промт «Allow? [y/N]» → ти приймаєш рішення
- У `-p`: **нема кого спитати**. Промт = job висить → timeout
- **Рішення:** заздалегідь скажи, що дозволено
- **Інструменти:** `--allowedTools`, `--disallowedTools`, `--tools`, `--permission-mode`

</v-clicks>

<v-click class="mt-3 p-3 bg-rose-500/10 rounded text-sm">

🚨 **Найчастіший факап:** забув allowlist → пайплайн hangs до timeout-у → 60 хв змарновано на runner-і.

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#auto-approve-tools" label="code.claude.com — Auto-approve tools" />

<!--
Бачив це сто разів. У моніторингу job-ів `claude -p` — якщо тривалість > 10 хв і тести нема — на 99% це permission prompt у вакуумі.
-->

---

# `--allowedTools` + permission rule syntax

```bash {all|2|3-4}{lines:true}
claude -p "Look at staged changes and create a commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

<v-clicks>

- **Синтаксис:** `Tool(matcher)` — `Tool` без матчера = повний tool
- **Glob:** `*` — стандартний; **пробіл перед `*` обовʼязковий!**
- ❌ `Bash(git diff*)` → також матчить `git diff-index` (не те!)
- ✅ `Bash(git diff *)` → лише команди, що починаються з `git diff `

</v-clicks>

<v-click>

```bash
# Read-only Bash для review-job-а:
--allowedTools "Bash(git diff *),Bash(git log *),Bash(cat *),Read"

# Edit-доступ для apply-fix:
--allowedTools "Bash(npm test),Bash(npm run lint),Read,Edit,Write"
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/headless#create-a-commit" label="code.claude.com — Permission rule syntax" />

<!--
Quote з docs: «The space before `*` is important: without it, `Bash(git diff*)` would also match `git diff-index`.» Це автентичний approval-рядок з docs — кладу як «золотий стандарт» allowlist для commit-job-а.
-->

---

# `--permission-mode`: 6 режимів

| Mode | Що автоприймає | CI use case |
|---|---|---|
| `default` | Reads only | Sensitive review |
| `acceptEdits` | Reads + edits + common fs (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`) | Apply-fix у MR |
| `plan` | Reads only | Readonly research |
| `auto` | Майже все, з classifier | ❌ Не для `-p` (повторні блоки → abort) |
| **`dontAsk`** | Тільки allow-rules + read-only | ✅ Locked-down CI |
| `bypassPermissions` | Все, окрім protected paths | Containers/VMs only |

<v-clicks>

- **`dontAsk`** — спеціально для CI. Quote: «useful for locked-down CI runs»
- **`auto`** — class пауза при 3-in-a-row або 20-total блоках. У `-p` пауза = **abort**. Не використовуй
- **`bypassPermissions`** — лише в ізольованому container-і. Інакше небезпечно

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/permission-modes" label="code.claude.com — Permission modes" />

<!--
Якщо забереш одне зі слайда — забери дві річі: dontAsk для CI, ніколи auto для -p. Auto спеціально документоване як «aborts in non-interactive mode».
-->

---

# Allowlist у `settings.json`

Альтернатива CLI-flag-ам — конфіг-файл, який можна versioning-ом тримати в репо:

```json {all|2-7|8-13|14}{lines:true}
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm run build)",
      "Read(.)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "WebFetch",
      "Bash(curl *)"
    ],
    "defaultMode": "dontAsk"
  }
}
```

<v-click>

```bash
claude -p "..." --settings ./ci-settings.json
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/settings" label="code.claude.com — Settings reference" />

<!--
deny — оцінюється першим. Завжди явно denyʼ .env і secrets/**, навіть якщо здається параноєю. Бо `Read(.)` рекурсивно — і випадково Claude натрапить на .env, який ти забув гітіґнорити.
-->

---

# Protected paths: те, що ніколи

<v-clicks>

Незалежно від mode — Claude **не може** автоприймати запис у:

- **Директорії:** `.git`, `.vscode`, `.idea`, `.husky`
- **`.claude`** (з винятками для `commands/`, `agents/`, `skills/`, `worktrees/`)
- **Файли:** `.gitconfig`, `.gitmodules`, `.bashrc`/`.zshrc`/`.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

</v-clicks>

<v-click class="mt-3 p-3 bg-blue-500/10 rounded text-sm">

**У `-p` режимі:** запис у protected path → промт → у `dontAsk` → deny → задача аборт. Це by design: захищає стан репо і твій конфіг.

</v-click>

<DocRef url="https://code.claude.com/docs/en/permission-modes#protected-paths" label="code.claude.com — Protected paths" />

<!--
Це автоматичний захист від «Claude вирішив переписати .git/config». Не вимикається. Добре.
-->

---
layout: section
---

# Auth у CI

API key vs OAuth token vs OIDC

---

# Precedence: 6 джерел auth

<v-clicks>

```
1. Cloud (CLAUDE_CODE_USE_BEDROCK / VERTEX / FOUNDRY)
2. ANTHROPIC_AUTH_TOKEN  (Bearer header — для LLM-gateway)
3. ANTHROPIC_API_KEY     (X-Api-Key — direct Anthropic API)
4. apiKeyHelper          (script для rotating creds)
5. CLAUDE_CODE_OAUTH_TOKEN  (long-lived OAuth → subscription)
6. /login OAuth          (default для Pro/Max/Team/Enterprise)
```

</v-clicks>

<v-click class="mt-2">

**У `-p` режимі:** `ANTHROPIC_API_KEY` завжди використовується якщо presented (не питає approval).

</v-click>

<v-click class="mt-2 p-3 bg-rose-500/10 rounded text-sm">

🚨 **Trap:** маєш subscription, але `ANTHROPIC_API_KEY` залишився в env → ключ переб'є subscription. Якщо ключ від мертвої організації → auth fail. Fix: `unset ANTHROPIC_API_KEY`.

</v-click>

<DocRef url="https://code.claude.com/docs/en/authentication#authentication-precedence" label="code.claude.com — Auth precedence" />

<!--
Це найважливіша таблиця auth-і. На воркшопі обведу її маркером. Запам'ятай: cloud > bearer > api key > helper > oauth.
-->

---

# `claude setup-token` для CI

Browser-login недоступний → треба long-lived OAuth token.

```bash
claude setup-token
# Walks through OAuth → prints token to terminal
# Does NOT save anywhere

export CLAUDE_CODE_OAUTH_TOKEN=your-token
```

<v-clicks>

- **1 рік** валідності
- **Subscription auth** — потребує Pro / Max / Team / Enterprise
- **Inference only** — не може Remote Control
- **Друкує в термінал, не зберігає** → клади в secret manager відразу
- **Bare mode не читає** цю змінну → для `--bare` потрібен API key

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/authentication#generate-a-long-lived-token" label="code.claude.com — Generate long-lived token" />

<!--
Це відповідь на питання «у мене Max, як CI-token зробити?» — не API key з Console, а саме setup-token. Жми бекап у Vault, бо при втраті — генеруй заново.
-->

---

# `apiKeyHelper`: rotating creds

```json
{
  "apiKeyHelper": "/usr/local/bin/get-api-key.sh"
}
```

<v-clicks>

- Скрипт виводить API key у stdout
- Викликається кожні **5 хвилин** або на HTTP **401**
- Тюнинг: `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`
- Якщо повільніший за 10 секунд — UI-warning у prompt bar

</v-clicks>

<v-click>

```bash
#!/usr/bin/env bash
# get-api-key.sh — pull from Vault each call
vault kv get -field=key secret/anthropic
```

</v-click>

<v-click class="mt-2 text-sm opacity-70">

**Use case:** короткоживучі ключі з vault, ротація без перезапуску job-а.

</v-click>

<DocRef url="https://code.claude.com/docs/en/authentication#credential-management" label="code.claude.com — apiKeyHelper" />

<!--
Корисно для довгих job-ів. У 30-хвилинному review-job-і ключ може зротуватись посередині — helper це переживе, статичний env — ні.
-->

---

# OIDC: zero-secret для cloud

<v-clicks>

- **GitLab → AWS:** `aws sts assume-role-with-web-identity` через `CI_JOB_JWT_V2`
- **GitLab → GCP:** Workload Identity Federation з external_account creds
- **GitHub → AWS:** `aws-actions/configure-aws-credentials@v4` з `id-token: write`
- **GitHub → GCP:** `google-github-actions/auth@v2`

</v-clicks>

<v-click>

```yaml
# GitHub Actions — мінімальні permissions для OIDC
permissions:
  contents: write
  pull-requests: write
  id-token: write   # критично для OIDC
```

</v-click>

<v-click class="mt-2 p-3 bg-emerald-500/10 rounded text-sm">

**Перевага:** нема long-lived ключів у secret manager-і → нема витоку при компромісі сховища. Coupling з repo + branch — temporary creds живуть хвилини.

</v-click>

<DocRef url="https://code.claude.com/docs/en/gitlab-ci-cd#using-with-aws-bedrock--google-vertex-ai" label="code.claude.com — GitLab OIDC" />
<DocRef url="https://code.claude.com/docs/en/github-actions#using-with-aws-bedrock--google-vertex-ai" label="code.claude.com — GitHub OIDC" />

<!--
OIDC — це майбутнє. Якщо ти на enterprise-плані з Bedrock/Vertex — обов'язково. Для звичайного API key теж радує: репо-scoped IAM-role замість API key у repo secrets.
-->

---
layout: section
---

# Hands-on

4 вправи. Терміналом паралельно.

---

# Вправа 1 — `claude -p` локально

**Мета:** перший headless-запит на власному файлі, парсинг JSON.

```bash
cd workshops/08-headless-ci/exercises/01-print-basic
cat README.md
```

<v-clicks>

**Кроки:**

1. Створи `sample.txt` з 5–10 рядками довільного тексту
2. `claude -p "summarize this file" sample.txt` — text mode
3. Те саме з `--output-format json | jq -r '.result'`
4. Те саме з `--bare --allowedTools "Read"` — порівняй швидкість запуску
5. Додай `--max-turns 1` — побач, як обмеження працює

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 10 хв. `solutions/01-print-basic/` — готовий скрипт.

</v-click>

<!--
Найпростіша вправа — щоб усі мали робочий setup. Якщо `claude -p` падає на auth — піднімай руку, разом дивимось env і precedence.
-->

---

# Вправа 2 — dry-run review PR-діфа

**Мета:** Claude як readonly-ревʼюер: читає stage, видає JSON з коментарями.

```bash
cd ../02-pr-diff-review
ls
```

<v-clicks>

**Кроки:**

1. У будь-якому репо: `git diff main..HEAD > diff.patch` (або interesting fixture)
2. Запусти review:
   ```bash
   cat diff.patch | claude -p \
     --append-system-prompt "You are a senior code reviewer. \
       Output JSON with array of {file, line, severity, comment}." \
     --permission-mode plan \
     --output-format json \
     --max-turns 1 \
     --json-schema "$(cat schema.json)"
   ```
3. Парсинг: `jq '.structured_output.comments[]'`
4. Локально друкуй коментарі в console; у вправі 3 будемо постити в MR через API

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/headless#customize-the-system-prompt" label="code.claude.com — Custom system prompt" />

<!--
Це базовий шаблон AI-ревʼю. Plan mode = readonly = безпечно навіть з broken diff. JSON schema гарантує структуру — без неї треба писати парсер під вільний markdown.
-->

---

# Live: схема + run

```json {all|3-9|10}{lines:true}
{
  "type": "object",
  "properties": {
    "comments": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "file":     {"type": "string"},
          "line":     {"type": "integer"},
          "severity": {"enum": ["info","warning","error"]},
          "comment":  {"type": "string"}
        },
        "required": ["file","line","severity","comment"]
      }
    }
  },
  "required": ["comments"]
}
```

<!--
Цей шаблон копіюй прямо у свої CI-job-и. Severity-enum дає тобі downstream-логіку: error → fail job, warning → just comment.
-->

---

# Вправа 3 — `.gitlab-ci.yml` для MR

**Мета:** робочий job, який тригериться на MR і коментує діф.

```bash
cd ../03-gitlab-mr-job
cat .gitlab-ci.yml
```

<v-clicks>

**Кроки:**

1. Скопіюй `.gitlab-ci.yml` у тестовий проєкт у GitLab
2. У **Settings → CI/CD → Variables** додай `ANTHROPIC_API_KEY` (masked, protected)
3. Створи feature branch, відкрий MR
4. Подивись Pipelines → AI job → читай логи
5. Bonus: пости review як коментар у MR через `glab api`

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 20 хв. Найдовша вправа — потребує справжнього GitLab-проєкту.

</v-click>

<DocRef url="https://code.claude.com/docs/en/gitlab-ci-cd" label="code.claude.com — GitLab CI/CD" />

<!--
Якщо нема GitLab — у solutions/ є GitHub Actions варіант. Логіка та сама, синтаксис інший.
-->

---

# `.gitlab-ci.yml`: каркас (з docs)

```yaml {all|3-7|8-12|13-19}{lines:true}
stages:
  - ai
claude-review:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk add --no-cache git curl bash jq
    - curl -fsSL https://claude.ai/install.sh | bash
    - export PATH=$HOME/.local/bin:$PATH
  script:
    - git fetch origin "$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"
    - git diff "origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"...HEAD > diff.patch
    - >
      cat diff.patch | claude -p
      --permission-mode plan
      --output-format json
      --max-turns 3
      --append-system-prompt "Review for bugs and security. Output JSON."
      > review.json
    - jq -r '.result' review.json
```

<DocRef url="https://code.claude.com/docs/en/gitlab-ci-cd#basic-gitlab-ci-yml-claude-api" label="code.claude.com — GitLab template" />

<!--
Цей шаблон — адаптована версія з docs. Ключове: rules → лише на MR; before_script → install Claude; script → fetch diff, run claude, parse JSON. Все.
-->

---

# Постимо коментар у MR через API

```bash {all|2|3-9}{lines:true}
# Витягуємо текст ревʼю
review_text=$(jq -r '.result' review.json)

# Постимо у MR як note (system comment)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
  --header "Content-Type: application/json" \
  --data "$(jq -n --arg body "$review_text" '{body: $body}')" \
  "$CI_API_V4_URL/projects/$CI_PROJECT_ID/merge_requests/$CI_MERGE_REQUEST_IID/notes"
```

<v-clicks>

- **`GITLAB_ACCESS_TOKEN`** — Project Access Token зі scope `api` (masked variable)
- **`CI_JOB_TOKEN`** — alternative, але lesser permissions
- **`$CI_MERGE_REQUEST_IID`** — авто-pre-defined у MR-context

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

GitHub Actions: `gh pr comment $PR_NUMBER --body-file review.txt` — простіше.

</v-click>

<!--
Це з GitLab API docs (`/notes` endpoint), не з claude.com. На solutions/ є більш fancy варіант — пости line-comments через `/discussions` endpoint. Це advanced.
-->

---

# Вправа 4 — OIDC + token-vault

**Мета:** прибрати API key з secrets взагалі. Mock setup, не реальний AWS.

```bash
cd ../04-oidc-secrets
cat README.md
```

<v-clicks>

**Кроки (mock):**

1. Подивись готовий `.gitlab-ci.yml` з Bedrock OIDC flow (з docs)
2. Заміни AWS sts call на mock-script `mock-vault.sh` (генерує fake creds)
3. Подивись як `aws sts assume-role-with-web-identity` flow виглядає end-to-end
4. Replicate для GCP WIF (`gcloud auth login --cred-file=<(...)`)
5. (Bonus) налаштуй у власному AWS-аккаунті — ось список IAM steps

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/gitlab-ci-cd#aws-bedrock-job-example-oidc" label="code.claude.com — GitLab Bedrock OIDC" />

<!--
Реальний AWS setup — поза форматом 15-хвилинної вправи. Mock — щоб ти зрозумів flow і міг сам зробити коли буде потрібно. Кроки в README як runbook.
-->

---

# Чому OIDC: візуально

```
┌────────────┐    OIDC JWT    ┌──────────────┐
│  GitLab CI │ ───────────────▶│  AWS STS     │
│   runner   │                 │  AssumeRole  │
└────────────┘                 └──────┬───────┘
                                      │ short-lived
                                      │ creds (1h)
                                      ▼
                               ┌──────────────┐
                               │   Bedrock    │
                               │  invokeModel │
                               └──────────────┘
```

<v-clicks>

- **Нема long-lived AWS keys** у GitLab Variables
- **Trust policy у IAM** скоупить до конкретного project + branch
- **Token живе ~1 годину** — runner-compromise = втрата години, не вічність
- **Audit trail** у CloudTrail прив'язаний до GitLab job ID

</v-clicks>

<!--
Це security pattern, який треба перейняти з K8s/Terraform-світу у CI/CD-світ. Anthropic-документована інтеграція робить його доступним «з коробки».
-->

---
layout: section
---

# Cost ceilings

`--max-turns`, `--max-budget-usd`, безпечні дефолти

---

# Стелі витрат: 4 інструменти

```bash {all|1|3|5|7}{lines:true}
claude -p "..." --max-turns 5

claude -p "..." --max-budget-usd 5.00

claude -p "..." --fallback-model sonnet

claude -p "..." --no-session-persistence
```

<v-clicks>

| Flag | Семантика |
|---|---|
| **`--max-turns N`** | N agentic ітерацій → exit з error. Default: no limit |
| **`--max-budget-usd $`** | Hard stop по витратах. Print mode only |
| **`--fallback-model`** | Якщо primary overloaded → fallback (без timeout) |
| **`--no-session-persistence`** | Не пише сесію на диск; не resume-able |

</v-clicks>

<DocRef url="https://code.claude.com/docs/en/cli-reference" label="code.claude.com — CLI reference" />

<!--
max-turns — обов'язкове для CI. Default «no limit» означає можна запустити job, який крутитиметься годинами. Я завжди ставлю 5–10 для review, 20 для apply-fix.
-->

---

# Шаблон «безпечні дефолти» для CI

```bash {all|2-4|5-6|7-8}{lines:true}
claude -p "$PROMPT" \
  --bare \
  --permission-mode dontAsk \
  --allowedTools "Read,Bash(git diff *),Bash(git log *)" \
  --max-turns 5 \
  --max-budget-usd 1.00 \
  --output-format json \
  --no-session-persistence
```

<v-clicks>

**Чому кожне рішення:**

- `--bare` — однаковий результат на будь-якому runner-і
- `--permission-mode dontAsk` — нема підвисання на промтах
- `--allowedTools` — narrow scope, нема `Bash(*)`
- `--max-turns 5` — стелля ітерацій для read-only review
- `--max-budget-usd 1.00` — hard stop ($1 на job × 1000 MR/міс = $1K — норм)
- `--output-format json` — парсимо результат
- `--no-session-persistence` — ephemeral runner

</v-clicks>

<!--
Цей шаблон — мій робочий starting point. Скопіюй в .gitlab-ci.yml у себе. Змінюй під конкретний use case.
-->

---
layout: section
---

# Pitfalls

10 типових факапів — і як їх уникнути

---

# Top-10 pitfalls headless

<v-clicks>

1. **Interactive auth attempt** — нема API key у env → відкриває browser → CI hangs
2. **Secrets у логах** — `--debug` друкує headers; маскуй на runner-і
3. **Permission prompt у `-p`** — нема allowlist → job hangs до timeout
4. **Runaway costs** — нема `--max-turns` → необмежені ітерації
5. **OAuth token + `--bare`** — bare mode не читає `CLAUDE_CODE_OAUTH_TOKEN`
6. **Auto mode у `-p`** — повторні блоки (3-in-a-row або 20-total) → abort у `-p`. Не використовуй для CI
7. **`ANTHROPIC_API_KEY` переб'є subscription** — приховано auth-fail
8. **Plugin failures silent** — без stream-json не побачиш `plugin_errors`
9. **Skills `/commit` у `-p`** — не працюють; описуй прозою
10. **`--bare` пропускає `CLAUDE.md`** — proj convention not loaded

</v-clicks>

<!--
Кожен з цих я бачив у production. 1 і 3 — найболючіші: ти платиш за runner-минути, які витрачаються на «нічого». 4 — найдорожчий: один runaway job може коштувати $50–100.
-->

---

# Дебаг: що дивитись першим

<v-clicks>

1. **`claude --version`** — чи встановлений у CI image
2. **`echo $ANTHROPIC_API_KEY | wc -c`** — чи env-var присутній (без друку самого ключа)
3. **`claude auth status`** — JSON-вивід; exit 0 = OK
4. **Запусти з `--verbose`** локально; **НЕ** в CI без masking
5. **Stream-json + `system/init`** — провір `plugin_errors` і `tools`
6. **`--max-turns 1`** для повторюваності — обмеж до одного раунду

</v-clicks>

<v-click>

```bash
# Quick CI auth healthcheck:
claude auth status || (echo "AUTH FAILED"; exit 1)
```

</v-click>

<DocRef url="https://code.claude.com/docs/en/cli-reference" label="code.claude.com — claude auth status" />

<!--
auth status — недооцінений. JSON-вивід в CI, exit code 0/1 — ідеально для healthcheck step перед основним claude -p.
-->

---
layout: section
---

# Production-готовність

---

# Чек-ліст перед merge у `main`

<v-clicks>

- [ ] **Auth не в коді:** `${{ secrets.X }}` / GitLab masked variables
- [ ] **`--max-turns N`** ставить стелю ітерацій
- [ ] **`--max-budget-usd`** для hard stop
- [ ] **`--permission-mode dontAsk`** або `acceptEdits` (не `default`)
- [ ] **`--allowedTools`** narrow — нема `Bash(*)`
- [ ] **Deny rules для секретів** у `settings.json`: `.env`, `secrets/**`
- [ ] **`--bare`** якщо потрібна reproducibility
- [ ] **`--output-format json`** для downstream-parsing
- [ ] **Stream-json `system/init` parsing** якщо плагіни критичні
- [ ] **Job timeout** на CI-рівні (GitLab `timeout`, GHA `timeout-minutes`)
- [ ] **Concurrency limit** — `concurrency.group` (GHA) / `resource_group` (GitLab)
- [ ] **OIDC** замість long-lived keys, якщо cloud-провайдер

</v-clicks>

<!--
Якщо хоча б 3 не виконано — не мерджити. На code review — це baseline.
-->

---

# CI/CD інтеграції: офіційне

| Платформа | Інтеграція | Maintainer |
|---|---|---|
| **GitHub** | `anthropics/claude-code-action@v1` | Anthropic |
| **GitLab** | Native template + GitLab MCP server | GitLab (beta) |
| **AWS Bedrock** | Через будь-яку CI з OIDC | Anthropic-документоване |
| **GCP Vertex** | Через будь-яку CI з WIF | Anthropic-документоване |
| **Azure Foundry** | `CLAUDE_CODE_USE_FOUNDRY=1` | Anthropic-документоване |

<v-clicks>

- **GitHub Actions:** `/install-github-app` команда у Claude → autosetup
- **GitLab:** натиснути 2 кнопки + 1 CI/CD variable → робочий MVP
- **Custom CI:** `curl -fsSL https://claude.ai/install.sh | bash` + `ANTHROPIC_API_KEY`

</v-clicks>

<DocRef url="https://github.com/anthropics/claude-code-action" label="GitHub — anthropics/claude-code-action" />
<DocRef url="https://code.claude.com/docs/en/gitlab-ci-cd" label="code.claude.com — GitLab CI/CD" />

<!--
Якщо тільки старт — почни з GitHub Action. Найпростіше, найбільш battle-tested. GitLab — якщо вже на GitLab.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless)
- [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference)
- [code.claude.com/docs/en/permission-modes](https://code.claude.com/docs/en/permission-modes)
- [code.claude.com/docs/en/authentication](https://code.claude.com/docs/en/authentication)
- [code.claude.com/docs/en/gitlab-ci-cd](https://code.claude.com/docs/en/gitlab-ci-cd)
- [code.claude.com/docs/en/github-actions](https://code.claude.com/docs/en/github-actions)

</div>

<div>

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — готові розв'язки
- `handout.pdf` — повний референс
- Plan: workshop 09 = Agent SDK

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Наступний воркшоп — 09 Agent SDK (Python/TypeScript нативно). Дякую!
-->
