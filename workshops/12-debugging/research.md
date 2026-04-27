# Workshop 12 — Debugging Claude Code: Research Dossier

**For:** Ukrainian developer workshop (Claude Code troubleshooting deep dive)
**Audience:** Developers who already use hooks, skills, MCP, plugins; need to debug breakage
**Date:** 2026-04-26

---

## 1. Diagnostic surface in Claude Code

Claude Code surfaces three primary diagnostic commands. Always start here before grepping logs.

| Command | Shows |
|---|---|
| `/context` | Everything in the context window: system prompt, memory, skills, MCP tools, conversation |
| `/doctor` | Configuration validation: invalid keys, schema errors, MCP misconfigs, plugin loading |
| `/status` | Active settings sources (managed/user/project/local), auth method |
| `/memory` | Which `CLAUDE.md` and rules files loaded |
| `/skills` | Available skills + source (project/user/plugin) |
| `/agents` | Configured subagents |
| `/hooks` | Active hook configurations grouped by event |
| `/mcp` | Connected MCP servers with status |
| `/permissions` | Resolved allow/deny rules |

**Source:** https://code.claude.com/docs/en/debug-your-config

**Key idea:** the cause of "Claude ignored my X" is almost always:
1. The file didn't load
2. It loaded from a different location than expected
3. Another scope overrode it

---

## 2. Hook debugging — exit codes, stderr, JSON

### Exit codes (canonical)

| Code | Behavior | JSON processed? |
|---|---|---|
| **0** | Success — action proceeds | YES — stdout JSON parsed for decisions |
| **2** | Blocking error — action blocked, stderr shown to Claude | NO — stdout/JSON ignored |
| **Other (1, 3, …)** | Non-blocking error — action proceeds, first stderr line shown to user | NO |

> "For most hook events, only exit code 2 blocks the action. Claude Code treats exit code 1 as a non-blocking error and proceeds with the action, even though 1 is the conventional Unix failure code."

**Most common hook bug:** developer writes `exit 1` expecting "block." It does NOT block. You need `exit 2`.

**Source:** https://code.claude.com/docs/en/hooks (Exit codes section)

### Exit 2 effects per event

```
PreToolUse              → Blocks the tool call
UserPromptSubmit        → Blocks prompt, erases from context
UserPromptExpansion     → Blocks expansion
PermissionRequest       → Denies permission
Stop                    → Prevents Claude from stopping
WorktreeCreate          → Any non-zero exit fails creation
```

PostToolUse, SessionEnd → exit 2 only shows stderr to user; cannot truly "block" because the action already happened.

### Stderr visibility rules

- **Exit 0, plain stdout** → debug log only (not transcript) for most events
- **Exit 0, JSON stdout** → processed as decisions (must be VALID JSON, only the JSON object)
- **Exit 2, stderr** → shown TO CLAUDE as error message
- **Exit 1+, stderr** → first line in transcript as `<hook> hook error`, full text in debug log

### Special: events that inject stdout AS context

Three events: `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`. Plain text stdout becomes additional context Claude sees. **Cap: 10,000 characters.**

### JSON output schema

Universal fields:

```json
{
  "continue": true,
  "stopReason": "Build failed",
  "suppressOutput": false,
  "systemMessage": "Warning text"
}
```

PreToolUse uses `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask|defer",
    "permissionDecisionReason": "reason",
    "updatedInput": { },
    "additionalContext": "..."
  }
}
```

### Common hook failure: shell profile pollution

> "If your shell profile prints text on startup, it can interfere with JSON parsing."

stdout must contain ONLY the JSON object. A `.bashrc` that echoes text breaks parsing. Fix:

```bash
#!/bin/bash
exec 2>/dev/null
source ~/.profile
exec 2>&1
jq -n '{...}'
```

### Debug mode: `claude --debug hooks`

Live event tracing per tool call. Records:
- Each event evaluated
- Which matchers were checked
- Hook exit code
- Hook output (full)

### `/hooks` command — what to check

Run `/hooks` to verify a hook actually loaded. If it doesn't appear:
- Hook is in standalone `.claude/hooks.json` (no such file exists — must be in `settings.json` under `"hooks"` key)
- `matcher` is a JSON array (must be a single string with `|`: `"Edit|Write"`)
- `matcher` is lowercase (case-sensitive: `Bash`, `Edit`, `Write`, `Read`)
- Schema error → `/doctor` reports it; entry dropped silently

**Source:** https://code.claude.com/docs/en/debug-your-config (Common causes table)

---

## 3. Skill debugging — 6-step checklist

(Reuse from workshop 04 — canonical 6 steps.)

1. **`/`-menu visible?**
   - No → wrong path; check `~/.claude/skills/<name>/SKILL.md` exists
   - Yes but "disabled" → `disable-model-invocation: true` (may be intentional)
