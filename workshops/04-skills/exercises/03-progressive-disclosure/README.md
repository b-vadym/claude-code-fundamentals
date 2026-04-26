# Вправа 3 — progressive disclosure

**Мета:** розбити роздутий 1-файловий skill на SKILL.md + `references/<cloud>.md`

**Час:** 15 хв.

## Контекст

`starter/SKILL.md` містить інструкцію деплою на 3 хмари (AWS, GCP, Azure). Усі деталі в одному файлі — кожна сесія, де skill тригериться, платить токенами за всі три платформи, навіть якщо проєкт використовує лише одну.

## Завдання

Розбити так, щоб:
- **SKILL.md** — оверв'ю + decision tree (яку хмару вибрати з contextu проєкту)
- **`references/aws.md`** — деталі AWS
- **`references/gcp.md`** — деталі GCP
- **`references/azure.md`** — деталі Azure

## Кроки

1. Відкрий `starter/SKILL.md`. Прочитай. Знайди:
   - Спільну частину (decision-tree, валідація, output формат)
   - Cloud-specific блоки

2. Створи `references/` тут (поряд з starter):
   ```bash
   mkdir references
   ```

3. Перенеси кожен cloud-блок у свій `references/<cloud>.md`

4. У новому SKILL.md залиш **markdown-links** на референси:
   ```markdown
   For AWS: read [aws.md](references/aws.md)
   For GCP: read [gcp.md](references/gcp.md)
   For Azure: read [azure.md](references/azure.md)
   ```
   ⚠️ Саме markdown-links — Claude їх розпізнає як supporting файли.

5. Перевір розмір:
   ```bash
   wc -l SKILL.md
   ```
   Має стати ≤ 100 рядків.

6. Встанови у `~/.claude/skills/cloud-deploy/` і тригерни на тестовому проєкті:
   ```bash
   touch terraform/aws/main.tf  # фейковий AWS-маркер
   ```
   Питай Claude: «допоможи задеплоїти». Перевір (через `/btw what just happened`), чи Claude підвантажив **лише** `aws.md`, не всі три.

## Очікуваний результат

- SKILL.md ~60–80 рядків, чистий decision-tree
- Три references-файли по ~50–80 рядків кожен
- Виграш у токенах при тригері: ×2–3

## Якщо не вийшло

`solutions/03-progressive-disclosure/` — еталонний розбий.
