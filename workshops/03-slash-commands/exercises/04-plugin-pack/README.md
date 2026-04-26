# Вправа 4 — пакуємо команди у plugin

**Мета:** перетворити дві команди (`git-summary` з вправи 1 + `env-info` з вправи 2) на встановлюваний плагін з namespaced invocation `/my-git-commands:<name>`.

**Час:** 15 хв.

## Кроки

1. **Подивись стартовий стан:**

   ```bash
   ls starter/
   # skills/git-summary/SKILL.md
   # skills/env-info/SKILL.md
   ```

   У `starter/skills/` лежать дві команди (без обгортки плагіна).

2. **Створи плагін з нуля поряд:**

   ```bash
   mkdir -p my-git-commands/.claude-plugin
   cp -r starter/skills my-git-commands/skills
   ```

3. **Напиши маніфест** `my-git-commands/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "my-git-commands",
     "description": "Git workflow commands: log summary, env info",
     "version": "0.1.0",
     "author": {
       "name": "Your Name"
     }
   }
   ```

4. **Локально завантаж:**

   ```bash
   claude --plugin-dir ./my-git-commands
   ```

5. **Перевір `/`-меню:**
   - Має з'явитися `/my-git-commands:git-summary`
   - І `/my-git-commands:env-info`
   - **Префікс** = `name` з `plugin.json`

6. **Виклич:**
   ```
   /my-git-commands:git-summary --since=yesterday
   /my-git-commands:env-info
   ```

7. **Edit-and-reload loop:** змінюй SKILL.md → `/reload-plugins` без рестарту.

8. **(Бонус):** опублікуй у git, додай до marketplace через `/plugin` форму.

## Pitfall

⚠️ **НЕ клади** `skills/`, `commands/`, `agents/`, `hooks/` всередину `.claude-plugin/`.

```
✅ my-git-commands/skills/git-summary/SKILL.md
❌ my-git-commands/.claude-plugin/skills/git-summary/SKILL.md
```

> Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root level.
> — https://code.claude.com/docs/en/plugins

## Skill name vs command name

`/my-git-commands:git-summary`:
- `my-git-commands` ← `name` поля в `plugin.json`
- `git-summary` ← ім'я теки в `skills/` (або `name` у frontmatter)

Конфлікти між плагінами неможливі — namespacing.

## Очікуваний результат

- Плагін локально завантажений через `--plugin-dir`
- Обидві команди доступні з namespaced prefix
- Розумієш різницю: проєктна `.claude/skills/` vs плагін

## Якщо не вийшло

`solutions/04-plugin-pack/my-git-commands/` — повна структура.

## Документація

- https://code.claude.com/docs/en/plugins#create-your-first-plugin
- https://code.claude.com/docs/en/plugins#plugin-structure-overview
