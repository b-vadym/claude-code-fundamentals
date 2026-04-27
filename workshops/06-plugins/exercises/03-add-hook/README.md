# Вправа 3 — `PostToolUse`-hook що логує редагування

**Мета:** додати у `git-toolkit` hook, який після кожного `Write` або `Edit` пише рядок у `${CLAUDE_PLUGIN_DATA}/edits.log`.

**Час:** 15 хв

**Передумова:** вправа 2 виконана. У `starter/` лежить плагін з трьома компонентами.

## Кроки

### 1. `hooks/hooks.json`

`starter/git-toolkit/hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-edit.sh"
          }
        ]
      }
    ]
  }
}
```

Зверни увагу: `${CLAUDE_PLUGIN_ROOT}` — НЕ абсолютний шлях з твого диска. Підставиться під час runtime.

### 2. Скрипт `scripts/log-edit.sh`

```bash
mkdir -p starter/git-toolkit/scripts
```

`starter/git-toolkit/scripts/log-edit.sh`:

```bash
#!/usr/bin/env bash
# Plugin hook: PostToolUse(Write|Edit) → log to ${CLAUDE_PLUGIN_DATA}/edits.log

set -euo pipefail

# Hook input arrives on stdin as JSON. Extract file_path from tool_input.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // "<unknown>"')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "<unknown>"')

# CLAUDE_PLUGIN_DATA is exported as env var by Claude Code.
mkdir -p "${CLAUDE_PLUGIN_DATA}"
echo "[$(date -Iseconds)] $TOOL $FILE" >> "${CLAUDE_PLUGIN_DATA}/edits.log"
```

### 3. Make executable

```bash
chmod +x starter/git-toolkit/scripts/log-edit.sh
```

Без цього кроку hook silently fail-ає на наступному `chmod +x`-чек-лісті.

### 4. Тест

```bash
claude plugin validate ./git-toolkit
claude --plugin-dir ./git-toolkit
```

У сесії попроси Claude:

```text
> Зроби маленький edit у README.md (додай порожній рядок у кінець)
```

Потім вийди з сесії і перевір лог:

```bash
ls ~/.claude/plugins/data/
# git-toolkit-<something>/

cat ~/.claude/plugins/data/git-toolkit-*/edits.log
# [2026-04-26T12:34:56+03:00] Edit /home/.../README.md
```

## Чек-перевірки

- [ ] `hooks/hooks.json` валідний JSON
- [ ] `${CLAUDE_PLUGIN_ROOT}` у command, НЕ абсолютний шлях
- [ ] `${CLAUDE_PLUGIN_DATA}` у скрипті (для логу що виживає update)
- [ ] `chmod +x scripts/log-edit.sh`
- [ ] Shebang `#!/usr/bin/env bash`
- [ ] Після `Edit` у сесії — рядок у `edits.log`

## Pitfalls

- ❌ `command: "/home/vadym/.../scripts/log-edit.sh"` — після install у іншого юзера такого шляху нема. **Завжди `${CLAUDE_PLUGIN_ROOT}`.**
- ❌ Логувати у `${CLAUDE_PLUGIN_ROOT}/edits.log` — пропаде при наступному update плагіна. **`${CLAUDE_PLUGIN_DATA}`** для persistent state.
- ❌ Забути `chmod +x` — Claude Code не зможе запустити скрипт. У `/plugin` Errors tab буде "Permission denied".
- ❌ Очікувати, що hook input приходить як CLI-аргументи — він приходить **на stdin як JSON**.

## Doc-посилання

- https://code.claude.com/docs/en/plugins-reference#hooks
- https://code.claude.com/docs/en/plugins-reference#environment-variables
- https://code.claude.com/docs/en/plugins-reference#hook-troubleshooting
