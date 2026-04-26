---
theme: seriph
background: https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=1920
title: "Workshop 09 — Agent SDK: будуємо власного асистента"
info: |
  ## Workshop 09 — Agent SDK
  Anthropic SDK + Claude Agent SDK. Tool use, prompt caching, streaming, CLI-агент.
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
lineNumbers: true
layout: cover
hideInToc: true
---

# Workshop 09

## Agent SDK: будуємо власного асистента

<div class="text-sm opacity-60 mt-12">90 хв · 4 вправи · Python · `exercises/` репо паралельно</div>

<!--
Привіт. Дев'ятий воркшоп серії — програмний доступ до Claude. Сьогодні ти не юзер CLI — ти автор. Зробимо живого асистента від hello-world до streaming CLI з prompt caching. Усе через Anthropic SDK і Claude Agent SDK. Тримай терміналом — паралельно зі мною.
-->

---
transition: fade-out
hideInToc: true
---

# Що ти зможеш після

<v-clicks>

- **Викликати Claude програмно** — `messages.create`, потоки, `usage`
- **Підключити tool use** — визначити функцію, обробити `tool_use` / `tool_result`
- **Заощадити на токенах** — `cache_control`, 5хв vs 1год TTL, читати hit-rate
- **Стрімити відповіді** — токен за токеном у реальному часі
- **Вибрати правильний SDK** — Client vs Agent SDK vs Claude Code CLI
- **Спакувати у CLI-команду** — свій `mychat` асистент з історією

</v-clicks>

<!--
Не теорія — після воркшопу в тебе своя CLI-команда `mychat`, яка стрімить, кешує і коштує копійки.
-->

---
hideInToc: true
---

# Як працюватимемо

<v-clicks>

- **Я веду** — слайди + `live-demo` зі свого терміналу
- **Ти кодиш паралельно** — `cd workshops/09-agent-sdk/exercises`
- **4 вправи** — кожна 10–15 хв, своя підтека з `starter/`
- **`solutions/`** — готові розв'язки на випадок «застряг»
- **`handout.pdf`** — пост-воркшоп референс із code-snippet'ами

</v-clicks>

<div v-click class="mt-4 p-4 bg-blue-500/10 rounded text-sm">
Передумови: Python 3.10+, <code>$ANTHROPIC_API_KEY</code> в env, <code>pip install anthropic claude-agent-sdk</code>
</div>

<!--
Дай хвилину на venv і API-ключ. Ключ безкоштовний на console.anthropic.com — нового користувача там вистачить $5 кредитів на цей воркшоп з лишком.
-->

---
layout: section
---

# Контекст

Три SDK для одного Claude. Який тобі треба?

---

# Три SDK — один Claude

<v-clicks>

| SDK | Що це | Установка |
|---|---|---|
| **Anthropic Client SDK** | Прямий REST-клієнт. `messages.create`. Ти сам пишеш цикл | `pip install anthropic` |
| **Claude Agent SDK** | Wrapper з агент-loop, built-in tools (Read/Edit/Bash), hooks, MCP | `pip install claude-agent-sdk` |
| **Claude Code CLI** | Інтерактивний `claude` у терміналі | `npm i -g @anthropic-ai/claude-code` |

</v-clicks>

<v-click class="mt-3 p-3 bg-amber-500/10 rounded text-sm">

**Note:** «Claude Code SDK перейменовано на Claude Agent SDK». Якщо у Google `claude-code-sdk` — це ця ж штука, нова назва.

</v-click>

<DocRef url="https://docs.claude.com/en/agent-sdk/overview" label="docs.claude.com — Agent SDK overview" />

<!--
Ключове — не плутати. Anthropic SDK — це low-level. Agent SDK — high-level. CLI — інтерактивний інструмент. У воркшопі юзаємо два перші.
-->

---

# Mental model: рівні абстракції

```
┌─────────────────────────────────────────┐
│ Claude Code CLI       (ти юзер)         │
├─────────────────────────────────────────┤
│ Claude Agent SDK      (агент-loop)      │
│   • built-in tools, hooks, MCP, sessions│
├─────────────────────────────────────────┤
│ Anthropic Client SDK  (HTTP wrapper)    │
│   • messages.create, streams, caching   │
├─────────────────────────────────────────┤
│ POST /v1/messages     (REST API)        │
└─────────────────────────────────────────┘
```

<v-clicks>

- **Чим нижче** — більше контролю, більше коду
- **Чим вище** — швидше старт, менше гнучкості
- **Каскад залежностей**: Agent SDK всередині використовує `messages.create`. CLI всередині — Agent SDK

</v-clicks>

