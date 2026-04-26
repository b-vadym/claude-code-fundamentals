# Solution 02 — commit-message-writer

Розширена версія порівняно зі starter:

**Що додано в description:**
- Конкретні тригерні фрази: «commit», «draft a commit message», «summarize staged changes»
- «Use proactively» — push для авто-делегування

**Що додано в тіло:**
- Повний перелік типів з поясненнями
- Правила для scope
- Empty-staging edge case
- Чіткий return-format ("ONLY the commit message text", no fences)

## Як викликати

```
# гарантовано:
@commit-message-writer (agent)

# або natural-language:
Use commit-message-writer for my staged changes.

# або:
Draft a commit for what I have staged.
```

## Перевірочні test cases

| Staging | Очікуваний output |
|---|---|
| Один новий test-файл у `tests/` | `test: add foo specs` (приблизно) |
| Зміна у `src/auth/` | `fix(auth): ...` або `refactor(auth): ...` |
| Тільки `package.json` deps | `chore: bump <pkg>` |
| Порожнє staging | `Nothing staged.` |
