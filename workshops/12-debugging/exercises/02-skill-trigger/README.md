# Вправа 2 — skill з vague description

**Мета:** діагностувати чому skill не тригериться семантично, переписати description.

**Час:** 10 хв.

## Що дано

- `starter/SKILL.md` — skill `bundle-size-check`
- Description: `"Check bundle size"`
- Skill працюватиме якщо викликати явно (`/bundle-size-check`)
- Але неявні запити («check bundle size», «how big is the bundle?») його не тригерять

## Кроки

1. **Встанови skill:**
   ```bash
   mkdir -p ~/.claude/skills/bundle-size-check
   cp starter/SKILL.md ~/.claude/skills/bundle-size-check/SKILL.md
   ```

2. **Перезапусти Claude Code** (тека нова — auto-detect не сработає).

3. **Перевір `/`-меню** — skill має бути там.

4. **Спробуй явний виклик:**
   ```
   /bundle-size-check
   ```
   Має спрацювати. Це підтверджує що skill loaded.

5. **Спробуй неявні запити:**
   ```
   > check the bundle size of this app
   > how big is our js bundle?
   > is the dist folder bloated?
   > are there any dependency size issues?
   ```
   Більшість не тригернуть skill.

6. **Пройди 6-крокову діагностику зі слайдів.**

7. **Перепиши description** так, щоб тригерило надійно. Залиш решту SKILL.md без змін.

8. **Re-test** — після кожного редагування Claude Code auto-reload-ить skill, рестарт не треба.

## Що шукаємо у виправленій description

- Action verbs (`Use when`, `Check`, `Diagnose`)
- Конкретні контексти і trigger phrases
- Синоніми як юзер може сказати (bundle, weight, size, bloat, dependencies)
- Front-load — перші 50 символів найважливіші

## Solution

`solutions/02-skill-trigger/SKILL.md` — приклад «pushy» description що надійно тригерить.
