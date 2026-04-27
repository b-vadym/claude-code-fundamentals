# Вправа 1 — broken hook

**Мета:** виявити чому PreToolUse hook не блокує небезпечну команду, і виправити.

**Час:** 15 хв.

## Що дано

- `starter/settings.json` — конфіг з PreToolUse hook
- `starter/block-rm.sh` — bash-скрипт що *має* блокувати `rm -rf`

Hook існує, конфіг у місці. Але `rm -rf /tmp/test` спокійно виконується.

## Симптом

```
> Run rm -rf /tmp/test-debug

# Claude:
[Bash] rm -rf /tmp/test-debug
✓ Done

# /tmp/test-debug — стерта.
```

## Кроки

1. **Підготуй тестовий проєкт:**
   ```bash
   mkdir -p /tmp/hook-debug && cd /tmp/hook-debug
   mkdir -p .claude
   cp <шлях до starter>/settings.json .claude/settings.json
   cp <шлях до starter>/block-rm.sh .claude/block-rm.sh
   chmod +x .claude/block-rm.sh
   mkdir /tmp/test-debug   # буде стерто, відтворити
   ```

2. **Запусти Claude Code тут:**
   ```bash
   claude
   ```

3. **`/hooks`** — переконайся що бачиш чи не бачиш hook у списку. Це дає першу підказку.

4. **Спробуй блокувати:**
   ```
   Run rm -rf /tmp/test-debug
   ```

5. **Запусти `claude --debug hooks`** в новій сесії, повтори запит. Подивись на debug-вивід.

6. **Знайди ВСІ баги** (їх 3) і виправ.

7. **Перевір** — `rm -rf` має блокуватись з повідомленням «Blocked: rm commands are denied».

## Підказки (якщо застряг)

- Дивись на `matcher` у `settings.json`
- Дивись на exit code у `block-rm.sh`
- Чи Claude *бачить* пояснення чому заблоковано?

## Solution

`solutions/01-broken-hook/` — виправлений конфіг + пояснення кожного бага.