<!--
Це не три конкуренти, це стек. Вибираєш рівень за задачею. Прості одношагові виклики — Anthropic SDK. Кодуючий бот у CI — Agent SDK. Лежить термінал відкритий — CLI.
-->

---

# Який SDK для якої задачі

<v-clicks>

| Задача | SDK |
|---|---|
| Translation/classification на вході | **Anthropic SDK** |
| Кастомний tool-runner з повним контролем | **Anthropic SDK** |
| «Claude Code у Lambda / cron / CI» | **Agent SDK** |
| Code-review бот в pull-request hook | **Agent SDK** |
| Інтерактивно як розробник | **CLI** |
| Production-app, де кожен токен лічимо | **Anthropic SDK + caching** |

</v-clicks>

<DocRef url="https://docs.claude.com/en/agent-sdk/overview#agent-sdk-vs-client-sdk" label="docs.claude.com — Agent SDK vs Client SDK" />

<!--
Загальне правило: якщо ти імітуєш Claude Code (читай файли, edit, bash) — Agent SDK. Якщо просиш модель витягти JSON чи перекласти — Anthropic SDK.
-->

---
layout: section
---

# Anthropic SDK

Hello-world, streaming, usage

---

# Установка і перший запит

```bash {1-2|3}{lines:true}
pip install anthropic
export ANTHROPIC_API_KEY=sk-ant-...
python hello.py
```

<v-click>

```python {all|1-3|5|7-13|15}{lines:true}
import os
from anthropic import Anthropic

client = Anthropic()  # реадить ANTHROPIC_API_KEY автоматично

message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Привіт, Claude!"}
    ],
)

print(message.content[0].text)
```

</v-click>

<DocRef url="https://docs.claude.com/en/api/getting-started" label="docs.claude.com — API getting started" />

<!--
Найпростіший приклад. `Anthropic()` без аргументів — читає env. `model` — обов'язково. `max_tokens` — обов'язково (відрізнення від OpenAI). `messages` — список. Усе.
-->

---

# Latest models (2026-04)

| Модель | API ID | Context | Max output | $ input | $ output |
|---|---|---|---|---|---|
| **Opus 4.7** | `claude-opus-4-7` | 1M | 128K | $5/MTok | $25/MTok |
| **Sonnet 4.6** | `claude-sonnet-4-6` | 1M | 64K | $3/MTok | $15/MTok |
| **Haiku 4.5** | `claude-haiku-4-5` | 200K | 64K | $1/MTok | $5/MTok |

<v-clicks>

- **Opus 4.7** — складне reasoning, agentic coding. Дефолт у вправах
- **Sonnet 4.6** — best speed/intelligence ratio. Дешевший за Opus у ~1.7×
- **Haiku 4.5** — найшвидший. Streaming-демо, класифікація, чат-боти

</v-clicks>

<DocRef url="https://docs.claude.com/en/about-claude/models/overview" label="docs.claude.com — Models overview" />

<!--
Усі три — multimodal (text + image), multilingual, vision. Опуса бери коли треба думати. Haiku коли треба швидко і дешево.
-->

---

# Multi-turn: розмова — це масив

```python {all|3-7|9}{lines:true}
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Привіт!"},
        {"role": "assistant", "content": "Вітаю! Чим можу допомогти?"},
        {"role": "user", "content": "Яка столиця Франції?"},
    ],
)
print(response.content[0].text)  # → "Париж"
```

<v-clicks>

- **Stateless API** — ти кожного разу шлеш ВЕСЬ контекст
- **Чергування ролей** обов'язкове: `user → assistant → user → assistant`
- **Перший меседж** — завжди `user`
- **Системний промт** — окремий параметр `system=`, не у `messages`

</v-clicks>

<!--
API нічого не пам'ятає між запитами. Кожен запит — повний transcript. Це і причина, чому prompt caching такий важливий — повторюваний префікс кешується.
-->

---

# Streaming: токен за токеном

```python {all|5-9|10-12}{lines:true}
from anthropic import Anthropic

client = Anthropic()

with client.messages.stream(
    model="claude-haiku-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Напиши хайку"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
    final = stream.get_final_message()
    print(f"\n\nUsage: {final.usage}")
```

<v-clicks>

- **`messages.stream(...)`** замість `messages.create(...)`
- **Context manager** — `with ... as stream`
- **`text_stream`** — лише текст, без службових подій (для UX)
- **`get_final_message()`** — повний message + usage **після** стрімінгу

</v-clicks>

<DocRef url="https://docs.claude.com/en/api/messages-streaming" label="docs.claude.com — Streaming" />

