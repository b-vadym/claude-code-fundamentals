# Workshop 05 — Hooks: вправи

Чотири вправи по 10–12 хвилин кожна. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Claude Code v1.x встановлений (`claude --version`)
- `jq` встановлений (`brew install jq` / `apt-get install jq`)
- Доступ до `~/.claude/settings.json` і `~/.claude/hooks/`
- Git-репо для тестових команд (можна цей)

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-block-dangerous-bash/` | `PreToolUse` regex проти `rm -rf /` | 12 хв |
| 2 | `02-tool-log/` | `PostToolUse` — JSONL audit log усіх tool-calls | 10 хв |
| 3 | `03-session-context/` | `SessionStart` — cwd + branch + recent commits | 12 хв |
| 4 | `04-prompt-warning/` | `UserPromptSubmit` — warn про «delete production» | 12 хв |

## Як запускати

Кожна тека має `README.md` зі специфічними кроками. Загалом:

```bash
cd 0N-name/
cat README.md          # інструкція
ls starter/            # стартовий стан
# роби кроки з README
ls ../solutions/0N-*/  # підглянь якщо застрягнеш
```

## solutions/

Готові розв'язки для кожної вправи. Не дивись поки не спробував сам — мета не «скопіювати», а зрозуміти різницю між твоїм підходом і еталоном.

## Як тестувати hook без виклику Claude

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | ./check.sh
echo "Exit: $?"
```

Pipe sample JSON → `$?` показує exit code → stderr показує block reason.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці
- Питання — Discord або підніми руку

## Що зберіг після воркшопу

- 4 робочих hook-и у `~/.claude/hooks/`
- `~/.claude/settings.json` зі зразками для PreToolUse / PostToolUse / SessionStart / UserPromptSubmit
- Розуміння exit-code семантики (особливо: тільки `2` блокує)
- Розуміння JSON output (especially `additionalContext`, `permissionDecision`)
- 6-крокова діагностика «чому hook не firing»
