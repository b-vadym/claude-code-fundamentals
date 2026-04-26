# Вправа 2 — description tuning

**Мета:** на власні очі побачити різницю між vague / specific / pushy description.

**Час:** 15 хв.

## Контекст

Skill `bundle-size-check` робить одне: запускає `du -sh dist/` і порівнює з попереднім вимірюванням. У теці три варіанти description (А/B/C).

## Кроки

1. Підготуй базовий skill:
   ```bash
   mkdir -p ~/.claude/skills/bundle-size-check
   cp body.md ~/.claude/skills/bundle-size-check/SKILL.md
   ```
   (тіло те саме у всіх трьох — змінюватимеш лише frontmatter)

2. **Раунд А (vague):** скопіюй frontmatter з `A-vague.md` поверх `SKILL.md`:
   ```bash
   ./swap-frontmatter.sh A-vague.md
   ```
   (або вручну: відкрий обидва файли, скопіюй frontmatter секцію)

3. **Тест-запити (одні й ті самі для всіх раундів):**
   - «який розмір bundle-у?»
   - «чи багато залежностей?»
   - «check the dist size»
   - «is bundle bloated?»
   - «show package weight»

4. Заповни `tests-table.md` — для кожного запиту: тригернуло (✅) чи ні (❌).

5. Повтори раунди **B (specific)** і **C (pushy)**.

6. Порівняй колонки. Зроби висновки.

## Очікуваний результат

- A — майже все ❌ (description занадто загальний)
- B — явні запити ✅, дотичні ⚠️
- C — навіть дотичні ✅

## Висновки

- Action verbs + конкретні контексти > загальні слова
- "Pushy" description свідомо борить недо-тригерення
- Перерахуй синоніми — як юзер може сказати по-різному
