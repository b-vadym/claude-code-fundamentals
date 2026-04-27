# Workshop 09 — Agent SDK: вправи

Чотири вправи по 10–15 хвилин. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Python 3.10+
- Anthropic API ключ: https://console.anthropic.com → Settings → Keys
- `export ANTHROPIC_API_KEY=sk-ant-...`

## Setup (один раз)

```bash
cd workshops/09-agent-sdk/exercises
python -m venv .venv
source .venv/bin/activate          # Linux/Mac
# .venv\Scripts\activate           # Windows
pip install -r requirements.txt
```

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-hello-agent/` | Перший виклик `messages.create`, `usage` | 10 хв |
| 2 | `02-tool-use/` | Tool definition, `tool_use` → `tool_result` цикл | 15 хв |
| 3 | `03-prompt-caching/` | `cache_control`, наблюдаємо hit на 2-му запиті | 15 хв |
| 4 | `04-mychat-cli/` | Streaming CLI-чат з історією та caching | 15 хв |

## Як запускати

Кожна тека має свій `README.md` зі специфічними кроками. Загалом:

```bash
cd 0N-name/
cat README.md          # інструкція
ls starter/            # стартовий код
python starter/<file>.py
ls ../solutions/0N-*/  # еталон якщо застрягнеш
```

## solutions/

Готові розв'язки. Не дивись поки не спробував сам — мета не «скопіювати», а зрозуміти різницю між твоїм підходом і еталоном.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці
- Питання — Discord або підніми руку на воркшопі

## Що зберіг після воркшопу

- Робочий CLI-чат `mychat.py` з streaming і caching
- Розуміння tool-loop патерну з MAX_ITER safeguard
- Уміння читати cache_creation / cache_read у `usage`
- Шаблон для власних агентів на Anthropic SDK і Claude Agent SDK
