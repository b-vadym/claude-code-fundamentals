# Вправа 4 — mychat CLI

**Мета:** робоча CLI-команда `python mychat.py` з історією, streaming, prompt caching.

**Час:** 15 хв.

## Контекст

Capstone — поєднуємо все за день:
- Streaming для UX (TTFB ~300мс)
- Conversation history (передаємо весь масив `messages`)
- `cache_control` на system prompt — економимо з 2-го запиту
- REPL-цикл з `input()` + спецкоманди

## Кроки

1. Відкрий `starter/mychat.py` — рамка REPL з `input()`.

2. **Реалізуй streaming-виклик:**
   ```python
   with client.messages.stream(
       model="claude-haiku-4-5",  # дешевий + швидкий
       max_tokens=1024,
       system=[{"type": "text", "text": SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"}}],
       messages=history,
   ) as stream:
       for text in stream.text_stream:
           print(text, end="", flush=True)
       final = stream.get_final_message()
   ```

3. **Підтримуй історію:** після кожного раунду додавай `{"role": "user", ...}` і `{"role": "assistant", "content": final.content}`.

4. **Друкуй cache stats** після кожного раунду:
   ```
   [usage] in=12 cache_read=4096 cache_creation=0
   ```

5. **Спецкоманди:**
   - `/clear` → обнуляє `history`
   - `/quit` або `/exit` → виходимо
   - `/usage` → друкує cumulative tokens

6. Поганяй чат на 5+ турнів. Подивись як cache_read стабільно тригериться.

## Очікуваний результат

```
mychat (Haiku 4.5). /clear /quit /usage
> привіт
Привіт! Чим можу допомогти?
[usage] in=12 cache_read=4096 cache_creation=0

> а ти пам'ятаєш моє ім'я?
Поки ні — як тебе звати?
[usage] in=18 cache_read=4112 cache_creation=0
```

## Бонус

- Зберегти conversation у файл (`mychat.log.json`) і `--resume`-режим
- `--model` flag через `argparse` (опус/sonnet/haiku)
- Markdown rendering: підсвічувати code blocks (rich-бібліотека)

## Якщо не вийшло

- `solutions/04-mychat-cli/mychat.py` — повний реф з усіма бонусами
