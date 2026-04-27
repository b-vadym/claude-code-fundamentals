# Вправа 3 — `allowed-tools` як pre-approval

**Мета:** написати `/git-cleanup`, що використовує **лише** `git`-команди без per-use approval. Зрозуміти різницю між **pre-approval** і справжнім **sandbox**.

**Час:** 15 хв.

## Ключове розуміння

`allowed-tools` — це **не sandbox**. Цитата з docs:

> The `allowed-tools` field grants permission for the listed tools while the skill is active. **It does not restrict which tools are available**: every tool remains callable, and your permission settings still govern tools that are not listed.
>
> — https://code.claude.com/docs/en/skills#pre-approve-tools-for-a-skill

Тобто:

- ✅ `allowed-tools: Bash(git *)` — дозволяє `git` без prompt-у
- ❌ Це **не** забороняє Claude викликати `Read`, `Write`, `Bash(rm *)` — він просто запитає підтвердження
- 🔒 Щоб **заборонити** — потрібні **deny rules** у `~/.claude/settings.json`

## Кроки

1. **Скопіюй стартер:**

   ```bash
   mkdir -p ~/.claude/skills/git-cleanup
   cp starter/SKILL.md ~/.claude/skills/git-cleanup/SKILL.md
   ```

2. **У SKILL.md заповни `allowed-tools`** так, щоб без prompt-у проходили:

   - `git status` (всі варіанти)
   - `git stash list`
   - `git branch -l` (list)
   - `git log --oneline`

   Усе інше (включно з `git push`, `git reset`) має тригерити approval.

3. **Перезапусти Claude Code.**

4. **Виклич:**
   ```
   /git-cleanup
   ```
   Має пройти без жодного prompt-у — бо команда тіла використовує лише дозволене.

5. **Спробуй модифікацію тіла:** замінити `git status` на `rm -rf /tmp/test`. Запусти знову. Що сталось?

   Очікуване: Claude або запитав апрув, або відмовив (залежно від твоїх deny-rules).

6. **(Бонус — справжній sandbox)** Додай у `~/.claude/settings.json`:

   ```json
   {
     "permissions": {
       "deny": ["Bash(rm *)", "Bash(curl *)"],
       "allow": ["Bash(git *)"]
     }
   }
   ```

   Тепер `rm` буде заблокований повністю, а `git` — пройде без prompt-у.

## Очікуваний результат

- `/git-cleanup` працює без single approval prompt
- Розумієш: `allowed-tools` пре-апрувить, deny-rules забороняють
- (Бонус) Маєш робочий sandbox profile у settings

## Якщо не вийшло

`solutions/03-allowed-tools/SKILL.md` + `solutions/03-allowed-tools/settings-snippet.json`.

## Документація

- https://code.claude.com/docs/en/skills#pre-approve-tools-for-a-skill
- https://code.claude.com/docs/en/skills#restrict-claudes-skill-access
- https://code.claude.com/docs/en/permissions
