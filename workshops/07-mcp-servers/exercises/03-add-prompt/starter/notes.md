# Project notes

Working notes for the MCP workshop server.

## Setup

- Python 3.10+
- `uv add "mcp[cli]"`
- run with `uv run server.py`

## Roadmap

- [x] tool: current_time
- [x] resource: file://notes
- [ ] prompt: summarize_notes

## Debug

If Inspector shows nothing, check that no `print(...)` writes to stdout
without `file=sys.stderr` redirect.
