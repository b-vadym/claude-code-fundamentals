# Вправа 2 — log every tool call

**Мета:** `PostToolUse` hook що пише JSONL audit log у `~/.claude/tool-log.jsonl` для **усіх** tool-calls (не лише Bash).

**Час:** 10 хв.

## Чому JSONL

- Append-only — кожен event самодостатній
- `jq` і `grep`-able без парсингу всього файлу
- Streaming-friendly — `tail -f ~/.claude/tool-log.jsonl | jq .`

## Кроки

1. **Скопіюй стартер:**

   ```bash
   cp starter/tool-log.sh ~/.claude/hooks/tool-log.sh
   chmod +x ~/.claude/hooks/tool-log.sh
   touch ~/.claude/tool-log.jsonl
   ```

2. **Доповни `tool-log.sh`** — там TODO:
   - читай stdin
   - сформуй компактний JSON-обʼєкт з `ts`, `session`, `cwd`, `tool`, `input`, `success`, `duration_ms`
   - append у `$HOME/.claude/tool-log.jsonl`
   - exit 0 (ніколи не блокуй для observability)

3. **Зареєструй у `~/.claude/settings.json`** — **без** matcher (логуємо все):

   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "$HOME/.claude/hooks/tool-log.sh"
             }
           ]
         }
       ]
     }
   }
   ```

4. **Manual test:**

   ```bash
   echo '{
     "session_id": "test",
     "cwd": "/tmp",
     "tool_name": "Bash",
     "tool_input": {"command": "ls"},
     "tool_response": {"success": true},
     "duration_ms": 42
   }' | ~/.claude/hooks/tool-log.sh

   cat ~/.claude/tool-log.jsonl | jq -c .
   # очікуємо одну лінію з ts, session, tool, input, success, duration_ms
   ```

5. **Тестуй у живій сесії:**
   - Зроби кілька дій у Claude Code (Read, Edit, Bash)
   - `tail -f ~/.claude/tool-log.jsonl | jq .` — побачиш події

## Очікуваний результат

- Файл `~/.claude/tool-log.jsonl` росте при кожному tool-call
- Кожен рядок — валідний JSON (перевір: `jq . < tool-log.jsonl`)

## Якщо не вийшло

- `solutions/02-tool-log/tool-log.sh` — повний скрипт
- `solutions/02-tool-log/queries.md` — корисні `jq` запити для аналізу логу

## Бонус (якщо є час)

- Додай окремий hook `PostToolUseFailure` що логує **fail** events з `error` полем
- Додай ротацію: щоразу логуй у `~/.claude/tool-log/$(date +%Y-%m-%d).jsonl`
- Напиши `analyze.sh` що рахує: top-10 tools, середній `duration_ms` по tool

## Doc reference

- https://code.claude.com/docs/en/hooks#posttooluse
- https://code.claude.com/docs/en/hooks-guide#filter-hooks-with-matchers (приклад "Log every Bash command")
