# Brainstorming: Claude Code — Економіка токенів

**Date**: 2026-04-22
**Status**: Research complete, ready for outline
**Entry file**: `token-economy.md` (second deck in same repo as `slides.md`)

**Note**: Немає `presentation-config.md`; параметри нижче прийняті з запиту користувача.

---

## Presentation parameters (прийняті)

- **Duration**: 30-40 хвилин
- **Target slides**: 25-30
- **Audience**: розробники, які вже користуються Claude Code (не вступ — вже знають основи)
- **Language**: українська
- **Tone**: практичний, з конкретними числами; trade-off першим, рецепт другим

---

## Working title & abstract

**Working title (options)**:
1. "Claude Code: Економіка токенів"
2. "Як помістити робочий день у $20"
3. "Економіка токенів: від 600k до 60k"

**One-liner promise**: показати розробнику, як тими ж задачами користуватися Claude Code при $20/міс Pro без upgrades — через свідоме управління контекстом, правильний вибір моделі, prompt caching і фільтрацію виводу.

**Primary commitment**: слухач після доповіді розуміє де саме витрачаються токени, які важелі є, і має checklist перевірки свого setup-у.

---

## Research summary

### Data from code.claude.com docs

#### Середні витрати (/en/costs)
- Enterprise avg: **$13 per developer per active day**, **$150-250 per developer per month**
- 90% користувачів: < $30/active day
- Agent teams: **~7x more tokens than standard sessions** у plan mode (кожен teammate свій context)
- Background idle: **< $0.04/session**

#### /cost vs /stats
- `/cost` — API token usage тільки (для API users). Pro/Max subscribers: показує не важливе для оплати число
- `/stats` — для Pro/Max subscribers показує usage patterns
- Status line: можна конфігурувати, щоб context usage завжди видно

#### Context window / auto-compaction
- Window: 200k tokens default (1M на Opus 4.7/4.6, Sonnet 4.6 з standard pricing)
- Startup consumes ~20% (auto-loaded: system prompt ~4200, auto memory ~680, env info ~280, MCP tool names ~120, CLAUDE.md full, skill descriptions до 1% context)
- Auto-compaction triggers перед exhaust; зберігає recent invoked skills (25k tokens budget, 5k per skill)
- CLAUDE.md: project root survives /compact (re-injected). Nested CLAUDE.md — ні
- **CLAUDE.md target: < 200 lines** (adherence падає на довших)

#### Slash-команди для економії токенів
- `/clear` — починати з нуля між unrelated tasks (stale context = waste на кожен subsequent message)
- `/rename` → `/clear` → `/resume` — зберегти сесію для повернення
- `/compact <instruction>` — ручний summarize з фокусом (напр. "Focus on code samples and API usage")
- `/rewind` — повернутися до previous checkpoint (conversation + code)
- `/context` — показати що займає context (хто винен)
- `/mcp` — подивитися сервери, вимкнути непотрібні
- `/model` — перемкнути модель mid-session
- `/effort` — знизити extended thinking level (low/medium/high/xhigh/max)
- `/memory` — toggle auto memory, browse CLAUDE.md файли
- **Не відомо Claude Code**: `/stats` був згаданий, але не у commands reference detailed

#### MCP token cost
- Tool definitions **deferred by default** (тільки names в context, schemas on-demand)
- CLI tools (gh, aws, gcloud, sentry-cli) більш context-efficient ніж MCP — no per-tool listing
- Run `/context` щоб бачити споживання

#### Skills — економія проти CLAUDE.md
- CLAUDE.md loaded in FULL at session start (кожна сесія, не тільки коли треба)
- Skills: тільки **description** loaded at start; **body loads on invocation**
- Description+when_to_use cap: **1,536 chars** per skill в listing
- Після /compact: re-attach max recent skills, **25k tokens combined budget, 5k per skill**
- Rule-of-thumb: якщо інструкція > procedure → винести у skill. Якщо щось загальне на весь проект → CLAUDE.md (але < 200 lines)
- `.claude/rules/*.md` з `paths:` frontmatter — path-scoped, грузиться тільки для matching files

#### Subagents для ізоляції
- Кожен subagent — свій context window, повертає лише summary
- Use cases: verbose operations (tests, logs, doc fetching), research, exploration
- "A subagent runs in its own context window" — main conversation receives only the summary
- Model override: `model: haiku` in subagent config для simple tasks

