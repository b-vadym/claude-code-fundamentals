# Claude Code Plugins: Research Dossier

**For:** Ukrainian developer workshop on plugin authoring (deep dive: manifest → multi-component bundling → marketplace → versioning)
**Audience:** Developers who already know plugins exist and have installed at least one. Workshop 04 covered basic packaging at the end; this one goes deeper.
**Date:** 2026-04-26

---

## 1. Plugin Manifest: `plugin.json` Schema

### Location

`<plugin-root>/.claude-plugin/plugin.json` — **only** `plugin.json` belongs inside `.claude-plugin/`. Components (`skills/`, `commands/`, `agents/`, `hooks/`) live at the plugin root, **not** inside `.claude-plugin/`.

**Source:** https://code.claude.com/docs/en/plugins-reference#plugin-directory-structure — "The `.claude-plugin/` directory contains the `plugin.json` file. All other directories (commands/, agents/, skills/, output-styles/, themes/, monitors/, hooks/) must be at the plugin root, not inside `.claude-plugin/`."

### Required vs Optional

If a manifest is present, only `name` is required. The manifest itself is **optional** — Claude Code auto-discovers components in default locations if absent and uses the directory name as the plugin name.

**Source:** https://code.claude.com/docs/en/plugins-reference#plugin-manifest-schema — "If you include a manifest, `name` is the only required field."

### Field Reference (verified against docs)

| Field | Type | Required | Purpose |
|-------|------|----------|---------|
| `name` | string | **Yes** | kebab-case unique identifier. Becomes namespace prefix: `/<name>:<component>` |
| `version` | string | No | Semver string. If set → users update only on bump. If omitted → git commit SHA = version |
| `description` | string | No | Brief purpose; shown in plugin manager |
| `author` | object | No | `{ name, email?, url? }` |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source repo URL |
| `license` | string | No | SPDX identifier (`MIT`, `Apache-2.0`) |
| `keywords` | array | No | Discovery tags |
| `skills` | string\|array | No | Custom path(s) — replaces default `skills/` |
| `commands` | string\|array | No | Custom path(s) — replaces default `commands/` |
| `agents` | string\|array | No | Custom path(s) — replaces default `agents/` |
| `hooks` | string\|array\|object | No | Path to hooks JSON or inline config |
| `mcpServers` | string\|array\|object | No | Inline MCP config or path |
| `lspServers` | string\|array\|object | No | Inline LSP config or path |
| `outputStyles` | string\|array | No | Custom output style files/dirs |
| `themes` | string\|array | No | Color theme files/dirs |
| `monitors` | string\|array | No | Background monitor configs |
| `userConfig` | object | No | Values prompted when plugin is enabled |
| `channels` | array | No | Message-channel declarations |
| `dependencies` | array | No | Other plugins required, with optional semver |

**Source:** https://code.claude.com/docs/en/plugins-reference#plugin-manifest-schema — full schema with type signatures.

### Minimal Example (verified)

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

**Source:** https://code.claude.com/docs/en/plugins#create-the-plugin-manifest

### Real local examples

- `code-simplifier`: `/home/vadym/.claude/plugins/cache/claude-plugins-official/code-simplifier/1.0.0/.claude-plugin/plugin.json` — minimal: name + version + description + author
- `visual-explainer`: `/home/vadym/.claude/plugins/cache/visual-explainer-marketplace/visual-explainer/0.6.2/.claude-plugin/plugin.json` — adds repository + license

---

## 2. Directory Layout Rules

