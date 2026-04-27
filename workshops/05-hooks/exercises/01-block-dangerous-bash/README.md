# Вправа 1 — block dangerous bash

**Мета:** `PreToolUse` hook що блокує небезпечні bash-команди (`rm -rf /`, fork bombs, `dd of=/dev/...`).

**Час:** 12 хв.

## Чому це важливо

`PreToolUse` deny — спрацьовує **навіть** у `bypassPermissions` mode і з `--dangerously-skip-permissions`. Це **єдиний** механізм policy enforcement, який юзер не може обійти permission-mode toggle-ом.

> "PreToolUse hooks fire before any permission-mode check. A hook that returns `permissionDecision: 'deny'` blocks the tool even in `bypassPermissions` mode."
> — code.claude.com/docs/en/hooks-guide

## Кроки

1. **Скопіюй стартер у свою теку hooks:**

   ```bash
   mkdir -p ~/.claude/hooks
   cp starter/check-bash.sh ~/.claude/hooks/check-bash.sh
   chmod +x ~/.claude/hooks/check-bash.sh
   ```

2. **Доповни `~/.claude/hooks/check-bash.sh`** — там є TODO:
   - читай stdin → витягуй `tool_input.command`
   - перевір regex проти масиву dangerous patterns
   - на match → write reason у stderr і `exit 2`
   - інакше → `exit 0`

3. **Зареєструй у `~/.claude/settings.json`:**

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "hooks": [
             {
               "type": "command",
               "command": "$HOME/.claude/hooks/check-bash.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }
   ```

4. **Manual test:**

   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' \
     | ~/.claude/hooks/check-bash.sh
   echo "Exit: $?"
   # очікуваний вивід:
   # stderr: Blocked: ...
   # Exit: 2
   ```

   Тепер позитивний кейс:

   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' \
     | ~/.claude/hooks/check-bash.sh
   echo "Exit: $?"
   # Exit: 0
   ```

5. **Перевір `/hooks` у Claude Code** — твій hook має з'явитися під `PreToolUse` → `Bash`.

6. **Тестуй у живій сесії:**
   - Попроси Claude `ls -la /tmp` — має пройти
   - Попроси Claude `rm -rf /tmp/foo` — має пройти (це безпечно, не root)
   - Попроси Claude `rm -rf /` — має блокнутись з твоїм reason

## Очікуваний результат

- Hook у `/hooks` menu під PreToolUse → Bash
- Manual test з небезпечною командою повертає `Exit: 2` + stderr reason
- Manual test з безпечною — `Exit: 0`
- Жива сесія: Claude бачить block reason і не виконує rm -rf /

## Якщо не вийшло

- `solutions/01-block-dangerous-bash/check-bash.sh` — повний скрипт
- `solutions/01-block-dangerous-bash/settings-snippet.json` — settings.json snippet
- Транскрипт show: stdout помилка → перевір `~/.zshrc` на unconditional `echo`
- "command not found" → `chmod +x` пропустив
- "jq: command not found" → встанови `jq`

## Бонус (якщо є час)

- Додай patterns для `chmod -R 777 /`, `mv /etc/...`, `> /etc/passwd`
- Замість `exit 2` — поверни JSON з `permissionDecision: "deny"` і `permissionDecisionReason`. Структура у `solutions/.../check-bash-json.sh`.

## Doc reference

- https://code.claude.com/docs/en/hooks#pretooluse
- https://code.claude.com/docs/en/hooks-guide#block-edits-to-protected-files
- https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py
