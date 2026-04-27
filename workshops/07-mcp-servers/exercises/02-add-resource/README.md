# Вправа 2 — додаємо resource

**Мета:** сервер експонує `notes.md` як MCP-resource з URI `file://notes`.

**Час:** 15 хв.

## Кроки

1. **Стартовий стан** — у `starter/` є `server.py` (з tool з вправи 1) і `notes.md`:

   ```bash
   cd 02-add-resource
   cp starter/server.py .
   cp starter/notes.md .
   ```

2. **Додай resource** у `server.py`:

   ```python
   from pathlib import Path

   @mcp.resource("file://notes")
   def get_notes() -> str:
       """Project notes."""
       return Path("notes.md").read_text(encoding="utf-8")
   ```

3. **Перезавантаж Inspector** (Ctrl+C, запусти знов):

   ```bash
   npx @modelcontextprotocol/inspector uv run server.py
   ```

4. **Resources tab** → побач `file://notes` → клік → побач content `notes.md`

5. **Bonus — templated resource:**

   Додай URI template, що повертає секцію за заголовком:

   ```python
   @mcp.resource("file://notes/{section}")
   def get_section(section: str) -> str:
       """Get a single H2 section from notes by slug."""
       text = Path("notes.md").read_text(encoding="utf-8")
       # naive: split by '## ', match by lowercased slug
       parts = text.split("\n## ")
       for part in parts[1:]:
           heading, *body = part.split("\n", 1)
           if heading.strip().lower().replace(" ", "-") == section:
               return f"## {heading}\n{body[0] if body else ''}"
       return f"Section '{section}' not found"
   ```

   У Inspector → Resources → введи `file://notes/setup` → побач секцію.

## Очікуваний результат

- `file://notes` показується у списку Resources
- Content відповідає `notes.md`
- (Bonus) `file://notes/<slug>` повертає одну секцію

## Якщо не вийшло

- **Resource не у списку** — перевір що декоратор має `()` і URI: `@mcp.resource("file://notes")`, не `@mcp.resource`
- **Empty content** — перевір що Inspector запущений з `--directory` що містить `notes.md`, або робоча тека правильна
- **Templated не з'являється** — це normal, templated resources не показуються у `resources/list`. Запитуй за конкретним URI у Inspector
- `solutions/02-add-resource/` — готовий файл