### Standard plugin root structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        ← ONLY plugin.json here
├── skills/                ← skill dirs with SKILL.md inside
│   └── <name>/SKILL.md
├── commands/              ← flat .md files (legacy alias for skills)
│   └── <name>.md
├── agents/                ← subagent definitions, .md files
│   └── <name>.md
├── hooks/
│   └── hooks.json         ← event handlers config
├── .mcp.json              ← MCP server config (root level, hidden)
├── .lsp.json              ← LSP server config (root level, hidden)
├── monitors/
│   └── monitors.json
├── bin/                   ← executables added to Bash $PATH while plugin enabled
├── settings.json          ← default settings (only `agent` and `subagentStatusLine` keys)
└── scripts/               ← arbitrary helper scripts (referenced from hooks/MCP/etc)
```

**Source:** https://code.claude.com/docs/en/plugins-reference#standard-plugin-layout

### Pitfall: components inside `.claude-plugin/`

**Source:** https://code.claude.com/docs/en/plugins#plugin-structure-overview — "**Common mistake**: Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside the `.claude-plugin/` directory. Only `plugin.json` goes inside `.claude-plugin/`."

### `commands/` vs `skills/`

Both produce `/<plugin-name>:<component-name>`. New plugins should use `skills/` (directories with `SKILL.md`); `commands/` is legacy support for flat `.md` files.

**Source:** https://code.claude.com/docs/en/plugins-reference#file-locations-reference — "Skills as flat Markdown files. Use `skills/` for new plugins."

---

## 3. Bundling Multiple Components

### Skills

Each skill = directory under `skills/` with a `SKILL.md`. Frontmatter `description` drives auto-invocation. Plugin skills are namespaced: `/<plugin>:<skill>`.

**Source:** https://code.claude.com/docs/en/plugins#add-skills-to-your-plugin

### Agents

Subagent files in `agents/<name>.md` with YAML frontmatter:

```yaml
---
name: code-reviewer
description: Reviews code for bugs, logic errors, security issues
tools: Glob, Grep, Read, WebFetch
model: sonnet
---

You are an expert code reviewer...
```

**Supported plugin-agent frontmatter fields:** `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`. Only valid `isolation` value is `"worktree"`. **Not allowed for plugin agents** (security): `hooks`, `mcpServers`, `permissionMode`.

**Source:** https://code.claude.com/docs/en/plugins-reference#agents

**Real example:** `/home/vadym/.claude/plugins/cache/claude-plugins-official/feature-dev/unknown/agents/code-reviewer.md`

### Hooks

`hooks/hooks.json` at plugin root. Same JSON format as user-level hooks in `settings.json`.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-edits.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook types:** `command`, `http`, `mcp_tool`, `prompt`, `agent`.

**Hook events** (full table in docs): `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SessionEnd`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PostCompact`, `Notification`, `FileChanged`, `CwdChanged`, etc.

**Source:** https://code.claude.com/docs/en/plugins-reference#hooks

**Real example:** `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/hooks.json` — uses `${CLAUDE_PLUGIN_ROOT}` to reference a script bundled in the plugin.

### Plugin path variables

- **`${CLAUDE_PLUGIN_ROOT}`** — absolute path to plugin install dir; **changes on update**, files written here don't survive
- **`${CLAUDE_PLUGIN_DATA}`** — persistent state dir at `~/.claude/plugins/data/{id}/`; survives updates; auto-created on first reference

Both are substituted inline in skill content, agent content, hook commands, monitor commands, MCP/LSP configs. Both are exported as env vars to subprocesses.

**Source:** https://code.claude.com/docs/en/plugins-reference#environment-variables

---

## 4. Versioning Strategy

### Resolution order (verified)

Claude Code resolves the plugin's version from the first set:

1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for `github`, `url`, `git-subdir`, and relative-path sources in a git-hosted marketplace)
4. `unknown` (for `npm` sources or local dirs not in a git repo)

**Source:** https://code.claude.com/docs/en/plugins-reference#version-management

### Two strategies

| Approach | How | Update behavior | Best for |
|----------|-----|------------------|----------|
| **Explicit semver** | `"version": "2.1.0"` in `plugin.json` | Users update only on bump. Pushing commits without bumping does nothing | Published plugins, stable cycles |
| **Commit-SHA** | Omit `version` everywhere | Every new commit = new version, users get updates automatically | Internal/team plugins, active dev |

