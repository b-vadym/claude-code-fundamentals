"""Exercise 01 — Hello Agent (starter).

Завдання: зробити перший виклик messages.create і вивести відповідь + usage.
"""

import os
from anthropic import Anthropic


def main() -> None:
    if not os.environ.get("ANTHROPIC_API_KEY"):
        raise SystemExit("Set ANTHROPIC_API_KEY env var first")

    client = Anthropic()

    # TODO: заповни model, max_tokens, messages
    message = client.messages.create(
        model="...",  # claude-opus-4-7
        max_tokens=...,  # 512
        messages=[
            # {"role": "user", "content": "..."}
        ],
    )

    # TODO: вивести текст відповіді
    # print(message.content[0].text)

    # TODO: вивести usage (input_tokens, output_tokens)


if __name__ == "__main__":
    main()