<!--
Streaming — не лише UX-фіча. Це ще й TTFB-фіча: користувач бачить перший токен через ~300мс замість 5с очікування. Обов'язкове в інтерактивних додатках.
-->

---

# Usage: рахуємо токени

```python
print(message.usage.input_tokens)             # вхідні
print(message.usage.output_tokens)            # вихідні
print(message.usage.cache_creation_input_tokens)  # cache write
print(message.usage.cache_read_input_tokens)      # cache hit
```

<v-clicks>

- **`input_tokens`** — лише ті, що **після** останнього cache breakpoint
- **`cache_creation_input_tokens`** — нові кеш-токени (платиш 1.25× або 2×)
- **`cache_read_input_tokens`** — hit (платиш 0.1×)
- **Total input** = creation + read + input

</v-clicks>

<v-click class="mt-2 p-3 bg-emerald-500/10 rounded text-sm">

**Лайфхак:** друкуй `usage` під час dev. Бачиш cache_read > 0 — кеш працює. Бачиш 0 — щось не так з breakpoint.

</v-click>

<DocRef url="https://docs.claude.com/en/build-with-claude/prompt-caching" label="docs.claude.com — Reading cache stats" />

<!--
Це чотири числа, які тобі треба знати. Пиши їх у логи — побачиш у production, наскільки твій кеш-стратегія справді економить.
-->

---
layout: section
---

# Hands-on 1

Hello-world агент

---

# Вправа 1 — Hello Agent

**Мета:** перший програмний виклик Claude. Прочитай `usage`.

```bash
cd exercises/01-hello-agent
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

<v-clicks>

**Кроки:**

1. Відкрий `starter/hello.py` — там `TODO`
2. Заповни `client.messages.create(...)` з:
   - `model="claude-opus-4-7"`
   - `max_tokens=512`
   - повідомленням «Привіт у три речення»
3. Запусти: `python starter/hello.py`
4. Додай вивід `message.usage.input_tokens`, `output_tokens`
5. **Бонус:** перепиши на streaming і подивись TTFB

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 10 хв. `solutions/01-hello-agent/hello.py` — еталон.

</v-click>

<!--
Найважливіша вправа — перевіряємо, що в усіх API-ключ працює. Хто застряг тут — підніміть руку, без цього інші вправи не запустяться.
-->

---
layout: section
---

# Tool use

Як змусити Claude викликати твою функцію

---

# Tool use: концепція

```
1. Ти описуєш tool (JSON schema)
        ↓
2. Claude вирішує: «треба викликати X»  →  stop_reason="tool_use"
        ↓
3. Ти запускаєш X локально
        ↓
4. Шлеш tool_result назад → Claude продовжує
        ↓
5. stop_reason="end_turn" → готово
```

<v-clicks>

- **Client tools** (твої) — Claude каже «виклич», ти виконуєш
- **Server tools** (Anthropic) — `web_search`, `code_execution` — крутиться у них
- Це **manual loop** — ти його пишеш сам у Anthropic SDK
- Agent SDK його ховає за `query()`

</v-clicks>

<DocRef url="https://docs.claude.com/en/agents-and-tools/tool-use/overview" label="docs.claude.com — Tool use overview" />

<!--
Tool use — це коли LLM перестає бути «текстовим в'язнем». Дав йому функцію — він може робити дії в реальному світі. Це фундамент усіх агентів.
-->

---

# Tool definition: JSON schema

```python {all|1-13|6-12}{lines:true}
tools = [
    {
        "name": "get_weather",
        "description": "Get the current weather for a location.",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {"type": "string", "description": "City and state"},
                "units": {"type": "string", "enum": ["celsius", "fahrenheit"]},
            },
            "required": ["location"],
        },
    }
]
```

<v-clicks>

- **`name`** — snake_case, як Python-функція
- **`description`** — **критично важливо**. Як skill-description: коли викликати
- **`input_schema`** — стандартний JSON Schema. `required` — обов'язково

</v-clicks>

<DocRef url="https://docs.claude.com/en/agents-and-tools/tool-use/overview" label="docs.claude.com — Define tools" />

<!--
Description — серце tool-у. Claude обирає tool за ним, як skill за description. Action verbs, конкретні контексти.
-->

---

# Loop: tool_use → tool_result

```python {all|1-6|8-12|14-22}{lines:true}
message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "Який зараз погодний у Києві?"}],
)

