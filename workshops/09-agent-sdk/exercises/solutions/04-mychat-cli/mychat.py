"""Exercise 04 — mychat CLI (solution).

Streaming REPL chatbot with history and prompt caching.

Run:
    export ANTHROPIC_API_KEY=sk-ant-...
    python mychat.py
"""

import argparse
import os
import sys
from anthropic import Anthropic


SYSTEM_PROMPT = (
    "You are a helpful assistant. Reply in the language the user writes in. "
    "Be concise (3 sentences max unless asked for detail). "
    "When unsure, ask a clarifying question. "
    "Never invent facts; say 'I don't know' if uncertain. "
    # Pad to encourage hitting the 4096-token cache minimum on Haiku 4.5.
    # In real apps you would replace this with actual rules/examples/docs.
    + ("\n\nFAQ:\n" + "\n".join(
        f"Q{i}: Sample frequently-asked question number {i} about the product. "
        f"A{i}: Sample canonical answer to question {i} that the assistant should "
        f"reuse verbatim when matched."
        for i in range(1, 220)
    ))
)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="mychat — streaming Claude REPL")
    p.add_argument("--model", default="claude-haiku-4-5",
                   help="Model id (default: claude-haiku-4-5)")
    p.add_argument("--max-tokens", type=int, default=1024)
    return p.parse_args()


def main() -> int:
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("Set ANTHROPIC_API_KEY env var first", file=sys.stderr)
        return 1

    args = parse_args()
    client = Anthropic()
    history: list[dict] = []
    cum_in = cum_out = cum_create = cum_read = 0

    print(f"mychat ({args.model}). /clear /quit /usage")
    while True:
        try:
            user = input("> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not user:
            continue
        if user in ("/quit", "/exit"):
            break
        if user == "/clear":
            history.clear()
            print("[history cleared]")
            continue
        if user == "/usage":
            print(f"[cum] in={cum_in} out={cum_out} "
                  f"cache_create={cum_create} cache_read={cum_read}")
            continue

        history.append({"role": "user", "content": user})

        with client.messages.stream(
            model=args.model,
            max_tokens=args.max_tokens,
            system=[{
                "type": "text",
                "text": SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},  # 5-min TTL
            }],
            messages=history,
        ) as stream:
            for text in stream.text_stream:
                print(text, end="", flush=True)
            print()
            final = stream.get_final_message()

        history.append({"role": "assistant", "content": final.content})

        u = final.usage
        cum_in += u.input_tokens
        cum_out += u.output_tokens
        cum_create += u.cache_creation_input_tokens
        cum_read += u.cache_read_input_tokens

        print(
            f"[usage] in={u.input_tokens} out={u.output_tokens} "
            f"cache_read={u.cache_read_input_tokens} "
            f"cache_creation={u.cache_creation_input_tokens}"
        )

    print(f"\n[final cum] in={cum_in} out={cum_out} "
          f"cache_create={cum_create} cache_read={cum_read}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