**Pitfall:** Setting `version` and never bumping it means users never receive updates. Pushing new commits is **not** enough — Claude Code sees the same string and keeps the cached copy.

**Pitfall:** Don't set `version` in **both** `plugin.json` and the marketplace entry. The `plugin.json` value silently wins, so a stale manifest can mask a new marketplace version.

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#version-resolution-and-release-channels

### Release channels

Two marketplaces pointing at the same repo with different `ref` (e.g. `stable` vs `latest`) → assign each marketplace to a different user group via managed settings. Each channel must resolve to a different version (different SHA or different explicit `version`).

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#set-up-release-channels

---

## 5. Namespaced Invocation

Plugin skills/commands always invoke as `/<plugin-name>:<skill-name>`. Plugin agents appear in `/agents` as `<plugin-name>:<agent-name>`.

**Source:** https://code.claude.com/docs/en/plugins#create-your-first-plugin — "**Why namespacing?** Plugin skills are always namespaced (like `/my-first-plugin:hello`) to prevent conflicts when multiple plugins have skills with the same name."

To change the namespace, change the `name` field in `plugin.json`.

---

## 6. Installation Paths

### Local path (development)

```bash
claude --plugin-dir ./my-plugin
```

Loads the plugin directly **for that session only**. Multiple `--plugin-dir` flags allowed. When a `--plugin-dir` plugin shares a name with an installed marketplace plugin, the local copy wins for that session.

**Source:** https://code.claude.com/docs/en/plugins#test-your-plugins-locally

### Local marketplace (testing distribution flow)

```bash
/plugin marketplace add ./my-marketplace
/plugin install my-plugin@my-marketplace
```

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#walkthrough-create-a-local-marketplace

### GitHub source (as marketplace entry)

```json
{
  "name": "my-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo",
    "ref": "v2.0.0",
    "sha": "a1b2c3..."
  }
}
```

`ref` = branch/tag (optional). `sha` = full 40-char commit SHA pin (optional).

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#github-repositories

### Other plugin sources (in marketplace.json)

| Source | Required fields | Use |
|--------|-----------------|-----|
| Relative path (string `./...`) | none | Plugin in same repo as marketplace |
| `github` | `repo`; `ref?`, `sha?` | GitHub-hosted plugin |
| `url` | `url`; `ref?`, `sha?` | Any git URL (GitLab, Bitbucket, self-hosted) |
| `git-subdir` | `url`, `path`; `ref?`, `sha?` | Plugin lives in subdir of monorepo (sparse clone) |
| `npm` | `package`; `version?`, `registry?` | npm package |

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#plugin-sources

### CLI commands (non-interactive)

```bash
claude plugin install <plugin>@<marketplace> [--scope user|project|local]
claude plugin uninstall <plugin>@<marketplace> [--keep-data]
claude plugin enable <plugin>@<marketplace>
claude plugin disable <plugin>@<marketplace>
claude plugin update <plugin>@<marketplace>
claude plugin list [--json] [--available]
claude plugin validate .             # validate plugin or marketplace
claude plugin tag [--push] [--dry-run]   # create release git tag
claude plugin marketplace add <source> [--scope ...] [--sparse ...]
claude plugin marketplace list
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

**Source:** https://code.claude.com/docs/en/plugins-reference#cli-commands-reference

---

## 7. Marketplace File Schema

### Location

`<marketplace-repo>/.claude-plugin/marketplace.json` at the marketplace repo root.

### Required fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | kebab-case marketplace ID. Public-facing: `/plugin install <plugin>@<marketplace-name>` |
| `owner` | object | Maintainer info: `name` (required), `email` (optional) |
| `plugins` | array | Plugin entries |

**Reserved names** (cannot use): `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`. Names impersonating official marketplaces (`official-claude-plugins`, etc.) also blocked.

### Optional metadata fields

- `metadata.description`
- `metadata.version`
- `metadata.pluginRoot` — base dir prepended to relative plugin sources (e.g. `"./plugins"` lets you write `"source": "formatter"` instead of `"source": "./plugins/formatter"`)
- `allowCrossMarketplaceDependenciesOn` — array of marketplaces this one's plugins may depend on

### Plugin entry: required fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | kebab-case plugin ID |
| `source` | string\|object | Where to fetch (see sources table above) |

### Plugin entry: optional fields

`description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict` (bool, default `true`).

Plus component-config fields: `skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`.

**Strict mode:**
- `strict: true` (default) — `plugin.json` is authority; marketplace entry can supplement
- `strict: false` — marketplace entry is full definition; plugin must NOT have its own `plugin.json` declaring components (conflict → load fails)

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#marketplace-schema and `#strict-mode`

