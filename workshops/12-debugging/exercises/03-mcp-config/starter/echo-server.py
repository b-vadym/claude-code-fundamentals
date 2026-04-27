#!/usr/bin/env python3
"""
Minimal stdio MCP server for the debugging workshop.

Implements just enough of the protocol:
- initialize / initialized
- tools/list
- tools/call (single tool: echo)

Reads MCP_GREETING from env to prepend a greeting to echoed text.
"""

import json
import os
import sys

GREETING = os.environ.get("MCP_GREETING", "")


def send(msg: dict) -> None:
    sys.stdout.write(json.dumps(msg) + "\n")
    sys.stdout.flush()


def handle(req: dict) -> None:
    method = req.get("method", "")
    rid = req.get("id")

    if method == "initialize":
        send({
            "jsonrpc": "2.0",
            "id": rid,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "echo-server", "version": "0.1.0"},
            },
        })
    elif method == "notifications/initialized":
        # Notification, no response.
        pass
    elif method == "tools/list":
        send({
            "jsonrpc": "2.0",
            "id": rid,
            "result": {
                "tools": [
                    {
                        "name": "echo",
                        "description": "Echo a string back, prefixed with the configured greeting.",
                        "inputSchema": {
                            "type": "object",
                            "properties": {"text": {"type": "string"}},
                            "required": ["text"],
                        },
                    }
                ]
            },
        })
    elif method == "tools/call":
        params = req.get("params", {})
        name = params.get("name")
        args = params.get("arguments", {})
        if name == "echo":
            text = args.get("text", "")
            output = f"{GREETING} {text}".strip()
            send({
                "jsonrpc": "2.0",
                "id": rid,
                "result": {
                    "content": [{"type": "text", "text": output}]
                },
            })
        else:
            send({
                "jsonrpc": "2.0",
                "id": rid,
                "error": {"code": -32601, "message": f"Unknown tool: {name}"},
            })
    else:
        if rid is not None:
            send({
                "jsonrpc": "2.0",
                "id": rid,
                "error": {"code": -32601, "message": f"Unknown method: {method}"},
            })


def main() -> None:
    sys.stderr.write(f"echo-server starting (greeting={GREETING!r})\n")
    sys.stderr.flush()
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError as e:
            sys.stderr.write(f"parse error: {e}\n")
            continue
        handle(req)


if __name__ == "__main__":
    main()
