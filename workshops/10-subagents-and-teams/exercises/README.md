# Workshop 10 — Subagents & Agent Teams: вправи

Чотири вправи по 10–15 хвилин кожна. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Claude Code v2.1+ (`claude --version`) — `Agent` tool перейменовано з `Task` у v2.1.63
- Доступ до `~/.claude/agents/` (для personal subagent-ів) і `.claude/agents/` (для project)
- Git-репо з достатньо коду, щоб було що шукати

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-explore-subagent/` | Виклик built-in `Explore` для пошуку у репо | 10 хв |
| 2 | `02-custom-subagent/` | Власний `commit-message-writer` у `.claude/agents/` | 15 хв |
| 3 | `03-parallel-dispatch/` | 3 паралельних `Agent` calls в одному message-і | 15 хв |
| 4 | `04-agent-team-chain/` | Researcher → planner → reviewer ланцюг через файли | 15 хв |

## Як запускати

Кожна тека має свій `README.md`. Загалом:

```bash
cd 0N-name/
cat README.md          # інструкція
ls starter/            # стартовий стан
# роби кроки з README
ls ../solutions/0N-*/  # підглянь якщо застрягнеш
```

## solutions/

Готові розв'язки. Не дивись поки не спробував сам — мета не «скопіювати», а зрозуміти різницю між твоїм підходом і еталоном.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці
- Питання — Discord або підніми руку на воркшопі

## Що зберіг після воркшопу

- Робочий `commit-message-writer` у `~/.claude/agents/` або `.claude/agents/`
- 3 готових subagent-и для chain-pattern-у (researcher / planner / reviewer)
- Decision tree: коли subagent, коли team, коли main
- Production-чек-ліст для нових subagent-ів