2. **Rephrase request to match description verbatim** — if it triggers then, description needs tuning
3. **Grep `disable-model-invocation` / `user-invocable`** in frontmatter
4. **Check `paths` glob restrictions** — skill may activate only on matching files
5. **Manual `/skill-name`** — works? Then loaded; problem is matching
6. **Request too simple?** Claude under-triggers skills for trivial one-step tasks (by design)

### Description budget — `SLASH_COMMAND_TOOL_CHAR_BUDGET`

> "Skill descriptions are loaded into context so Claude knows what's available. All skill names are always included, but if you have many skills, descriptions are shortened to fit the character budget. The budget scales dynamically at 1% of the context window, with a fallback of 8,000 characters."

To raise: `SLASH_COMMAND_TOOL_CHAR_BUDGET=16000`. Or trim each description (cap per entry: 1,536 chars).

### Skill content lifecycle (post-compaction)

> "When the conversation is summarized to free context, Claude Code re-attaches the most recent invocation of each skill after the summary, keeping the first 5,000 tokens of each. Re-attached skills share a combined budget of 25,000 tokens. Claude Code fills this budget starting from the most recently invoked skill, so older skills can be dropped entirely after compaction."

**Mitigation:** re-invoke a skill mid-session if it seems to "lose effect" after compaction.

**Source:** https://code.claude.com/docs/en/skills (Troubleshooting section, Skill content lifecycle)

---

## 4. MCP debugging

### `/mcp` command

Shows every configured server, its connection status, project-approval state. Three failure modes:

1. **Project-scoped server in `.mcp.json` requires one-time approval.** If dismissed, server disabled until approved from `/mcp`.
2. **Server fails to start** → shows as "failed" in `/mcp`. Most common cause: relative file paths in `command` or `args` resolved against the launch directory (NOT `.mcp.json` location).
3. **Connected but zero tools** → started but doesn't return tool list. Try **Reconnect** from `/mcp`. If still zero — `claude --debug mcp` for stderr.

**Source:** https://code.claude.com/docs/en/debug-your-config (Check MCP servers)

### `.mcp.json` schema

Lives at **project root** (NOT in `.claude/`).

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

For HTTP servers:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### Common config errors

