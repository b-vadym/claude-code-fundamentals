# Вправа 1 — built-in Explore subagent

**Мета:** викликати `Explore` для пошуку у кодовій базі без захаращення основного контексту.

**Час:** 10 хв.

## Кроки

1. **Зайди у будь-який середній репо** (можна цей-таки — `claude-code-developers`).

2. **Запусти Claude Code:**

   ```bash
   claude
   ```

3. **Попроси Explore зробити пошук:**

   ```
   Use the Explore subagent to find all places where DocRef is used in this repo.
   ```

4. **Спостерігай у transcript-і.** Має бути:

   - **Один** `Agent(Explore, ...)` tool-call
   - У rendering-у — окремий блок «Agent» з власним прогресом
   - Тільки `summary` повертається назад до main (а не вміст 47 файлів)

5. **Експеримент з thoroughness:**

   - Спробуй варіант: «Use Explore quickly to find DocRef.vue» — Claude передасть `quick`
   - Спробуй: «Use Explore very thoroughly to map all DocRef usage patterns» — `very thorough`

6. **Контр-приклад:**

   - Спитай: «Прочитай файл components/DocRef.vue»
   - Швидше за все Claude **не** делегує — занадто просто, зробить сам

## Очікуваний результат

- Розуміння як виглядає `Agent` call у transcript
- Помітив, що main-context отримав summary, не raw content
- Один з варіацій thoroughness спрацював за намір

## Якщо не вийшло

- `solutions/01-explore-subagent/` — приклади запитів і очікуваних transcript-фрагментів
- Перевір що у тебе Claude Code v2.1.63+ (`claude --version`)
