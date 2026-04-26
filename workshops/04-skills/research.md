# Claude Code Skills: Research Dossier

**For:** Ukrainian developer workshop on skills (deep dive: idea → creation → packaging → debugging → distribution)  
**Audience:** Developers familiar with skills conceptually (fundamentals deck)  
**Date:** 2026-04-26

---

## 1. Anatomy: File Structure and Frontmatter

### Skill Directory Structure

A skill lives in a directory (not a flat file) with this structure:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (between --- markers)
│   └── Markdown instructions
└── Supporting files (optional)
    ├── scripts/        # Executable code (bash, python, etc.)
    ├── references/     # Docs loaded as-needed
    └── assets/         # Templates, icons, fonts
```

**Sources:**
- https://code.claude.com/docs/en/skills — "Each skill is a directory with `SKILL.md` as the entrypoint"
- Local example: `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md`

### Frontmatter Fields (YAML)

All fields are optional. Only `description` is recommended. **Key fields:**

| Field | Type | Purpose | Example |
|-------|------|---------|---------|
| `name` | string | Display name for `/slash-command`. Lowercase, hyphens, max 64 chars. If omitted, uses directory name. | `name: brainstorming` |
| `description` | string | **When to trigger.** Claude uses this to decide whether to auto-load skill. Front-load the key use case. Capped at 1,536 characters combined with `when_to_use`. | `description: Use when starting any conversation` |
| `when_to_use` | string | Additional context, trigger phrases, example requests. Appended to `description` in context, counts toward 1,536-char cap. | (Optional, rarely used alone) |
| `disable-model-invocation` | bool | If `true`, only user can invoke with `/name`. Claude cannot trigger automatically. Use for workflows with side effects (deploy, commit). | `disable-model-invocation: true` |
| `user-invocable` | bool | If `false`, only Claude can invoke. Hide from `/` menu. Use for background knowledge (context without action). | `user-invocable: false` |
| `allowed-tools` | string/list | Pre-approve tools without per-use prompts while skill is active. Does not restrict—permission settings still govern. | `allowed-tools: [Bash, Read]` |
| `context` | string | Set to `fork` to run skill in isolated subagent (forked context). | `context: fork` |
| `agent` | string | Which subagent type (`Explore`, `Plan`, `general-purpose`, or custom). Used only if `context: fork`. | `agent: Explore` |
| `argument-hint` | string | Hint during autocomplete: e.g., `[issue-number]` or `[filename] [format]`. | `argument-hint: [repo-name]` |
| `arguments` | string/list | Named positional arguments for `$name` substitution in skill content. | `arguments: [issue, branch]` |
| `model` | string | Model override when skill is active. Session resumes normal model on next turn. Accepts `/model` values or `inherit`. | `model: claude-opus` |
| `effort` | string | Effort level override (`low`, `medium`, `high`, `xhigh`, `max`). Depends on model availability. | `effort: max` |
| `paths` | string/list | Glob patterns limiting activation. Skill auto-loads only for matching files. | `paths: ["**/*.rs", "**/*.go"]` |
| `version` | string | Plugin skill version (used in plugin `plugin.json`, not in standalone skills). | `version: 0.4.0` |
| `hooks` | object | Lifecycle hooks scoped to skill (rarely used). | (See hooks documentation) |
| `shell` | string | Shell for `` !`command` `` injection: `bash` (default) or `powershell`. | `shell: bash` |

**Sources:**
- https://code.claude.com/docs/en/skills#frontmatter-reference — Complete field specification
- Local example (detailed frontmatter): `/home/vadym/.claude/plugins/cache/slidev-dev-marketplace/slidev/0.1.0/skills/slide-management/SKILL.md` (lines 1-4)

---

## 2. Discovery and Loading: Where Skills Live and How Claude Finds Them

### Storage Hierarchy (Precedence)

Skills can live at multiple levels. When a skill name is shared, precedence is:

1. **Enterprise** (managed settings) — organization-wide
2. **Personal** `~/.claude/skills/<skill-name>/SKILL.md` — all projects
3. **Project** `.claude/skills/<skill-name>/SKILL.md` — current project only
4. **Plugin** `<plugin-dir>/skills/<skill-name>/SKILL.md` — namespaced as `/plugin-name:skill-name`
5. **Additional directories** (via `--add-dir`) — `.claude/skills/` within added dirs auto-loads (exception to normal config loading)

**Live change detection:** Editing `.claude/skills/` or project `.claude/skills/` during a session takes effect immediately without restart. Creating a brand-new skills directory requires restart.

**Sources:**
- https://code.claude.com/docs/en/skills#where-skills-live — Storage locations and priority table
- https://code.claude.com/docs/en/skills#skills-from-additional-directories — Additional directory loading

### How Claude Decides to Invoke a Skill

Claude's skill selection logic:

1. **Description in context always.** Claude receives all skill names + descriptions (metadata), loaded into context to know what's available.
2. **Full content loads only when invoked.** Skill's SKILL.md body enters conversation only when triggered (saves tokens).
3. **Auto-trigger rules:**
   - Claude reads `description` (and `when_to_use` if present, combined capped at ~1,536 chars)
   - If the user's request matches the description semantically, Claude considers invoking the skill
   - **Important caveat:** Claude only invokes skills for tasks it can't easily handle alone (simple one-step tasks often don't trigger despite matching description)
   - Skills with `disable-model-invocation: true` are hidden from Claude entirely (description not in context)
   - Skills with `user-invocable: false` are always in Claude's context for reference, but hidden from user's `/` menu

4. **Subagent preloading.** When a skill is marked `context: fork`, the full SKILL.md content becomes the subagent's task prompt (not loaded into main context).

**Sources:**
- https://code.claude.com/docs/en/skills#control-who-invokes-a-skill — Invocation control table
- https://code.claude.com/docs/en/skills#skill-content-lifecycle — When content loads
- https://code.claude.com/docs/en/skills#troubleshooting — Why skills don't trigger

---

## 3. Triggers: How to Write Descriptions That Work

### Description Writing Best Practices

The `description` field is the primary mechanism Claude uses to decide whether to invoke a skill. Key principles:

**Front-load the key use case:**
- Start with the most important trigger phrase
- Use language users would naturally say
- Include specific keywords and contexts
- Example (from skill-creator docs): "How to build a simple fast dashboard to display internal Anthropic data. **Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'**"

**Include concrete contexts:**
- Don't: "Explain code" (too vague)
- Do: "Explains code with visual diagrams and analogies. Use when explaining how code works, teaching about a codebase, or when the user asks 'how does this work?'"

**Be "pushy" about triggering:**
- Combat Claude's tendency to under-trigger skills
- Use action verbs and specific scenarios
- Name both WHAT the skill does AND WHEN to use it

**Combine description + when_to_use carefully:**
- Both are concatenated and cap at 1,536 characters in the skill list
- Maximize impact within this budget
- Trim unnecessary words; be concise

**High-variance queries test triggering:**
- Casual phrasing, abbreviations, typos, local context
- Explicit vs. implicit requests ("add a column" vs. "I need profit margin")
- Adjacent domains (where skill could apply but another is better)
- Well-written descriptions handle these edge cases

**Sources:**
- https://code.claude.com/docs/en/skills#frontmatter-reference — "`description` helps Claude decide when to load it automatically"
- `/home/vadym/.claude/plugins/cache/claude-plugins-official/skill-creator/unknown/skills/skill-creator/SKILL.md` (lines 62–67) — "make the skill descriptions a little bit 'pushy'"
- `/home/vadym/.claude/plugins/cache/slidev-dev-marketplace/slidev/0.1.0/skills/slide-management/SKILL.md` (line 3) — Example of aggressive, context-rich description

### Red Flags for Descriptions

Signs a description needs work:

1. **Missing keywords** — User wouldn't naturally phrase the trigger this way
2. **Too generic** — "Helpful tips" vs. "When working with REST APIs, always use this skill for endpoint design"
3. **Too narrow** — "Fix bugs in TypeScript files only" (overfits to examples; doesn't generalize)
4. **No action verb** — Passive descriptions don't trigger well
5. **Buried use case** — Key trigger info comes after secondary details

**Sources:**
- https://code.claude.com/docs/en/skills#troubleshooting — Skill not triggering / triggers too often

---

## 4. Progressive Disclosure: Keeping SKILL.md Focused

### Three-Level Loading System

Skills use progressive disclosure to minimize token cost:

| Level | Content | When loaded | Size guideline |
|-------|---------|-------------|-----------------|
| **Metadata** | Name + description | Always in context | ~100 words |
| **SKILL.md body** | Main instructions | When skill triggers (invoked manually or by Claude auto-detection) | <500 lines ideal |
| **Supporting files** | References, scripts, assets | As-needed (only when referenced in SKILL.md or when Claude/user requests) | Unlimited |

**Key pattern:** Keep `SKILL.md` under 500 lines. If approaching limit, add a second layer with clear pointers.

### Structure for Large Skills

**Domain-organized references (skills supporting multiple frameworks/platforms):**

```
cloud-deploy/
├── SKILL.md (workflow overview + framework selection logic)
└── references/
    ├── aws.md (detailed AWS steps)
    ├── gcp.md (detailed GCP steps)
    └── azure.md (detailed Azure steps)
