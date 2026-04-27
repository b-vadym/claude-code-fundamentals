# Вправа 2 — Tool use

**Мета:** дати Claude tool, який рахує дні між двома датами, і провести цикл `tool_use → tool_result`.

**Час:** 15 хв.

## Контекст

Tool — це функція, яку **ти** реалізуєш, але **Claude** вирішує коли її викликати. Передаєш у `messages.create(tools=[...])`. Якщо Claude захотів викликати — `stop_reason="tool_use"` і у `content` буде `tool_use`-блок.

## Кроки

1. Відкрий `starter/agent.py`.

2. **Опиши tool** `days_between` з `input_schema`:
   - `start: string` (ISO date `YYYY-MM-DD`)
   - `end: string`
   - обидва `required`

3. **Реалізуй Python-функцію** `run_tool(name, params) -> str`, яка для `days_between` повертає `abs((end - start).days)` як рядок.

4. **Зроби цикл `while`** з `MAX_ITER=5`:
   - `messages.create(tools=tools, messages=messages)`
   - Якщо `stop_reason != "tool_use"` → break
   - Інакше: для кожного `tool_use` блоку у `content` запусти tool, додай `tool_result` блоки у нове повідомлення user
   - Continue

5. **Запит:** «Скільки днів між 2024-01-01 і 2024-08-15?»

6. **Виведи:**
   - Усі ітерації з номером
   - `tool_use.input` для кожного виклику
   - Фінальну текстову відповідь
   - Total `usage` (input + output) сумарно по всіх викликах

## Очікуваний результат

```
[iter 1] Claude wants: days_between({"start":"2024-01-01","end":"2024-08-15"})
[iter 1] tool result: 227
[iter 2] Claude says: Між 2024-01-01 і 2024-08-15 — 227 днів.
Total usage: input=... output=...
```

## Експерименти (бонус)

- Запит «коли мені буде 30 років, якщо я народився 1995-03-12?» — Claude має сам обчислити поточну дату і викликати tool
- Спробуй неоднозначний запит: «скільки залишилось до Нового року?» — побачиш чи Claude перепитає чи зробить assumption

## Якщо не вийшло

- `solutions/02-tool-use/agent.py` — повний робочий приклад з логуванням
