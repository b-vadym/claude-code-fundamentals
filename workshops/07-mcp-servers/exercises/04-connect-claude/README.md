# Вправа 4 — підключаємо до Claude Code

**Мета:** твій сервер з вправ 1–3 запущений у реальній Claude Code сесії, tool викликається на природний запит.

**Час:** 15 хв.

## Кроки

1. **Підготуй фінальний сервер** — скопіюй з вправи 3:

   ```bash
   cd 04-connect-claude
   cp ../03-add-prompt/server.py .
   cp ../03-add-prompt/notes.md .
   # переконайся що uv venv активне і "mcp[cli]" встановлений
   ```

2. **Додай у Claude Code** через CLI:

   ```bash
   claude mcp add --scope user --transport stdio my-clock \
     -- uv --directory $(pwd) run server.py
   ```

   Або через `.mcp.json` у проєкт-root (для team scope):

   ```json
   {
     "mcpServers": {
       "my-clock": {
         "command": "uv",
         "args": ["--directory", "/abs/path/to/04-connect-claude", "run", "server.py"]
       }
     }
   }
   ```

3. **Перевір реєстрацію:**

   ```bash
   claude mcp list
   claude mcp get my-clock     # деталі
   ```

4. **Запусти Claude Code:**

   ```bash
   claude
   ```

5. **Усередині сесії:**

   ```
   /mcp
   ```

   - Має бути `my-clock: connected`
   - Якщо `failed` → подивись `claude mcp get my-clock`, запусти команду руками щоб побачити stderr

6. **Тести:**

   - **Tool (auto-trigger):**
     ```
     > який зараз час у Києві?
     ```
     Claude мав викликати `current_time(tz="Europe/Kyiv")`. Підтвердження зазвичай у tool-use UI.

   - **Resource:**
     ```
     > read the project notes resource from my-clock
     ```

   - **Prompt (slash-команда):**
     ```
     /
     ```
     У меню має з'явитися `my-clock:summarize_notes`. Виклич з аргументом `style`.

## Очікуваний результат

- `claude mcp list` показує `my-clock`
- `/mcp` всередині сесії — connected
- Природний запит про час → виклик tool
- Slash-меню містить prompt-и сервера

## Якщо не вийшло

**Stuck on `failed`:**

```bash
# 1. Перевір що команда руками працює:
uv --directory $(pwd) run server.py
# Має тихо запуститися (читає stdin). Ctrl+C щоб зупинити.

# 2. Перевір що пакет встановлено у venv:
uv tree | grep mcp

# 3. Грепни stdout-факапи:
grep -n 'print(' server.py
# Усі мають бути file=sys.stderr або відсутні
```

**Tool не auto-тригерить:**

- Спитай явніше: «use my-clock tool to get current time in Kyiv»
- Перевір docstring — він стає description для моделі
- Запит «який час» може просто piped without tool — Claude інколи відповідає сам

**Видалити пізніше:**

```bash
claude mcp remove my-clock
```

`solutions/04-connect-claude/` — той самий `server.py` плюс приклад `.mcp.json`.
