# Вправа 1 — Hello-world MCP-tool

**Мета:** STDIO-сервер з одним tool `current_time(tz)`, протестований у MCP Inspector.

**Час:** 15 хв.

## Кроки

1. **Setup:**

   ```bash
   cd 01-hello-tool
   uv venv
   source .venv/bin/activate
   uv add "mcp[cli]"
   ```

2. **Скопіюй стартовий файл:**

   ```bash
   cp starter/server.py .
   ```

3. **Допиши tool у `server.py`** — використай `datetime` + `zoneinfo`:

   ```python
   from datetime import datetime
   from zoneinfo import ZoneInfo

   @mcp.tool()
   def current_time(tz: str = "UTC") -> str:
       """Return current time in the given IANA timezone (e.g. Europe/Kyiv).

       Args:
           tz: IANA timezone string. Default UTC.
       """
       return datetime.now(ZoneInfo(tz)).isoformat()
   ```

4. **Запусти MCP Inspector:**

   ```bash
   npx @modelcontextprotocol/inspector uv run server.py
   ```

   Браузер відкриється на `http://localhost:5173` (або сусідньому порті).

5. **У Inspector:**
   - **Connection pane** → Connect
   - **Tools** tab → побач `current_time` зі схемою
   - Виклич з `tz=Europe/Kyiv` → перевір ISO-time у result

6. **Експеримент:**
   - Виклич без аргументу — має повернути UTC
   - Виклич з невалідним tz (`xxx`) — має кинути exception, побач у Notifications

## Очікуваний результат

- Сервер запускається
- Inspector показує `current_time` з правильною схемою (`tz: string, default "UTC"`)
- Виклик повертає valid ISO timestamp

## Якщо не вийшло

- **Inspector не підключається** — перевір що сервер не пише у stdout. `grep print server.py` має нічого не дати, або всі `print` мати `file=sys.stderr`
- **Schema без default** — тип hint має бути `str = "UTC"`, не просто `str`
- `solutions/01-hello-tool/server.py` — повністю готовий
