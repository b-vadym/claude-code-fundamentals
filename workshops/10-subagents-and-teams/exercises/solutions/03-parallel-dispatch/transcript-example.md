# Solution 03 — паралельний dispatch (приклад transcript)

## Запит

```
Use 3 separate Explore subagents IN PARALLEL:
1) Where auth lives
2) Test runners and files
3) Build tooling

Run all three at once.
```

## Що ти побачиш

```
[user] Use 3 separate Explore subagents IN PARALLEL ...

[assistant] Запускаю три Explore паралельно.

⏵ Agent(Explore) [1/3, running]
  prompt: "Find authentication / login / session code. Return file paths + key functions."
  thoroughness: medium

⏵ Agent(Explore) [2/3, running]
  prompt: "Identify test runner config (vitest/jest/...) and count test files."
  thoroughness: medium

⏵ Agent(Explore) [3/3, running]
  prompt: "Find build tooling (Vite/webpack/Rollup) and list config files."
  thoroughness: quick

  ↓ all three running concurrently
  ↓ subagent 1 finishes (~18s) → "Auth: src/auth/handler.ts, ..."
  ↓ subagent 2 finishes (~14s) → "Tests: vitest, 142 specs in tests/."
  ↓ subagent 3 finishes (~22s) → "Build: Vite, 3 config files."

[assistant]  Synthesis:
  - **Auth:** lives in src/auth/. Two main entry points: handler.ts (HTTP) and session.ts (state).
  - **Tests:** Vitest, 142 specs across tests/ + per-package __tests__/.
  - **Build:** Vite, vite.config.ts at root + per-package overrides.
```

## Ключові моменти

1. **Один assistant turn → 3 Agent tool-calls** одночасно
2. **Wall-clock ≈ 22 сек** (час найповільнішого), а не 54 сек (сума)
3. **Main context отримав 3 коротких summary** (~150 токенів), не 3 raw exploration (~5K кожний)
4. Claude робить **synthesis крок** після того, як всі повернулись

## Anti-pattern

Якщо Claude замість паралельного dispatch-у зробив послідовно:

```
⏵ Agent(Explore) [1/1] → done
⏵ Agent(Explore) [1/1] → done
⏵ Agent(Explore) [1/1] → done
```

Переформатуй з явним:
- «in a SINGLE message»
- «all three at once»
- «do not wait for one to finish before starting the next»

## Cost-tradeoff

| Підхід | Wall-clock | Total tokens (main + sub) | Main-context cost |
|---|---|---|---|
| Sequential subagents | ~54s | ≈3× single | ≈3× summary |
| Parallel subagents | ~22s | ≈3× single | ≈3× summary |
| Direct in main | ~30s | ≈1× | **3× raw** (все осідає у main) |

Парлель не економить токени — вона економить **час** і **main-context**.
