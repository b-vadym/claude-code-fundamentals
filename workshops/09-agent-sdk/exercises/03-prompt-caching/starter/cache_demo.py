"""Exercise 03 — Prompt caching (starter).

Завдання: додати cache_control, побачити cache_creation на 1-му запиті
і cache_read на 2-му.
"""

from anthropic import Anthropic


def large_system_prompt() -> str:
    """Generate ~5000-token codebook to be cached.

    Хитрість: робимо не lorem ipsum, а корисний контент — каталог
    статусів обробки документів.
    """
    sections = []
    for code in range(1, 401):
        sections.append(
            f"Status {code:04d}: Internal code for processing stage {code}. "
            f"Indicates that the document has reached intermediate review checkpoint "
            f"number {code}. Operators must follow Standard Operating Procedure "
            f"chapter {(code % 12) + 1}, sub-chapter {code % 7}, when handling "
            f"documents marked with this status. Escalation path: tier "
            f"{(code % 4) + 1} support."
        )
    return "You are a document classification expert.\n\n" + "\n".join(sections)


def main() -> None:
    client = Anthropic()
    system = large_system_prompt()
    print(f"System prompt size: ~{len(system) // 4} tokens (rough)")

    questions = [
        "What does Status 0042 mean?",
        "Which SOP chapter applies to Status 0100?",
    ]

    for i, q in enumerate(questions, 1):
        # TODO: додай cache_control до system block
        response = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=512,
            system=[
                {
                    "type": "text",
                    "text": system,
                    # TODO: "cache_control": {"type": "ephemeral"},
                }
            ],
            messages=[{"role": "user", "content": q}],
        )

        u = response.usage
        print(
            f"[call {i}] input={u.input_tokens}  "
            f"cache_creation={u.cache_creation_input_tokens}  "
            f"cache_read={u.cache_read_input_tokens}"
        )


if __name__ == "__main__":
    main()