```

Claude reads only the relevant reference file, not all three.

**Supporting file best practices:**
- Reference files clearly from SKILL.md with guidance on when to read them
- For files >300 lines, include a table of contents
- Use `[reference.md](reference.md)` markdown links so Claude knows when to load them
- Keep scripts in `scripts/` directory; reference and execute, don't embed full code

**Sources:**
- https://code.claude.com/docs/en/skills#add-supporting-files — Progressive disclosure patterns
- https://code.claude.com/docs/en/skills#skill-content-lifecycle — Context loading details
- `/home/vadym/.claude/plugins/cache/claude-plugins-official/skill-creator/unknown/skills/skill-creator/SKILL.md` (lines 87–109) — "Progressive Disclosure" section

---

## 5. Tool Restrictions: allowed-tools and Isolation

### Pre-Approving Tools with allowed-tools

The `allowed-tools` field grants permission for listed tools **only while the skill is active**. Does not restrict tools—permission settings still govern.

```yaml
---
name: deploy
allowed-tools: Bash(git add *) Bash(git commit *) Read
---
```

**Semantics:**
- Claude can use listed tools without per-use approval prompts when this skill is invoked
- All other tools still require approval (or are blocked by your permission settings)
- Permission rules override `allowed-tools`: a denied tool cannot be pre-approved
- When skill finishes, normal permission rules resume

**Token implication:** Pre-approving frequent tools (Read, Bash) can reduce permission-prompt overhead in long skill invocations.

**Syntax:** `ToolName(matcher-pattern)` or `ToolName` for entire tool. Patterns use glob syntax: `Bash(npm *)`.

**Sources:**
- https://code.claude.com/docs/en/skills#pre-approve-tools-for-a-skill — Field specification
- https://code.claude.com/docs/en/skills#restrict-claudes-skill-access — Permission interaction

### Subagent and context: fork Isolation

Setting `context: fork` in a skill's frontmatter runs the skill in an isolated subagent context:

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---
```

