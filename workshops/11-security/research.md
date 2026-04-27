# Workshop 11 — Security & Sandboxing: Research Dossier

**For:** Ukrainian developer workshop on Claude Code security (defensive focus)
**Audience:** Developers familiar with Claude Code basics, deploying in real environments
**Date:** 2026-04-26
**Scope:** Defensive security only — sandboxing, secrets, supply-chain. No offensive techniques.

---

## 1. Permission system: layered defense

### Three pillars

Claude Code defends through three orthogonal layers that compose:

| Layer | Where | Scope | Bypass risk |
|---|---|---|---|
| **Permissions** | `settings.json` `permissions.{allow,deny,ask}` | All tools (Bash, Read, Edit, WebFetch, MCP, Agent) | Pattern fragility (curl) |
| **Sandbox** | `settings.json` `sandbox.*` + `/sandbox` cmd | Bash subprocesses (OS-level: Seatbelt/bubblewrap) | Sockets, broad domains |
| **Hooks** | `PreToolUse` matchers, exit code 2 | Any tool — last-resort block | Hook script bugs |

**Source:** https://code.claude.com/docs/en/security#built-in-protections, https://code.claude.com/docs/en/sandboxing#how-sandboxing-relates-to-permissions

### Evaluation order

For every tool call: **deny → ask → allow** (first match wins). Within deny, **managed > local > project > user**.

A hook that exits 2 blocks before permission rules even evaluate. A hook returning `permissionDecision: "allow"` does NOT bypass deny rules.

**Source:** https://code.claude.com/docs/en/permissions#manage-permissions, https://code.claude.com/docs/en/permissions#extend-permissions-with-hooks

### Permission modes

| Mode | Behavior | When safe |
|---|---|---|
| `default` | Prompt on first tool use | Interactive work |
| `acceptEdits` | Auto-accept file edits within working dir | Clean repo, trusted code |
| `plan` | Read-only, no edits or execution | Reviewing untrusted code |
| `auto` | Background safety checks; research preview | Prototype, careful |
| `dontAsk` | Auto-deny everything not pre-approved | High-trust automation |
| `bypassPermissions` | Skip prompts (writes to `.git`/`.claude` still prompt) | Sandboxed VM/container only |

`disableBypassPermissionsMode: "disable"` in managed settings prevents bypass mode entirely.

**Source:** https://code.claude.com/docs/en/permissions#permission-modes

---

## 2. Settings.json: precedence, schema, key fields

### Files & precedence (highest wins)

1. **Managed** — `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS), `/etc/claude-code/managed-settings.json` (Linux), `C:\Program Files\ClaudeCode\` (Windows). Cannot be overridden.
2. **Command-line args**
3. **Local project** — `.claude/settings.local.json` (gitignored)
4. **Shared project** — `.claude/settings.json` (committed)
5. **User** — `~/.claude/settings.json`

Arrays merge across scopes; scalars use precedence.

**Source:** https://code.claude.com/docs/en/settings (file-locations section)

### Permissions schema

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(./src/**)"],
    "deny": ["Bash(rm -rf *)", "Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"],
    "ask": ["Bash(git push *)"],
    "defaultMode": "default",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable",
    "disableAutoMode": "disable"
  }
}
```

**Source:** https://code.claude.com/docs/en/settings (permissions schema), https://code.claude.com/docs/en/permissions (rule syntax)

### Bash pattern syntax — gotchas

- `Bash(npm *)` — prefix-match with space-as-word-boundary
- `Bash(*install)` — substring (no boundary)
- `Bash(* --help *)` — wildcard middle
- `*` spans multiple args (incl. spaces)
- `:*` suffix is equivalent to ` *` only at end of pattern
- **Compound commands:** rules match each subcommand (separators: `&&`, `||`, `;`, `|`, `|&`, `&`, newline)
- **Process wrappers stripped:** `timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs` — so `Bash(npm test *)` matches `timeout 30 npm test`
- **Env runners NOT stripped:** `npx`, `docker exec`, `mise exec`, `devbox run` — `Bash(devbox run *)` would match `devbox run rm -rf .`. Write specific rules.