if message.stop_reason == "tool_use":
    tool_use = next(c for c in message.content if c.type == "tool_use")
    # Claude хоче: tool_use.name="get_weather", tool_use.input={"location":"Kyiv"}
    result = run_local(tool_use.name, tool_use.input)

    response = client.messages.create(
        model="claude-opus-4-7", max_tokens=1024, tools=tools,
        messages=[
            {"role": "user", "content": "Який зараз погодний у Києві?"},
            {"role": "assistant", "content": message.content},  # вся попередня
            {"role": "user", "content": [{
                "type": "tool_result",
                "tool_use_id": tool_use.id,
                "content": [{"type": "text", "text": result}],
            }]},
        ],
    )
```

<!--
Це й увесь tool loop у raw виді. У реалі загортаєш у `while stop_reason == "tool_use"` з max_iterations щоб не зациклитись.
-->

---

# Цикл правильно: while + safeguard

```python {all|1-3|5-9|11-14|16-17}{lines:true}
messages = [{"role": "user", "content": "Який зараз погодний у Києві?"}]
MAX_ITER = 10
i = 0

while i < MAX_ITER:
    response = client.messages.create(
        model="claude-opus-4-7", max_tokens=1024,
        tools=tools, messages=messages,
    )

    if response.stop_reason != "tool_use":
        break  # end_turn, max_tokens, refusal — виходимо

    # Збираємо tool_result-и для УСІХ tool_use блоків (їх може бути кілька)
    tool_uses = [c for c in response.content if c.type == "tool_use"]
    tool_results = [
        {"type": "tool_result", "tool_use_id": tu.id,
         "content": run_local(tu.name, tu.input)}
        for tu in tool_uses
    ]
    messages.append({"role": "assistant", "content": response.content})
    messages.append({"role": "user", "content": tool_results})
    i += 1
