# Вправа 4 — мікро-команда як ланцюг

**Мета:** побудувати researcher → planner → reviewer ланцюг через файли-артефакти.

**Час:** 15 хв.

Це **не** agent teams (experimental flag). Це звичайні subagent-и, що передають стан через **файли у спільному working directory**.

## Кроки

1. **Скопіюй subagent-визначення у scope:**

   ```bash
   # Personal — буде доступно в усіх проєктах:
   mkdir -p ~/.claude/agents
   cp starter/agents/*.md ~/.claude/agents/

   # АБО project (якщо тестуєш у конкретному репо):
   mkdir -p .claude/agents
   cp starter/agents/*.md .claude/agents/
   ```

2. **Підготуй task у workdir:**

   ```bash
   mkdir -p workdir
   cp starter/workdir/task.md workdir/task.md   # уже є приклад
   ```

3. **Перезапусти Claude Code** (subagent-и завантажуються при старті).

4. **Запусти ланцюг одним prompt-ом:**

   ```
   Use the chain-researcher subagent to read workdir/task.md and write workdir/research.md.
   Then use chain-planner to read research.md and write workdir/plan.md.
   Then use chain-reviewer to read both and write workdir/review.md.
   Finally summarize what review.md says.
   ```

5. **Спостерігай у transcript:**

   - 3 послідовні `Agent` calls
   - Кожен пише свій файл
   - Основна сесія робить final read

6. **Перевір артефакти:**

   ```bash
   ls workdir/
   # task.md      ← вхід
   # research.md  ← від researcher
   # plan.md      ← від planner
   # review.md    ← від reviewer
   ```

## Очікуваний результат

- 4 файли у `workdir/` (task + 3 артефакти)
- Кожен наступний subagent посилається на попередні артефакти
- Working directory працює як shared state

## Чому це працює (а не agent teams)

- **Subagent не бачить контексту іншого subagent-а** — але бачить файли
- **Working dir shared** з main + усіма subagent-ами
- **Main session оркеструє** — subagent-и не передають один одному напряму
- Не потрібен experimental flag, працює сьогодні

## Якщо не вийшло

- `solutions/04-agent-team-chain/` — повні розв'язки 3 subagent-ів + приклад артефактів
- Якщо subagent скаржиться, що не бачить файлу — перевір що ти у тому ж working dir
- Якщо результати «порожні» — task.md може бути занадто абстрактним, додай конкретики

## Що далі

Цей pattern масштабується: додай `tester`, `documenter`, `releaser`. Кожен робить одне діло, читає попередні артефакти, пише свій. Це CI-pipeline у мініатюрі.

Якщо хочеш, щоб **subagent-и обговорювали між собою**, а не лише через main — це уже **agent teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).
