# Slash Commands Deep Dive: Research Dossier

**For:** Ukrainian developer workshop on slash commands (`/name`, arguments, shell injection, plugin namespacing)
**Audience:** Developers who saw `/`-commands in fundamentals deck — now want to author them.
**Date:** 2026-04-26

---

## 1. Commands Merged Into Skills (CRITICAL)

**Source:** https://code.claude.com/docs/en/skills (Note callout):

> **Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way. Your existing `.claude/commands/` files keep working. Skills add optional features: a directory for supporting files, frontmatter to control whether you or Claude invokes them, and the ability for Claude to load them automatically when relevant.

**Implications for the workshop:**

- The frontmatter schema for slash commands is **the same schema as skills**.
- Legacy `.claude/commands/foo.md` continues to work (backward compat) but is feature-frozen.
- New custom commands should be authored as `.claude/skills/foo/SKILL.md` to gain: supporting files, `disable-model-invocation`, `paths`, `context: fork`, etc.
- **Naming precedence:** "if a skill and a command share the same name, the skill takes precedence." (https://code.claude.com/docs/en/skills#where-skills-live)

**Source:** https://code.claude.com/docs/en/plugins (table):

> | `commands/` | Plugin root | Skills as flat Markdown files. Use `skills/` for new plugins |

The plugins doc explicitly recommends `skills/` over `commands/` for new plugins.

---

## 2. Argument Substitution

**Source:** https://code.claude.com/docs/en/skills#available-string-substitutions

| Variable               | Description                                                                                                                                                            |
| :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill. If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`.                            |
| `$ARGUMENTS[N]`        | Access a specific argument by 0-based index, such as `$ARGUMENTS[0]` for the first argument.                                                                            |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`, such as `$0` for the first argument or `$1` for the second.                                                                              |
| `$name`                | Named argument declared in the `arguments` frontmatter list. Names map to positions in order, so with `arguments: [issue, branch]` `$issue` = first, `$branch` = second.|
| `${CLAUDE_SESSION_ID}` | The current session ID.                                                                                                                                                 |
| `${CLAUDE_SKILL_DIR}`  | The directory containing the skill's `SKILL.md` file.                                                                                                                   |

**Quoting rule (verified):**

> Indexed arguments use shell-style quoting, so wrap multi-word values in quotes to pass them as a single argument. For example, `/my-skill "hello world" second` makes `$0` expand to `hello world` and `$1` to `second`. The `$ARGUMENTS` placeholder always expands to the full argument string as typed.

**Frontmatter `arguments` field:**

> Named positional arguments for `$name` substitution in the skill content. Accepts a space-separated string or a YAML list. Names map to argument positions in order.

**`argument-hint` field:**

> Hint shown during autocomplete to indicate expected arguments. Example: `[issue-number]` or `[filename] [format]`.

**Example (from docs):**

```yaml
---
name: migrate-component
description: Migrate a component from one framework to another
---
Migrate the $0 component from $1 to $2.
```

`/migrate-component SearchBar React Vue` → `$0=SearchBar`, `$1=React`, `$2=Vue`.

---

## 3. Shell Injection (`!`backtick`` and ` ```! ` blocks)

**Source:** https://code.claude.com/docs/en/skills#inject-dynamic-context

Verbatim:

> The `` !`<command>` `` syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder, so Claude receives actual data, not the command itself.

**Example from docs:**

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

**Order of operations (verbatim):**

> 1. Each `` !`<command>` `` executes immediately (before Claude sees anything)
> 2. The output replaces the placeholder in the skill content
> 3. Claude receives the fully-rendered prompt with actual PR data
>
> This is preprocessing, not something Claude executes. Claude only sees the final result.

**Multi-line variant** uses ` ```! ` fenced block (instead of inline backticks):

````markdown
## Environment
```!
node --version
npm --version
git status --short
```
````

**Disabling shell execution** (security):

> To disable this behavior for skills and custom commands from user, project, plugin, or additional-directory sources, set `"disableSkillShellExecution": true` in settings. Each command is replaced with `[shell command execution disabled by policy]` instead of being run. Bundled and managed skills are not affected.

**Shell choice** (frontmatter `shell` field):

> `bash` (default) or `powershell`. Setting `powershell` runs inline shell commands via PowerShell on Windows. Requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`.

---

## 4. `allowed-tools` Restriction Semantics

**Source:** https://code.claude.com/docs/en/skills#pre-approve-tools-for-a-skill

Verbatim:

> The `allowed-tools` field grants permission for the listed tools while the skill is active, so Claude can use them without prompting you for approval. **It does not restrict which tools are available**: every tool remains callable, and your permission settings still govern tools that are not listed.

**Example:**

```yaml
---
name: commit
description: Stage and commit the current changes
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---
```

**Pattern syntax:**
- `ToolName` — entire tool
- `ToolName(matcher-pattern)` — glob-matched subset
- Space-separated string OR YAML list both accepted

**To actually BLOCK** (deny rules — different mechanism):

> To block a skill from using certain tools, add deny rules in your permission settings instead.

**Implication for workshop exercise 3:** `allowed-tools` is a pre-approval, not a sandbox. To genuinely sandbox a command (e.g., "may only run git, nothing else"), you combine `allowed-tools: Bash(git *)` with deny rules in `settings.json` (`Bash(*)` deny + `Bash(git *)` allow).

UNVERIFIED claim from prompt: "may only Bash(git *), nothing else" — strictly speaking `allowed-tools` cannot enforce this alone. The exercise will:
1. Use `allowed-tools: Bash(git status *) Bash(git log *) Bash(git diff *)` for pre-approval.
2. Show that other tools still need approval (or settings deny rules to block).
3. Explain the distinction explicitly in slide + README.

---

## 5. Plugin Namespacing

**Source:** https://code.claude.com/docs/en/plugins#create-your-first-plugin

Verbatim:

> The folder name becomes the skill name, prefixed with the plugin's namespace (`hello/` in a plugin named `my-first-plugin` creates `/my-first-plugin:hello`).

> Plugin skills are always namespaced (like `/my-first-plugin:hello`) to prevent conflicts when multiple plugins have skills with the same name.
>
> To change the namespace prefix, update the `name` field in `plugin.json`.

**Plugin manifest minimum:**

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**Manifest fields verified:**
- `name` — Unique identifier and skill namespace.
- `description` — Shown in plugin manager.
- `version` — Optional. If omitted and distributed via git, commit SHA used.
- `author` — Optional, for attribution.

**Local testing** (verified):

> Run Claude Code with the `--plugin-dir` flag to load your plugin:
> ```bash
> claude --plugin-dir ./my-first-plugin
> ```

> When a `--plugin-dir` plugin has the same name as an installed marketplace plugin, the local copy takes precedence for that session.

**Reload during dev:**

> As you make changes to your plugin, run `/reload-plugins` to pick up the updates without restarting.

**Common mistake (Warning callout):**

> **Common mistake**: Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside the `.claude-plugin/` directory. Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root level.

**Plugin directory schema:**

| Directory         | Location    | Purpose                                                                        |
| :---------------- | :---------- | :----------------------------------------------------------------------------- |
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest                                                |
| `skills/`         | Plugin root | Skills as `<name>/SKILL.md` directories                                        |
| `commands/`       | Plugin root | Skills as flat Markdown files. **Use `skills/` for new plugins**               |
| `agents/`         | Plugin root | Custom agent definitions                                                       |
| `hooks/`          | Plugin root | Event handlers in `hooks.json`                                                 |

---

## 6. Command vs Auto-Invoked Skill: When to Use Which

**Source:** https://code.claude.com/docs/en/skills#types-of-skill-content

The docs distinguish two content types:

> **Reference content** adds knowledge Claude applies to your current work. Conventions, patterns, style guides, domain knowledge. This content runs inline so Claude can use it alongside your conversation context.

> **Task content** gives Claude step-by-step instructions for a specific action, like deployments, commits, or code generation. These are often actions you want to invoke directly with `/skill-name` rather than letting Claude decide when to run them. Add `disable-model-invocation: true` to prevent Claude from triggering it automatically.

**Decision rule (synthesized from docs):**

| Trigger style                       | Frontmatter                       | Use when                                                  |
| :---------------------------------- | :-------------------------------- | :-------------------------------------------------------- |
| Explicit user invocation only       | `disable-model-invocation: true`  | Side effects: deploy, commit, push, drop DB                |
| Both user and Claude (default)      | (no flag)                         | Task that's safe to auto-trigger                           |
| Claude only (background knowledge)  | `user-invocable: false`           | Reference / domain context (legacy-system explainer)       |

**Source verbatim:**

> **`disable-model-invocation: true`**: Only you can invoke the skill. Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`. You don't want Claude deciding to deploy because your code looks ready.

> **`user-invocable: false`**: Only Claude can invoke the skill. Use this for background knowledge that isn't actionable as a command. A `legacy-system-context` skill explains how an old system works.

**Workshop framing:** Slash command = `disable-model-invocation: true` (most of the time). Auto-skill = default. Background-knowledge skill = `user-invocable: false`.

---

## 7. Bundled Slash Commands (Reference)

**Source:** https://code.claude.com/docs/en/skills#bundled-skills

> Claude Code includes a set of bundled skills that are available in every session, including `/simplify`, `/batch`, `/debug`, `/loop`, and `/claude-api`. Unlike most built-in commands, which execute fixed logic directly, bundled skills are prompt-based: they give Claude a detailed playbook and let it orchestrate the work using its tools. You invoke them the same way as any other skill, by typing `/` followed by the skill name.

**Built-ins** (full reference: https://code.claude.com/docs/en/commands) include `/help`, `/compact`, `/init`, `/review`, `/security-review`. Built-ins like `/init`, `/review`, `/security-review` are also reachable via the Skill tool (verified at https://code.claude.com/docs/en/skills#restrict-claudes-skill-access).

---

## 8. Frontmatter Reference (Slash-Command-Relevant Fields)

Source: https://code.claude.com/docs/en/skills#frontmatter-reference

Fields most relevant to slash commands:

| Field                      | For commands? | Notes                                                                                  |
| :------------------------- | :------------ | :------------------------------------------------------------------------------------- |
| `name`                     | Yes           | Becomes `/name`. Lowercase, hyphens, ≤64 chars.                                        |
| `description`              | Yes           | Shown in `/`-menu. Capped at 1,536 chars combined with `when_to_use`.                  |
| `argument-hint`            | Yes           | Autocomplete hint, e.g., `[issue] [format]`.                                           |
| `arguments`                | Yes           | Named positional. `arguments: [issue, branch]` enables `$issue`, `$branch`.            |
| `disable-model-invocation` | Yes           | `true` for command-only (no auto-trigger).                                             |
| `user-invocable`           | Rarely        | `false` hides from `/`-menu (= not a command anymore).                                 |
| `allowed-tools`            | Yes           | Pre-approval list.                                                                     |
| `model` / `effort`         | Optional      | Override per-invocation.                                                               |
| `paths`                    | Rarely        | Glob restriction (more useful for auto-skills than for explicit commands).             |
| `shell`                    | Yes           | `bash` (default) / `powershell` for `!`-injection.                                    |
| `context: fork` / `agent`  | Optional      | Run command in subagent.                                                               |

---

## 9. Token Budget for Command Descriptions

**Source:** https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short

> Skill descriptions are loaded into context so Claude knows what's available. All skill names are always included, but if you have many skills, descriptions are shortened to fit the character budget, which can strip the keywords Claude needs to match your request. The budget scales dynamically at 1% of the context window, with a fallback of 8,000 characters.

> To raise the limit, set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable. Or trim the `description` and `when_to_use` text at the source: front-load the key use case, since each entry's combined text is capped at 1,536 characters regardless of budget.

**For slash commands specifically:** since they're explicit, the description matters less for triggering and more for `/`-menu UX. A short description + good `argument-hint` is the right pattern.

---

## 10. Live Reload Semantics

**Source:** https://code.claude.com/docs/en/skills#live-change-detection

> Adding, editing, or removing a skill under `~/.claude/skills/`, the project `.claude/skills/`, or a `.claude/skills/` inside an `--add-dir` directory takes effect within the current session without restarting. **Creating a top-level skills directory that did not exist when the session started requires restarting Claude Code so the new directory can be watched.**

**For plugins:** `/reload-plugins` picks up edits to an installed plugin's skills.

---

## 11. Open Questions / UNVERIFIED

1. **UNVERIFIED** — Whether the legacy `.claude/commands/foo.md` flat-file format supports `$ARGUMENTS`, `argument-hint`, etc. Docs say "files in `.claude/commands/` still work and support the same frontmatter" → presumably yes, but the example structure with arguments is shown only for `SKILL.md`. Workshop will demo only with `SKILL.md` form to avoid edge cases.

2. **UNVERIFIED** — Exact behavior of `allowed-tools` glob patterns: docs show `Bash(npm *)` and `Bash(git add *)` but the precise matcher syntax (e.g., does it support `**`, `?`, character classes?) is not documented in detail. Workshop sticks to simple prefix patterns.

3. **UNVERIFIED** — Whether `!`backtick`` injection respects `allowed-tools` for the bash invocation, or runs unconditionally. Docs frame it as "preprocessing, not something Claude executes," suggesting unconditional. The `disableSkillShellExecution` setting is the intended kill-switch.

---

## References

**Official docs (verified for this workshop):**

- https://code.claude.com/docs/en/skills — Skills overview, frontmatter, shell injection, allowed-tools, lifecycle
- https://code.claude.com/docs/en/plugins — Plugin manifest, namespacing, `--plugin-dir`, directory structure
- https://code.claude.com/docs/en/commands — Built-in command reference (mentioned, not deeply quoted)

**Local context:**

- Workshop 04 template: `/home/vadym/projects/presentations/claude-code-developers/workshops/04-skills/` — style, structure, DocRef usage, density
- Personal CLAUDE.md memory: presentation facts must be verified, both legacy decks frozen

**Status:** Verified dossier complete. All quotes traceable to doc URLs. Ready for slide and exercise generation.