```

<!--
MAX_ITER — обов'язковий. Без нього модель може зациклитись (бачив у production: 100 ітерацій get_weather з тим самим input). 10 — нормальна стеля для більшості агентів.
-->

---

# `stop_reason`: коли цикл зупиняти

| Значення | Що означає |
|---|---|
| `end_turn` | Claude закінчив відповідь — виходимо |
| `tool_use` | Хоче викликати tool — обробляємо й продовжуємо |
| `max_tokens` | Уперлися у `max_tokens` ліміт — збільш або обріж |
| `stop_sequence` | Спрацювала `stop_sequences` — за дизайном виходимо |
| `pause_turn` | Server-tool довгий, треба перепитати |
| `refusal` | Модель відмовилась виконувати — лог + вихід |

<v-clicks>

- **Тільки `tool_use`** означає «крути цикл далі»
- Усі інші — **break**
- `refusal` — рідко, але треба обробити: показати юзеру дружнє повідомлення

</v-clicks>

<DocRef url="https://docs.claude.com/en/agents-and-tools/tool-use/handle-tool-calls" label="docs.claude.com — stop_reason values" />

<!--
Це ті 6 значень, які треба пам'ятати. Більшість туторіалів показують лише end_turn / tool_use і ламається на max_tokens.
-->

---
layout: section
---

# Hands-on 2

Tool use — твоя перша функція

---

# Вправа 2 — Tool use

**Мета:** дати Claude tool, який рахує дні між датами.

```bash
cd ../02-tool-use
cat starter/agent.py
```

<v-clicks>

**Кроки:**

1. Визнач tool `days_between` з `input_schema`: `start`, `end` (ISO дати)
2. Реалізуй Python-функцію, яка рахує різницю
3. Цикл `while stop_reason == "tool_use"` з `MAX_ITER=5`
4. Запит: «Скільки днів між 2024-01-01 і моїм днем народження 2024-08-15?»
5. Подивись trace: скільки ітерацій, які `tool_use.input`-и

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 15 хв. `solutions/02-tool-use/agent.py` — повний робочий приклад.

</v-click>

<!--
Зверни увагу як Claude сам розбирає природну мову у структурований input. «мій день народження» → `2024-08-15`. Це і є магія tool use.
-->

---
layout: section
---

# Prompt caching

90% знижка на повторюваний префікс

---

# Чому caching — must-have

<v-clicks>

- **API stateless** — кожен запит = повний transcript
- **Багатотурова розмова з 50K-токеновим system prompt** = 50K × N запитів
- **Більше турнів — лінійне зростання** ціни
- **Caching** — заплати один раз, читай за 10% решту TTL
- **Економія в розмовах 2+ турни — 30–85%**

</v-clicks>

<v-click class="mt-3 p-3 bg-emerald-500/10 rounded text-sm">

**Без caching:** 10 турнів × 50K токенів × $5/MTok = **$2.50**
**З caching (5хв):** $0.31 (write) + 9 × $0.025 (read) = **$0.54**
**Економія: 78%**

</v-click>

<DocRef url="https://docs.claude.com/en/build-with-claude/prompt-caching" label="docs.claude.com — Prompt caching" />

<!--
Якщо забереш одне з усього воркшопу — забери це. Будь-який production-агент має caching. Без нього — тиждень роботи й $1000 рахунок.
-->

---

# Як працює: ставимо breakpoint

```python {all|3-12|7|11}{lines:true}
response = client.messages.create(
    model="claude-opus-4-7", max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are an expert legal assistant.",
            "cache_control": {"type": "ephemeral"},  # 5хв TTL
        },
        {
            "type": "text",
            "text": load_huge_document(),  # 50K токенів
            "cache_control": {"type": "ephemeral", "ttl": "1h"},  # 1год
        },
    ],
    messages=[{"role": "user", "content": "Summarize section 3"}],
)
```

<v-clicks>

- **`cache_control` — на блоку**, де закінчується статична частина
- Claude кешує **усе ДО і ВКЛЮЧНО з** цим блоком
- Наступний запит з тим самим префіксом → cache hit

</v-clicks>

<!--
Ключове: ставиш breakpoint у кінці статичного префіксу, не у динамічному. Інакше кеш не спрацює.
-->

---

# Економіка: 5хв vs 1год TTL

| Операція | 5-хв TTL | 1-год TTL |
|---|---|---|
| Cache write | **1.25×** input price | **2×** input price |
| Cache read (hit) | **0.1×** | **0.1×** |
| Звичайні input tokens | 1× | 1× |

<v-clicks>

**Коли який TTL:**

- **5-хв**: інтерактивні чати, dev-loop, демо. Дешевший write
- **1-год**: довгі sessions (підтримка, code-review батч), документи, які перевикористовуються між юзерами
- **>10 турнів за 5 хв** → 5-хв окей. **Перерви >5 хв** → беремо 1-год

</v-clicks>

<v-click class="mt-2 p-3 bg-amber-500/10 rounded text-sm">

**Ліміт: 4 breakpoint-и** на запит. Більше — error. Зазвичай вистачає (tools, system, перші повідомлення, останнє).

</v-click>

<DocRef url="https://docs.claude.com/en/build-with-claude/prompt-caching#cache-pricing" label="docs.claude.com — Cache pricing" />

<!--
2× write для 1-год — звучить дорого. Але якщо 100 юзерів читають той самий документ — 100 hit-ів × 0.1× окуповують 1 write × 2× за 5 запитів. Math sense.
-->

---

# Мінімальний розмір кешу

| Модель | Мінімум cache-able tokens |
|---|---|
| Opus 4.7 / 4.6 / 4.5 | **4096** |
| Haiku 4.5 | **4096** |
| Sonnet 4.6 | **2048** |
| Старіші Sonnet/Opus | 1024 |

<v-clicks>

- **Менше за мінімум** → `cache_control` ігнорується, не робить write, не виставляє hit
- **`usage.cache_creation_input_tokens` буде 0** — це маркер
- Для 200-токенного system prompt **caching марний** — додай tools, examples, документи

</v-clicks>

<DocRef url="https://docs.claude.com/en/build-with-claude/prompt-caching#minimum-cacheable-prompt-length" label="docs.claude.com — Minimum cacheable length" />

<!--
Я довго думав чому невеликий промт не кешується. Відповідь — мінімум 4096 у Opus 4.7. Усе менше = no-op. Спочатку перевір довжину.
-->

---

# Інвалідація: tools → system → messages

```
┌─────────────────┐
│ tools           │ ← змінив? Усе нижче інвалідовано
├─────────────────┤
│ system          │ ← змінив? messages інвалідовано (tools кеш ок)
├─────────────────┤
│ messages[0..N]  │ ← додав messages[N+1]? messages[0..N] кеш ок
└─────────────────┘
```

<v-clicks>

- **Каскад згори вниз** — змінюєш верхній рівень, нижні інвалідуються
- **Стратегія**: статичне (tools, sys, examples) — згори, динамічне (user message) — знизу
- **Lookback window**: 20 блоків від breakpoint назад. Розкидав >20 блоків — частина за межами

</v-clicks>

<DocRef url="https://docs.claude.com/en/build-with-claude/prompt-caching#what-invalidates-the-cache" label="docs.claude.com — Invalidation rules" />

<!--
Каскад інвалідації — це чому ти ставиш breakpoint у кінці static секції. Найдовше у каше живуть верхні блоки.
-->

---

# Перевірка: cache hit чи ні?

```python {all|3-5|6}{lines:true}
response = client.messages.create(...)
usage = response.usage
print(f"Cache write: {usage.cache_creation_input_tokens}")  # очікувано >0 на 1-му запиті
print(f"Cache read:  {usage.cache_read_input_tokens}")      # очікувано >0 на 2-му+
print(f"New input:   {usage.input_tokens}")                 # tokens після breakpoint
```

<v-clicks>

**Diagnostics:**

- **Перший запит:** `cache_creation > 0`, `cache_read = 0`. Норм
- **Другий запит:** `cache_creation = 0`, `cache_read > 0`. **Hit!**
- **Другий: усе по 0 у cache** — breakpoint не спрацював. Перевір розмір (≥4096) і незмінність префіксу
- **5хв пройшло без запиту** — кеш expire, наступний запит = новий write

</v-clicks>

<!--
Це твій debug-loop. Запускаєш, дивишся числа. Не вгадай — вимірюй.
-->

---
layout: section
---

# Hands-on 3

Prompt caching — побачимо хіт на власні очі

---

# Вправа 3 — Prompt caching

**Мета:** велика system-instruction кешована, два запити, observe hit.

```bash
cd ../03-prompt-caching
cat starter/cache_demo.py
```

<v-clicks>

**Кроки:**

1. У `starter/cache_demo.py` готова рамка: 5000-словний system prompt
2. Додай `cache_control: {"type": "ephemeral"}` на system block
3. Зроби **два** виклики `messages.create` поспіль (різні `user` повідомлення)
4. Друкуй для кожного: `input_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`
5. Полічи економію: `(creation_cost + read_cost) / (1× × total)`

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 15 хв. Очікуваний результат: 1-й запит — write, 2-й — hit ~80% input.

</v-click>

<!--
Ключове — побачити власні очі різницю в числах. Пишеш до спільного чату скрин з numbers — порівняємо.
-->

---
layout: section
---

# Claude Agent SDK

Коли raw SDK — це багато boilerplate

---

# Agent SDK: hello world

```bash
pip install claude-agent-sdk
```

```python {all|1-3|5-12}{lines:true}
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Знайди всі TODO коменти у репо й зроби summary",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Glob", "Grep"]),
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

