"""Workshop 07 — Exercise 4 solution.

Same server as exercise 3, ready to be added to Claude Code:

    claude mcp add --scope user --transport stdio my-clock \
      -- uv --directory $(pwd) run server.py
"""

import logging
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

from mcp.server.fastmcp import FastMCP

logging.basicConfig(level=logging.INFO, stream=sys.stderr)
log = logging.getLogger("clock")

mcp = FastMCP("clock")

NOTES_PATH = Path(__file__).parent / "notes.md"


@mcp.tool()
def current_time(tz: str = "UTC") -> str:
    """Return current time in the given IANA timezone (e.g. Europe/Kyiv).

    Args:
        tz: IANA timezone string. Default UTC.
    """
    return datetime.now(ZoneInfo(tz)).isoformat()


@mcp.resource("file://notes")
def get_notes() -> str:
    """Project notes."""
    return NOTES_PATH.read_text(encoding="utf-8")


@mcp.prompt(title="Summarize notes")
def summarize_notes(style: str = "bullet") -> str:
    """Generate a request to summarize project notes.

    Args:
        style: Output style. One of: bullet, paragraph, tldr.
    """
    notes = NOTES_PATH.read_text(encoding="utf-8")
    return f"Summarize the following notes in {style} style:\n\n{notes}"


if __name__ == "__main__":
    mcp.run(transport="stdio")
