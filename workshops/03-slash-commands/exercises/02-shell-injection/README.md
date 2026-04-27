# Вправа 2 — динамічний контекст через `!`команда``

**Мета:** додати в команду `/env-info` shell-ін'єкцію — Claude отримає вже виконаний вивід `pwd`, `git branch --show-current`, `git log -1`.

**Час:** 10 хв.

## Чому це важливо

Без shell-ін'єкції Claude має сам **викликати** Bash як окремий tool-call. З `!`pwd`` — вивід підставляється в текст команди **до того, як Claude її прочитає**. Це economy токенів і часу: один turn замість двох.

> Це **preprocessing**, а не виконання Claude. Claude бачить уже-готовий результат.
> — https://code.claude.com/docs/en/skills#inject-dynamic-context

## Кроки

1. **Скопіюй стартер:**

   ```bash
   mkdir -p ~/.claude/skills/env-info
   cp starter/SKILL.md ~/.claude/skills/env-info/SKILL.md
   ```

2. **Відкрий і допиши.** Стартер містить заготовку — твоя задача замінити `TODO`-блоки на справжні `!`<команда>``:

   - Поточна тека: `!`pwd``
   - Поточна гілка: `!`git branch --show-current``
   - Останній коміт: `!`git log -1 --oneline``
   - Версія Node: `!`node --version 2>/dev/null \|\| echo none``
   - (Бонус) Вивід кількох команд через fenced block:

     ````markdown
     ```!
     uname -a
     git status --short
     ```
     ````

3. **Тестуй у репо з git-станом** (нехай буде хоч один незакомічений файл).

4. **Виклич:**
   ```
   /env-info
   ```

5. **Подивись у вивід.** Зверни увагу: Claude знає поточну гілку без додаткового tool-call — бо вивід уже в його промпті.

6. **Експеримент:** додай команду, яка фейлить (наприклад `!`nonexistent-cmd``). Що Claude бачить — exit code чи stderr?

## Pitfall: `disableSkillShellExecution`

Якщо в `~/.claude/settings.json` є `"disableSkillShellExecution": true` — твої `!`...`` замінюються плейсхолдером `[shell command execution disabled by policy]`. Менеджмент може це політично заборонити для security.

## Очікуваний результат

- Команда повертає інфо без явних tool-call-ів від Claude
- Економія: 1 turn замість 4–5

## Якщо не вийшло

`solutions/02-shell-injection/SKILL.md`.

## Документація

- https://code.claude.com/docs/en/skills#inject-dynamic-context