#### Hooks для preprocessing
- PreToolUse hook може filter output before Claude sees it
- Приклад: `npm test 2>&1 | grep -A 5 -E '(FAIL|ERROR|error:)' | head -100` замість full test output
- Результат: "from tens of thousands of tokens to hundreds"

#### Code intelligence plugins / LSP
- Typed-language plugins → Claude використовує precise symbol navigation замість grep+read
- Автоматичне репортування type errors після edit → no compiler run needed

#### Extended thinking (extended reasoning/ thinking tokens)
- Enabled by default
- Default thinking budget: **tens of thousands of tokens per request**, billed as output
- Turn off for simple tasks: `/effort low`, disable in `/config`, or `MAX_THINKING_TOKENS=8000`

#### Plan mode / verification targets / specific prompts
- Plan mode (Shift+Tab): explore first, propose, approve — prevents expensive rework
- Course-correct early: Esc to stop; `/rewind` or double-Esc
- Verification targets: test cases, screenshots, expected output → Claude self-verifies
- Incremental testing: write one file, test, continue

### Anthropic prompt caching (platform.claude.com/docs/en/build-with-claude/prompt-caching)

#### Pricing multipliers
| Operation | 5m ephemeral | 1h cache |
|-----------|-------------|----------|
| Cache write | **1.25x** base input | **2x** base input |
| Cache read | **0.1x** base input | **0.1x** base input |

#### Concrete Opus 4.7 ($5 input / $25 output per MTok)
| Op | Price per MTok |
|----|----------------|
| Base input | $5 |
| 5m cache write | $6.25 (1.25x) |
| 1h cache write | $10 (2x) |
| Cache hit / refresh | $0.50 (0.1x) |
| Output | $25 |

**Example**: 100k-token cached prompt. First request: $0.625 (write). Each reuse within TTL: $0.05 (read). **Savings per reuse: 92%**.

#### Cache mechanics
- Hierarchy: `tools` → `system` → `messages`. Change at level N invalidates N and all below
- 5m cache refreshed free on hit
- 1h use case: agentic workflows > 5 min between steps, long chats
- Min cacheable prompt length (Opus 4.7): **4,096 tokens**. Sonnet 4.6: **2,048**. Haiku 4.5: **4,096**
- Up to 4 cache breakpoints per request
- Usage fields: `cache_creation_input_tokens`, `cache_read_input_tokens`

#### Does Claude Code use caching automatically?
- Claude Code automatically applies prompt caching for repeated content (system prompts, CLAUDE.md, tool schemas). Docs cite це як auto-optimization. Deep-dive у docs не знайдено.
- Stakeholder takeaway: **зміни у CLAUDE.md → cache invalidates → next turn = full re-write cost**. Keep CLAUDE.md stable during a session.

### Model pricing 2026 (per 1M tokens)

| Model | Input | Output | Notes |
|-------|-------|--------|-------|
| **Opus 4.7** | $5 | $25 | New tokenizer — up to **+35% tokens** for same text |
| **Opus 4.6** | $5 | $25 | Older tokenizer |
| **Sonnet 4.6** | $3 | $15 | 1M context window standard pricing |
| **Sonnet 4.5** | $3 | $15 | |
| **Haiku 4.5** | $1 | $5 | Cheapest production model |

**Batch API**: 50% discount input+output, async <24h.

### Plans (claude.com/pricing)

| Plan | Price | Claude Code? | Notes |
|------|-------|--------------|-------|
| Free | $0 | ❌ | Не включає Claude Code |
| Pro | **$17/month annual, $20/month monthly** | ✅ | "More usage" |
| Max | from **$100/month** | ✅ | 5x або 20x Pro usage, higher limits |
| Team Standard | $20/seat annual, $25 monthly | ✅ | + Claude Cowork |
| Team Premium | $100/seat annual, $125 monthly | ✅ | |
| Enterprise | $20/seat + usage at API rates | ✅ | |

### RTK — Rust Token Killer (rtk-ai/rtk)

- CLI proxy sitting between agent and shell
- Filters / compresses command outputs before Claude sees them
- Install: `rtk init -g` для Claude Code → restart → transparent rewriting (e.g. `git status` → `rtk git status`)
- Works with: Claude Code, Cursor, Gemini CLI, Aider, Codex, Windsurf, Cline
- Local: `rtk gain` shows savings, `rtk discover` analyzes history for missed opportunities
- Latest: v0.35.0 (Apr 2026) — AWS CLI filters (source: github.com/rtk-ai/rtk releases)

