# Стартовий prompt для вправи 3

```
Use 3 separate Explore subagents IN PARALLEL to investigate this repo:
1) Where authentication / auth flow lives (files, key functions)
2) Which test runners and test files exist (count, locations)
3) What build / bundler tooling is configured

Run all three at once in a single message, then synthesize findings.
```

## Альтернатива (якщо репо без auth)

```
Use 3 Explore subagents in parallel:
1) Map the slide files (workshops/*/slides.md) — count slides per workshop
2) Map shared infrastructure (components/, scripts/)
3) Map deployment config (.github/workflows/)

Synthesize a one-paragraph repo overview.
```

## Гібрид (parallel → sequential)

```
Use 2 Explore subagents in parallel:
A) Find all tests
B) Find auth code

After they finish, use ONE more general-purpose subagent that reads
both results and writes a brief "test coverage gaps for auth" report.
```
