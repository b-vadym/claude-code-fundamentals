"""Exercise 02 — Tool use (starter).

Завдання: дати Claude tool `days_between`, провести цикл tool_use → tool_result.
"""

from datetime import date
from anthropic import Anthropic


# TODO: опиши tool
TOOLS = [
    # {
    #     "name": "days_between",
    #     "description": "Calculate number of days between two ISO dates.",
    #     "input_schema": {
    #         "type": "object",
    #         "properties": {
    #             "start": {"type": "string", "description": "Start date YYYY-MM-DD"},
    #             "end":   {"type": "string", "description": "End date YYYY-MM-DD"},
    #         },
    #         "required": ["start", "end"],
    #     },
    # }
]


def run_tool(name: str, params: dict) -> str:
    """Локальний executor. Розширюй під нові tools."""
    # TODO: implement days_between
    raise NotImplementedError(name)


def chat(user_msg: str) -> None:
    client = Anthropic()
    messages = [{"role": "user", "content": user_msg}]

    MAX_ITER = 5
    for i in range(1, MAX_ITER + 1):
        response = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=1024,
            tools=TOOLS,
            messages=messages,
        )

        if response.stop_reason != "tool_use":
            # TODO: print final answer
            return

        # TODO: handle tool_use blocks, append assistant + tool_result, continue


if __name__ == "__main__":
    chat("Скільки днів між 2024-01-01 і 2024-08-15?")
