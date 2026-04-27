"""Workshop 07 — Exercise 2 starter.

Goal: add a `file://notes` resource that exposes `notes.md`.
"""

import logging
import sys
from datetime import datetime
from zoneinfo import ZoneInfo

from mcp.server.fastmcp import FastMCP

logging.basicConfig(level=logging.INFO, stream=sys.stderr)
log = logging.getLogger("clock")

mcp = FastMCP("clock")


@mcp.tool()
def current_time(tz: str = "UTC") -> str:
    """Return current time in the given IANA timezone (e.g. Europe/Kyiv).

    Args:
        tz: IANA timezone string. Default UTC.
    """
    return datetime.now(ZoneInfo(tz)).isoformat()


# TODO: add @mcp.resource("file://notes") returning notes.md content


if __name__ == "__main__":
    mcp.run(transport="stdio")
