# Вправа 4 — read transcript via jq

**Мета:** навчитися читати session JSONL через jq, знаходити compact_boundary і дослідити втрату контексту.

**Час:** 15 хв.

## Що дано

- `starter/session.jsonl` — синтетичний (але реалістичний) transcript. ~45 events
- `starter/investigation.md` — 4 питання для розслідування

Сценарій сесії:
1. Юзер дав 5-крокову задачу (refactor + tests + docs + commit + PR)
2. Claude почав робити крок 1
3. Сесія заповнила контекст великим file read
4. Спрацював auto-compaction
5. Claude продовжив — але виконав не всі кроки. Чому?

## Кроки

1. **Перейди у теку:**
   ```bash
   cd 04-transcript-jq
   cat starter/investigation.md
   ```

2. **Перевір що jq встановлений:**
   ```bash
   jq --version
   ```

3. **Базова навігація:**
   ```bash
   # Скільки events взагалі?
   wc -l starter/session.jsonl

   # Які type-и зустрічаються?
   jq -r '.type' starter/session.jsonl | sort -u

   # Перші 3 події pretty-printed
   head -3 starter/session.jsonl | jq .
   ```

4. **Дай відповіді на 4 питання з `investigation.md`** — пиши свої jq-запити.

5. **Звір з `solutions/04-transcript-jq/queries.sh`** — там готові запити з поясненням.

## Що шукаємо

- На якому line `compact_boundary` подія?
- Який план юзер дав на самому початку (1-й user message)?
- Які кроки Claude фактично виконав до compaction?
- Що Claude робить ПІСЛЯ compaction — чи дотримується початкового плану?
- Hook outputs — що було?

## Solution

`solutions/04-transcript-jq/queries.sh` — bash-скрипт з 6 готовими jq-запитами і коментарями що кожен показує.
