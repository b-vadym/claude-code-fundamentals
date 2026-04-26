# Workshop 09 — Agent SDK: Research Dossier

**For:** Ukrainian developer workshop on building programmatic Claude agents.
**Audience:** Developers comfortable with Python, who used Claude Code CLI but want to build their OWN AI assistants.
**Date:** 2026-04-26

All facts below cite a doc URL or canonical source. No claim is included without a verifiable reference.

---

## 1. Two SDKs, one CLI: the lay of the land

There are **three** distinct surfaces for using Claude programmatically. Distinguishing them is the first thing the workshop teaches.

| Surface | What it is | Install | Best for |
|---|---|---|---|
| **Anthropic Client SDK** | Direct REST wrapper for `POST /v1/messages` | `pip install anthropic` | Custom apps, full control of every byte |
| **Claude Agent SDK** | Higher-level wrapper. Bundles the Claude Code agent loop, built-in tools (Read/Edit/Bash), permissions, hooks, MCP, subagents | `pip install claude-agent-sdk` | "Claude Code in a library" — bug-fix bots, CI agents |
| **Claude Code CLI** | The interactive `claude` command in a terminal | `npm install -g @anthropic-ai/claude-code` | Interactive dev work, one-off tasks |

Sources:
- https://docs.claude.com/en/agent-sdk/overview — "The Agent SDK gives you the same tools, agent loop, and context management that power Claude Code, programmable in Python and TypeScript."
- https://docs.claude.com/en/api/getting-started — Direct API + Client SDKs
- https://docs.claude.com/en/agent-sdk/overview#agent-sdk-vs-client-sdk — explicit comparison

### Comparison snippet (Agent SDK vs Client SDK)

From https://docs.claude.com/en/agent-sdk/overview#agent-sdk-vs-client-sdk:

```python
# Client SDK: You implement the tool loop
response = client.messages.create(...)
while response.stop_reason == "tool_use":
    result = your_tool_executor(response.tool_use)
    response = client.messages.create(tool_result=result, **params)

# Agent SDK: Claude handles tools autonomously
async for message in query(prompt="Fix the bug in auth.py"):
    print(message)
```

**Note from docs:** "The Claude Code SDK has been renamed to the Claude Agent SDK." (https://docs.claude.com/en/agent-sdk/overview)

**Version note:** "Opus 4.7 (`claude-opus-4-7`) requires Agent SDK v0.2.111 or later." (same page)

---

## 2. Latest models (2026-04 status)

From https://docs.claude.com/en/about-claude/models/overview:

| Model | API ID (alias) | Context | Max output | Input price | Output price | Cutoff |
|---|---|---|---|---|---|---|
| **Claude Opus 4.7** | `claude-opus-4-7` | 1M tokens | 128K | $5/MTok | $25/MTok | Jan 2026 |
| **Claude Sonnet 4.6** | `claude-sonnet-4-6` | 1M tokens | 64K | $3/MTok | $15/MTok | Aug 2025 |
| **Claude Haiku 4.5** | `claude-haiku-4-5` | 200K | 64K | $1/MTok | $5/MTok | Feb 2025 |

Defaults the workshop uses:
- **Opus 4.7** for examples needing reasoning quality (default in code samples)
- **Haiku 4.5** for the streaming demo (cheap, fast)

---

## 3. Anthropic Client SDK basics

Source: https://docs.claude.com/en/api/getting-started, Context7 `/anthropics/anthropic-sdk-python`.

### Install

```bash
pip install anthropic
# or for TypeScript
npm install @anthropic-ai/sdk
```

### Auth

Set `ANTHROPIC_API_KEY` env var. SDK reads it automatically; `Anthropic()` no-arg works.

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

### Hello-world (Python)

```python
import os
from anthropic import Anthropic

client = Anthropic()  # reads ANTHROPIC_API_KEY

message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello, Claude!"}
    ],
)
print(message.content[0].text)
```

### Multi-turn

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello!"},
        {"role": "assistant", "content": "Hello! How can I help?"},
        {"role": "user", "content": "What is the capital of France?"},
    ],
)
```

### Streaming

```python
from anthropic import Anthropic

client = Anthropic()

