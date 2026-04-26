"""Workshop 07 — Exercise 1 starter.

Goal: implement `current_time(tz)` tool.
"""

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("clock")


# TODO: implement @mcp.tool()
# def current_time(tz: str = "UTC") -> str:
#     """Return current time in the given IANA timezone (e.g. Europe/Kyiv).
#
#     Args:
#         tz: IANA timezone string. Default UTC.
#     """
#     ...


if __name__ == "__main__":
    mcp.run(transport="stdio")