**Behavior:**
- Skill content becomes the subagent's task prompt (not loaded into main conversation)
- Subagent has no access to conversation history
- `agent` field determines environment (model, tools, permissions)
- Results summarized and returned to main conversation
- Skill content does not persist in main context after completion

**Use case:** Resource-intensive research, isolated code analysis, or tasks that shouldn't contaminate main conversation context.

**Sources:**
- https://code.claude.com/docs/en/skills#run-skills-in-a-subagent — Subagent execution
- https://code.claude.com/docs/en/skills#restrict-claudes-skill-access — Access control details

---

## 6. Distribution: Project vs. User vs. Plugin

### Three Distribution Scopes

| Scope | Location | Installation | Skill name | Use case |
|-------|----------|--------------|-----------|----------|
| **Project** | `.claude/skills/<name>/SKILL.md` | Commit to repo | `/skill-name` | Team workflows, version-controlled customizations |
| **User/Personal** | `~/.claude/skills/<name>/SKILL.md` | Manual copy or script | `/skill-name` | Personal across all projects |
| **Plugin** | `<plugin>/skills/<name>/SKILL.md` | Plugin install system | `/plugin-name:skill-name` | Distribute to community, marketplace, teams |

### Plugin Structure for Skills

Every plugin must have:

1. **Manifest** at `.claude-plugin/plugin.json`:
   ```json
   {
     "name": "my-plugin",
     "description": "Brief description",
     "version": "1.0.0",
     "author": { "name": "You" }
   }
   ```

