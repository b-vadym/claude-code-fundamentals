"""Exercise 01 — Hello Agent (solution).

Run: python hello.py
Streaming variant at the bottom (uncomment).
"""

import os
import time
from anthropic import Anthropic


def basic() -> None:
    client = Anthropic()

    message = client.messages.create(
        model="claude-opus-4-7",
        max_tokens=512,
        messages=[
            {"role": "user", "content": "Розкажи про себе у три речення українською"}
        ],
    )

    print("=" * 60)
    print(message.content[0].text)
    print("=" * 60)
    print(f"Input tokens:  {message.usage.input_tokens}")
    print(f"Output tokens: {message.usage.output_tokens}")
    print(f"Stop reason:   {message.stop_reason}")


def streaming() -> None:
    """Bonus: same call but streamed, with TTFB measurement."""
    client = Anthropic()

    start = time.monotonic()
    first_token_at: float | None = None

    with client.messages.stream(
        model="claude-haiku-4-5",
        max_tokens=512,
        messages=[
            {"role": "user", "content": "Розкажи про себе у три речення українською"}
        ],
    ) as stream:
        for text in stream.text_stream:
            if first_token_at is None:
                first_token_at = time.monotonic()
            print(text, end="", flush=True)
        print()
        final = stream.get_final_message()

    ttfb = (first_token_at - start) * 1000 if first_token_at else None
    print("=" * 60)
    print(f"TTFB:          {ttfb:.0f}ms" if ttfb else "TTFB: n/a")
    print(f"Input tokens:  {final.usage.input_tokens}")
    print(f"Output tokens: {final.usage.output_tokens}")


if __name__ == "__main__":
    if not os.environ.get("ANTHROPIC_API_KEY"):
        raise SystemExit("Set ANTHROPIC_API_KEY env var first")

    basic()
    print()
    streaming()