<v-clicks>

- **`query()`** — async iterator. Yield-ить кожен крок агента
- **`allowed_tools`** — pre-approve. Без них Claude питав би на кожен Read
- **Built-in tools**: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, Monitor, AskUserQuestion

</v-clicks>

<DocRef url="https://docs.claude.com/en/agent-sdk/overview" label="docs.claude.com — Agent SDK overview" />

<!--
Порівняй з Anthropic SDK tool-loop вище — там 30 рядків коду, тут 7. Це і є цінність Agent SDK: він прячe loop, tools, permissions.
-->

---

# Дві API: query() vs ClaudeSDKClient

| | `query()` | `ClaudeSDKClient` |
|---|---|---|
| Stateless / multi-turn | One-shot | Multi-turn session |
| Custom tools (in-process MCP) | ❌ | ✅ |
| Hooks | ❌ | ✅ |
| Real-time streaming | basic | full |

<v-clicks>

- **`query()`** — для скриптів-однорядкарів. CI step, cron, hello-world
- **`ClaudeSDKClient`** — коли потрібна сесія, кастомні tools, lifecycle hooks
- **Обидва — async**. `asyncio.run(...)` обов'язково

</v-clicks>

<DocRef url="https://docs.claude.com/en/agent-sdk/overview" label="docs.claude.com — Two interfaces" />

<!--
У 90% демо ти бачиш query(). Але як тільки треба «питати юзера» через AskUserQuestion — нужен ClaudeSDKClient.
-->

---

# Hooks: PreToolUse / PostToolUse

```python {all|1-7|9-19}{lines:true}
from datetime import datetime
from claude_agent_sdk import query, ClaudeAgentOptions, HookMatcher

async def log_change(input_data, tool_use_id, context):
    file_path = input_data.get("tool_input", {}).get("file_path", "?")
    with open("./audit.log", "a") as f:
        f.write(f"{datetime.now()}: modified {file_path}\n")
    return {}

async for message in query(
    prompt="Refactor utils.py for readability",
    options=ClaudeAgentOptions(
        permission_mode="acceptEdits",
        hooks={
            "PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[log_change])]
        },
    ),
):
    if hasattr(message, "result"):
        print(message.result)
```

<DocRef url="https://docs.claude.com/en/agent-sdk/hooks" label="docs.claude.com — Hooks" />

<!--
Hooks дають контроль без втручання в loop. PreToolUse може блокувати tool, PostToolUse — логувати, SessionStart — додати context, тощо. Як у Claude Code, ті самі.
-->

---

