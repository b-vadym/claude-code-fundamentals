# Solution — skill trigger tuning

## Що було не так у starter

```yaml
description: Check bundle size
```

3 проблеми:

1. **Generic** — «check size» можна сказати про що завгодно (file, response, image)
2. **Без action verb перед контекстом** — нема «Use when ...»
3. **Без синонімів** — юзери кажуть «bloat», «weight», «dist», «payload» — жоден не матчиться

## Виправлене

```yaml
description: Check JavaScript bundle size after a build. Use when the user asks about bundle weight, dist size, build output size, dependency bloat, payload size, or wants to compare bundle sizes before/after a change. Triggers on phrases like "how big is the bundle", "is the bundle bloated", "check dist size", "are there big dependencies", "what's our js payload".
```

Що змінилось:

- **Front-load:** перші слова — «Check JavaScript bundle size after a build» — найрелевантніший use case
- **«Use when ...»** — explicit trigger condition
- **Синоніми:** weight, dist, build output, bloat, payload — основні фразування
- **Sample phrases:** Claude бачить буквальні приклади, краще матчить semantically
- **Контекст:** «after a build», «before/after a change» — звужує до ситуації

## Як перевірити

Кожен з цих запитів має тепер тригерити skill:

```
> check the bundle size of this app
> how big is our js bundle?
> is the dist folder bloated?
> are there any dependency size issues?
> what's our js payload weight?
```

## Caveat від Anthropic

Якщо запит дуже простий (наприклад «check size» без context-у) — Claude свідомо НЕ тригерить skill, бо вирішує сам тривіально. Це by design. Хороший description допомагає, але магії нема — тригернеться лише якщо skill реально дає цінність понад просту команду.

## Cap reminder

Description + when_to_use разом ≤ 1,536 символів. Виправлений вище ~390 символів — є запас.

Якщо у тебе багато skill-ів і всі мають довгі description-и — скоро упрешся у `SLASH_COMMAND_TOOL_CHAR_BUDGET` (default 8K, або 1% контекстного вікна). Для рідко-юзаних skill-ів — обрізай до 100-150 символів.
