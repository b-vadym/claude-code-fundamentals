# Вправа 2 — dry-run review PR-діфа

**Мета:** Claude як readonly-ревʼюер: читає stage, видає JSON-структуру з коментарями.

**Час:** 15 хв.

## Контекст

Це базовий шаблон AI-ревʼю — той самий, що в вправі 3 покладемо у CI. Різниця: тут локально, без посту в MR.

## Кроки

1. **Зґенеруй або скористайся демо-діфом:**

   У будь-якому git-репо з кількома commit-ами поверх main:

   ```bash
   git diff main..HEAD > diff.patch
   ```

   Або візьми готовий `sample-diff.patch` із цієї теки (фікстура з типовими bug-патернами).

2. **Подивись на JSON Schema у `schema.json`:**

   ```bash
   cat schema.json
   ```

   Це структура, у яку Claude мусить впасти: масив `comments` з полями `file`, `line`, `severity`, `comment`.

3. **Запусти review:**

   ```bash
   cat diff.patch | claude -p \
     --append-system-prompt "You are a senior code reviewer. Analyze the diff and identify bugs, security issues, and style problems. Output JSON matching the schema with one comment per issue. If diff is fine, return empty comments array." \
     --permission-mode plan \
     --output-format json \
     --json-schema "$(cat schema.json)" \
     --max-turns 1 \
     > review.json
   ```

   - `--permission-mode plan` → readonly режим, безпечно
   - `--max-turns 1` → одна ітерація, бо задача single-shot
   - `--json-schema` → guarantee структури

4. **Парсимо результат:**

   ```bash
   jq '.structured_output.comments[] | "\(.severity | ascii_upcase): \(.file):\(.line) — \(.comment)"' \
     -r review.json
   ```

   Має вивести щось на кшталт:
   ```
   ERROR: src/auth.js:42 — SQL injection: user input concatenated into query
   WARNING: src/api.js:107 — Missing rate limit on POST /login
   INFO: src/utils.js:8 — Consider extracting magic number to constant
   ```

5. **Експеримент: severity → exit code:**

   ```bash
   if jq -e '.structured_output.comments[] | select(.severity == "error")' review.json > /dev/null; then
     echo "Critical issues found — would FAIL the build"
     exit 1
   else
     echo "No critical issues"
   fi
   ```

6. **Bonus: cost monitoring:**

   ```bash
   echo "Review cost: \$$(jq -r '.total_cost_usd' review.json)"
   ```

## Очікуваний результат

- `review.json` згенеровано з валідною структурою
- `jq` парсить `.structured_output.comments[]` без помилок
- Severity-based exit-логіка працює — error → exit 1

## Якщо не вийшло

- **`.structured_output` is null:** Claude не зміг впасти у схему. Спробуй на меншому/простішому діфі.
- **Permission denied на Read:** `--permission-mode plan` дозволяє лише reads. Якщо треба запустити команду — зміни на `dontAsk` + `--allowedTools "Read,Bash(...)"`.
- **`max-turns 1` мало:** збільш до 3 для складних діфів.
- **JSON Schema невалідна:** перевір синтаксисом — `jq . schema.json`.

## Файли в теці

- `schema.json` — JSON Schema для review-output
- `sample-diff.patch` — фікстура для тестування (5 файлів, 2 явні bug-и)
- `review.sh` (генеруй сам, або у solutions/) — обгортка над claude

## Подальше читання

- <https://code.claude.com/docs/en/headless#get-structured-output> — `--json-schema`
- <https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode> — plan mode
- `solutions/02-pr-diff-review/` — готова обгортка та приклад виводу