#### Real `rtk gain` output from presenter's own setup (use as live evidence):

```
RTK Token Savings (Global Scope)
══════════════════════════════════
Total commands:    4753
Input tokens:      23.8M
Output tokens:     1.8M
Tokens saved:      22.0M (92.5%)
Total exec time:   114m24s (avg 1.4s)
Efficiency meter: ██████████████████████░░ 92.5%

By Command:
 1. rtk read                284 cmds  10.0M saved  20.8% avg
 2. rtk curl -sL https://...  4 cmds   4.2M saved 100.0%
 3. rtk curl -sL https://...  3 cmds   3.2M saved 100.0%
 4. rtk find                 442 cmds 502.7K saved 57.1%
 5. rtk ls                  1543 cmds 264.5K saved 65.5%
```

**Key numbers to show on slide**:
- **22.0M tokens saved over 4753 commands = 92.5% reduction**
- Top saver: `rtk read` (file reads) — 10M saved on 284 commands
- `rtk curl` — near 100% reduction (HTTP response bodies truncated)
- `rtk ls`, `rtk find` — frequent commands (1543 + 442 = ~2k invocations) with 57-65% savings

---

## Core themes identified

### Theme 1: Розумій де ідуть токени (діагностика)
- Startup context ~20% йде до того як ти щось написав (CLAUDE.md + skills + MCP names + auto memory)
- Enterprise avg $13/day — не "сотні доларів", але копиться
- `/cost`, `/stats`, `/context`, status-line — інструменти бачити, куди

### Theme 2: Context — головний бюджет (management)
- 200k window заповнюється швидко
- Auto-compaction — останній резерв, але губить деталі
- `/clear` між задачами, `/compact` свідомо з focus instruction, `/rewind` на помилках
- CLAUDE.md тримати < 200 lines, все інше — skills (progressive loading) або `.claude/rules/*.md` з `paths`

### Theme 3: Prompt caching — головний монетний важіль
- Cache read = 10x дешевше за input = 92% економії на повторах
- Min 4k-tokens для Opus 4.7 → маленькі CLAUDE.md не кешуються (tradeoff: маленький CLAUDE.md економить на write, але втрачає cache benefit — насправді не, бо загальний content однаковий; просто потрібно щоб набиралось 4k+)
- 5m TTL vs 1h TTL — коли Claude Code сидить довго між turns
- Зміни у CLAUDE.md → invalidates cache (ціна: full re-write). Stable CLAUDE.md = дешеві turns

### Theme 4: Вибір моделі — 5x різниця
- Opus $5/$25 — тільки для архітектури, multi-step reasoning
- Sonnet $3/$15 — default для coding
- Haiku $1/$5 — subagents, простий reasoning, filter operations
- `/model` mid-session, `/effort low` для простих
- Opus 4.7 tokenizer: +35% токенів → часто Opus 4.6 дешевше за 4.7 на тих самих задачах
- Plan mode у Opus → потім implement у Sonnet

### Theme 5: Ізоляція через subagents (divide & conquer)
- Main context залишається чистим
- Verbose operations (tests, logs, research, fetch docs) — subagent, повертає summary
- Subagents можуть використовувати Haiku → cheap workers

### Theme 6: Output filtering (before it hits context)
- RTK — 60-90% економії на shell output
- PreToolUse hooks — filter grep errors тільки, не full log
- LSP plugins — go-to-definition замість read-all-files
- Specific prompts: "add validation to login fn in auth.ts" vs "improve codebase"

### Theme 7: Extended thinking — hidden output cost
- Default budget — tens of thousands output tokens per request
- Billed as OUTPUT (expensive)
- Disable для простих: `/effort low` / `MAX_THINKING_TOKENS=8000` / `/config`

### Theme 8: Pro vs API — який план обрати
- Pro $20 — "unlimited-ish" with rate limits; не думаєш про токени
- API — pay-per-use; видно кожну копійку; prompt caching дає реальне ROI
- Max $100+ — 5-20x Pro; для full-time користувачів
- Enterprise — seat + API usage — для контрольованих команд

---

## Key messages (3-5 max)

**Primary message**: Економія токенів — не магія. Це 3 важелі: (1) менший стартовий context, (2) prompt caching на stable prefix, (3) правильна модель для задачі. Разом — 60-90% економії без втрати якості.

