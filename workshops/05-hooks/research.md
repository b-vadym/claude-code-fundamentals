# Claude Code Hooks: Research Dossier

**For:** Workshop 05 — Lifecycle Hooks deep dive
**Audience:** Developers who saw hooks in fundamentals deck; now want to write them
**Date:** 2026-04-26

All facts are tied to a doc URL or local quote. Items not verified in docs are tagged **UNVERIFIED**.

---

## 1. What hooks are

> "Hooks are user-defined shell commands that execute at specific points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them."
> — https://code.claude.com/docs/en/hooks-guide

Hook *types*:
- `command` — shell command (most common)
- `http` — POST event JSON to URL
- `mcp_tool` — call tool on connected MCP server
- `prompt` — single-turn LLM eval (Haiku by default)
- `agent` — multi-turn subagent verification (experimental)
  Source: hooks-guide §"How hooks work"

Workshop scope: **command hooks only** (others are mentioned at the end as pointers).

---

## 2. Lifecycle event catalogue

The full lifecycle event list (https://code.claude.com/docs/en/hooks-guide §"How hooks work"):

| Event | When |
|---|---|
| `SessionStart` | session begins or resumes |
| `UserPromptSubmit` | user submits a prompt, before Claude processes it |
| `UserPromptExpansion` | a typed `/`-command expands into a prompt |
| `PreToolUse` | before a tool call executes — **can block** |
| `PermissionRequest` | a permission dialog appears |
| `PermissionDenied` | tool denied by auto-mode classifier |
| `PostToolUse` | after a tool call succeeds |
| `PostToolUseFailure` | after a tool call fails |
| `PostToolBatch` | after a batch of parallel tool calls resolves |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | subagent spawned / finished |
| `TaskCreated` / `TaskCompleted` | TodoWrite-driven task lifecycle |
| `Stop` | Claude finishes responding |
| `StopFailure` | turn ended due to API error (output/exit ignored) |
| `TeammateIdle` | agent-team teammate going idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context |
| `ConfigChange` | a config file changes during session |
| `CwdChanged` | working dir changes (e.g., `cd`) |
| `FileChanged` | watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | worktree lifecycle |
| `PreCompact` / `PostCompact` | context compaction lifecycle |
| `Elicitation` / `ElicitationResult` | MCP user input flow |
| `SessionEnd` | session terminates |

Workshop covers **9 core events** mentioned in the brief: PreToolUse, PostToolUse, SessionStart, SessionEnd, UserPromptSubmit, Stop, SubagentStop, PreCompact, Notification.

---

## 3. Exit code semantics (verified)

From https://code.claude.com/docs/en/hooks-guide §"Hook output":

> * **Exit 0**: the action proceeds. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart` hooks, anything you write to stdout is added to Claude's context.
> * **Exit 2**: the action is blocked. Write a reason to stderr, and Claude receives it as feedback so it can adjust.
> * **Any other exit code**: the action proceeds. The transcript shows a `<hook name> hook error` notice followed by the first line of stderr; the full stderr goes to the debug log.

Reference page restates: https://code.claude.com/docs/en/hooks §"Exit Code Semantics"
- Exit 1 is **NOT** treated as blocking. Only **exit 2** blocks.
- For `UserPromptSubmit` exit 2 = block prompt, erase from context, show stderr to user.
- For `PreToolUse` exit 2 = deny tool call, stderr → Claude.
- For `PostToolUse` exit 2 = block (show stderr to Claude); tool already executed.
- For `Stop` / `SubagentStop` exit 2 = prevent stop, continue conversation.
- For `PreCompact` exit 2 = block compaction.
- For `Notification` / `SessionEnd` / `StopFailure` / `PostCompact` / `WorktreeRemove` / `InstructionsLoaded` — exit code ignored / shown to user only.

---

## 4. JSON output schema (verified)

Universal fields (https://code.claude.com/docs/en/hooks §"Common JSON Output Schema"):

```json
{
  "continue": true,
  "stopReason": "Reason shown to user when continue is false",
  "suppressOutput": false,
  "systemMessage": "Warning shown to user"
}
```

| Field | Default | Effect |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Shown to user when `continue: false`; not to Claude |
| `suppressOutput` | `false` | Omits stdout from debug log |
| `systemMessage` | none | Warning shown to user |

**Per-event decision shapes:**

- `PreToolUse` — `hookSpecificOutput.permissionDecision`: `allow | deny | ask | defer`, plus `permissionDecisionReason`, `updatedInput`, `additionalContext`
- `PostToolUse`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` — top-level `decision: "block"` + `reason`
- `UserPromptSubmit` — `decision: "block"` + `reason`, or `hookSpecificOutput.additionalContext` to inject context
- `SessionStart` — `hookSpecificOutput.additionalContext` (or stdout text)
- `PermissionRequest` — `hookSpecificOutput.decision.behavior`: `allow | deny`, plus `updatedPermissions`

> "Use exit 2 to block with a stderr message, or exit 0 with JSON for structured control. Don't mix them: Claude Code ignores JSON when you exit 2."
> — hooks-guide §"Structured JSON output"

When multiple hooks match a single event, **deny > defer > ask > allow**.
> "When multiple hooks match, each one returns its own result. For decisions, Claude Code picks the most restrictive answer."
> — hooks-guide §"How hooks work"

---

## 5. settings.json schema

Hooks live under the top-level `hooks` key (https://code.claude.com/docs/en/hooks §"Settings.json Configuration Schema"):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh",
            "timeout": 600,
            "statusMessage": "Running validation...",
            "if": "Bash(git *)"
          }
        ]
      }
    ]
  }
}
```

Three nesting levels: **event → matcher group → hook handler**.

**Common handler fields:**
- `type` (required): `command | http | mcp_tool | prompt | agent`
- `if` (optional, tool events only): permission-rule syntax e.g. `Bash(git *)`, `Edit(*.ts)`. Requires CC v2.1.85+.
- `timeout` (seconds): default 600 (command), 30 (prompt), 60 (agent)
- `statusMessage`: spinner text while hook runs
- `once`: skills/agents only

**Command-hook fields:** `command` (required), `async`, `asyncRewake`, `shell` (`bash` default | `powershell`).

---

## 6. Matcher patterns

From https://code.claude.com/docs/en/hooks §"Matcher Patterns":

| Pattern | Evaluated as | Example |
|---|---|---|
| `"*"`, `""`, omitted | match all | fires every time |
| Only `[A-Za-z0-9_|]` | exact match or `\|`-separated list | `"Bash"`, `"Edit\|Write"` |
| Contains other characters | JavaScript regex | `"^Notebook"`, `"mcp__memory__.*"` |

**Matcher target depends on event:**
- Tool events → tool name (`Bash`, `Edit`, `Write`, `Read`, `mcp__<server>__<tool>`)
- `SessionStart` → source (`startup`, `resume`, `clear`, `compact`)
- `SessionEnd` → reason (`clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other`)
- `Notification` → type (`permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`)
- `SubagentStart/Stop` → agent type (`Bash`, `Explore`, `Plan`, custom)
- `PreCompact/PostCompact` → trigger (`manual`, `auto`)

**No matcher support:** `UserPromptSubmit`, `Stop`, `PostToolBatch`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`.