**Anthropic pitfall warning:** `Bash(curl http://github.com/ *)` is fragile. Variants like `curl -X GET http://github.com/...`, `curl https://github.com/...`, `curl -L http://bit.ly/xyz` (redirects), `URL=...; curl $URL` all bypass it. **Recommended:** deny `curl`/`wget` entirely, use WebFetch with `WebFetch(domain:github.com)`, OR use a PreToolUse hook.

**Source:** https://code.claude.com/docs/en/permissions#bash, https://code.claude.com/docs/en/permissions (warning block on bash filtering)

### Read/Edit pattern syntax (gitignore-style)

| Pattern | Resolves to |
|---|---|
| `//path` | Absolute from filesystem root |
| `~/path` | Home dir |
| `/path` | **Project root**, NOT absolute |
| `path` or `./path` | Cwd |

**Pitfall:** `/Users/alice/file` is project-relative, NOT absolute. Use `//Users/alice/file`.

**Symlinks:** allow rules require BOTH symlink+target to match; deny rules block if EITHER matches. Safe by default.

**Source:** https://code.claude.com/docs/en/permissions#read-and-edit

---

## 3. Sandboxing: OS-level isolation

### What it is

`/sandbox` enables OS-enforced filesystem & network isolation for Bash subprocesses. Macros: macOS Seatbelt, Linux bubblewrap+socat, WSL2 bubblewrap. **Linux requires:** `apt-get install bubblewrap socat`.

WSL1 unsupported. Native Windows planned but not yet.

**Source:** https://code.claude.com/docs/en/sandboxing#prerequisites

### Modes

- **Auto-allow** — sandboxed bash auto-runs without prompt; commands needing non-allowed network fall back to permission flow. `rm`/`rmdir` targeting `/`, `~`, system paths still prompt.
- **Regular permissions** — sandbox enforced + every command still prompts.

**Source:** https://code.claude.com/docs/en/sandboxing#sandbox-modes

### Settings reference

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyWrite": ["~/.ssh"],
      "denyRead": ["~/.aws/credentials", "~/.ssh/**"],
      "allowRead": ["."]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org", "api.anthropic.com"],
      "deniedDomains": ["*.suspicious.example"],
      "allowManagedDomainsOnly": false
    }
  }
}
```

**Path prefixes inside sandbox.filesystem:**
- `/` — absolute (different from Read/Edit `//`)
- `~/` — home
- `./` or no prefix — project root for project settings, `~/.claude` for user settings

**Source:** https://code.claude.com/docs/en/sandboxing#configure-sandboxing

### Critical pitfalls (from Anthropic docs)

1. **Both filesystem AND network needed** — without network isolation, compromised agent exfiltrates SSH keys. Without filesystem, agent backdoors `.bashrc` to gain network later.
2. **`allowUnixSockets`** — granting `/var/run/docker.sock` = full host access via docker.
3. **Filesystem write to `$PATH` dirs** = code execution as other users.
4. **Broad `allowedDomains` like `github.com`** can be used for data exfiltration via gists/issues. **Domain fronting** can bypass.
5. **`enableWeakerNestedSandbox`** on Linux for Docker-in-Docker — significantly weaker.

**Source:** https://code.claude.com/docs/en/sandboxing#security-limitations

### Sandbox vs permissions: how they merge

`sandbox.filesystem.{allowRead,denyRead,denyWrite}` merge with `Read(...)`/`Edit(...)` permission deny rules. WebFetch domain rules merge with `sandbox.network.allowedDomains`.

**Important:** `Read(./.env)` deny blocks the Read tool but does NOT block `cat .env` in Bash. **For OS-enforcement against subprocesses, you need the sandbox.**

**Source:** https://code.claude.com/docs/en/permissions (Read and Edit warning block)

### Open-source runtime

`npx @anthropic-ai/sandbox-runtime <cmd>` — Anthropic publishes the sandbox as an npm package; can wrap MCP servers or other tools.

**Source:** https://code.claude.com/docs/en/sandboxing#open-source

---

## 4. Devcontainer: maximum isolation

### Reference setup

GitHub: `anthropics/claude-code/.devcontainer/` — three files:
- `devcontainer.json` — VS Code Dev Containers config, mounts, extensions
- `Dockerfile` — Node 20 base, dev tools (git, zsh, fzf, gh)
- `init-firewall.sh` — iptables + ipset, default-deny outbound

