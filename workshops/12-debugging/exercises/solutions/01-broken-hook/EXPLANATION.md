# Solution — broken hook

3 баги у starter, всі впливають на одну і ту ж функціональність.

## Баг 1 — `matcher: "bash"` (lowercase)

**Файл:** `settings.json`

Tool names у matcher case-sensitive. `Bash` (з великої), не `bash`.

**Симптом:** hook у `/hooks` бачиться, але ніколи не викликається.

**Як знайти:** `claude --debug hooks` → побачиш «matcher 'bash' did not match tool 'Bash'» (або подібне).

**Фікс:** `"matcher": "Bash"`

## Баг 2 — `exit 1` замість `exit 2`

**Файл:** `block-rm.sh`

Exit code 1 — non-blocking error за документацією Claude Code. Дія проходить.

> «Claude Code treats exit code 1 as a non-blocking error and proceeds with the action, even though 1 is the conventional Unix failure code.»

**Симптом:** hook запускається, виводить «Blocked», але `rm` все одно виконується.

**Фікс:** `exit 2` для блокування.

## Баг 3 — повідомлення на stdout замість stderr

**Файл:** `block-rm.sh`

При exit 0 з plain text — stdout йде у debug log, не у transcript.
При exit 2 — Claude бачить **stderr**, не stdout.

`echo "Blocked: ..."` без `>&2` → нічого не показується Claude. Він бачить лише exit code.

**Фікс:** `echo "Blocked: ..." >&2`

## Як перевірити що працює

```bash
# У сесії з виправленим hook-ом:
> Run rm -rf /tmp/test-debug

# Очікуваний вивід:
# Hook блокує, Claude отримує stderr-повідомлення
# і повідомляє юзеру: «Я не можу запустити rm -rf — заблоковано
# проєктним hook-ом: Blocked: rm -rf is dangerous...»
```

Без stderr-повідомлення Claude знає лише «hook denied», без причини.
З stderr — Claude знає причину і може запропонувати безпечну альтернативу.

## Чому це топові баги

- **Lowercase matcher:** copy-paste-ом з прикладу де було `bash` як shell name (не tool name).
- **exit 1:** muscle-memory з Unix.
- **stdout без `>&2`:** автор думав, що echo завжди йде «куди треба».

Усі три — реальні баги з production reviews.