---

## 7. Hook locations

From https://code.claude.com/docs/en/hooks-guide §"Configure hook location":

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | all projects | no (local) |
| `.claude/settings.json` | one project | yes (commit) |
| `.claude/settings.local.json` | one project | no (gitignored) |
| Managed policy settings | org-wide | yes (admin) |
| Plugin `hooks/hooks.json` | when plugin enabled | yes (bundled) |
| Skill/agent frontmatter | while component active | yes |

Precedence (https://code.claude.com/docs/en/settings): managed > local > project > user.

> "If you edit settings files directly while Claude Code is running, the file watcher normally picks up hook changes automatically."
> — hooks-guide

---

## 8. Security boundary (verified)

Critical:
- Hooks run with **user's permissions and environment** (hooks ref §"Key Security Notes")
- Hooks can read your home dir, network, etc.
- Only exit code 2 blocks; exit 1 looks like an error but doesn't block
- `PreToolUse` hook with `permissionDecision: "deny"` enforces policy **even in `bypassPermissions` mode** (hooks-guide §"Hooks and permission modes") — this is *the* reason to write security hooks

> "PreToolUse hooks fire before any permission-mode check. A hook that returns `permissionDecision: 'deny'` blocks the tool even in `bypassPermissions` mode or with `--dangerously-skip-permissions`. This lets you enforce policy that users cannot bypass by changing their permission mode."
> — hooks-guide

Trust model: **never run an untrusted hook**. A hook is the same as `curl ... | bash`.

---

## 9. Debugging hooks

From hooks-guide §"Limitations and troubleshooting":

**Hook not firing:**
- `/hooks` menu shows configured hooks per event
- Matchers are case-sensitive
- Verify event type (PreToolUse vs PostToolUse confusion)
- `PermissionRequest` does **not** fire in `-p` (headless) mode → use `PreToolUse`

**Hook error in transcript:** `<hook name> hook error: ...`
- Test manually:
  ```bash
  echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh
  echo $?
  ```
- "command not found" → use absolute paths or `$CLAUDE_PROJECT_DIR`
- "jq: command not found" → install `jq` or use python
- Not running at all → `chmod +x ./my-hook.sh`

**JSON validation failed (subtle one):**
> "When Claude Code runs a hook, it spawns a shell that sources your profile (`~/.zshrc` or `~/.bashrc`). If your profile contains unconditional `echo` statements, that output gets prepended to your hook's JSON."

Fix: wrap profile output in `if [[ $- == *i* ]]; then ... fi`.

**Stop hook runs forever:**
> "Your Stop hook script needs to check whether it already triggered a continuation. Parse the `stop_hook_active` field from the JSON input and exit early if it's `true`."

**Debug log:** start with `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Mid-session: `/debug`.

**Transcript view:** `Ctrl+O` shows one-line summary per hook fired (success silent, exit 2 shows stderr, other non-zero shows hook error notice).

---

## 10. Useful environment variables

From https://code.claude.com/docs/en/hooks §"Environment Variables & Paths":

| Variable | Expands to |
|---|---|
| `$CLAUDE_PROJECT_DIR` | project root (use for `.claude/hooks/script.sh`) |
| `${CLAUDE_PLUGIN_ROOT}` | plugin directory |
| `${CLAUDE_PLUGIN_DATA}` | plugin persistent data |
| `CLAUDE_ENV_FILE` | file path (in SessionStart, CwdChanged, FileChanged) — write `KEY=VALUE` lines, Claude sources before each Bash command |
| `CLAUDE_CODE_REMOTE` | `"true"` in web, unset locally |

---

## 11. PreToolUse — Bash matcher specifics

Tool input on stdin (https://code.claude.com/docs/en/hooks §"PreToolUse"):

```json
{
  "session_id": "abc123",
  "cwd": "/current/dir",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "optional"
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Bash tool-input schema fields:** `command`, `description`, `timeout`, `run_in_background`.

**Reference Anthropic example:** https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py — Anthropic-blessed regex-based bash validator.

---

## 12. PostToolUse — log every tool call

Input on stdin includes `tool_response` (success result) and `duration_ms`. From hooks-guide §"Filter hooks with matchers" → "Log every Bash command":

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/.claude/command-log.txt"
          }
        ]
      }
    ]
  }
}
```

Workshop variant: log to JSONL with timestamp, tool name, command, success — for **every** tool, not just Bash.

---

## 13. SessionStart — context injection

Input fields (https://code.claude.com/docs/en/hooks §"SessionStart"):
- `session_id`, `transcript_path`, `cwd`, `hook_event_name: "SessionStart"`, `source: startup|resume|clear|compact`, `model`

**stdout text → context** (verified). Or JSON with `hookSpecificOutput.additionalContext`.

> "Any text your command writes to stdout is added to Claude's context."
> — hooks-guide §"Re-inject context after compaction"

Example pattern:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          { "type": "command", "command": "echo 'Reminder: use Bun, not npm.'" }
        ]
      }
    ]
  }
}
```

