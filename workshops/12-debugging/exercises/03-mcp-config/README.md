# Вправа 3 — broken `.mcp.json`

**Мета:** діагностувати чому MCP-сервер не стартує, виправити обидва баги.

**Час:** 10 хв.

## Що дано

- `starter/echo-server.py` — простий stdio MCP-сервер на Python (1 tool: `echo`)
- `starter/.mcp.json` — конфіг з **двома** проблемами

Сервер сам по собі робочий — якщо запустити його руками, він стартує. Проблема в `.mcp.json`.

## Кроки

1. **Підготуй тестовий проєкт:**
   ```bash
   mkdir -p /tmp/mcp-debug && cd /tmp/mcp-debug
   cp <шлях>/starter/.mcp.json .
   cp <шлях>/starter/echo-server.py .
   chmod +x echo-server.py
   ```

2. **Запусти Claude Code:**
   ```bash
   claude
   ```

3. **`/mcp`** — побачиш `echo-server` як `failed` або відсутній.

4. **Тепер вийди і запусти з debug:**
   ```bash
   claude --debug mcp
   ```

5. **Прочитай stderr** — побачиш або `spawn: No such file or directory`, або `Failed to parse config`.

6. **Знайди обидва баги:**
   - один — про шлях
   - другий — про env var

7. **Виправ і перевір** — `/mcp` має показати `connected (1 tool)`.

8. **Перевір тул:**
   ```
   > use the echo MCP tool to say "hello debug"
   ```
   Має повернути `"hello debug"`.

## Підказки

- `echo-server.py` потребує `${MCP_GREETING}` env var
- Чи `.mcp.json` його надає? Чи він має default?
- Шлях у `command` — relative чи absolute?

## Solution

`solutions/03-mcp-config/.mcp.json` — виправлений конфіг + пояснення.