# Subagents: ділимо задачу

```python {all|7-13}{lines:true}
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

async for message in query(
    prompt="Use code-reviewer agent on this codebase",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Glob", "Grep", "Agent"],
        agents={
            "code-reviewer": AgentDefinition(
                description="Expert reviewer for quality and security.",
                prompt="Analyze code quality and suggest improvements.",
                tools=["Read", "Glob", "Grep"],
            )
        },
    ),
):
    if hasattr(message, "result"):
        print(message.result)
```

<v-clicks>

- **`Agent` у `allowed_tools`** — обов'язково, щоб main міг викликати subagent
- **Окремий контекст** — основний агент бачить лише результат, не процес
- Спрацьовує `parent_tool_use_id` у meta — можна трекати трасу

</v-clicks>

<DocRef url="https://docs.claude.com/en/agent-sdk/subagents" label="docs.claude.com — Subagents" />

<!--
Цьому buduyem окремий воркшоп 10. Тут просто покажу що Agent SDK таке вміє коробкою.
-->

---

# Agent SDK завантажує `.claude/`

<v-clicks>

- За замовчуванням Agent SDK читає `.claude/` і `~/.claude/`:
  - `.claude/skills/*/SKILL.md` — твої skill-и (з вправ воркшопу 04)
  - `.claude/commands/*.md` — slash-команди
  - `CLAUDE.md` — project memory
  - `plugins/` — встановлені плагіни
- **Опт-аут:** `setting_sources=[]` у `ClaudeAgentOptions`
- Або **опт-ін лише на одне:** `setting_sources=["project"]`

</v-clicks>

<v-click class="mt-2 p-3 bg-blue-500/10 rounded text-sm">

**Use case:** твоя CLI-утиліта на Agent SDK у CI підхопить project skills автоматично. Як Claude Code на ноуті.

</v-click>

<DocRef url="https://docs.claude.com/en/agent-sdk/overview" label="docs.claude.com — Claude Code features" :offset="1" />

<!--
Це причина, чому Agent SDK треба. Ти в проєкті вже визначив skills і CLAUDE.md — Agent SDK їх юзає. Anthropic SDK — ні, треба руками.
-->

---
layout: section
---

# Hands-on 4

Збираємо CLI-чат `mychat`

---

# Вправа 4 — mychat CLI

**Мета:** робоча CLI-команда `python mychat.py` з історією і streaming.

```bash
cd ../04-mychat-cli
cat starter/mychat.py
```

<v-clicks>

**Кроки:**

1. У `starter/mychat.py` рамка: REPL-цикл з `input()`
2. Заповни `client.messages.stream(...)` з `model="claude-haiku-4-5"`
3. Підтримуй `messages` як список — додавай `user`/`assistant` після кожного раунду
4. Друкуй streaming text, у кінці — usage
5. **Бонус 1:** `cache_control` на system prompt → побачимо hit з 2-го раунду
6. **Бонус 2:** команда `/clear` обнуляє історію, `/quit` виходить

</v-clicks>

<v-click class="mt-2 text-sm opacity-70">

Час: 15 хв. `solutions/04-mychat-cli/mychat.py` — реф з усіма бонусами.

</v-click>

<!--
Це capstone — усе що було сьогодні в одному файлі. Stream + history + caching + CLI. Реальна міні-програма.
-->

---
layout: section
---

# Debug

Що робити, коли «не працює»

---

# Топ-6 граблів

<v-clicks>

1. **`max_tokens` забув** → `TypeError: missing required argument`. Вимагається обов'язково
2. **stop_reason не `tool_use`, а `max_tokens`** → tool обрізало. Збільш max_tokens
3. **Кеш не хітається** → перевір розмір (≥4096), незмінність префіксу, breakpoint position
4. **`asyncio` не запускається в Jupyter** → `import nest_asyncio; nest_asyncio.apply()`
5. **`refusal` stop_reason** → модель відмовилась. Перепиши system prompt м'якше
6. **Tool loop не зупиняється** → MAX_ITER + log усіх tool_use; ймовірно tool повертає невалідний result

</v-clicks>

<DocRef url="https://docs.claude.com/en/api/errors" label="docs.claude.com — Errors reference" />

<!--
Я бачу ці граблі в коді 90% розробників на 1-му тижні. Якщо ти їх знаєш заздалегідь — економиш собі день дебагу.
-->

---

# Чек-ліст production-агента

<v-clicks>

