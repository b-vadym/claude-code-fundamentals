"""Workshop 07 — Exercise 1 solution."""

import logging
import sys
from datetime import datetime
from zoneinfo import ZoneInfo

from mcp.server.fastmcp import FastMCP

# stderr logging — never stdout for STDIO servers
logging.basicConfig(level=logging.INFO, stream=sys.stderr)
log = logging.getLogger("clock")

mcp = FastMCP("clock")


@mcp.tool()
def current_time(tz: str = "UTC") -> str:
    """Return current time in the given IANA timezone (e.g. Europe/Kyiv).

    Args:
        tz: IANA timezone string. Default UTC.
    """
    log.info("current_time called: tz=%s", tz)
    return datetime.now(ZoneInfo(tz)).isoformat()


if __name__ == "__main__":
    mcp.run(transport="stdio")