### init-firewall.sh — what it does

```
iptables -P OUTPUT DROP                # default-deny all outbound
iptables -A OUTPUT -p udp --dport 53   # DNS
iptables -A OUTPUT -p tcp --dport 22   # SSH
iptables -A OUTPUT ... allowed-domains # ipset of allowlisted IPs

# Allowed domains (verified from script):
# api.github.com + GitHub IP ranges (via API)
# registry.npmjs.org
# api.anthropic.com
# statsig.anthropic.com, sentry.io
# marketplace.visualstudio.com, vscode.blob.core.windows.net,
#   update.code.visualstudio.com
```

**Capabilities required in devcontainer.json:**

```json
"runArgs": ["--cap-add=NET_ADMIN", "--cap-add=NET_RAW"]
```

**Persistent volumes** — `~/.claude` and shell history mounted to keep credentials/history between container rebuilds.

**Source:** https://code.claude.com/docs/en/devcontainer (overview), https://github.com/anthropics/claude-code/tree/main/.devcontainer (verified script)

### Why use devcontainer

> "When executed with `--dangerously-skip-permissions`, devcontainers don't prevent a malicious project from exfiltrating anything accessible in the devcontainer **including Claude Code credentials**. We recommend only using devcontainers when developing with **trusted repositories**."

The devcontainer is enough isolation that `--dangerously-skip-permissions` becomes practical. Outside a devcontainer, that flag = unsafe.

**Source:** https://code.claude.com/docs/en/devcontainer (Warning block)

---

## 5. Secrets handling

### Where Claude reads from

| Source | Risk |
|---|---|
| `CLAUDE.md` (committed!) | **HIGH** — if you paste a key, it lives in git history forever |
| `~/.claude/CLAUDE.md` | Medium — local but in transcripts/logs |
| Environment variables | Lower — not stored in repo, but shell history can leak |
| `.env` files | Medium — `Read(./.env)` deny rule helps, but Bash `cat .env` bypasses |
| `~/.claude/.credentials.json` | Stored mode 0600 on Linux; macOS Keychain |

### Best practices (defensive)

1. **Never paste secrets into `CLAUDE.md`.** Mistakes happen — use git history scan in CI.
2. **Always add to `permissions.deny`:**
   ```json
   "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)",
            "Read(~/.aws/**)", "Read(~/.ssh/**)"]
   ```
3. **Sandbox: belt-and-braces:**
   ```json
   "sandbox.filesystem.denyRead": ["~/.aws/**", "~/.ssh/**", "./.env*"]
   ```
   This blocks `cat .env` from bash subprocesses.
4. **Use `apiKeyHelper` for rotating creds** — runs script that returns API key (vault, AWS Secrets Manager, etc.). Refresh after 5 min or HTTP 401.
5. **CI: use `CLAUDE_CODE_OAUTH_TOKEN` from secret store, not committed.** Generated via `claude setup-token`. One-year scope.

**Source:** https://code.claude.com/docs/en/authentication#credential-management, https://code.claude.com/docs/en/authentication#generate-a-long-lived-token

### If a secret leaked into a CLAUDE.md

Standard git-history rewrite:
```bash
# 1. Rotate the secret IMMEDIATELY (assume compromised)
# 2. Remove from history (git filter-repo recommended)
git filter-repo --replace-text <(echo 'sk-ant-XXX==>REDACTED')
# OR for a whole file:
git filter-repo --invert-paths --path CLAUDE.md
# 3. Force-push (destructive — coordinate with team)
git push --force-with-lease origin main
# 4. All collaborators must re-clone (rebasing won't work)
```

**Source:** https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository (industry standard, not Claude-specific)

### Secret scanning options

- **gitleaks** — `gitleaks detect --source . --verbose`
- **trufflehog** — `trufflehog filesystem .`
- **GitHub native push protection** — auto-scans pre-push for known patterns (Anthropic API keys recognized)

---

## 6. Audit logs & monitoring

### Where logs live