| Symptom | Cause | Fix |
|---|---|---|
| MCP servers in `.mcp.json` never load | File is under `.claude/` or uses Claude Desktop format | Repository root, not inside `.claude/` |
| Project MCP added but doesn't appear | One-time approval prompt was dismissed | Run `/mcp` and approve |
| MCP server fails to start from some directories | Relative path in `command`/`args` | Use absolute paths; `npx`/`uvx` work as-is |
| Server starts but missing env vars | Vars in `settings.json` `env` (doesn't propagate to MCP children) | Per-server `env` inside `.mcp.json` |
| `Failed to parse config` | Required `${VAR}` not set, no default | Set env var or add `${VAR:-default}` |

### Transports

- **stdio** — local process; not auto-reconnected on disconnect
- **HTTP** — recommended for remote; auto-reconnect (5 attempts, exp backoff 1s→2s→4s→8s→16s)
- **SSE** — DEPRECATED; use HTTP instead

### Auth failures

OAuth flow can fail with: "Incompatible auth server: does not support dynamic client registration" — server requires pre-registered creds. Workaround: register OAuth app on server's developer portal, provide credentials when adding.

For non-OAuth (Kerberos, internal SSO): use `headersHelper` in `.mcp.json` — runs a command per connection, merges output into headers.

**Source:** https://code.claude.com/docs/en/mcp (full doc)

---

## 5. Session transcripts — location and format

### Where they live

```
~/.claude/projects/<project-slug>/<session-id>.jsonl
```

`<project-slug>` = sanitized cwd path. For `/home/vadym/projects/foo` slug becomes something like `-home-vadym-projects-foo`.

Each line is a JSON object representing one event in the session: user prompt, assistant response, tool call, tool result, hook output, system message, etc.

### Useful jq queries

```bash
# List all sessions for a project
ls ~/.claude/projects/-home-vadym-projects-foo/

# Show only user prompts from a session
jq 'select(.type == "user") | .message.content' session-id.jsonl

# Find all tool calls
jq 'select(.type == "assistant" and (.message.content[]?.type == "tool_use"))' session-id.jsonl

# Hook outputs (where hooks ran)
jq 'select(.type == "system" and (.subtype // "") | contains("hook"))' session-id.jsonl

# Auto-compaction events
jq 'select(.type == "system" and .subtype == "compact_boundary")' session-id.jsonl

# Skill invocations
jq 'select(.type == "assistant" and (.message.content[]?.text // "") | contains("Skill"))' session-id.jsonl
```

### Caveat — schema is undocumented

The exact JSONL schema is not in official docs (UNVERIFIED). Field names like `.type`, `.message.content`, `.subtype` are observed in real transcripts on the user's machine but not formally specified. Treat queries as starting points, not contract.

---

## 6. Auto-compaction loss

### What gets preserved

- A summary of the prior conversation (Claude-generated)
- **Skills:** most recent invocation of each, first 5,000 tokens, shared 25K budget
- Most recent few turns verbatim
- System prompt + memory files (CLAUDE.md, etc.) — re-injected fresh

### What gets lost

- Older tool outputs verbatim
- Earlier file reads (only summarized references remain)
- Skills not invoked recently OR pushed out by 25K budget
- Detailed code chunks Claude saw in mid-session

### Mitigation

1. **Re-invoke skill** if it seems to stop working — the content gets restored
2. **`/recap`** (silent injection) — useful before context fills
3. **Subagents** for heavy research — keeps main context clean
4. **`/compact <focus>`** — manual compaction with directive; e.g. `/compact keep only the plan and the diff`
5. **Auto-compact thrashing** — if you see "Autocompact is thrashing" error: a file or tool output keeps refilling. Read in chunks, drop large output, run `/clear` if old conversation no longer needed

**Source:** https://code.claude.com/docs/en/skills (lifecycle), https://code.claude.com/docs/en/troubleshooting (thrashing)

---

## 7. Common error messages catalog

| Error | Likely cause | Fix |
|---|---|---|
| `Hook X exited with code 1` (non-blocking, but you wanted block) | Used exit 1 instead of 2 | Change `exit 1` → `exit 2` |
| `Hook X JSON parse error` | stdout has non-JSON before/after JSON object | Suppress shell profile output; ensure ONLY JSON to stdout |
| `Skill X not found` (after `/`) | Wrong path or directory layout | `~/.claude/skills/<name>/SKILL.md` (folder + entry, not flat .md) |
| `MCP server X failed to start` | Relative path in command, missing executable, missing env | Absolute path; check `claude --debug mcp` stderr |
| `MCP server X: Connection refused` | Remote server down, or local stdio process died | Test endpoint; for stdio, run command manually |
| `Autocompact is thrashing` | Single file fills context after each compact | Read file in chunks; `/compact <focus>`; `/clear` |
| `spawn claude ENOENT` (when CC is itself an MCP server) | Wrong path to `claude` binary in MCP config | Use absolute path to `claude` binary |

**Source:** https://code.claude.com/docs/en/troubleshooting (full table at top)

---

## 8. LSP failures

LSPs are integrated through IDE plugins (JetBrains, VSCode). Common issues are not deeply documented in code.claude.com.

Patterns observed:

- **JetBrains "No available IDEs detected" on WSL2** — Windows Firewall blocks WSL2 NAT bridge. Fix: configure firewall rule, or switch to mirrored networking via `.wslconfig`.
- **Escape key not interrupting in JetBrains terminal** — keybinding clash. Fix: Settings → Tools → Terminal → uncheck "Move focus to editor with Escape".

LSP server logs typically aren't surfaced through Claude Code itself. For deeper LSP debug, check the IDE plugin's own log directory. (UNVERIFIED — exact locations vary by IDE.)

**Source:** https://code.claude.com/docs/en/troubleshooting (IDE integration issues section)

---

## 9. Debug flag matrix

| Flag | What it does |
|---|---|
| `claude --debug` | All categories enabled |
| `claude --debug hooks` | Hook event evaluation, matchers, exit codes, full output |
| `claude --debug mcp` | MCP server stderr, handshake, tool list responses |
| `claude --debug api` | (UNVERIFIED) raw HTTP requests/responses |
| `claude doctor` | One-shot diagnostic for installation/config |

`/doctor` (in-session) checks:
- Installation type, version, search functionality
- Auto-update status
- Invalid settings files (malformed JSON, wrong types)
- MCP server config errors (incl. same name in multiple scopes with different endpoints)
- Keybinding configuration problems
- Context usage warnings (large CLAUDE.md, MCP token usage, unreachable permission rules)
- Plugin and agent loading errors

---

## 10. Open / unverified

1. **JSONL transcript schema** — observed in practice; not in official docs
2. **`--debug api`** — flag exists but undocumented
3. **Compaction thrashing exact threshold** — docs say "limit several times in a row" without exact count
4. **LSP log locations** — IDE-specific; no central documentation

---

## References

**Primary docs:**
- https://code.claude.com/docs/en/troubleshooting — install, auth, performance, IDE
- https://code.claude.com/docs/en/debug-your-config — `/context`, `/doctor`, `/hooks`, `/mcp`, common-cause table
- https://code.claude.com/docs/en/hooks — exit codes, JSON schema, `--debug hooks`
- https://code.claude.com/docs/en/skills — troubleshooting, content lifecycle, `SLASH_COMMAND_TOOL_CHAR_BUDGET`
- https://code.claude.com/docs/en/mcp — `.mcp.json`, transports, OAuth, scopes

**Supplementary:**
- https://code.claude.com/docs/en/hooks-guide — practical hook examples (limitations + troubleshooting)
- https://code.claude.com/docs/en/sub-agents — for routing heavy work away from main context
