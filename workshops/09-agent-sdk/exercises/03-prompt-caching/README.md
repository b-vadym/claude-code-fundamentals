# Вправа 3 — Prompt caching

**Мета:** побачити власні очі різницю між `cache_creation_input_tokens` (1-й запит) і `cache_read_input_tokens` (2-й запит). Розрахувати економію.

**Час:** 15 хв.

## Контекст

Anthropic API stateless — кожен запит шле повний контекст. Якщо у тебе 50K-токеновий system prompt і 10 турнів — це 500K токенів на input. Caching робить так, що Claude кешує префікс і на повторний запит ти платиш 0.1× за hit.

**Мінімум для caching у Opus 4.7 / Haiku 4.5: 4096 токенів.** Коротший — `cache_control` ігнорується.

## Кроки

1. Відкрий `starter/cache_demo.py` — там є функція `large_system_prompt()`, яка генерує ~5000 токенів (виправдано довгий «codebook» для аналізу).

2. **Додай `cache_control`:**
   ```python
   system=[
       {
           "type": "text",
           "text": large_system_prompt(),
           "cache_control": {"type": "ephemeral"},  # 5-min TTL
       }
   ]
   ```

3. **Зроби два виклики поспіль** з різними user-повідомленнями (різні питання щодо одного codebook).

4. **Друкуй для кожного:**
   ```
   [call N] input_tokens=...  cache_creation=...  cache_read=...
   ```

5. **Очікуваний результат:**
   ```
   [call 1] input_tokens=15  cache_creation=5021  cache_read=0
   [call 2] input_tokens=20  cache_creation=0     cache_read=5021
   ```

6. **Полічи економію:**
   - Без caching: 2 × 5021 × $5/MTok = ?
   - З caching: (5021 × $5 × 1.25) + (5021 × $5 × 0.1) = ?
   - % saved?

## Бонус

- **1-год TTL:** додай `"ttl": "1h"` і порівняй cache_creation_input_tokens (буде те саме число, але платиш 2× замість 1.25×)
- **Multiple breakpoints:** додай 2-й breakpoint на «examples» блок. Подивись як обидва відображаються в usage
- **Зміни system на 1 символ** — побачиш як hit пропадає (cache invalidated)

## Якщо не вийшло

- `cache_creation = 0` на 1-му запиті → промт <4096 токенів, мало для caching
- Hit пропав на 2-му → перевір що system **точно** той самий
- Помилка `max 4 cache_control breakpoints` → ти поставив >4
- `solutions/03-prompt-caching/cache_demo.py` — еталон з cost-math