### Verified minimal marketplace example

```json
{
  "name": "my-plugins",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "quality-review-plugin",
      "source": "./plugins/quality-review-plugin",
      "description": "Adds a /quality-review skill"
    }
  ]
}
```

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#walkthrough-create-a-local-marketplace

### Hosting

- **GitHub** (recommended): `claude plugin marketplace add owner/repo` or `/plugin marketplace add owner/repo`
- **Other git** (GitLab, Bitbucket, self-hosted): full URL
- **Direct URL to `marketplace.json`**: works but **relative-path plugin sources break** (only the JSON is downloaded, not the rest of the repo) — use `github`/`url`/`git-subdir`/`npm` sources instead
- **Local path**: for testing — `/plugin marketplace add ./my-marketplace`

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#host-and-distribute-marketplaces

---

## 8. Installation Scopes

| Scope | Settings file | Use case |
|-------|--------------|----------|
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins, version-controlled |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Org-administered, read-only |

**Source:** https://code.claude.com/docs/en/plugins-reference#plugin-installation-scopes

---

## 9. Common Pitfalls (verified)

1. **Components inside `.claude-plugin/`** — they must be at plugin root. Only `plugin.json` belongs in `.claude-plugin/`. `claude --debug` reports skill/agent/hook directories not loaded.
   - Source: https://code.claude.com/docs/en/plugins#plugin-structure-overview

2. **Setting `version` and not bumping** — users keep cached copy on every commit. Either bump or omit.
   - Source: https://code.claude.com/docs/en/plugins-reference#version-management

3. **Setting `version` in both `plugin.json` AND marketplace entry** — `plugin.json` silently wins. Stale manifest masks marketplace version.
   - Source: https://code.claude.com/docs/en/plugin-marketplaces#version-resolution-and-release-channels

4. **Hard-coded paths in hooks/MCP/scripts** — must use `${CLAUDE_PLUGIN_ROOT}`. Plugins are copied to a cache dir, so absolute paths from dev machine break post-install.
   - Source: https://code.claude.com/docs/en/plugins-reference#environment-variables

5. **Path traversal (`../shared-utils`)** — won't work after install. Plugin contents are copied to `~/.claude/plugins/cache`, files outside aren't copied. Use symlinks (preserved) or restructure.
   - Source: https://code.claude.com/docs/en/plugins-reference#path-traversal-limitations

6. **Hook script not executable** — `chmod +x scripts/your-hook.sh` and ensure shebang.
   - Source: https://code.claude.com/docs/en/plugins-reference#hook-troubleshooting

7. **Relative-path plugin sources in URL-based marketplaces** — marketplace added via direct `marketplace.json` URL doesn't pull repo contents → relative `./plugins/X` paths break. Use `github`/`url`/`git-subdir`/`npm` sources.
   - Source: https://code.claude.com/docs/en/plugin-marketplaces#plugins-with-relative-paths-fail-in-url-based-marketplaces

8. **Plugin agents trying to declare `hooks` / `mcpServers` / `permissionMode`** — silently rejected for security reasons.
   - Source: https://code.claude.com/docs/en/plugins-reference#agents