with client.messages.stream(
    model="claude-haiku-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a haiku"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
    final = stream.get_final_message()
    print(f"\nUsage: {final.usage}")
```

Source: Context7 `/anthropics/anthropic-sdk-python` — "Stream messages asynchronously and synchronously with Claude SDK".

---

## 4. Tool use (function calling)

Source: https://docs.claude.com/en/agents-and-tools/tool-use/overview

### Tool definition

```python
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

### Loop pattern

1. Send `messages.create(tools=tools, messages=[...])`
2. If `response.stop_reason == "tool_use"` → extract `tool_use` block, run the function locally
3. Append assistant message + a `tool_result` block in a new user message, send again
4. Repeat until `stop_reason == "end_turn"`

```python
if message.stop_reason == "tool_use":
    tool_use = next(c for c in message.content if c.type == "tool_use")
    result = run_tool_locally(tool_use.name, tool_use.input)

    response = client.messages.create(
        model="claude-opus-4-7",
        max_tokens=1024,
        tools=tools,
        messages=[
            {"role": "user", "content": "What's the weather in SF?"},
            {"role": "assistant", "content": message.content},
            {
                "role": "user",
                "content": [{
                    "type": "tool_result",
                    "tool_use_id": tool_use.id,
                    "content": [{"type": "text", "text": result}],
                }]
            }
        ],
    )
```

Source: Context7 `/anthropics/anthropic-sdk-python` — "Define and use tools (function calling) with Claude SDK".

### Tool-use system-prompt overhead

From https://docs.claude.com/en/agents-and-tools/tool-use/overview#pricing:

| Model | `auto`/`none` | `any`/`tool` |
|---|---|---|
| Opus 4.7, Sonnet 4.6, Haiku 4.5 | 346 tokens | 313 tokens |

So enabling `tools=[…]` adds ~346 tokens to every request (regardless of which tool fires). Important for prompt caching strategy.

---

## 5. Prompt caching (CRITICAL)

Source: https://docs.claude.com/en/build-with-claude/prompt-caching

### What it is

Mark a prefix of your request with `cache_control`. Anthropic stores that prefix's KV cache. On the next request that starts with the same prefix:
- **Cache write** (first request): you pay 1.25× (5-min TTL) or 2× (1-hour TTL) the base input price.
- **Cache read** (hit): you pay **0.1×** the base input price (90% off).
- Output tokens cost the same.

### Syntax

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are an expert legal assistant.",
            "cache_control": {"type": "ephemeral"},  # 5-min default
        },
        {
            "type": "text",
            "text": "<huge document>",
            "cache_control": {"type": "ephemeral", "ttl": "1h"},  # 1-hour
        },
    ],
    messages=[{"role": "user", "content": "Summarize section 3"}],
)
```

### TTL options

| TTL | `cache_control` | Write cost | Read cost |
|---|---|---|---|
| 5 minutes | `{"type": "ephemeral"}` | 1.25× | 0.1× |
| 1 hour | `{"type": "ephemeral", "ttl": "1h"}` | 2× | 0.1× |

### Limits

- **Max 4 breakpoints** per request.
- **Minimum cacheable size**: 4096 tokens for Opus 4.7 / 4.6 / 4.5 / Haiku 4.5; 2048 for Sonnet 4.6; 1024 for older.
- **Lookback**: 20 blocks per breakpoint.
- Breakpoint placement: **at end of the unchanging block**.

### Invalidation hierarchy (top → bottom)

`tools` → `system` → `messages`. Changing `tools` invalidates everything downstream. Changing `system` keeps tools cache, invalidates messages cache. Adding a message at the end keeps everything before.

### Reading the result

```python
usage = response.usage
print(usage.cache_creation_input_tokens)  # cache write tokens (paid 1.25×/2×)
print(usage.cache_read_input_tokens)      # cache hit tokens (paid 0.1×)
print(usage.input_tokens)                 # tokens AFTER the last breakpoint
# total = creation + read + input
```

### Cost math (Opus 4.7, $5/MTok input)

- 50K-token system prompt, 2-message session:
  - **Without caching:** 2 × 50K × $5 = **$0.50**
  - **With 5-min caching:** (50K × $5 × 1.25) + (50K × $5 × 0.1) = $0.3125 + $0.025 = **$0.3375**
  - **Saving:** ~33% on a 2-turn session. With 10 turns the saving approaches ~85%.

---

## 6. Claude Agent SDK essentials

Source: https://docs.claude.com/en/agent-sdk/overview

### Install

```bash
pip install claude-agent-sdk
# or
npm install @anthropic-ai/claude-agent-sdk
```

### Hello-world

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="What files are in this directory?",
        options=ClaudeAgentOptions(allowed_tools=["Bash", "Glob"]),
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

### Built-in tools

`Read`, `Write`, `Edit`, `Bash`, `Monitor`, `Glob`, `Grep`, `WebSearch`, `WebFetch`, `AskUserQuestion`. (Source: same overview, "Built-in tools" tab.)

### Two interfaces

- `query()` — one-shot, stateless. Returns AsyncIterator.
- `ClaudeSDKClient` — multi-turn, custom tools (in-process MCP), hooks, sessions.

(Source: Context7 `/anthropics/claude-agent-sdk-python` — "Claude Agent SDK for Python".)

### Subagents (delegation)

```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Expert reviewer for quality and security.",
            prompt="Analyze code quality and suggest improvements.",
            tools=["Read", "Glob", "Grep"],
        )
    },
)
```

### MCP servers

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    }
)
```

