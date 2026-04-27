# Solution — broken `.mcp.json`

2 баги у starter, обидва типові.

## Баг 1 — relative path у `command`

**Starter:**
```json
"command": "./echo-server.py"
```

**Проблема:**
Relative paths у `command`/`args` resolve проти **launch directory** (звідки ти запустив `claude`), а **не** проти `.mcp.json`. Якщо запустиш `claude` з іншої теки — fail.

> «MCP server fails to start from some directories — `command` or `args` uses a relative file path. Use absolute paths for local scripts.» — code.claude.com/docs/en/debug-your-config

**Симптом:** `/mcp` показує `failed`. `--debug mcp` логує `spawn ./echo-server.py: ENOENT` або `spawn: No such file or directory`.

**Фікс варіанти:**

```json
// Варіант A: абсолютний шлях через ${PWD} (резолвиться при старті CC)
"command": "python3",
"args": ["${PWD}/echo-server.py"]

// Варіант B: повністю hardcoded абсолютний шлях
"command": "/Users/vadym/projects/foo/echo-server.py"

// Варіант C: викликати через python3 explicit (executable на PATH)
"command": "python3",
"args": ["/абсолютний/шлях/до/echo-server.py"]
```

Виконувані команди на PATH (`npx`, `uvx`, `python3`) працюють як-є.

## Баг 2 — env var без default

**Starter:**
```json
"env": {
  "MCP_GREETING": "${ECHO_GREETING}"
}
```

**Проблема:**
Якщо `ECHO_GREETING` не встановлено в env де ти запускаєш `claude`, CC не зможе запарсити конфіг:

> «If a required environment variable is not set and has no default value, Claude Code will fail to parse the config.» — code.claude.com/docs/en/mcp

**Симптом:** `/mcp` не показує сервер взагалі (не failed — а просто немає). `--debug mcp` каже `Failed to parse .mcp.json` або подібне.

**Фікс:**

```json
"env": {
  "MCP_GREETING": "${ECHO_GREETING:-hello}"
}
```

Синтаксис `${VAR:-default}` — якщо VAR не задано, використовується default.

## Як перевірити що працює

```bash
cd /tmp/mcp-debug
claude
```

`/mcp`:
```
echo-server     ✅ connected (1 tool)
```

Виклик:
```
> use echo to say "hello debug"

# Очікувана відповідь tool-а: "hello hello debug"
```

(Бо `MCP_GREETING=hello` через default + текст «hello debug» з виклику.)

## Bonus pitfall — стіл

Якщо `.mcp.json` поклав у `.claude/.mcp.json` (під поддиректорію) — CC його НЕ знайде. Має бути у корені проєкту, поряд з `package.json`/`pyproject.toml`.

> «Project MCP config goes at the repository root as `.mcp.json`, not inside `.claude/`.» — code.claude.com/docs/en/debug-your-config
