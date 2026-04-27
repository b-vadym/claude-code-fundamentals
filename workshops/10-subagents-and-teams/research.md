# Subagents & Agent Teams: Research Dossier

**For:** Ukrainian developer workshop on subagents — when to spawn, how to define custom ones, parallel dispatch, agent team chains.
**Audience:** Developers familiar with Claude Code basics; have already gone through workshop 02 (token-economy) which warned about ×7 cost of subagents.
**Date:** 2026-04-26

---

## 1. Built-in Subagents

Claude Code ships with a fixed set of built-in subagents that Claude delegates to automatically.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **Explore** | Haiku | Read-only (Write/Edit denied) | File discovery, code search, codebase exploration |
| **Plan** | Inherits from main session | Read-only (Write/Edit denied) | Codebase research while in plan mode |
| **General-purpose** | Inherits from main session | All tools | Complex multi-step tasks needing exploration + action |
| **statusline-setup** | Sonnet | (limited) | When user runs `/statusline` |
| **Claude Code Guide** | Haiku | (limited) | Q&A about Claude Code features |

**Key facts:**
- `Explore` uses **Haiku** — fast, cheap, optimized for searching without modifying files. Claude can pass a thoroughness level: `quick`, `medium`, `very thorough`.
- `Plan` is auto-invoked from plan mode. Cannot be called directly outside plan mode.
- `general-purpose` is the catch-all when you say "use a subagent" without specifying.
- **Subagents cannot spawn other subagents.** `Plan` exists specifically to prevent infinite nesting in plan mode.

**Sources:**
- https://code.claude.com/docs/en/subagents#built-in-subagents — Built-in agent table

---

## 2. Custom Subagent Definition

Subagents are Markdown files with YAML frontmatter, just like skills, but stored in a different directory.

### File location

| Location | Scope | Priority | How to create |
|----------|-------|----------|---------------|
| Managed settings | Org-wide | 1 (highest) | Deployed via managed settings |
| `--agents` CLI flag | Current session only | 2 | JSON via `--agents` |
| `.claude/agents/<name>.md` | Current project | 3 | Manual or `/agents` |
| `~/.claude/agents/<name>.md` | All your projects | 4 | Manual or `/agents` |
| `<plugin>/agents/<name>.md` | Where plugin enabled | 5 (lowest) | Plugin install |

**Note:** The `/agents` interactive command is the recommended creation path. CLI-only listing: `claude agents`.

### Frontmatter fields

Only `name` and `description` are required. Body becomes the subagent's system prompt (replaces Claude Code default).

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier, lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate. Use phrases like "use proactively after X" |
| `tools` | No | Allowlist of tools. Inherits all if omitted |
| `disallowedTools` | No | Denylist (applied first if both present) |
| `model` | No | `sonnet`, `opus`, `haiku`, full ID (e.g. `claude-opus-4-7`), or `inherit`. Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Cap on agentic turns before stopping |
| `skills` | No | Skills to preload into subagent's startup context |
| `mcpServers` | No | MCP servers scoped to this subagent (string ref or inline) |
| `hooks` | No | Lifecycle hooks scoped to subagent |
| `memory` | No | `user`, `project`, or `local` — persistent memory dir |
| `background` | No | `true` to always run in background |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | Set to `worktree` for isolated git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn (only when run as `--agent`) |

**Sources:**
- https://code.claude.com/docs/en/subagents#supported-frontmatter-fields — Complete field reference
- https://code.claude.com/docs/en/subagents#choose-the-subagent-scope — Scope/priority table
- https://code.claude.com/docs/en/subagents#write-subagent-files — File structure

### Minimal example

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after writing or modifying code.
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

---

## 3. The Agent Tool (formerly Task)

In Claude Code v2.1.63 the **Task** tool was renamed to **Agent**. Existing `Task(...)` references in settings still work as aliases.

**How Claude invokes a subagent:**
- Claude sees subagent metadata (name + description) in its context
- When task matches a description semantically, Claude calls `Agent` (or `Task`) with the agent name and a task prompt
- Subagent runs in its own context window with its own tool restrictions
- When done, only the **summary** returns to Claude's main context