For startup-only context: `matcher: "startup"`. For both: omit matcher.

---

## 14. UserPromptSubmit — prompt validation

Input on stdin (https://code.claude.com/docs/en/hooks §"UserPromptSubmit"):

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/dir",
  "permission_mode": "default|plan|acceptEdits|auto|...",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "User's input text"
}
```

**Outputs:**
- exit 0 + stdout text → added as additional context to user prompt
- exit 0 + JSON `decision: "block"` + `reason` → erase prompt, show reason to user
- exit 2 → block prompt, stderr shown to user

> "* `0` = allow prompt, optionally add context
> * `2` = block prompt, erase from context, show stderr reason"
> — hooks ref §"UserPromptSubmit"

**No matcher support** — fires on every prompt.

---

## 15. Notification, Stop, SubagentStop, PreCompact, SessionEnd

- **Notification** — fires when CC needs input (matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`). Exit code shown to user only.
- **Stop** — fires when Claude finishes turn. Exit 2 = prevent stop, continue. **Trap: avoid loops by checking `stop_hook_active`.**
- **SubagentStop** — fires when subagent ends. Same exit semantics.
- **PreCompact** — `matcher: manual|auto`. Exit 2 blocks compaction.
- **SessionEnd** — `matcher: clear|resume|logout|prompt_input_exit|bypass_permissions_disabled|other`. Exit code **ignored** — observability/cleanup only.

