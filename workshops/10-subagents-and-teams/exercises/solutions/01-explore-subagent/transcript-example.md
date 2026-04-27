# Solution 01 — Explore subagent (експрес-приклад transcript)

Це фрагмент того, що ти приблизно побачиш у Claude Code UI коли скажеш:

> Use the Explore subagent to find all places where DocRef is used in this repo.

```
[user] Use the Explore subagent to find all places where DocRef is used in this repo.

[assistant]  Делегую Explore.

⏵ Agent(Explore)
  prompt: "Find every usage of the DocRef component across the repo,
           returning file paths and line numbers grouped by workshop."
  thoroughness: medium

  ↓ subagent context (separate window)
  ↓  Glob: **/*.md, **/*.vue
  ↓  Grep: '<DocRef'
  ↓  Read: workshops/01-fundamentals/slides.md (matched 32 lines)
  ↓  Read: workshops/02-token-economy/slides.md (matched 18 lines)
  ↓  Read: workshops/04-skills/slides.md (matched 13 lines)
  ↓  ...
  ↑ returns:
    "DocRef component used in 63 places across 3 workshops:
     - workshops/01-fundamentals/slides.md: 32 refs (lines 108, 132, ...)
     - workshops/02-token-economy/slides.md: 18 refs
     - workshops/04-skills/slides.md: 13 refs
     Convention: every slide explaining a Claude Code feature carries DocRef."

[assistant]  DocRef використовується у 63 місцях, з домінантою у fundamentals.
              Хочеш переглянути патерни вживання чи список конкретних слайдів?
```

## Що тут важливе

1. **Один `Agent` tool-call** — а не послідовність grep + read
2. **Thoroughness `medium`** — Claude обрав сам, бо запит без квантору
3. **Subagent context separate** — у тебе в main-у не залишилось тих 63 line-ів raw, а лише summary
4. **3-line summary** — main-context отримав ~50 токенів замість ~2K, які жмуть всі 63 рядки

## Контр-приклад

> Read the file components/DocRef.vue and tell me what props it takes.

```
[assistant]  (Claude НЕ викликає subagent)
  ↓ Read: components/DocRef.vue
  ↑ "DocRef takes 3 props: url (required string), label (required string),
     offset (optional number)."
```

Прямий Read у main, без subagent — задача занадто проста.

## Порівняння thoroughness

| Запит | thoroughness | Поведінка |
|---|---|---|
| «find DocRef» | medium | Стандартний обхід репо |
| «find DocRef quickly» / «just check» | quick | Targeted lookup, мінімум tool calls |
| «very thoroughly map» / «exhaustive» | very thorough | Повний обхід, кожен match |