**Restricting which subagents an agent can spawn:**
```yaml
---
name: coordinator
description: Coordinates work across specialized agents
tools: Agent(worker, researcher), Read, Bash
---
```
- Allowlist: only `worker` and `researcher` can be spawned
- `Agent` without parens = no restriction
- `Agent` omitted from `tools` = cannot spawn at all
- This restriction only applies to agents running as the **main thread** (`claude --agent`). Subagents themselves cannot spawn subagents — `Agent(...)` in a subagent definition has no effect.

**Sources:**
- https://code.claude.com/docs/en/subagents#restrict-which-subagents-can-be-spawned — Agent allowlist
- https://code.claude.com/docs/en/subagents#understand-automatic-delegation — Delegation logic

---

## 4. Invocation Patterns

### Automatic delegation
Claude reads `description` and decides. Encourage with phrases like "use proactively" in description.

### Natural language hint
```
Use the test-runner subagent to fix failing tests
```
Claude usually delegates but can choose not to.

### @-mention (guaranteed)
```
@code-reviewer (agent) look at the auth changes
```
Forces that subagent to run for one task. The full message still goes to Claude — it composes the task prompt for the subagent.

Plugin-provided subagents appear as `<plugin-name>:<agent-name>` in typeahead. Manual: `@agent-<name>` or `@agent-<plugin>:<name>`.

### Whole session as subagent
```bash
claude --agent code-reviewer
```
The main thread takes on subagent's system prompt, tool restrictions, model. Persists across resume. Default for project: set `agent` in `.claude/settings.json`.

**Sources:**
- https://code.claude.com/docs/en/subagents#invoke-subagents-explicitly — Three invocation patterns

---

## 5. Parallel Dispatch Pattern

To spawn multiple subagents in parallel, Claude makes **multiple `Agent` tool calls in a single message**. This is just standard tool-call parallelism.

```
Research the authentication, database, and API modules in parallel using separate subagents
```

Each subagent explores its area independently. Claude synthesizes findings when all return.

**Best when:** research paths don't depend on each other.

**Warning from docs:** "When subagents complete, their results return to your main conversation. Running many subagents that each return detailed results can consume significant context."

For sustained parallelism beyond what one main context can synthesize, use **agent teams**.

**Sources:**
- https://code.claude.com/docs/en/subagents#run-parallel-research — Parallel research pattern

---

## 6. Isolated Context

A subagent receives **only its system prompt + the task prompt + basic environment** (working directory). It does **NOT** receive:
- The main conversation's history
- Other subagents' results
- Skills loaded in the parent (must be listed explicitly via `skills:` frontmatter)

**Implication:** the task prompt must be self-contained. Re-state context, file paths, constraints. Don't say "fix the bug we discussed" — the subagent has no idea what was discussed.

A subagent **starts in the main conversation's working directory**. `cd` commands inside the subagent don't persist between Bash calls and don't affect the main conversation. To give it a copy of the repo, use `isolation: worktree`.

**Sources:**
- https://code.claude.com/docs/en/subagents#write-subagent-files — System prompt scope
- https://code.claude.com/docs/en/subagents#context-and-communication — What loads automatically

### Resuming a subagent

Each `Agent` invocation creates a **new instance with fresh context**. To continue a previous subagent's work without restarting, ask Claude to resume it. Resumed subagents retain full conversation history (tool calls, results, reasoning).

When a subagent completes, Claude receives its **agent ID**. Resumption uses the `SendMessage` tool with that ID. **`SendMessage` is only available when agent teams are enabled** via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

If a stopped subagent receives a `SendMessage`, it auto-resumes in the background.

Transcripts persist at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and survive main-conversation compaction. Cleaned up after `cleanupPeriodDays` (default 30).

**Sources:**
- https://code.claude.com/docs/en/subagents#resume-subagents — Agent ID and SendMessage

---

## 7. State Sharing Patterns

Since subagents don't share context, you have two practical mechanisms to pass data:

### A. Summary returns
The default. Subagent does work, returns a single text summary. Main agent reads it. Works for: "find me the file with X", "what tests fail", "review this PR".

### B. File-based artifacts
Subagent writes a file (e.g. `.claude/work/research-results.md`); main agent reads it after subagent completes. Works for: structured plans, lists of findings, generated code that needs review.

This is the same working directory by default — both subagent and main session see the same file tree.

