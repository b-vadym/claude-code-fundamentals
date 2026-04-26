# Solution 04 — researcher → planner → reviewer chain

## Файли

- `agents/chain-researcher.md` — копія starter (вже надійна)
- `agents/chain-planner.md` — копія starter
- `agents/chain-reviewer.md` — копія starter
- `workdir/task.md` — копія starter
- `workdir/sample-research.md` — приклад того, що researcher може видати
- `workdir/sample-plan.md` — приклад того, що planner може видати
- `workdir/sample-review.md` — приклад того, що reviewer може видати

## Як викликати

Один prompt — оркеструє все:

```
Use chain-researcher to read workdir/task.md and write workdir/research.md.
Then use chain-planner to read research.md and write workdir/plan.md.
Then use chain-reviewer to read both and write workdir/review.md.
Finally, summarize what review.md says.
```

## Очікуваний transcript

```
⏵ Agent(chain-researcher)   → reads task.md, writes research.md
   ↑ "Research written to workdir/research.md (4 sections, 0 related files)"

⏵ Agent(chain-planner)       → reads research.md, writes plan.md
   ↑ "Plan written to workdir/plan.md (5 steps)"

⏵ Agent(chain-reviewer)      → reads both, writes review.md
   ↑ "Review written to workdir/review.md (verdict: approve with changes, 2 critical issues)"

[main] Reads review.md and presents summary to user.
```

## Що варто зауважити

1. **Subagent-и не передають дані напряму.** Лише через файли.
2. **Main session знає про всі три файли** — вона їх не читає під час chain (тільки після), бо це б засмітило основний контекст. Останній read відбувається лише для фінального summary.
3. **Послідовно, не паралельно.** Наступний крок залежить від попереднього артефакту.
4. **Кожен subagent повертає лише one-line confirmation** — main-context чистий.

## Розширення

Цей pattern легко масштабувати:

```
researcher → planner → implementer → tester → reviewer
```

Кожен новий subagent читає попередні артефакти, пише свій. Один prompt оркеструє все.

Якщо хочеш паралель з peer-to-peer комунікацією — це уже **agent teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Тоді planner може запитати researcher-а напряму через `SendMessage`, не через main.