**Supporting messages**:
1. **CLAUDE.md < 200 lines + skills для procedures** → маленький стартовий context + progressive loading
2. **Stable session prefix + prompt caching** → cache read 10x дешевше → 92% економії на повторних turn-ах
3. **Sonnet за замовчуванням, Opus рідко, Haiku для subagents** → 5x економії vs "Opus усюди"
4. **Subagents + hooks + RTK** → filtered output, не raw; main context залишається чистим

**Call to action**:
- Відкрий свій CLAUDE.md — порахуй lines. > 200? Роби skills
- Додай status line з context usage; `/context` запусти після 20 turn-ів
- Встанови RTK: `rtk init -g`; подивися `rtk gain` через тиждень
- Спробуй day на Sonnet only: `/model sonnet` + `/effort low`

---

## Visual opportunities

### Diagrams needed
1. **Context window allocation pie chart** — що займає startup 20% (CLAUDE.md, skills, MCP names, auto memory, system prompt)
2. **Prompt caching flow** — mermaid sequence:
   - Turn 1: write cache ($6.25/MTok)
   - Turn 2-N: read cache ($0.50/MTok)
   - Invalidate: змінив CLAUDE.md → back to write
3. **Cache hierarchy invalidation** — tools → system → messages, із "break line" показом де invalidation відбувається
4. **Subagent context isolation** — два контекст-вікна поруч: main clean, subagent full
5. **Model cost comparison bar chart** — Opus $5/$25, Sonnet $3/$15, Haiku $1/$5 (per 1M tokens)
6. **RTK compression example** — cargo test: 155 lines → 3 lines (side-by-side)
7. **Token spend over a day** — area chart: startup → discussion → large file read (spike) → compaction → recovery

### Images/screenshots
- `/cost` output screenshot (з /costs doc)
- `/context` output (щоб показати hot-spots)
- Status line з context % displayed
- RTK CLI output (`rtk gain`)
- `/effort` selector

### Tables (render as side-by-side)
- Plan comparison (Pro/Max/Team/Enterprise/API)
- Model pricing matrix
- Slash-commands cheat sheet

---

## Rough structure ideas (~28 slides, 30-40 min)

**Opening (3 slides, ~3 min)**:
- Cover
- Problem: "Ти за день витрачаєш $30 на 4 features. Твій колега — $6 на 6. Різниця — не в таланті."
- Roadmap (3 важелі + practical recipes)

**Section 1: Де ідуть токени (5-6 slides, ~7 min)**:
- Анатомія сесії (startup 20% vs conversation)
- Що auto-loadєся: CLAUDE.md, skills desc, MCP names, auto memory
- Context window 200k — куди йдуть кожні 20k
- `/cost` / `/stats` / `/context` / status line — діагностика
- Enterprise numbers ($13/day avg) для калібрування

**Section 2: Context management (6-7 slides, ~8 min)**:
- CLAUDE.md < 200 lines — чому
- Skills замість великого CLAUDE.md (progressive loading)
- `.claude/rules/*.md` з `paths` (path-scoped)
- `/clear` vs `/compact` vs `/rewind` — коли що
- Auto-compaction: що виживає, що ні
- Subagents для verbose operations

**Section 3: Prompt caching (5-6 slides, ~7 min)**:
- Як воно працює (tools → system → messages)
- Математика: 1.25x write, 0.1x read → 92%
- Коли інвалідується (ти редагуєш CLAUDE.md → big penalty)
- 5m vs 1h TTL — коли що
- Claude Code автоматично vs явно (через API)

**Section 4: Model & effort (3-4 slides, ~5 min)**:
- Pricing matrix (Opus / Sonnet / Haiku)
- Opus 4.7 tokenizer +35% — коли 4.6 краще
- `/model`, `/effort low`, `MAX_THINKING_TOKENS`
- Plan в Opus → Execute в Sonnet pattern

**Section 5: Output side (3-4 slides, ~5 min)**:
- RTK: 60-90% на shell output (live demo results)
- PreToolUse hooks (filter test output)
- LSP plugins vs grep+read
- Specific prompts vs vague ("improve codebase" → disaster)

**Section 6: Pro vs API (2 slides, ~3 min)**:
- Pro $20 — коли достатньо
- API — коли вигідно (batch, caching ROI, precise control)
- Max $100+ — для full-time

**Closing (2 slides, ~2 min)**:
- Checklist (твій setup audit)
- Call to action + посилання

---

## Scope decisions (confirmed by presenter)