---

## 16. Workshop topics for slides

Mapping → slide buckets:

1. **Intro / motivation** (3 slides): why hooks, what they aren't (skill vs hook), agenda
2. **Lifecycle catalogue** (3 slides): event table, when each fires, "no matcher" gotcha
3. **Anatomy** (4 slides): settings.json schema, matcher patterns, exit codes, JSON output schema
4. **Hands-on prep** (1 slide): exercise structure, terminal setup
5. **Exercise 1 — block dangerous bash** (3 slides): goal, regex matcher, walkthrough of solution
6. **Exercise 2 — log every tool call** (3 slides): goal, JSONL pattern, jq tricks
7. **Exercise 3 — SessionStart context** (3 slides): goal, what to inject, demo
8. **Exercise 4 — UserPromptSubmit warning** (3 slides): goal, soft warn vs block, decision tree
9. **Debug** (3 slides): /hooks menu, manual test, common failures
10. **Security** (2 slides): hooks = curl|bash, deny enforces in bypass, audit your settings
11. **Production checklist + resources** (2 slides): chk-list, distribution via plugins, doc links

Total ≈ 32–35 slides — matches workshop 04 density.

---

## 17. Items NOT verified — flag in slides as UNVERIFIED if used

- Exact CC version requirements for each hook event (only `if` field is documented as v2.1.85+).
- Whether `chmod +x` works on Windows (docs only show `chmod` for macOS/Linux). **UNVERIFIED for Windows.**
- Whether `~/.claude/settings.json` is auto-created on first run. **UNVERIFIED — assume manual.**
- Hook execution order beyond "parallel within event"; exact order between events is **UNVERIFIED**.

These won't appear as factual claims in slides without the UNVERIFIED tag.

---

## 18. Doc URL index (used in slides)

- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/hooks-guide
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/permissions
- https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py

Local file references for testing:
- `~/.claude/settings.json`
- `.claude/settings.json`
- `.claude/hooks/<name>.sh`
