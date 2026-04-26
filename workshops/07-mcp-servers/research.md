# MCP Servers (Python SDK): Research Dossier

**For:** Ukrainian developer workshop on building MCP servers
**Audience:** Developers who connect to MCP servers in fundamentals; now build their own
**Date:** 2026-04-26

---

## 1. Architecture: Hosts, Clients, Servers

### Participants

> "MCP follows a client-server architecture where an MCP host — an AI application like Claude Code or Claude Desktop — establishes connections to one or more MCP servers. The MCP host accomplishes this by creating one MCP client for each MCP server."

- **MCP Host** — AI application (Claude Code, VS Code, Claude Desktop) that coordinates clients
- **MCP Client** — component inside the host, one per connected server, owns a dedicated connection
- **MCP Server** — program providing context (tools/resources/prompts) to the client

**Local vs remote:** "Local" = STDIO-transport server, runs as subprocess of host. "Remote" = Streamable HTTP, runs on separate machine, can serve many clients.

**Source:** https://modelcontextprotocol.io/docs/concepts/architecture (Participants, Layers)

### Two Layers

- **Data layer** — JSON-RPC 2.0 protocol; lifecycle, primitives, notifications
- **Transport layer** — STDIO or Streamable HTTP; handles framing, auth

> "The transport layer abstracts communication details from the protocol layer, enabling the same JSON-RPC 2.0 message format across all transport mechanisms."

**Source:** https://modelcontextprotocol.io/docs/concepts/architecture#layers

---

## 2. Primitives: Tools, Resources, Prompts

### Server Primitives (what the server exposes)

| Primitive | What | Methods | Use case |
|-----------|------|---------|----------|
| **Tools** | Executable functions LLM can invoke | `tools/list`, `tools/call` | DB queries, API calls, file ops |
| **Resources** | Data sources providing context | `resources/list`, `resources/read` | File contents, DB records, API responses |
| **Prompts** | Reusable interaction templates | `prompts/list`, `prompts/get` | System prompts, few-shot examples |

> "MCP defines three core primitives that *servers* can expose: Tools (Executable functions), Resources (Data sources), Prompts (Reusable templates)"

Each primitive has methods for **discovery** (`*/list`), **retrieval/execution** (`*/get`, `*/call`).

**Source:** https://modelcontextprotocol.io/docs/concepts/architecture#primitives

### Client Primitives (what host can offer back)

- **Sampling** — server requests LLM completion from host (`sampling/createMessage`)
- **Elicitation** — server asks user for input (`elicitation/create`)
- **Logging** — server sends log messages to client

**Source:** Same page, "MCP also defines primitives that *clients* can expose"

### Notifications

Server can push updates without request: `notifications/tools/list_changed` etc. Client refreshes state on receipt.

> "Claude Code supports MCP `list_changed` notifications, allowing MCP servers to dynamically update their available tools, prompts, and resources without requiring you to disconnect and reconnect."

**Sources:**
- https://modelcontextprotocol.io/docs/concepts/architecture#notifications
- https://code.claude.com/docs/en/mcp#dynamic-tool-updates

---

## 3. Python SDK: Setup and FastMCP

### System Requirements

> "Python 3.10 or higher installed. You must use the Python MCP SDK 1.2.0 or higher."

**Source:** https://modelcontextprotocol.io/docs/develop/build-server (Python tab, System requirements)

### Installation (uv-based, recommended)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv init weather
cd weather
uv venv
source .venv/bin/activate
uv add "mcp[cli]" httpx
```

**Sources:**
- https://github.com/modelcontextprotocol/python-sdk (README "Installation")
- https://modelcontextprotocol.io/docs/develop/build-server (Set up your environment)

### Minimal FastMCP Server

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("Demo")

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

> "The FastMCP class uses Python type hints and docstrings to automatically generate tool definitions, making it easy to create and maintain MCP tools."

**Source:** https://modelcontextprotocol.io/docs/develop/build-server

### Decorators

```python
@mcp.tool()                                # Tool from function
@mcp.resource("greeting://{name}")          # Resource with URI template
@mcp.prompt(title="Code Review")            # Prompt template
```

- Type hints → JSON Schema for `inputSchema`
- Docstring → tool/resource/prompt description
- Function name → primitive name (override via decorator args)

**Source:** https://github.com/modelcontextprotocol/python-sdk (README examples)

### Resource URI Schemes

```python
@mcp.resource("file://documents/{name}")
def read_document(name: str) -> str:
    """Read a document by name."""
    return f"Content of {name}"