2. **Skills directory** at `skills/` (plugin root):
   ```
   my-plugin/
   ├── .claude-plugin/
   │   └── plugin.json
   └── skills/
       └── skill-name/
           └── SKILL.md
   ```

**Plugin skills are namespaced** (e.g., `/my-plugin:hello`) to prevent naming conflicts across plugins.

**Version management:**
- If you set explicit `version` in `plugin.json`, users only see updates when you bump it
- If omitted, commit SHA becomes version (every commit = new version)
- Allows semantic versioning and staged rollouts

**Sources:**
- https://code.claude.com/docs/en/plugins#create-your-first-plugin — Quickstart, manifest schema
- https://code.claude.com/docs/en/plugins#create-plugins — Directory structure warning: "Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`"
- https://code.claude.com/docs/en/plugins#add-skills-to-your-plugin — Plugin skill anatomy

---

## 7. Debugging: Verifying Skills Load and Why They Don't Trigger

### Checking if a Skill Loaded

**In Claude Code session:**

1. Type `/` and see if your skill appears in autocomplete
   - If visible and not marked "disabled," skill loaded successfully
   - If not visible, check paths (directory structure, naming)

2. Use `/help` and search for skill name

3. For plugin skills, use `/reload-plugins` after editing to pick up changes mid-session

**Common issues:**

| Problem | Cause | Solution |
|---------|-------|----------|
| Skill not in `/` menu | Directory name wrong, or SKILL.md missing | Check `.claude/skills/<skill-name>/SKILL.md` exists |
| `/` shows skill but disabled | `disable-model-invocation: true` set (intentional) | This is correct for manual-only workflows |
| Plugin skill not loaded | Plugin not installed or cached | Use `/reload-plugins`, or reinstall via marketplace |
| Changes don't apply | Skill file edited but session started before | Restart Claude Code; `.claude/skills/` changes auto-reload in-session |

### Why a Skill Doesn't Trigger Automatically

**Diagnosis checklist:**

1. **Check the description** — Does it match natural user language? Is it specific enough?
   - Test: Rephrase request to exactly match description keywords
   - If it triggers then, description needs work

2. **Verify skill isn't intentionally disabled:**
   ```bash
   grep -E "disable-model-invocation|user-invocable" .claude/skills/<name>/SKILL.md
   ```
   - `disable-model-invocation: true` → Claude can't auto-invoke (only `/name` works)
   - `user-invocable: false` → Claude can invoke but hidden from menu

3. **Check `paths` glob restrictions:**
   ```yaml
   paths: ["**/*.rs"]  # Only triggers for Rust files
   ```
   - If set, skill only auto-loads when working with matching files

4. **Test manual invocation:**
   - Try `/skill-name` explicitly
   - If manual invocation works, skill is loaded; problem is description matching

5. **Claude undertriggers by design:**
   - Simple one-step tasks Claude can handle alone don't trigger skills (e.g., "read this file")
   - Complex, multi-step, specialized tasks reliably trigger
   - Make test prompts substantive enough to benefit from skill

6. **Character budget limits:**
   - If you have many skills, descriptions may be truncated to fit context budget (~1% of window, default 8,000 chars)
   - Solution: Trim description; front-load key phrase; increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var

**Sources:**
- https://code.claude.com/docs/en/skills#troubleshooting — Complete troubleshooting section
- https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short — Budget explanation and workaround

---

## 8. Real-World Examples: Good Patterns

