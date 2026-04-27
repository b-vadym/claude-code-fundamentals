# Workshop 07 — MCP Servers: вправи

Чотири вправи по 10–20 хвилин кожна. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Claude Code v1.x встановлений (`claude --version`)
- Python 3.10+ (`python --version`)
- `uv` (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- Node.js 18+ для MCP Inspector (`node --version`)

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-hello-tool/` | STDIO-сервер з tool `current_time(tz)` | 15 хв |
| 2 | `02-add-resource/` | Додати `file://notes` як resource | 15 хв |
| 3 | `03-add-prompt/` | Додати prompt template `summarize_notes(style)` | 15 хв |
| 4 | `04-connect-claude/` | Підключити до Claude Code, виклик у сесії | 15 хв |

## Як запускати

Кожна тека має свій `README.md` зі специфічними кроками. Загалом:

```bash
cd 0N-name/
cat README.md          # інструкція
ls starter/            # стартовий стан
# роби кроки з README
ls ../solutions/0N-*/  # підглянь якщо застрягнеш
```

## solutions/

Готові розв'язки для кожної вправи. Не дивись поки не спробував сам — мета не «скопіювати», а зрозуміти різницю між твоїм підходом і еталоном.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці
- MCP Inspector — `npx @modelcontextprotocol/inspector` і вкладка **Notifications** з stderr-логами

## Що зберіг після воркшопу

- Робочий MCP-сервер з tool + resource + prompt
- Підключений до твого Claude Code (`claude mcp list` показує)
- Розуміння як писати STDIO-сервери на Python SDK
- Чек-ліст 6 кроків діагностики, коли сервер не підключається
