"""Workshop 07 — Exercise 2 solution."""

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


@mcp.resource("file://notes/{section}")
def get_section(section: str) -> str:
    """Get a single H2 section from notes by slug (lowercased, hyphenated)."""
    text = NOTES_PATH.read_text(encoding="utf-8")
    parts = text.split("\n## ")
    for part in parts[1:]:
        heading, *body = part.split("\n", 1)
        slug = heading.strip().lower().replace(" ", "-")
        if slug == section:
            return f"## {heading}\n{body[0] if body else ''}"
    return f"Section '{section}' not found"


if __name__ == "__main__":
    mcp.run(transport="stdio")
