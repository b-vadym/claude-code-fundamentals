# Вправа 4 — prompt warning

**Мета:** `UserPromptSubmit` hook що ловить sensitive фрази у промпті юзера і додає warning у контекст.

**Час:** 12 хв.

## Контекст

`UserPromptSubmit` firing **до того**, як Claude обробить промпт. Має 3 типи відповіді:

| Поведінка | Як |
|---|---|
| **Warn (soft)** | exit 0 + JSON з `hookSpecificOutput.additionalContext` |
| **Block (hard)** | exit 2 + stderr з причиною (промпт стирається з контексту) |
| **Pass through** | exit 0 без output |

Ми робимо **warn** — Claude бачить попередження, юзер не дратується. Hard-block приклад у solutions для довідки.

## Trigger phrases (case-insensitive regex)

- `delete production`
- `drop production`
- `truncate production`
- `force push.*(main|master)`
- `disable safety`
- `bypass review`
- `skip tests`

Реальний список варіюється від команди — це seed.

## Кроки

1. **Скопіюй стартер:**

   ```bash
   cp starter/prompt-warning.sh ~/.claude/hooks/prompt-warning.sh
   chmod +x ~/.claude/hooks/prompt-warning.sh
   ```

2. **Доповни `prompt-warning.sh`** — там TODO:
   - читай stdin → витягни `prompt`
   - перевір кожен pattern (case-insensitive)
   - на match → JSON з warning у `additionalContext`
   - exit 0 завжди

3. **Зареєструй** (UserPromptSubmit **не підтримує matcher** — фірить на кожен промпт):

   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "$HOME/.claude/hooks/prompt-warning.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }
   ```

4. **Manual test (no match):**

   ```bash
   echo '{"prompt":"how do I refactor this function?"}' \
     | ~/.claude/hooks/prompt-warning.sh
   # очікуємо: empty stdout, exit 0
   ```

   **Match:**

   ```bash
   echo '{"prompt":"please delete production database now"}' \
     | ~/.claude/hooks/prompt-warning.sh | jq .
   # очікуємо JSON з hookSpecificOutput.additionalContext
   ```

5. **Тестуй у живій сесії:**
   - Введи звичайний промпт — Claude відповідає як завжди
   - Введи «delete production users» — Claude бачить warning і ймовірно перепитає

## Очікуваний результат

JSON output на match:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "⚠️ Sensitive phrase detected:\n• matched: 'delete production'\n\nProceed only with explicit confirmation from user."
  }
}
```

## Якщо не вийшло

- `solutions/04-prompt-warning/prompt-warning.sh` — повний скрипт
- `solutions/04-prompt-warning/prompt-warning-block.sh` — варіант з hard-block (exit 2)

## Бонус

- Замість статичного списку — читай patterns з `~/.claude/sensitive-patterns.txt`
- Логуй усі matches у окремий файл (audit) — навіть якщо warning, є слід
- Зроби confirmation flow: при match emit `decision: "block"` + `reason` що пропонує перефразувати

## Caveats (важливо)

⚠️ **Phrase detection обходиться** — юзер може написати «remove the prod records» і pattern не спрацює. Hook це **перший рубіж**, не silver bullet. Як policy — комбінуй з:
- Rules engine у `PreToolUse` (де ти бачиш конкретний command)
- CLAUDE.md що нагадує про production conventions
- Code review

## Doc reference

- https://code.claude.com/docs/en/hooks#userpromptsubmit
- https://code.claude.com/docs/en/hooks-guide (no `matcher` — UserPromptSubmit fires always)