### Hooks

`PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit` etc. Same hooks as Claude Code itself.

---

## 7. When to use which

| Need | SDK |
|---|---|
| Programmatic single-shot LLM call (translation, classification) | **Anthropic SDK** |
| Custom tool runner with full control | **Anthropic SDK** |
| "Claude Code in a Lambda / cron / CI step" | **Agent SDK** |
| Long-running coding agent with file edits | **Agent SDK** |
| Already running interactively as a developer | **Claude Code CLI** |
| Production app where every token matters | **Anthropic SDK** + prompt caching |

---

## 8. Pitfalls / gotchas worth covering

- **"Async-only" Agent SDK.** Both Python `query()` and TypeScript are async iterators. Newcomers expect a blocking call; show `asyncio.run`.
- **Cache breakpoint placement** — putting it on a CHANGING block = no hit. The breakpoint marks **end of static prefix**.
- **Cache minimum size** — 4096 tokens for Opus/Haiku 4.x. Caching a 200-token system prompt does nothing.
- **Tool loop infinite loops** — always cap iterations (`max_iterations=10`) when rolling your own loop with the Anthropic SDK.
- **Streaming + caching** — cache fields show in the `message_start` event of a stream.
- **`stop_reason` values** — `end_turn`, `tool_use`, `max_tokens`, `stop_sequence`, `pause_turn`, `refusal`. Only `tool_use` means "loop again".
- **Agent SDK reads `.claude/`** — by default loads skills, slash-commands, CLAUDE.md from `.claude/` and `~/.claude/`. Use `setting_sources=[]` to opt out (https://docs.claude.com/en/agent-sdk/overview, "Claude Code features" section).

---

## 9. Exercise design

Four exercises, each with starter + solution + Python venv-friendly.

1. **`01-hello-agent`** (10 min) — single `messages.create` call. Verify it runs, read `usage.input_tokens` / `usage.output_tokens`.
2. **`02-tool-use`** (15 min) — define `get_weather`, handle `tool_use`/`tool_result`, return final answer.
3. **`03-prompt-caching`** (15 min) — large system prompt, two queries, observe `cache_creation_input_tokens` then `cache_read_input_tokens`. Math the savings.
4. **`04-mychat-cli`** (15 min) — wrap a streaming agent in a CLI tool with conversation history, persisted in memory, streamed to stdout.

Each ships:
- `starter/` — minimal scaffold, TODO comments
- `solutions/<exercise>/` — working code
- `requirements.txt` for venv
- `README.md` step-by-step in Ukrainian

---

## 10. Sources index

Primary:
- https://docs.claude.com/en/api/getting-started
- https://docs.claude.com/en/agent-sdk/overview
- https://docs.claude.com/en/agents-and-tools/tool-use/overview
- https://docs.claude.com/en/build-with-claude/prompt-caching
- https://docs.claude.com/en/about-claude/models/overview

Secondary (live code samples):
- Context7 `/anthropics/anthropic-sdk-python`
- Context7 `/anthropics/claude-agent-sdk-python`
- Context7 `/anthropics/claude-agent-sdk-demos`

GitHub:
- https://github.com/anthropics/anthropic-sdk-python
- https://github.com/anthropics/claude-agent-sdk-python
- https://github.com/anthropics/claude-agent-sdk-demos