**Pattern (used in exercise 4):**
1. Main: spawn researcher, instruct to write `research.md`
2. Researcher: gathers info, writes to file, returns short confirmation
3. Main: reads `research.md`, spawns planner with reference to it
4. Planner: reads file, produces `plan.md`, returns confirmation
5. Main: reads `plan.md`, hands off to reviewer

Files survive between subagent runs because both subagents and main share the working directory.

**Caveat:** subagents can't directly hand off to each other (no inter-subagent messaging in classic subagent mode). Main session orchestrates.

**Sources:**
- https://code.claude.com/docs/en/subagents#chain-subagents — Sequential pattern
- https://code.claude.com/docs/en/subagents#common-patterns — Isolation and chaining

---

## 8. Cost Trade-offs

Workshop 02 (token-economy) warned that subagents cost ~×7 of a single message because each subagent loads:
- Full tool descriptions
- All MCP server schemas not scoped away
- The skill metadata (description budget)
- The task prompt
- CLAUDE.md / project memory
- Working files referenced

For workshop 10 we go the other way: **when is the cost worth it?**

| Scenario | Subagent worth it? | Why |
|----------|-------------------|-----|
| Searching 200-file repo for a function | Yes (Explore) | Massive grep output stays out of main context |
| Reading 5K-line log | Yes | Verbose output isolated, only summary returns |
| Quick math, single edit, follow-up | No | Latency + token overhead exceeds benefit |
| Running test suite, reporting failures | Yes | Test output verbose, only failures summarized |
| 3 independent investigations | Yes (parallel) | Wall-clock saved, each path stays clean |

**The rule:** subagent saves tokens **in the main context** (where compaction is expensive) at the cost of more total tokens (each subagent is a fresh load). Worth it when the verbose output has no long-term value.

**Sources:**
- https://code.claude.com/docs/en/subagents#choose-between-subagents-and-main-conversation — When to use what
- https://code.claude.com/docs/en/subagents#isolate-high-volume-operations — Cost reasoning

---

## 9. Limitations

From the docs (verified):

1. **No nested subagents.** A subagent cannot spawn another subagent (use Skills or chain from main).
2. **No mid-flight user interaction.** Foreground subagents pass permission prompts and `AskUserQuestion` calls back to main, but this disrupts main session. Background subagents auto-deny prompts not pre-approved.
3. **Permissions decided at spawn.** Background subagents prompt for needed perms upfront; once running, anything not pre-approved is auto-denied.
4. **No skill inheritance.** Subagents don't inherit skills from parent. Use `skills:` frontmatter to preload.
5. **Plugin subagents lose some fields.** `hooks`, `mcpServers`, `permissionMode` are ignored when loaded from a plugin (security).
6. **Forks are interactive-only.** Fork mode (subagent that inherits full conversation history) doesn't work in headless `claude -p` mode.
7. **First request reuses parent prompt cache** (fork mode only) — saves cost when forking vs spawning fresh.

**Sources:**
- https://code.claude.com/docs/en/subagents#choose-between-subagents-and-main-conversation — Nested subagent note
- https://code.claude.com/docs/en/subagents#run-subagents-in-foreground-or-background — Background permission flow
- https://code.claude.com/docs/en/subagents#fork-the-current-conversation — Fork limitations and caching

---

## 10. Agent Teams (vs. Subagents)

Agent teams are the **next tier up** from subagents — multiple Claude Code sessions coordinating with each other through a shared task list and direct messaging.

