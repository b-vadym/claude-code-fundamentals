"""Exercise 02 — Tool use (solution).

Demonstrates the full tool_use → tool_result loop with MAX_ITER safeguard.
"""

import json
from datetime import date
from anthropic import Anthropic


TOOLS = [
    {
        "name": "days_between",
        "description": (
            "Calculate the absolute number of days between two ISO dates. "
            "Use when the user asks how many days are between two dates, "
            "or how long until a future date."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "start": {"type": "string", "description": "Start date YYYY-MM-DD"},
                "end":   {"type": "string", "description": "End date YYYY-MM-DD"},
            },
            "required": ["start", "end"],
        },
    }
]


def run_tool(name: str, params: dict) -> str:
    if name == "days_between":
        start = date.fromisoformat(params["start"])
        end = date.fromisoformat(params["end"])
        return str(abs((end - start).days))
    raise ValueError(f"Unknown tool: {name}")


def chat(user_msg: str) -> None:
    client = Anthropic()
    messages: list[dict] = [{"role": "user", "content": user_msg}]

    total_in, total_out = 0, 0
    MAX_ITER = 5

    for i in range(1, MAX_ITER + 1):
        response = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=1024,
            tools=TOOLS,
            messages=messages,
        )
        total_in += response.usage.input_tokens
        total_out += response.usage.output_tokens

        if response.stop_reason != "tool_use":
            # Final assistant text
            for block in response.content:
                if getattr(block, "type", None) == "text":
                    print(f"\n[final] {block.text}")
            print(f"\nTotal usage over {i} iter(s): in={total_in} out={total_out}")
            return

        # Collect ALL tool_use blocks, run them, prepare ALL tool_results
        tool_uses = [c for c in response.content if c.type == "tool_use"]
        tool_results = []
        for tu in tool_uses:
            print(f"[iter {i}] Claude wants: {tu.name}({json.dumps(tu.input)})")
            try:
                result = run_tool(tu.name, tu.input)
                print(f"[iter {i}] tool result: {result}")
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": tu.id,
                    "content": [{"type": "text", "text": result}],
                })
            except Exception as e:
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": tu.id,
                    "content": [{"type": "text", "text": f"Error: {e}"}],
                    "is_error": True,
                })

        # Append assistant message + tool_results, then loop
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})

    print(f"\n[!] Hit MAX_ITER={MAX_ITER}, stopping.")


if __name__ == "__main__":
    chat("Скільки днів між 2024-01-01 і 2024-08-15?")
    print("\n" + "=" * 60 + "\n")
    chat("Я народився 1995-03-12. Скільки мені днів станом на 2026-04-26?")