```

URI templates use `{name}` placeholders that bind to function parameters.

**Source:** https://github.com/modelcontextprotocol/python-sdk (README "Resources")

### Prompts

```python
@mcp.prompt(title="Code Review")
def review_code(code: str) -> str:
    return f"Please review this code:\n\n{code}"
```

> "Prompts are reusable templates that help LLMs interact with your server effectively"

**Source:** https://github.com/modelcontextprotocol/python-sdk (README "Prompts")

---

## 4. Transports: STDIO, SSE, Streamable HTTP

### STDIO (default for local)

- Single client, subprocess of host
- No network overhead
- **Critical:** never write to stdout — corrupts JSON-RPC framing

> "For STDIO-based servers: Never write to stdout. Writing to stdout will corrupt the JSON-RPC messages and break your server. The print() function writes to stdout by default, but can be used safely with file=sys.stderr."

```python
import sys
print("Processing request", file=sys.stderr)  # safe
import logging
logging.info("Processing request")            # safe (default stderr)
```

**Source:** https://modelcontextprotocol.io/docs/develop/build-server (Logging in MCP Servers)

### Streamable HTTP (recommended for remote)

```python
mcp.run(transport="streamable-http")
# server runs on http://localhost:8000/mcp
```

- HTTP POST for client → server messages
- Optional Server-Sent Events for server → client streaming
- Supports OAuth, bearer tokens, API keys
- Multiple clients supported

> "MCP recommends using OAuth to obtain authentication tokens."

**Sources:**
- https://github.com/modelcontextprotocol/python-sdk (README "Running the Server")
- https://modelcontextprotocol.io/docs/concepts/architecture#transport-layer

### SSE (deprecated)

> "The SSE (Server-Sent Events) transport is deprecated. Use HTTP servers instead, where available."

Still in `claude mcp add --transport sse` for legacy servers.

**Source:** https://code.claude.com/docs/en/mcp#option-2-add-a-remote-sse-server

---

## 5. Connecting to Claude Code

### CLI: `claude mcp add`

Three transport options. **Important:** all options come BEFORE the server name; `--` separates name from command/args.

**Local STDIO:**
```bash
claude mcp add --transport stdio --env API_KEY=xxx myserver \
  -- python /path/to/server.py
```

**Remote HTTP:**
```bash
claude mcp add --transport http myserver https://api.example.com/mcp
claude mcp add --transport http myserver https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

**Remote SSE (deprecated):**
```bash
claude mcp add --transport sse myserver https://api.example.com/sse
```

**Source:** https://code.claude.com/docs/en/mcp#installing-mcp-servers

### Management Commands

```bash
claude mcp list              # all configured servers
claude mcp get <name>        # server details
claude mcp remove <name>     # delete
/mcp                         # inside Claude Code: status, OAuth login
```

**Source:** https://code.claude.com/docs/en/mcp#managing-your-servers

### Scopes

| Scope | Loads in | Shared | Stored in |
|-------|----------|--------|-----------|
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes (via VCS) | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` |

> "Local scope is the default. ... A local-scoped server loads only in the project where you added it and stays private to you."

**Precedence:** local > project > user > plugin > claude.ai connectors.

**Source:** https://code.claude.com/docs/en/mcp#mcp-installation-scopes

### `.mcp.json` Schema (project scope)

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/abs/path/to/server.py"],
      "env": {"DEBUG": "1"}
    },
    "remote-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Supports `${VAR}` and `${VAR:-default}` env var expansion in `command`, `args`, `env`, `url`, `headers`.

**Source:** https://code.claude.com/docs/en/mcp#environment-variable-expansion-in-mcp-json

### Security Approval

> "For security reasons, Claude Code prompts for approval before using project-scoped servers from `.mcp.json` files. If you need to reset these approval choices, use the `claude mcp reset-project-choices` command."

**Source:** Same page, "Project scope".

---

## 6. Authentication

### Stdio (local)

Pass secrets via environment variables:

```bash
claude mcp add --transport stdio --env GH_TOKEN=ghp_xxx mygh \
  -- npx -y @modelcontextprotocol/server-github
```

In `.mcp.json` use `${VAR}` expansion to keep secrets out of VCS.

### HTTP

- **Bearer token:** `--header "Authorization: Bearer xxx"`
- **API key:** `--header "X-API-Key: xxx"` (custom header)
- **OAuth 2.0:** server initiates flow on first call; user runs `/mcp` inside Claude Code to authenticate

> "Use `/mcp` to authenticate with remote servers that require OAuth 2.0 authentication"

**Source:** https://code.claude.com/docs/en/mcp (Tips section)

---

## 7. Debugging: Inspector + Logs

### MCP Inspector

Interactive web UI for testing/debugging MCP servers. No install — runs via npx.

```bash
# Inspect locally developed Python server
npx @modelcontextprotocol/inspector \
  uv --directory path/to/server run server.py

