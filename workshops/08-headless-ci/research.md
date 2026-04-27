# Workshop 08 — Headless / CI/CD: Research Dossier

**For:** Ukrainian developer workshop on running Claude Code non-interactively in CI/CD pipelines (productionizing the `-p` flag).
**Audience:** Developers who saw the `claude -p "review MR"` pattern in token-economy deck and want a deeper, hardened CI/CD recipe.
**Date:** 2026-04-26

> **No-hallucination rule:** every claim cites a doc URL or file path. Anything unverified is marked **UNVERIFIED**.

---

## 1. The `-p` / `--print` flag and "headless" terminology

Claude Code's non-interactive entry point is `claude -p "<prompt>"` (long form `--print`). The `-p` flag exits after one response, with no REPL.

Quote (`https://code.claude.com/docs/en/headless`):
> The CLI was previously called "headless mode." The `-p` flag and all CLI options work the same way.

Source: <https://code.claude.com/docs/en/headless>

Basic example:

```bash
claude -p "What does the auth module do?"
```

All CLI flags work with `-p`; the flag itself just suppresses the interactive UI.

Source: <https://code.claude.com/docs/en/cli-reference> — table row for `--print, -p`.

---

## 2. `--bare` mode for scripted/CI calls

`--bare` is a separate, additive flag that disables auto-discovery of:

- hooks
- skills
- plugins
- MCP servers
- auto memory
- `CLAUDE.md`

Quote:
> Bare mode is useful for CI and scripts where you need the same result on every machine. A hook in a teammate's `~/.claude` or an MCP server in the project's `.mcp.json` won't run, because bare mode never reads them. Only flags you pass explicitly take effect.

In bare mode Claude has access only to **Bash, file read, and file edit tools** (other tools must be brought in explicitly).

> `--bare` is the recommended mode for scripted and SDK calls, and will become the default for `-p` in a future release.

Source: <https://code.claude.com/docs/en/headless#start-faster-with-bare-mode>

**Important auth caveat in bare mode:**
> Bare mode skips OAuth and keychain reads. Anthropic authentication must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in the JSON passed to `--settings`. Bedrock, Vertex, and Foundry use their usual provider credentials.

Same source. Cross-confirmed in <https://code.claude.com/docs/en/authentication> ("Bare mode does not read `CLAUDE_CODE_OAUTH_TOKEN`").

---

## 3. Output formats

`--output-format` accepts three values (CLI reference table):

| Value | Behavior |
|---|---|
| `text` | Default; plain text response |
| `json` | Single JSON object with `result`, `session_id`, and metadata |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

Source: <https://code.claude.com/docs/en/headless#get-structured-output> and <https://code.claude.com/docs/en/cli-reference> (`--output-format` row).

### JSON output

`claude -p "..." --output-format json` returns a JSON object whose text result is in the `result` field; session metadata also included. Pipe through `jq`:

```bash
claude -p "Summarize this project" --output-format json | jq -r '.result'
```

Source: <https://code.claude.com/docs/en/headless#get-structured-output>.

