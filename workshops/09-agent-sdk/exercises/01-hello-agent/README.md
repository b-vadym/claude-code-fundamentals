# Вправа 1 — Hello Agent

**Мета:** перший програмний виклик Claude. Прочитати `usage`.

**Час:** 10 хв.

## Кроки

1. **Перевір API ключ:**
   ```bash
   echo $ANTHROPIC_API_KEY      # має починатись з sk-ant-
   ```
   Якщо порожньо — `export ANTHROPIC_API_KEY=sk-ant-...`

2. **Відкрий `starter/hello.py`** — там `TODO`-маркери. Заповни:
   - `model="claude-opus-4-7"`
   - `max_tokens=512`
   - User prompt: «Розкажи про себе у три речення українською»

3. **Запусти:**
   ```bash
   python starter/hello.py
   ```
   Очікуваний вивід — текст відповіді + блок з usage.

4. **Додай детальніший вивід `usage`:**
   ```python
   print(f"Input tokens:  {message.usage.input_tokens}")
   print(f"Output tokens: {message.usage.output_tokens}")
   ```

5. **Бонус — streaming:**
   - Перепиши `messages.create` на `messages.stream` (див. слайд про streaming)
   - Друкуй текст по токенах
   - Заміряй TTFB (час до першого токену)

## Очікуваний результат

- Скрипт працює, повертає українську відповідь
- Видно `input_tokens` та `output_tokens` у `usage`
- (Бонус) Streaming-варіант показує TTFB ~300мс

## Якщо не вийшло

- `pip install anthropic` пройшло без помилок?
- Ключ у env? `python -c "import os; print(bool(os.environ.get('ANTHROPIC_API_KEY')))"`
- `solutions/01-hello-agent/hello.py` — повний робочий код