1. **Fact verification rule (hard)**: Every claim on a slide must be backed by a documentation URL. If not verifiable in docs → DROP, do not include with a hedge. See `feedback_no_hallucinations.md` memory.
2. **Free Haiku on web**: DROPPED (not verified in claude.com/pricing).
3. **Agent teams 7x warning**: separate slide (in Context management section).
4. **Plan mode**: separate slide (in Output-side / workflow section).
5. **RTK**: use presenter's own `rtk gain` output (above) — real evidence, not docs numbers.

## Raw notes

- **`/stats` скрізь у /costs doc згаданий, але деталі відсутні** — подивитись у /commands reference (збережено в tool-results) при написанні слайду про commands. Якщо не знайду точного синтаксису — не малюю окремий слайд.
- **Interactive context window visualization** (`code.claude.com/docs/en/context-window`) — багате джерело для візуального слайду про startup context; посилання як DocRef.
- **Opus 4.7 new tokenizer (+35%)**: джерело — finout.io (third-party blog). Додати слайд тільки якщо знаходжу підтвердження в офіційних Anthropic docs. Інакше — скіп. АЛЬО: WebSearch повертав це як виявлений факт на кількох сайтах — потрібен fetch на офіційну сторінку 4.7 release notes.
- **Minimum cacheable size**: для CLAUDE.md < 4k tokens (Opus 4.7 min) — кешування не активується (підтверджено у prompt-caching docs). Трейд-оф: маленький CLAUDE.md = низький startup cost але не кешується. Варто згадати на слайді про caching limits.
- **RTK save is indirect** — не токени Claude моделі, а shell output що був би завантажений. Економія $$ залежить від моделі. Згадати на rtk слайді як нюанс.
- **`claudeMdExcludes` setting** — для monorepos. Згадаю побіжно на CLAUDE.md слайді (1 bullet), без окремого слайду.
- **Background idle cost <$0.04/session** — маленька цифра, FYI slide або скіп. Скіп.

---

## Slide-to-docs mapping (для DocRef компоненту)

Кожен слайд про feature → має `<DocRef url="https://code.claude.com/docs/en/..." />`:

| Тема слайду | DocRef target |
|-------------|---------------|
| Cost overview | /en/costs |
| /cost, /stats | /en/commands |
| CLAUDE.md | /en/memory |
| Skills progressive loading | /en/skills |
| Auto-compaction | /en/context-window |
| Subagents | /en/sub-agents |
| Hooks preprocessing | /en/hooks |
| MCP tool search | /en/mcp#scale-with-mcp-tool-search |
| Plan mode | /en/common-workflows#use-plan-mode-for-safe-code-analysis |
| /effort | /en/model-config#adjust-effort-level |
| Prompt caching | platform.claude.com/docs/en/build-with-claude/prompt-caching |
| Model config | /en/model-configuration |
| Code intelligence plugins | /en/discover-plugins#code-intelligence |

---

## References

**Claude Code docs (fetched)**:
- https://code.claude.com/docs/en/costs
- https://code.claude.com/docs/en/memory
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/commands (saved to tool-results, 56KB)
- https://code.claude.com/docs/en/context-window (saved to tool-results, 54KB)
- https://code.claude.com/docs/en/sub-agents (saved to tool-results, 51KB)

**Anthropic docs**:
- https://platform.claude.com/docs/en/build-with-claude/prompt-caching

**Plans/pricing**:
- https://claude.com/pricing

**Third-party**:
- https://github.com/rtk-ai/rtk
- https://www.rtk-ai.app/
- https://evolink.ai/blog/claude-api-pricing-guide-2026
- https://www.finout.io/blog/claude-opus-4.7-pricing-the-real-cost-story-behind-the-unchanged-price-tag

**Keywords researched**: prompt caching pricing, Claude API pricing 2026, RTK proxy, Claude Code token optimization, Opus 4.7 tokenizer.

---

## Next steps

1. Review this brainstorm
2. Run `/slidev:frame` з параметрами вище (duration 30-40, audience devs, slides ~28) → save as `token-economy.config.md`
3. Run `/slidev:outline` → save as `token-economy.outline.md`
4. Manually author `token-economy.md` as single-file deck using `slides.md` conventions (НЕ `/slidev:generate`, який створює subdir і ламає component sharing)
5. Add `<DocRef>` компонент на кожен feature slide
6. Run `/slidev:notes` для ukr speaker notes