- [ ] **`MAX_ITER`** в tool loop (рекомендую 10)
- [ ] **`max_tokens`** виставлено усвідомлено (не максимум, не мінімум)
- [ ] **Логування `usage`** у кожному виклику — для метрик
- [ ] **`cache_control`** на статичних блоках, якщо ≥4096 токенів
- [ ] **Retry на `429`** — Anthropic SDK робить це автоматично, але контроль
- [ ] **Timeout** — Anthropic SDK дефолт 600с, переглянь під свій use case
- [ ] **Error handling** для `RateLimitError`, `APIError`, `BadRequestError`
- [ ] **`stop_reason` обробляється** для усіх 6 значень, не лише `end_turn` / `tool_use`
- [ ] **API key з env, не у коді** — secret scanner вловить

</v-clicks>

<!--
Цим чеклістом я ревью усі агенти, що приходять на код-рев'ю. Якщо хоча б 7 з 9 — гідний production.
-->

---

# Безпека: API ключ

<v-clicks>

- **`ANTHROPIC_API_KEY` лише з env** — ніколи у git
- **`.env` файл** + `python-dotenv` — для локальної розробки, у `.gitignore`
- **Production:** AWS Secrets Manager, Google Secret Manager, GitHub Actions secrets, Vault
- **Workspaces** в Anthropic Console — окремі ключі під кожен use case → можна обмежити spend
- **Rotation** — ключ можна revoke за секунди, заведи окремі для прод/staging/dev

</v-clicks>

<DocRef url="https://docs.claude.com/en/api/getting-started" label="docs.claude.com — API keys & workspaces" />

<!--
Скільки разів я бачив API ключ у public GitHub репо — стільки разів він був revoked Anthropic-ом за 30 хв. Не теорія — реальність.
-->

---
layout: section
---

# Production-готовність

---

# Вибір моделі: decision tree

```
Складне reasoning, agentic coding?
    ├─ Так → Opus 4.7
    └─ Ні
        │
        Швидкість критична?
            ├─ Так → Haiku 4.5
            └─ Ні
                │
                Балансований use case?
                    └─ Sonnet 4.6
```

<v-clicks>

- **Opus 4.7** для production-агентів з file edits
- **Sonnet 4.6** для більшості бізнес-кейсів — best $/quality
- **Haiku 4.5** для chat UI, classification, real-time stream
- **Mix** — Opus для plan, Haiku для execute (у Agent SDK через `model` override)

</v-clicks>

<!--
Дефолтуй у Sonnet 4.6 для нового проєкту. Перейди в Opus якщо плутає логіку. Перейди в Haiku якщо latency болить.
-->

---

# Streaming + caching у production

```python {all|3|4|7-10}{lines:true}
with client.messages.stream(
    model="claude-opus-4-7", max_tokens=2048,
    system=[{"type": "text", "text": SYSTEM_PROMPT,
             "cache_control": {"type": "ephemeral"}}],
    messages=conversation_history,
) as stream:
    for event in stream:
        if event.type == "message_start":
            print(f"Cache hit: {event.message.usage.cache_read_input_tokens}")
        elif event.type == "text":
            yield event.text  # стрімимо у клієнт
```

<v-clicks>

- **`message_start` event** — перший. Має `usage` з cache stats
- **`text` events** — основний потік для UX
- Можна зчитувати **обидві метрики** ще до завершення відповіді
- Cache stats у streaming = **debug-friendly**: бачиш hit одразу

</v-clicks>

<!--
Це — паттерн для production-чату. Streaming для UX, caching для коштів. Усе разом — швидко й дешево.
-->

---
layout: end
hideInToc: true
---

# Resources

<div class="grid grid-cols-2 gap-4 mt-8 text-left">

<div>

**Docs**
- [docs.claude.com/en/api/getting-started](https://docs.claude.com/en/api/getting-started)
- [docs.claude.com/en/agent-sdk/overview](https://docs.claude.com/en/agent-sdk/overview)
- [docs.claude.com/en/build-with-claude/prompt-caching](https://docs.claude.com/en/build-with-claude/prompt-caching)
- [docs.claude.com/en/agents-and-tools/tool-use/overview](https://docs.claude.com/en/agents-and-tools/tool-use/overview)

</div>

<div>

**GitHub**
- [anthropic-sdk-python](https://github.com/anthropics/anthropic-sdk-python)
- [claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python)
- [claude-agent-sdk-demos](https://github.com/anthropics/claude-agent-sdk-demos)

**Цей воркшоп**
- `exercises/` — 4 вправи
- `solutions/` — еталонний код
- `handout.pdf` — повний референс

</div>

</div>

<div class="mt-12 text-sm opacity-60">
Питання? Discord / GitHub Issues / напряму
</div>

<!--
Наступний воркшоп — 10-subagents-and-teams. Дякую!
-->
