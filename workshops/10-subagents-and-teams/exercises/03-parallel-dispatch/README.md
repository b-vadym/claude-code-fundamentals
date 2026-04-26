# Вправа 3 — паралельний dispatch

**Мета:** запустити 3 subagent-и в одному message-і, спостерігати паралельні `Agent` calls.

**Час:** 15 хв.

## Кроки

1. **Зайди у середній репо** з кількома різними областями (auth, tests, build). Можна цей-таки.

2. **Запусти Claude Code:**

   ```bash
   claude
   ```

3. **Скопіюй prompt з `starter/parallel-prompt.md`** і встав:

   ```
   Use 3 separate Explore subagents IN PARALLEL to investigate this repo:
   1) Where authentication / auth flow lives (files, key functions)
   2) Which test runners and test files exist (count, locations)
   3) What build / bundler tooling is configured

   Run all three at once in a single message, then synthesize findings.
   ```

4. **Спостерігай у transcript:**

   - Має бути **три `Agent(Explore, ...)` tool-call-и в одному assistant turn**
   - Усі три виконуються concurrent — побачиш у статусах
   - Кожен повертає свій summary
   - Claude синтезує: «Auth: X. Tests: Y. Build: Z.»

5. **Експеримент 1:** попроси Claude **НЕ** в паралель:

   ```
   Now repeat the same investigation but sequentially, one at a time.
   ```

   Порівняй wall-clock час.

6. **Експеримент 2:** додай одну залежну задачу:

   ```
   Use 2 Explore subagents in parallel: A) find tests, B) find auth.
   Then ONE subagent that reads results and writes a coverage gap report.
   ```

   Це гібрид: 2 паралельних → 1 послідовний.

## Очікуваний результат

- 3 паралельних `Agent` calls видно у transcript-і
- Wall-clock швидше за послідовно
- Main отримав 3 короткі summary, не 3 raw exploration

## Caveat

> «Running many subagents that each return detailed results can consume significant context.»
> — code.claude.com/docs/en/subagents#run-parallel-research

3-5 паралельних — нормально. 10+ — задумайся, можливо це вже agent team.

## Якщо не вийшло

- `solutions/03-parallel-dispatch/` — приклад transcript-а з прогресом
- Якщо Claude робить послідовно: переформатуй запит з явним «in parallel» та «in a single message»