# Inspect npm-published server
npx -y @modelcontextprotocol/inspector npx @modelcontextprotocol/server-filesystem /Users/me/Desktop

# Inspect PyPI-published server
npx @modelcontextprotocol/inspector uvx mcp-server-git --repository ~/code/repo
```

**Features:**
- **Server connection pane** — choose transport, customize args/env
- **Resources tab** — list, inspect content, test subscriptions
- **Prompts tab** — view templates, test with custom args, preview messages
- **Tools tab** — list, view schemas, test with inputs, see results
- **Notifications pane** — server logs and notifications

**Source:** https://modelcontextprotocol.io/docs/tools/inspector

### Server Logs

- **Stdio:** must write to stderr (Python's `logging` defaults to stderr)
- **HTTP:** stdout is fine
- Inside Claude Code: `/mcp` shows server connection status

### Reconnection

> "If an HTTP or SSE server disconnects mid-session, Claude Code automatically reconnects with exponential backoff: up to five attempts, starting at a one-second delay and doubling each time. ... Stdio servers are local processes and are not reconnected automatically."

**Source:** https://code.claude.com/docs/en/mcp#automatic-reconnection

### Output Limits

> "Claude Code will display a warning when MCP tool output exceeds 10,000 tokens. To increase this limit, set the `MAX_MCP_OUTPUT_TOKENS` environment variable (for example, `MAX_MCP_OUTPUT_TOKENS=50000`)"

**Source:** https://code.claude.com/docs/en/mcp (Tips section)

### Startup Timeout

> "Configure MCP server startup timeout using the MCP_TIMEOUT environment variable (for example, `MCP_TIMEOUT=10000 claude` sets a 10-second timeout)"

**Source:** Same.

---

## 8. Lifecycle (JSON-RPC view)

1. **Initialize:** client sends `initialize` with `protocolVersion`, `capabilities`, `clientInfo`
2. **Server responds** with own `protocolVersion`, declared `capabilities` (which primitives it supports), `serverInfo`
3. **Client sends `notifications/initialized`**
4. **Discovery:** client calls `tools/list`, `resources/list`, `prompts/list`
5. **Use:** `tools/call`, `resources/read`, `prompts/get`
6. **Notifications:** server pushes `tools/list_changed` etc. when state changes
7. **Termination:** transport-specific (close stdin or HTTP session)

**Sources:**
- https://modelcontextprotocol.io/docs/concepts/architecture#data-layer-protocol (full JSON-RPC examples)
- https://modelcontextprotocol.io/specification/latest/basic/lifecycle

---

## 9. Open Questions / Unverified

1. **UNVERIFIED** — exact behavior when stdio server crashes mid-session: docs say "Stdio servers are local processes and are not reconnected automatically" but don't detail user-facing UI.
2. **UNVERIFIED** — whether FastMCP supports custom JSON Schema (`Field`/Pydantic) beyond plain type hints. README hints yes via Pydantic; not explicitly demonstrated for tool input schema overrides.
3. **UNVERIFIED** — exact OAuth flow steps inside Claude Code beyond "/mcp authenticates". Docs reference but don't walk through.
4. **UNVERIFIED** — Channels capability mentioned in `code.claude.com/docs/en/mcp#push-messages-with-channels` is referenced but is a separate doc page; not covered in this workshop.

---

## References

**Official MCP Docs (modelcontextprotocol.io):**
- Architecture: https://modelcontextprotocol.io/docs/concepts/architecture
- Build server (Python): https://modelcontextprotocol.io/docs/develop/build-server
- Inspector: https://modelcontextprotocol.io/docs/tools/inspector
- Specification (lifecycle): https://modelcontextprotocol.io/specification/latest

**Python SDK:**
- README: https://github.com/modelcontextprotocol/python-sdk
- Quickstart resources (weather example): https://github.com/modelcontextprotocol/quickstart-resources/tree/main/weather-server-python

**Claude Code:**
- MCP integration: https://code.claude.com/docs/en/mcp

**Verification depth:** 4 doc pages fetched verbatim, every claim mapped to URL or quoted excerpt. Open questions marked UNVERIFIED.