### Example 1: brainstorming (Process Skill)

**File:** `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md`

**Key patterns:**
- **Aggressive description:** "You MUST use this before any creative work..." (enforces process)
- **Structured checklist:** 9 numbered steps, clear decision points (flowchart included)
- **HARD-GATE enforcement:** "Do NOT invoke any implementation skill... until approved"
- **Scope:** Large (~165 lines), but fully focused on brainstorming workflow
- **No supporting files needed:** Instructions self-contained

**Takeaway:** Process skills can be prescriptive and override defaults. Descriptions use imperative language to signal importance.

### Example 2: slide-management (Complex Interactive Skill)

**File:** `/home/vadym/.claude/plugins/cache/slidev-dev-marketplace/slidev/0.1.0/skills/slide-management/SKILL.md`

**Key patterns:**
- **MANDATORY description:** "**MANDATORY USE - ALWAYS INVOKE THIS SKILL**..." (triggers even when subtle)
- **Version field:** `version: 0.4.0` (plugin versioning)
- **Progressive disclosure:** Main skill body explains workflow; sub-steps reference specific tools
- **Tool integration:** Bash calls to manage-slides.py script with detailed syntax
- **Position vs. index conversion:** Handles user confusion about slide numbering
- **Interactive flow:** Step-by-step questions with explicit error handling
- **Large but necessary:** ~750 lines, but fully detailed (tool implementation guide)

**Takeaway:** Complex workflows benefit from step-by-step instructions with tool syntax and example interactions shown in detail.

### Example 3: caveman-help (Lightweight Reference)

**File:** `/home/vadym/.claude/plugins/cache/caveman/caveman/c2ed24b3e5d4/skills/caveman-help/SKILL.md`

**Key patterns:**
- **One-shot skill:** "Display this reference card when invoked. One-shot — do NOT change mode..."
- **Short frontmatter:** Name + simple description
- **Minimal body:** ~60 lines with two tables (modes and skills)
- **External links:** "Full docs: https://github.com/JuliusBrussee/caveman"
- **No supporting files:** All content inline, but concise

**Takeaway:** Small, reference-only skills stay lean. Tables are better than prose for quick lookup.

### Example 4: using-superpowers (Meta-Skill for Skill Invocation)

**File:** `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/using-superpowers/SKILL.md`

