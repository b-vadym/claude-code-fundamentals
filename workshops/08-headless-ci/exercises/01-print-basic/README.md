# Вправа 1 — `claude -p` локально

**Мета:** перший headless-запит, парсинг JSON, порівняння `--bare` vs full mode.

**Час:** 10 хв.

## Передумови

- `claude --version` повертає v1.x
- `jq --version` працює
- Auth: `echo ${ANTHROPIC_API_KEY:0:8}...` (НЕ друкуй повний ключ) — щось є
- АБО: `claude auth status` повертає logged-in

## Кроки

1. **Підготуй sample-файл:**

   ```bash
   cat > sample.txt <<'EOF'
   The auth module handles JWT validation, token refresh, and rate limiting.
   It uses Redis for session storage and Postgres for user records.
   Session tokens expire after 1 hour; refresh tokens after 30 days.
   On failed authentication, the module logs to Datadog and increments a counter.
   The middleware runs before all /api/v1/* routes except /api/v1/public.
   EOF
   ```

2. **Базовий запит (text mode):**

   ```bash
   claude -p "Summarize this file in 2 sentences" sample.txt
   ```

3. **JSON output + jq:**

   ```bash
   claude -p "Summarize this file in 2 sentences" sample.txt \
     --output-format json | jq -r '.result'
   ```

   Подивись повний JSON: прибери `| jq -r '.result'`. Зверни увагу на `total_cost_usd`, `session_id`, `num_turns`.

4. **Bare mode (швидший старт):**

   ```bash
   time claude --bare -p "Summarize this file in 2 sentences" sample.txt \
     --allowedTools "Read"
   ```

   Порівняй з:

   ```bash
   time claude -p "Summarize this file in 2 sentences" sample.txt
   ```

   `--bare` має бути швидшим (немає auto-discovery).

5. **Обмеження ітерацій:**

   ```bash
   claude -p "Refactor this file extensively" sample.txt --max-turns 1
   ```

   Подивись як Claude робить рівно 1 turn і виходить.

6. **Вивід вартості (production pattern):**

   ```bash
   result=$(claude -p "Summarize" sample.txt --output-format json)
   echo "Cost: \$$(echo "$result" | jq -r '.total_cost_usd')"
   echo "Turns: $(echo "$result" | jq -r '.num_turns')"
   echo "---"
   echo "$result" | jq -r '.result'
   ```

## Очікуваний результат

- Усі 6 кроків виконано
- Розумієш різницю між text / json виводами
- Бачив `total_cost_usd` для свого запиту
- Bare mode помітно швидший на старті

## Якщо не вийшло

- **Auth fail:** `unset ANTHROPIC_API_KEY; claude auth login` АБО `export ANTHROPIC_API_KEY=...`
- **`--bare` падає на auth:** bare mode не читає `CLAUDE_CODE_OAUTH_TOKEN`. Потрібен `ANTHROPIC_API_KEY`.
- **`jq: parse error`:** перевір що `claude -p ... --output-format json` працює без `jq`
- **Subscription vs key:** якщо обидва є — key переб'є. `unset ANTHROPIC_API_KEY` для subscription.

## Подальше читання

- `claude --help` — повний список flag-ів
- <https://code.claude.com/docs/en/headless> — офіційна документація
- `solutions/01-print-basic/run.sh` — готовий скрипт з усіма кроками