### Enable
Experimental, off by default:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```
Requires Claude Code v2.1.32 or later.

### Architecture

| Component | Role |
|-----------|------|
| **Team lead** | Main session creating the team and coordinating |
| **Teammates** | Separate Claude Code instances, each with own context |
| **Task list** | Shared list of work items teammates claim |
| **Mailbox** | Inter-agent messaging |

Storage: `~/.claude/teams/{team-name}/config.json`, `~/.claude/tasks/{team-name}/`.

### Key differences vs subagents

| | Subagents | Agent teams |
|--|----------|-------------|
| **Communication** | Report back to main only | Teammates message each other |
| **Coordination** | Main agent manages all work | Shared task list, self-coordination |
| **Best for** | Focused tasks where only result matters | Complex work needing discussion/debate |
| **Token cost** | Lower | Significantly higher (each = full instance) |

### Display modes
- `in-process` — all teammates in main terminal, Shift+Down to cycle
- `tmux` — each teammate in own pane (requires tmux or iTerm2 + `it2` CLI)
- Default `auto`

### Use cases (from docs)
- **Parallel code review:** 3 reviewers, each focused on security / performance / tests
- **Competing hypotheses for debugging:** 5 teammates each defend a theory, debate, converge
- **Cross-layer features:** frontend / backend / tests, each owned by a teammate

### Reuse subagent definitions
You can spawn a teammate using a subagent definition's `name`. The teammate inherits `tools` and `model`; the body is **appended** to the system prompt rather than replacing it. `skills` and `mcpServers` from the subagent definition are **NOT applied** when running as a teammate — teammates load skills/MCP from project + user settings normally.

### Limitations
- Experimental
- No `/resume` for in-process teammates
- Task status can lag (manual nudge sometimes needed)
- One team per session (no nested teams)
- Lead is fixed for team's lifetime
- Permissions set at spawn (can't set per-teammate at spawn)
- Split panes need tmux/iTerm2 — not in VS Code terminal, Windows Terminal, Ghostty

**Sources:**
- https://code.claude.com/docs/en/agent-teams — Full agent teams reference
- https://code.claude.com/docs/en/agent-teams#compare-with-subagents — Comparison table
- https://code.claude.com/docs/en/agent-teams#use-subagent-definitions-for-teammates — Definition reuse
- https://code.claude.com/docs/en/agent-teams#limitations — Constraints

---

## 11. When to Use What — Decision Tree

```
Task at hand
 ├─ Quick, targeted change in known files? → Main conversation
 ├─ Verbose output you don't need (logs, search) → Explore subagent
 ├─ Multi-step research + action → general-purpose subagent
 ├─ 3+ independent investigations → Parallel subagent dispatch
 ├─ Sequential research → plan → implement → review → Subagent chain
 ├─ Need workers to debate / challenge each other → Agent teams (experimental)
 └─ Same as last subagent, but with full context → Fork (experimental)
```

**Heuristic:** start with main conversation. Reach for a subagent when output volume threatens your context. Reach for a team when *coordination* between workers is the value.

---

## 12. Real Subagent Example Patterns (verified from docs)

### Code reviewer
```yaml
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---
```
Read-only, runs `git diff` first, returns prioritized findings (Critical / Warnings / Suggestions).

### Debugger
```yaml
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---
```
Includes Edit (fixes bugs). Workflow: capture error → reproduce → isolate → minimal fix → verify.

### Data scientist
```yaml
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights. Use proactively for data analysis tasks and queries.
tools: Bash, Read, Write
model: sonnet
---
```
Domain-specific, explicitly sets `sonnet` for analytical tasks.

### DB reader (with hook validation)
```yaml
---
name: db-reader
description: Execute read-only database queries. Use when analyzing data or generating reports.
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```
Validates SQL for read-only via PreToolUse hook (exit code 2 to block writes).

**Sources:**
- https://code.claude.com/docs/en/subagents#example-subagents — All examples verbatim

---

## 13. Open Questions (UNVERIFIED)

1. **UNVERIFIED** — Exact token overhead per subagent spawn vs Anthropic's "×7" mention from token-economy deck. Docs don't quote a number; multiplier is empirical.
2. **UNVERIFIED** — Whether `--agents` JSON flag in headless mode supports all the same fields as file-based subagents. Docs imply yes but not exhaustive.
3. **UNVERIFIED** — Whether subagents share the parent's prompt cache. For forks the docs explicitly say yes; for named subagents they say "separate cache."
4. **UNVERIFIED** — Order of resolution when both `tools` and `disallowedTools` set. Docs say "disallowedTools applied first, then tools resolved against remaining pool" but don't show edge cases.

---

## References

**Official Claude Code Docs:**
- Subagents reference: https://code.claude.com/docs/en/subagents
- Agent Teams: https://code.claude.com/docs/en/agent-teams
- Headless mode (CLI): https://code.claude.com/docs/en/headless
- CLI flags: https://code.claude.com/docs/en/cli-reference
- Context window: https://code.claude.com/docs/en/context-window

**Document Status:** Ready for slide generation. Every claim cites a doc URL. Open questions marked UNVERIFIED.
