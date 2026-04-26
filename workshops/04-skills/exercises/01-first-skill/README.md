# Вправа 1 — пишемо першу

**Мета:** робочий skill `git-status-summary` встановлений у `~/.claude/skills/` і викликається явно та неявно.

**Час:** 10 хв.

## Кроки

1. **Скопіюй стартовий SKILL.md у свою personal-теку:**

   ```bash
   mkdir -p ~/.claude/skills/git-status-summary
   cp starter/SKILL.md ~/.claude/skills/git-status-summary/SKILL.md
   ```

2. **Перезапусти Claude Code** (або `/reload-plugins` якщо вже відкрита сесія).

3. **Перевір `/`-меню:**
   - Введи `/` у Claude Code prompt
   - Має з'явитися `git-status-summary` у списку
   - Якщо нема — перевір шлях `~/.claude/skills/git-status-summary/SKILL.md` точно

4. **Явний виклик:**
   ```
   /git-status-summary
   ```
   Має згенерувати summary поточного git-стану (запусти у репо з якимись змінами для наочності).

5. **Неявний виклик:**
   - Закрий `/`-меню
   - Спитай: «який стан гіту в цьому репо?»
   - Подивись чи Claude підхопив skill (зазвичай зазначає що тригерить)

6. **Експеримент:** спробуй варіації запиту
   - «show me what changed locally» — спрацювало?
   - «list staged files» — спрацювало?
   - «git status please» — спрацювало?

## Очікуваний результат

- Skill встановлений
- Явний виклик працює
- Хоча б один з неявних варіантів запитів спрацював

## Якщо не вийшло

- `solutions/01-first-skill/` — повністю готовий SKILL.md з відомою-робочою description
- Розділ debug у слайдах (Section 5) — чек-ліст з 6 кроків