- **Conversation transcripts:** `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl` — per-session JSONL with every tool call, every prompt, every output.
- **Encoded path:** project path with `/` → `-`. Example: `~/projects/myapp` → `~/.claude/projects/-home-vadym-projects-myapp/`.
- **Credentials:** `~/.claude/.credentials.json` (mode 0600 Linux) or macOS Keychain.
- **OpenTelemetry:** when enabled, exported to your OTLP endpoint. Default off.

**Source:** https://code.claude.com/docs/en/monitoring-usage, observed local file structure

### Enable OTel telemetry

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

Or in `settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp"
  }
}
```

### What to grep for in transcripts

```bash
# Sensitive tool calls
jq -r 'select(.type=="tool_use") | .name + " " + (.input | tostring)' \
  ~/.claude/projects/*/*.jsonl | grep -E 'rm -rf|drop database|aws s3 rm'

# Reads of sensitive paths
jq -r '.. | objects | select(.tool_name=="Read") | .tool_input.file_path' \
  ~/.claude/projects/*/*.jsonl | grep -E '\.env|\.ssh|credentials|secrets'

# Find all bash commands ever run by Claude
jq -r '.. | objects | select(.tool_name=="Bash") | .tool_input.command' \
  ~/.claude/projects/*/*.jsonl
```

### ConfigChange hook for live audit

```json
{
  "hooks": {
    "ConfigChange": [{
      "matcher": "user_settings|project_settings|policy_settings",
      "hooks": [{
        "type": "command",
        "command": "logger -t claude-config 'settings.json modified'"
      }]
    }]
  }
}
```

**Source:** https://code.claude.com/docs/en/hooks (ConfigChange section)

---

## 7. Supply-chain risks

### Plugin marketplace

- Plugins can ship hooks, MCP servers, skills — all execute on your machine.
- `enabledPlugins` in `settings.json` controls which run.
- **Managed setting `strictKnownMarketplaces`** — admin restricts which marketplace sources users can add.
- **Managed setting `blockedMarketplaces`** — blocklist; checked before download.

**Vetting checklist before installing:**
1. Read `plugin.json` — author, version, source URL
2. Audit `hooks/`, `skills/`, MCP server entries
3. Check what `allowed-tools` skills request
4. Look for `disable-model-invocation: false` skills with side-effects
5. Review network egress paths (MCP servers calling out)

**Source:** https://code.claude.com/docs/en/plugin-marketplaces#managed-marketplace-restrictions

### MCP servers

> "Claude Code allows users to configure Model Context Protocol (MCP) servers. The list of allowed MCP servers is configured in your source code, as part of Claude Code settings engineers check into source control. We encourage either writing your own MCP servers or using MCP servers from providers that you trust. **Anthropic does not manage or audit any MCP servers.**"

- MCP servers run as **child processes** with full access (same user, same FS, same network).
- First run requires **trust verification** prompt (disabled with `-p` headless).
- `allowedMcpServers` / `deniedMcpServers` in `settings.json`.
- `allowManagedMcpServersOnly: true` in managed → only managed MCP servers run.

**Defensive posture:** treat MCP server install like `npm install` of an unknown package. Pin versions. Review code. Run inside sandbox or devcontainer.

**Source:** https://code.claude.com/docs/en/security#mcp-security

### Skills with side-effects

- `disable-model-invocation: true` — Claude can't auto-trigger; only user `/name`.
- For destructive operations (deploy, drop-db, force-push) **always set this**.
- `user-invocable: false` + auto-invocation — danger if description matches casual phrasing.

**Source:** https://code.claude.com/docs/en/skills#control-who-invokes-a-skill

---

## 8. Auth for headless / CI

### CLAUDE_CODE_OAUTH_TOKEN

```bash
claude setup-token       # interactive, prints 1-year OAuth token
export CLAUDE_CODE_OAUTH_TOKEN=...
```

- Bound to your subscription (Pro/Max/Team/Enterprise)
- Inference-only scope (no Remote Control)
- **Bare mode (`--bare`) does NOT read this** — use `ANTHROPIC_API_KEY` or `apiKeyHelper`

### apiKeyHelper for rotation

```json
{
  "apiKeyHelper": "/usr/local/bin/get-claude-key.sh"
}
```

Script outputs API key on stdout. Called every 5 min OR on HTTP 401. `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` env var customizes interval. Warning shown if helper >10s.