9. **Marketplace `name` collides with reserved Anthropic names** — listed in section 7 above. Validation rejects.
   - Source: https://code.claude.com/docs/en/plugin-marketplaces#marketplace-schema

10. **Plugin not appearing after install** — run `/plugin validate .` (or `claude plugin validate .`) to check JSON + frontmatter; run `claude --debug` to see loading messages.
    - Source: https://code.claude.com/docs/en/plugins-reference#debugging-and-development-tools

---

## 10. Workshop 04 vs 06 Boundary

Workshop 04 already covered:
- Basic `plugin.json` with name+description+version+author (minimal)
- `skills/` directory with single skill
- `claude plugin install ./path` (local install)
- Namespaced invocation `/plugin:skill`
- Versioning: explicit vs commit-SHA (mentioned briefly)

Workshop 06 goes deeper:
- **Multi-component bundling** (skills + commands + hooks + agents in one plugin)
- **`hooks/hooks.json`** format and event reference
- **Plugin agents** with proper frontmatter (and what's banned)
- **`marketplace.json`** schema and hosting
- **`/plugin marketplace add`** + `/plugin install <plugin>@<marketplace>`
- **Plugin sources reference** (relative, github, url, git-subdir, npm)
- **`${CLAUDE_PLUGIN_ROOT}`** and `${CLAUDE_PLUGIN_DATA}` patterns
- **Versioning strategy** in depth (release channels, dual-version pitfall)
- **Strict mode** for marketplace entries
- **Validation tooling** (`claude plugin validate`)
- **Installation scopes** (user/project/local/managed)

---

## 11. Open Questions / UNVERIFIED

1. **UNVERIFIED** — Whether `/plugin install ./path` (without `--scope` and without a marketplace) works as a one-shot bare install. Docs only cover `--plugin-dir` for local dev and `/plugin install <name>@<marketplace>` for marketplace installs. Workshop 04 slides show `claude plugin install ./my-git-toolkit` but I cannot find this form documented; treating as legacy or imprecise. **For workshop 06 we use the documented forms only:** `claude --plugin-dir ./X` for local dev, `/plugin marketplace add ./marketplace` + `/plugin install <plugin>@<marketplace>` for distribution flow.

2. **UNVERIFIED** — Exact ordering when both `${CLAUDE_PLUGIN_ROOT}` and `${user_config.X}` substitutions appear in the same hook command string. Likely standard variable substitution, but no spec confirms order.

3. **UNVERIFIED** — Whether `/plugin update <name>@<marketplace>` works without internet when only `--scope local` plugins are installed.

---

## 12. References

**Primary docs (all fetched and reviewed):**
- https://code.claude.com/docs/en/plugins — Create plugins (quickstart + complex plugins)
- https://code.claude.com/docs/en/plugin-marketplaces — Create and distribute marketplaces
- https://code.claude.com/docs/en/plugins-reference — Complete schemas, CLI, debugging
- https://code.claude.com/docs/en/skills — Skills (referenced from workshop 04)
- https://code.claude.com/docs/en/sub-agents — Agent details

**Local plugin examples examined:**
- `/home/vadym/.claude/plugins/cache/claude-plugins-official/code-simplifier/1.0.0/.claude-plugin/plugin.json` — minimal manifest
- `/home/vadym/.claude/plugins/cache/visual-explainer-marketplace/visual-explainer/0.6.2/.claude-plugin/plugin.json` — with repository/license
- `/home/vadym/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/hooks.json` — real hook with `${CLAUDE_PLUGIN_ROOT}`
- `/home/vadym/.claude/plugins/cache/claude-plugins-official/feature-dev/unknown/agents/code-reviewer.md` — real plugin agent

**Document Status:** Ready for slide generation, exercises, handout. All claims tied to URL or local file path. Open questions marked UNVERIFIED.
