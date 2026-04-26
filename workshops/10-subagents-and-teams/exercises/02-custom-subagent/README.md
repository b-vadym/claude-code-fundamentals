# Вправа 2 — кастомний subagent

**Мета:** написати `commit-message-writer` у `.claude/agents/` (project) або `~/.claude/agents/` (personal) і викликати його.

**Час:** 15 хв.

## Кроки

1. **Скопіюй стартовий файл у потрібний scope:**

   ```bash
   # personal (всі проєкти):
   mkdir -p ~/.claude/agents
   cp starter/commit-message-writer.md ~/.claude/agents/commit-message-writer.md

   # АБО project (тільки цей репо, commit разом з кодом):
   mkdir -p .claude/agents
   cp starter/commit-message-writer.md .claude/agents/commit-message-writer.md
   ```

2. **Перезапусти Claude Code** (subagent-и завантажуються при старті сесії).

   Альтернативно: команда `/agents` у живій сесії — підхопить новий файл.

3. **Підготуй staged changes для тестування:**

   ```bash
   echo "test change" >> some-file.txt
   git add some-file.txt
   ```

4. **Виклич явно через `@-mention`:**

   ```
   @commit-message-writer (agent)
   ```

   Має згенерувати Conventional Commit message з твого diff-у.

5. **Виклич через natural language:**

   ```
   Use commit-message-writer to draft a commit for my staged changes.
   ```

6. **Експеримент: змінюй `model` у frontmatter** і дивись різницю:

   - `haiku` — швидко, простий формат
   - `sonnet` — повільніше, краще body
   - `inherit` — як основна сесія

## Очікуваний результат

- Subagent зявляється у `/agents` list (або при `@-mention` typeahead)
- `@-mention` гарантовано спавне саме його
- Generation повертається швидко (особливо з `haiku`)

## Якщо не вийшло

- `solutions/02-custom-subagent/` — повний приклад з description, що тригерить надійно
- Перевір: `cat ~/.claude/agents/commit-message-writer.md` — файл точно там?
- `claude agents` у CLI — список усіх завантажених subagent-ів