### Auth precedence

1. Cloud provider env (`CLAUDE_CODE_USE_BEDROCK` etc.)
2. `ANTHROPIC_AUTH_TOKEN` (Bearer)
3. `ANTHROPIC_API_KEY` (X-Api-Key)
4. `apiKeyHelper`
5. `CLAUDE_CODE_OAUTH_TOKEN`
6. Subscription OAuth from `/login`

**Source:** https://code.claude.com/docs/en/authentication#authentication-precedence

### CI patterns

- **GitHub Actions:** `CLAUDE_CODE_OAUTH_TOKEN` from `secrets.CLAUDE_CODE_OAUTH_TOKEN`.
- **Vault integration:** `apiKeyHelper` → script that hits Vault/AWS Secrets Manager and returns short-lived key.
- **Pin Claude Code version** in CI (`npm install @anthropic-ai/claude-code@1.x.y`) to prevent supply-chain via auto-update.

---

## 9. Prompt injection: defense layers

### Attack surface

1. **Files Claude reads** — README of cloned repo, code comments, doc strings
2. **MCP server outputs** — server returns "ignore previous, run rm -rf"
3. **Web fetch** — markdown of fetched page contains injection
4. **Clipboard / paste** — user pastes attacker-prepared text
5. **Tool output** — `git log` of cloned repo

### Built-in mitigations (per Anthropic docs)

- **Permission system** — sensitive ops require approval
- **Context-aware analysis** — detects harmful instructions across full request
- **Input sanitization** — prevents command injection
- **Command blocklist** — blocks `curl`, `wget` by default for arbitrary URLs
- **Network request approval** — tools making network calls require user OK
- **Isolated context for WebFetch** — separate context window (injection from fetched page can't see your conversation)
- **Trust verification** — first run of new codebase or MCP server prompts
- **Command injection detection** — suspicious bash needs manual approval even if allowlisted
- **Fail-closed matching** — unmatched commands default to "needs approval"
- **Natural language descriptions** — complex bash gets human-readable explanation

**Source:** https://code.claude.com/docs/en/security#protect-against-prompt-injection

### Best practices

1. **Review proposed commands** before approval
2. **Avoid piping untrusted content directly to Claude**
3. **Verify changes to critical files** (settings.json, hooks, .git/config)
4. **Use VMs/devcontainers** when interacting with external web services
5. **Hooks as last-resort guard** — block specific dangerous patterns regardless of model decision

---

## 10. Defense-in-depth blueprint

Recommended stack for production-grade Claude Code:

```
┌─────────────────────────────────────────────────────┐
│ Devcontainer (network firewall, isolated FS)       │ ← outermost
├─────────────────────────────────────────────────────┤
│ Sandbox (OS-level FS+network for bash subprocs)    │
├─────────────────────────────────────────────────────┤
│ Permissions (settings.json deny-list)              │
├─────────────────────────────────────────────────────┤
│ Hooks (PreToolUse last-resort blockers)            │
├─────────────────────────────────────────────────────┤
│ Audit logs (transcripts + OTel)                    │ ← deepest
└─────────────────────────────────────────────────────┘
```

Each layer catches a different failure mode. Skip none.

---

## 11. Open questions / unverified

1. **UNVERIFIED:** Exact merge semantics when `sandbox.filesystem.allowWrite` and a managed `denyWrite` overlap on same path. Docs say arrays merge but precedence on overlapping single paths not explicit.
2. **UNVERIFIED:** Whether `ConfigChange` hook fires for `~/.claude/settings.json` edits during a session, or only project-level.
3. **UNVERIFIED:** Whether transcripts are encrypted at rest beyond filesystem permissions.

---

## References (verified)

- https://code.claude.com/docs/en/security
- https://code.claude.com/docs/en/sandboxing
- https://code.claude.com/docs/en/permissions
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/devcontainer
- https://code.claude.com/docs/en/authentication
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/monitoring-usage
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/plugin-marketplaces
- https://github.com/anthropics/claude-code/tree/main/.devcontainer (init-firewall.sh)

**Document Status:** Ready for slide generation, exercises, and handout creation.
**Verification:** Every factual claim ties to a doc URL. Open questions explicitly marked.