### Schema-validated JSON via `--json-schema`

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'
```

The structured payload lands in `.structured_output` (separate from `.result`).

Source: same page; cross-link to `/en/agent-sdk/structured-outputs`.

### Stream-json events

Each line is a JSON object representing an event. Documented event types:

- `system/init` — first event; reports model, tools, MCP servers, **and `plugins` + `plugin_errors` arrays** (use to fail CI when a plugin failed to load).
- `system/api_retry` — emitted before retry on retryable errors; fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` (one of: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`).
- `system/plugin_install` — when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set; `status` ∈ {`started`, `installed`, `failed`, `completed`}.
- `stream_event` (with `--include-partial-messages`) — partial text deltas; useful for token-by-token streaming.

Source: <https://code.claude.com/docs/en/headless#stream-responses> — full event tables.

Streaming text-only example using `jq`:

```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

---

## 4. Permission model in headless

In an interactive session Claude prompts for tool approval. In `-p` mode there is nobody to prompt, so you must **pre-approve** what's allowed.

### `--allowedTools`

Pre-approve a list of tools (or tool patterns). Syntax matches `permissions.allow` rules.

```bash
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"
```

Permission rule patterns: `Tool(matcher)` with glob-style `*`. Important: trailing space matters.
> The trailing ` *` enables prefix matching, so `Bash(git diff *)` allows any command starting with `git diff`. The space before `*` is important: without it, `Bash(git diff*)` would also match `git diff-index`.

Source: <https://code.claude.com/docs/en/headless#create-a-commit>.

### `--disallowedTools`

Removes tools from the model's context entirely. Source: CLI reference.

### `--tools`

Restricts which built-in tools are even available:
> Use `""` to disable all, `"default"` for all, or tool names like `"Bash,Edit,Read"`.

Source: <https://code.claude.com/docs/en/cli-reference> — `--tools` row.

### `--permission-mode`

Six modes documented in `/en/permission-modes`:

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Sensitive work |
| `acceptEdits` | Reads + file edits + `mkdir`/`touch`/`mv`/`cp`/`rm`/`rmdir`/`sed` | Iterating on code |
| `plan` | Reads only | Exploring before editing |
| `auto` | Everything, with classifier safety checks | Long tasks (research preview, restricted plans) |
| `dontAsk` | Only pre-approved tools (no prompts) | Locked-down CI |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs |

**Recommendation for CI:** the docs explicitly call out `dontAsk`:
> `dontAsk` denies anything not in your `permissions.allow` rules or the read-only command set, which is useful for locked-down CI runs.

Source quote: <https://code.claude.com/docs/en/headless#auto-approve-tools>; mode definition: <https://code.claude.com/docs/en/permission-modes#allow-only-pre-approved-tools-with-dontask-mode>.

### Auto-mode in non-interactive

> In non-interactive mode (`-p` flag), repeated blocks abort the session since there is no user to prompt.

Source: <https://code.claude.com/docs/en/permission-modes#when-auto-mode-falls-back>. Auto mode also has plan/model/provider gates and is not available on Bedrock/Vertex.

### Protected paths (never auto-approved)

`.git`, `.vscode`, `.idea`, `.husky`, `.claude` (with subdir exceptions), and several dotfiles. Source: <https://code.claude.com/docs/en/permission-modes#protected-paths>.

---

## 5. Auth in CI

Authentication precedence (from <https://code.claude.com/docs/en/authentication#authentication-precedence>):

1. Cloud provider creds (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — sent as `Authorization: Bearer`; for LLM-gateway proxies
3. `ANTHROPIC_API_KEY` — sent as `X-Api-Key`; direct Anthropic API
4. `apiKeyHelper` script output (for rotating creds)
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived OAuth token from `claude setup-token`
6. Subscription OAuth from `/login` (default for Pro/Max/Team/Enterprise)

> In non-interactive mode (`-p`), the key is always used when present.

(Re: `ANTHROPIC_API_KEY`.) Same source.

### `claude setup-token`

> For CI pipelines, scripts, or other environments where interactive browser login isn't available, generate a one-year OAuth token with `claude setup-token`.

Notes:
- Token is **printed to terminal, not saved**. Copy and store in secret manager.
- Set as `CLAUDE_CODE_OAUTH_TOKEN`.
- Authenticates with subscription (Pro/Max/Team/Enterprise required).
- **Inference only** — cannot establish Remote Control sessions.
- **Bare mode does NOT read this var.** Use `ANTHROPIC_API_KEY` or `apiKeyHelper` if `--bare`.

Source: <https://code.claude.com/docs/en/authentication#generate-a-long-lived-token>.

### `apiKeyHelper`

Settings field. Outputs API key to stdout. Called every 5 minutes or on HTTP 401. Override with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`. Slow helpers (>10s) trigger a UI warning.

Source: <https://code.claude.com/docs/en/authentication#credential-management>.

### Cloud-provider env vars

- `CLAUDE_CODE_USE_BEDROCK=1` — route to Bedrock
- `CLAUDE_CODE_USE_VERTEX=1` — route to Vertex
- `CLAUDE_CODE_USE_FOUNDRY=1` — route to Microsoft Foundry
- `AWS_REGION`, `AWS_ROLE_TO_ASSUME` — for Bedrock OIDC
- `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` — for Vertex WIF
- `ANTHROPIC_VERTEX_PROJECT_ID`, `VERTEX_REGION_CLAUDE_4_5_SONNET` — appear in GitHub Actions Vertex example

Sources: <https://code.claude.com/docs/en/gitlab-ci-cd>, <https://code.claude.com/docs/en/github-actions>.

---

## 6. Cost ceilings

### `--max-turns`

> Limit the number of agentic turns (print mode only). Exits with an error when the limit is reached. No limit by default.

Source: CLI reference.

### `--max-budget-usd`

> Maximum dollar amount to spend on API calls before stopping (print mode only).

Source: CLI reference. Example: `claude -p --max-budget-usd 5.00 "query"`.

### `--fallback-model`

> Enable automatic fallback to specified model when default model is overloaded (print mode only).

Source: CLI reference.

### `--no-session-persistence`

> Disable session persistence so sessions are not saved to disk and cannot be resumed (print mode only).

Useful in CI to keep ephemeral runners truly ephemeral. Source: CLI reference.

---

## 7. GitLab CI/CD reference template

From <https://code.claude.com/docs/en/gitlab-ci-cd>:

### Quick setup (Claude API)

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

Required CI/CD variable: `ANTHROPIC_API_KEY` (masked).

Notes from the same doc:
- Beta integration, maintained by GitLab, not Anthropic.
- Triggers via `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT` variables when invoked from a comment-event listener.
- For project-API operations (commenting on MR, opening MR), use `CI_JOB_TOKEN` or a Project Access Token with `api` scope (`GITLAB_ACCESS_TOKEN`).

### AWS Bedrock OIDC variant

Documented full job (see § "AWS Bedrock job example" in source). Key flow:
1. `apk add awscli`
2. Write GitLab OIDC JWT (`CI_JOB_JWT_V2`) to file
3. `aws sts assume-role-with-web-identity` → temporary creds
4. Export `AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY/SESSION_TOKEN`
5. Run `claude -p ...`

Required CI vars: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`.

### Vertex WIF variant

`gcloud auth login --cred-file=<(...)` with external_account JSON; required vars `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`.

---

## 8. GitHub Actions reference template

From <https://code.claude.com/docs/en/github-actions>:

Official action: `anthropics/claude-code-action@v1` (repo: <https://github.com/anthropics/claude-code-action>).

### Basic workflow

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Code-review on PR open

```yaml
name: Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Review this pull request for code quality, correctness, and security. Analyze the diff, then post your findings as review comments."
          claude_args: "--max-turns 5"
```

### Action inputs (v1.0)

| Input | Required |
|---|---|
| `prompt` | No (omit for `@claude` mention mode) |
| `claude_args` | No — passes through any CLI flag |
| `anthropic_api_key` | Yes for direct API |
| `github_token` | No (defaults to `GITHUB_TOKEN`) |
| `trigger_phrase` | No (default `@claude`) |
| `use_bedrock` | No |
| `use_vertex` | No |

**Beta → v1 breaking changes** documented in the same page (e.g., `direct_prompt` → `prompt`, `max_turns` → `claude_args: --max-turns`).

### Bedrock OIDC GitHub Actions sample

Required permissions block:
```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
  id-token: write   # <-- needed for OIDC
```

Steps: `aws-actions/configure-aws-credentials@v4` with `role-to-assume`; then the action with `use_bedrock: "true"` and `claude_args: '--model us.anthropic.claude-sonnet-4-6 --max-turns 10'`.

### Vertex WIF GitHub Actions sample

`google-github-actions/auth@v2` with `workload_identity_provider` + `service_account`; the action with `use_vertex: "true"`. Env vars: `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION: us-east5`, `VERTEX_REGION_CLAUDE_4_5_SONNET: us-east5`.

---

## 9. Security checklist for headless

Sources: GitLab CI/CD doc "Security considerations", GitHub Actions doc "Security considerations", and `settings` docs.

- **Never commit API keys.** Always use repo secrets / masked CI variables.
- Prefer **OIDC** (Bedrock, Vertex) over long-lived keys.
- For subscription auth, use `claude setup-token` → store in secret manager → set `CLAUDE_CODE_OAUTH_TOKEN`.
- **Limit tools and permissions:**
  ```json
  {
    "permissions": {
      "allow": ["Bash(git *)", "Read(.)"],
      "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)", "WebFetch", "Bash(curl *)"],
      "defaultMode": "dontAsk"
    }
  }
  ```
- **Disable telemetry in CI** if needed: `CLAUDE_CODE_ENABLE_TELEMETRY=0`.
- **Always use `--max-turns`** to bound iterations and **`--max-budget-usd`** for spend.
- Review every Claude PR/MR like any other contributor.
- Use `--no-session-persistence` on ephemeral runners.
- Keep `CLAUDE.md` focused and concise (it loads on every run).

---

## 10. Common pitfalls

Distilled from the four doc pages above:

1. **Interactive auth attempts in CI.** Without `ANTHROPIC_API_KEY` / `CLAUDE_CODE_OAUTH_TOKEN` set, Claude Code tries to open a browser → CI hangs. Fix: secrets must be set before the job starts, or use `apiKeyHelper`.
2. **Secrets in logs.** `--debug` prints headers. Mask API keys at the runner level. GitLab does this for masked variables; GitHub Actions does it for `${{ secrets.X }}`.
3. **Permission prompts hang the job.** A missing `--allowedTools` or `--permission-mode` causes Claude to wait for input. Fix: explicit `--permission-mode dontAsk` or `acceptEdits` plus an allowlist.
4. **Runaway costs.** No `--max-turns` → unbounded iterations on a stuck task. Fix: `--max-turns 5` (or so) for review jobs.
5. **OAuth token doesn't work in `--bare`.** Bare mode skips OAuth and keychain. Fix: use API key or `apiKeyHelper`.
6. **Auto mode aborts in `-p`.** Three classifier blocks → session aborts non-interactively. Fix: don't use `--permission-mode auto` for CI; use `dontAsk` or `acceptEdits`.
7. **`ANTHROPIC_API_KEY` overrides subscription unintentionally.** If you have both, key wins.  Fix: `unset ANTHROPIC_API_KEY` if you meant to use OAuth token.
8. **Plugin failures silent.** Without parsing `system/init`'s `plugin_errors` field from stream-json, missing plugins go undetected.
9. **Skills/built-in commands unavailable in `-p`.** Quote: "User-invoked skills like `/commit` and built-in commands are only available in interactive mode. In `-p` mode, describe the task you want to accomplish instead." Source: <https://code.claude.com/docs/en/headless#create-a-commit>.
10. **`--bare` skips `CLAUDE.md`.** If your CI relies on project conventions documented in `CLAUDE.md`, either drop `--bare` or pass `--append-system-prompt-file`.

---

## 11. Open questions / **UNVERIFIED**

1. **UNVERIFIED** — Exact list of all fields in `--output-format json` response. Docs mention `result`, `session_id`, `structured_output`, "metadata about the request (session ID, usage, etc.)" but full schema not enumerated on the headless page.
2. **UNVERIFIED** — Whether `--max-budget-usd` counts cache reads/writes against the budget (only that it stops on API spend).
3. **UNVERIFIED** — Whether a long-lived OAuth token from `claude setup-token` triggers MFA challenges if the underlying account requires MFA.
4. **UNVERIFIED** — Whether `--debug` masks `ANTHROPIC_API_KEY` in logs by default. Recommended: never enable `--debug` in jobs that print logs publicly.
5. **UNVERIFIED** — Token cost (in tokens) of `apiKeyHelper` invocation overhead.

---

## 12. Doc sources (canonical)

- <https://code.claude.com/docs/en/headless> — `-p` flag, `--bare`, output formats, stream-json events, examples
- <https://code.claude.com/docs/en/cli-reference> — full CLI flag table
- <https://code.claude.com/docs/en/permission-modes> — six modes including `dontAsk`, classifier behavior in `-p`
- <https://code.claude.com/docs/en/authentication> — auth precedence, `setup-token`, `apiKeyHelper`
- <https://code.claude.com/docs/en/settings> — settings.json schema for permissions/env
- <https://code.claude.com/docs/en/gitlab-ci-cd> — GitLab CI templates (Claude API, Bedrock OIDC, Vertex WIF)
- <https://code.claude.com/docs/en/github-actions> — GitHub Actions v1 action + cloud-provider variants
- <https://github.com/anthropics/claude-code-action> — official action repo

---

**Document status:** ready for slide generation, exercises, and handout.
**Verification:** every claim cites a source URL or is marked UNVERIFIED.
