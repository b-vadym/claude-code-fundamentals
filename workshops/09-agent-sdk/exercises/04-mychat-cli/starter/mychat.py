"""Exercise 04 — mychat CLI (starter).

Build a simple REPL chatbot with streaming, history, and prompt caching.
"""

import os
from anthropic import Anthropic


SYSTEM_PROMPT = (
    "You are a helpful assistant. Reply in the language the user writes in. "
    "Be concise (3 sentences max unless asked for detail). "
    "When unsure, ask a clarifying question."
)


def main() -> None:
    if not os.environ.get("ANTHROPIC_API_KEY"):
        raise SystemExit("Set ANTHROPIC_API_KEY env var first")

    client = Anthropic()
    history: list[dict] = []

    print("mychat (Haiku 4.5). /clear /quit /usage")
    while True:
        try:
            user = input("> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if not user:
            continue
        if user in ("/quit", "/exit"):
            break
        if user == "/clear":
            history.clear()
            print("[history cleared]")
            continue

        history.append({"role": "user", "content": user})

        # TODO: client.messages.stream(...) with model, system+cache_control, history
        # TODO: print streamed text, capture final message
        # TODO: append assistant message to history
        # TODO: print [usage] line


if __name__ == "__main__":
    main()
