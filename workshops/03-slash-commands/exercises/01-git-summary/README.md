# Вправа 1 — `/git-summary` з `$ARGUMENTS`

**Мета:** написати slash-команду `/git-summary`, що приймає прапорець (наприклад `--since=yesterday`) і викликається явно.

**Час:** 10 хв.

## Кроки

1. **Створи теку команди в personal-локації:**

   ```bash
   mkdir -p ~/.claude/skills/git-summary
   ```

2. **Скопіюй стартовий SKILL.md:**

   ```bash
   cp starter/SKILL.md ~/.claude/skills/git-summary/SKILL.md
   ```

3. **Відкрий його і допиши тіло** так, щоб:

   - У frontmatter був `argument-hint: [--since=<duration>]`
   - У frontmatter був `disable-model-invocation: true` (це команда, не auto-skill)
   - Тіло використовувало `$ARGUMENTS`, наприклад:

     ```markdown
     Run `git log --oneline $ARGUMENTS` and group commits by author.
     ```

4. **Перезапусти Claude Code** (або `/reload-plugins`).

5. **Перевір `/`-меню** — `/git-summary` має бути там, з підказкою аргументів.

6. **Виклич без аргументів:**
   ```
   /git-summary
   ```

7. **Виклич з аргументами:**
   ```
   /git-summary --since=yesterday
   /git-summary --author=vadym --since="1 week ago"
   ```

   Зверни увагу: `--since="1 week ago"` (з лапками) піде як один токен у `$ARGUMENTS`.

8. **Експеримент:** замініть `$ARGUMENTS` на `$0` у тілі і викличіть з кількома прапорцями. Що зміниться?

## Очікуваний результат

- Команда з'являється у `/`-меню з підказкою
- `$ARGUMENTS` підставляється у тіло до того, як Claude почне виконувати

## Якщо не вийшло

`solutions/01-git-summary/SKILL.md` — робочий варіант з коментарями.

## Документація

- https://code.claude.com/docs/en/skills#available-string-substitutions
- https://code.claude.com/docs/en/skills#pass-arguments-to-skills
