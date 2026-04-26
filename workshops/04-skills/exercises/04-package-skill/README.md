# Вправа 4 — пакуємо у plugin

**Мета:** перетворити два skill-и на встановлюваний плагін з `plugin.json`, namespaced invocation.

**Час:** 15 хв.

## Кроки

1. Подивись стартовий стан:
   ```bash
   tree starter/
   ```
   Маєш два skill-и: `git-status-summary` (з вправи 1) і `git-bisect-helper` (новий, простий).

2. Створи структуру плагіна:
   ```bash
   mkdir -p my-git-toolkit/.claude-plugin
   mkdir -p my-git-toolkit/skills
   cp -r starter/skills/* my-git-toolkit/skills/
   ```

3. Напиши `my-git-toolkit/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "my-git-toolkit",
     "description": "Git workflow skills: status summary, bisect helper",
     "version": "0.1.0",
     "author": {
       "name": "Your Name"
     }
   }
   ```

4. Встанови локально:
   ```bash
   claude plugin install ./my-git-toolkit
   ```

5. Перевір:
   - `/` має показати `/my-git-toolkit:git-status-summary` і `/my-git-toolkit:git-bisect-helper`
   - Зверни увагу на namespacing — двокрапка розділяє ім'я плагіна та skill-а

6. **Бонус (5+ хв):** опублікуй у git
   ```bash
   cd my-git-toolkit && git init && git add . && git commit -m "Initial plugin"
   git remote add origin git@github.com:<you>/my-git-toolkit.git
   git push -u origin main
   ```

7. **Бонус-2:** додай у marketplace (instructions у docs.claude.com).

## Pitfall

⚠️ Не клади `skills/`, `commands/`, `agents/`, `hooks/` всередину `.claude-plugin/`.
   - **Правильно:** `my-git-toolkit/skills/git-status-summary/SKILL.md`
   - **Неправильно:** `my-git-toolkit/.claude-plugin/skills/...`

## Очікуваний результат

- Локально встановлений плагін
- Обидва skill-и доступні через namespaced invocation
- Розуміння як готувати plugin до публічного релізу

## Якщо не вийшло

`solutions/04-package-skill/my-git-toolkit/` — повна структура.