**Key patterns:**
- **Gate condition:** `<SUBAGENT-STOP>` marker (don't run in subagents)
- **Imperative enforcement:** `<EXTREMELY-IMPORTANT>` tags and all-caps statements
- **Priority rules:** Explicit instruction priority table (user > superpowers > default)
- **Red flags table:** Lists thoughts that signal rationalizing away skills
- **Flowchart:** Graphviz digraph showing decision flow
- **Governance:** Skills override defaults, but user instructions always win

**Takeaway:** Meta-skills about process or tool use need clear authority statements and decision flowcharts. Can override defaults explicitly when properly framed.

**Sources:**
- All examples read from local file paths in `.claude/plugins/cache/`

---

## 9. Versioning and Recent Changes

### Version Management

**For standalone skills and project skills:** No versioning field. Updates happen in-place.

**For plugin skills:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0"
}
```

- Set `version` for semantic versioning control
- Omit for git-based versioning (commit SHA)
- Allows staged rollouts and backward compatibility

**Recent changes to skill format (as of latest docs):**

1. **Custom commands merged into skills** — Old `.claude/commands/deploy.md` and new `.claude/skills/deploy/SKILL.md` both create `/deploy`. Backward compatible.
2. **Nested directory discovery** — `.claude/skills/` in subdirectories (monorepos) auto-discovered
3. **Extended thinking support** — Include word "ultrathink" in skill content to enable extended thinking
4. **Dynamic context injection** — `` !`command` `` syntax for preprocessing (outputs replace placeholders before Claude sees skill)
5. **Subagent skill preloading** — Skills can be pre-injected into subagent startup

**Sources:**
- https://code.claude.com/docs/en/skills#custom-commands-have-been-merged-into-skills — Backward compat
- https://code.claude.com/docs/en/skills#inject-dynamic-context — Shell command injection
- https://code.claude.com/docs/en/skills#advanced-patterns — Extended thinking and subagent patterns

---

## 10. Token Cost and Performance Implications

### How Skill Loading Consumes Tokens

**Metadata phase (always):**
- Skill name + description loaded into every session
- Cost: ~50–150 tokens per skill (depending on description length)
- Unavoidable: all available skills are listed so Claude knows they exist

**Full SKILL.md content phase (when triggered):**
- Entire body enters conversation as single system message
- Cost: variable, depends on skill size (typical: 200–2,000 tokens)
- Timing: when skill is invoked (manual `/name` or auto-detected by Claude)
- Loaded once per session; re-attached after auto-compaction (first 5,000 tokens preserved)

**Supporting files (as-needed):**
- Only loaded if referenced from SKILL.md and Claude/user requests
- Cost: paid only when accessed
- Pattern: Keep main SKILL.md <500 lines; offload large references

**Auto-compaction implications:**
- When context fills, Claude Code auto-summarizes and re-injects recently-used skills
- Each re-injected skill budget: 25,000 tokens shared across all invoked skills
- Most-recent skills prioritized; older skills may be dropped if many invoked
- Strategy: Re-invoke a skill mid-session to restore full content if it seems to stop working

**Optimization strategies:**

1. **Trim descriptions** — Fewer keywords = smaller metadata footprint
2. **Progressive disclosure** — References in separate files defer cost
3. **Reuse supporting files** — If multiple test cases need same script, bundle it in `scripts/`
4. **Avoid large inline examples** — Use `examples.md` reference instead
5. **Monitor re-invocations** — If skill seems to lose effect after compaction, re-invoke to restore

**Sources:**
- https://code.claude.com/docs/en/skills#skill-content-lifecycle — Compaction and token retention
- https://code.claude.com/docs/en/skills#add-supporting-files — Token efficiency of progressive disclosure

---

## 11. Open Questions and Unverified Claims

**Items mentioned in conversations but not explicitly documented in official docs or skill files:**

1. **UNVERIFIED** — Exact token cost threshold for triggering auto-compaction. Docs say "when context fills up" but no specific token count provided.

2. **UNVERIFIED** — Whether Claude's skill selection uses embedding similarity or keyword matching for description matching. Behavior suggests keyword-based with semantic context, but mechanism not documented.

3. **UNVERIFIED** — How Claude ranks multiple applicable skills. Do older skills (earlier in list) have advantage, or is ranking purely relevance-based?

4. **UNVERIFIED** — Whether skill descriptions are re-indexed after edits in same session, or if old metadata persists until restart.

5. **UNVERIFIED** — Token cost of `allowed-tools` pre-approval (whether it consumes tokens vs. just changing permission flow).

---

## References and Doc Links

**Official Claude Code Docs:**
- Skills overview: https://code.claude.com/docs/en/skills
- Plugins (skills distribution): https://code.claude.com/docs/en/plugins
- Agent Skills standard: https://agentskills.io (open format specification)

**Local Skill Examples:**
- Brainstorming skill (process): `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md`
- Slide management (complex): `/home/vadym/.claude/plugins/cache/slidev-dev-marketplace/slidev/0.1.0/skills/slide-management/SKILL.md`
- Skill creator (meta): `/home/vadym/.claude/plugins/cache/claude-plugins-official/skill-creator/unknown/skills/skill-creator/SKILL.md`
- Using superpowers (governance): `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/using-superpowers/SKILL.md`

**Depth of Research:**
- 4 official documentation pages (code.claude.com, platform.claude.com) fetched and reviewed
- 4 detailed local skill implementations read and analyzed
- Frontmatter fields, loading behavior, and distribution patterns verified against multiple sources
- Progressive disclosure, triggering, and token costs documented with source citations
- All factual claims tied to doc URL or file path

---

**Document Status:** Ready for slide generation, exercises, and handout creation.  
**Verification:** Every claim includes source (doc URL or file path). Open questions marked UNVERIFIED.
