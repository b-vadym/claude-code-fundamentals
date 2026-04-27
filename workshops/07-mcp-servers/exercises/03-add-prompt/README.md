# Вправа 3 — додаємо prompt template

**Мета:** prompt template `summarize_notes(style)`, що генерує запит на summary `notes.md`.

**Час:** 15 хв.

## Кроки

1. **Стартовий стан** — у `starter/` є `server.py` з tool + resource:

   ```bash
   cd 03-add-prompt
   cp starter/server.py .
   cp starter/notes.md .
   ```

2. **Додай prompt** у `server.py`:

   ```python
   @mcp.prompt(title="Summarize notes")
   def summarize_notes(style: str = "bullet") -> str:
       """Generate a request to summarize project notes.

       Args:
           style: Output style. One of: bullet, paragraph, tldr.
       """
       notes = NOTES_PATH.read_text(encoding="utf-8")
       return f"Summarize the following notes in {style} style:\n\n{notes}"
   ```

3. **Перезапусти Inspector:**

   ```bash
   npx @modelcontextprotocol/inspector uv run server.py
   ```

4. **Prompts tab** → побач `summarize_notes` з аргументом `style`
5. **Тестуй** — введи `style=paragraph`, натисни Generate → побач згенерований user-message

6. **Bonus — структуроване повідомлення:**

   Поверни список messages замість рядка:

   ```python
   from mcp.server.fastmcp.prompts import base

   @mcp.prompt(title="Summarize notes (structured)")
   def summarize_notes_v2(style: str = "bullet") -> list[base.Message]:
       notes = NOTES_PATH.read_text(encoding="utf-8")
       return [
           base.UserMessage(f"Style: {style}"),
           base.UserMessage("Summarize:\n\n" + notes),
       ]
   ```

## Очікуваний результат

- `summarize_notes` у Prompts tab
- Аргумент `style` з default `bullet`
- Generate показує згенерований user-message з вмістом notes

## Якщо не вийшло

- **Prompt не у списку** — перевір що декоратор `@mcp.prompt()`, не `@mcp.prompt` (без дужок)
- **`base.Message` import error** — `from mcp.server.fastmcp.prompts import base`
- `solutions/03-add-prompt/` — готовий файл
