# Вправа 3 — SessionStart context injection

**Мета:** при кожному `SessionStart` додати у контекст: cwd, поточну гілку, останні 3 коміти, кількість TODO у CLAUDE.md.

**Час:** 12 хв.

## Чому це корисно

`SessionStart` запускається на:
- `startup` — перший старт сесії
- `resume` — відновлення (`claude --continue`)
- `clear` — `/clear`
- `compact` — після auto-compaction

> "Any text your command writes to stdout is added to Claude's context."
> — code.claude.com/docs/en/hooks-guide

Тобто все що скрипт echo-ає → Claude бачить як system reminder. Це найкорисніший hook у щоденній роботі: Claude не питає «де я?» — одразу знає.

## Кроки

1. **Скопіюй стартер:**

   ```bash
   cp starter/session-context.sh ~/.claude/hooks/session-context.sh
   chmod +x ~/.claude/hooks/session-context.sh
   ```

2. **Доповни `session-context.sh`** — там TODO:
   - Прочитай stdin → витягни `cwd`
   - Перейди у `cwd`; якщо не git-репо — вивести спрощений context
   - Інакше — branch, ahead/behind, останні 3 коміти
   - Підрахуй TODO у `./CLAUDE.md` (рядки що містять `TODO`/`FIXME`)
   - Все це у stdout

3. **Зареєструй у `~/.claude/settings.json`** (без matcher — firing на startup, resume, clear, compact):

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "$HOME/.claude/hooks/session-context.sh",
               "timeout": 10
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
     "cwd": "'$PWD'",
     "hook_event_name": "SessionStart",
     "source": "startup"
   }' | ~/.claude/hooks/session-context.sh
   ```

   Має вивести багатолінійний текст з твоїм проєктним контекстом.

5. **Тестуй у живій сесії:** запусти Claude Code з нової сесії, задай питання типу «де я зараз?» — Claude уже має контекст з твого hook.

## Очікуваний результат

```
[Project context]
cwd: /home/dev/myproject
branch: feature/hooks (ahead 2)
recent commits:
  3136432 Add opusplan slide
  4845898 Add CI/CD section
  19a3d61 Add /recap slide
todos: 3 (in CLAUDE.md)
```

## Якщо не вийшло

- `solutions/03-session-context/session-context.sh` — повний скрипт
- `solutions/03-session-context/session-context-json.sh` — варіант з JSON output (`hookSpecificOutput.additionalContext`)

## Бонус

- Додай **різну** поведінку залежно від `source` (startup vs compact)
- При `source: compact` — додай специфічне нагадування з custom-conventions
- При `source: resume` — додай рядок «session resumed at \<timestamp\>»

## Doc reference

- https://code.claude.com/docs/en/hooks#sessionstart
- https://code.claude.com/docs/en/hooks-guide#re-inject-context-after-compaction
