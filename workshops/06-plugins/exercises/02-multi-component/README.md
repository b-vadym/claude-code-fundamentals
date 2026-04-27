# Вправа 2 — skill + command + agent

**Мета:** додати у `git-toolkit` три компоненти: skill (з directory + SKILL.md), command (плоский .md), agent (з frontmatter і tools).

**Час:** 12 хв

**Передумова:** вправа 1 виконана, є `git-toolkit/.claude-plugin/plugin.json` з `name: git-toolkit`.

## Кроки

### 1. Skill: `status-summary/SKILL.md`

```bash
mkdir -p starter/git-toolkit/skills/status-summary
```

`starter/git-toolkit/skills/status-summary/SKILL.md`:

```markdown
---
description: Use when user asks for current git working tree state,
  what's staged, modified, or untracked. Show grouped summary.
allowed-tools: [Bash]
---

# git-toolkit:status-summary

Run `git status --short --branch` and present:

1. **Branch line** — name, ahead/behind
2. **Staged** (lines starting with `M `, `A `, `D `)
3. **Unstaged** (` M`, ` D`)
4. **Untracked** (`??`)

Group within each section by file extension.
Highlight files >100 KB with a ⚠️ note.
```

### 2. Command: `commands/log-stats.md`

```markdown
---
description: Show commit count by author for the last 30 days
allowed-tools: [Bash]
---

Run `git shortlog -sn --since="30 days ago"` and format the output as a markdown table with columns: Author, Commits.

If the repository has no commits in that range, return "(no commits in last 30 days)".
```

### 3. Agent: `agents/commit-message-reviewer.md`

```markdown
---
name: commit-message-reviewer
description: Reviews staged commit message for clarity, length, and conventional-commit format
tools: Bash, Read, Grep
model: sonnet
effort: low
---

You are a commit-message reviewer. Read the staged message via:

```bash
git log -1 --format=%B HEAD
```

Check:

- **Subject line** ≤ 72 characters, imperative mood (e.g., "Add", not "Added")
- **No WIP/junk markers** ("wip", "fixup", "tmp", "asdf")
- **Conventional Commits** format if the project uses it (look at last 10 commits to detect)

Output: short diagnosis + concrete rewrite suggestion if needed.
```

### 4. Перевір

```bash
claude plugin validate ./git-toolkit
claude --plugin-dir ./git-toolkit
```

У сесії перевір:

- `/git-toolkit:status-summary` — у `/`-меню ✅
- `/git-toolkit:log-stats` — у `/`-меню ✅
- `/agents` → `git-toolkit:commit-message-reviewer` — у списку ✅

## Чек-перевірки

- [ ] Skill — це **директорія** `skills/status-summary/` з `SKILL.md` всередині
- [ ] Command — **плоский файл** `commands/log-stats.md`
- [ ] Agent — `agents/commit-message-reviewer.md` з `tools` і `model` у frontmatter
- [ ] Усі три з'являються у Claude Code під префіксом `git-toolkit:`

## Pitfalls

- ❌ `skills/status-summary.md` (плоский файл) — для skill-у потрібна **директорія**
- ❌ `commands/log-stats/log-stats.md` (директорія) — для command потрібен **плоский файл**
- ❌ Agent з `hooks:` або `mcpServers:` у frontmatter — silently rejected (security)
- ❌ Agent з `permissionMode:` — теж не дозволяється у плагіні

## Doc-посилання

- https://code.claude.com/docs/en/plugins#add-skills-to-your-plugin
- https://code.claude.com/docs/en/plugins-reference#skills
- https://code.claude.com/docs/en/plugins-reference#agents
