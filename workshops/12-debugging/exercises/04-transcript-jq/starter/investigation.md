# Розслідування — 4 питання

Користуйся `starter/session.jsonl` + jq.

## 1. Compact boundary

Знайди line у JSONL де відбулась auto-compaction. На якому номері рядка? Що було в `summary`-полі?

**Підказка:** `.type == "system"`, `.subtype == "compact_boundary"`.

## 2. Початковий план

Знайди ПЕРШИЙ user message. Який 5-крокий план дав юзер?

**Підказка:** `.type == "user"`, перша подія цього типу.

## 3. Що зроблено ДО compaction

Виведи усі tool calls (`tool_use`) до line з compact_boundary.
Які саме кроки плану Claude почав виконувати?

**Підказка:** комбінуй `head -N` з jq, де N — line compact-boundary.

## 4. Що ПІСЛЯ compaction

Виведи усі tool calls ПІСЛЯ compact_boundary.
Чи дотримується Claude початкового плану? Чи переходить до наступного кроку?

**Підказка:** `tail -n +N` де N — line після compact-boundary.

## Bonus: hook outputs

Виведи всі події які виглядають як hook outputs.

**Підказка:** `.subtype` що містить `"hook"`, або `.type == "system"` з `.message` що згадує hook.

## Очікуваний інсайт

Після compaction Claude бачить summary початкового плану (Claude-generated), але деталі — як саме план виглядав, у якому порядку — могли стиснутись/спотворитись. Це класичний симптом «забуття» після compaction.

**Mitigation:** перед заповненням контексту юзер міг би:
- Викликати skill що зберігає план як standing instruction
- Скористатись `/recap`
- Винести важку частину у subagent
- `/compact <focus>` з directive «keep the original 5-step plan»
