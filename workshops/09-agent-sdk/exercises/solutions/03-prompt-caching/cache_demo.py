"""Exercise 03 — Prompt caching (solution).

Two queries against the same large system prompt.
First call: cache_creation_input_tokens > 0, cache_read = 0 (miss).
Second call: cache_creation = 0, cache_read > 0 (hit).
"""

from anthropic import Anthropic


# Opus 4.7 input pricing
PRICE_PER_MTOK_INPUT = 5.0
WRITE_5MIN_MULT = 1.25
WRITE_1H_MULT = 2.0
READ_MULT = 0.1


def large_system_prompt() -> str:
    """~5000-token classification codebook (real-looking content)."""
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


def cost_for(creation: int, read: int, regular: int, ttl: str = "5m") -> float:
    """Compute USD cost for input tokens given the three buckets."""
    write_mult = WRITE_5MIN_MULT if ttl == "5m" else WRITE_1H_MULT
    return (
        creation * PRICE_PER_MTOK_INPUT * write_mult
        + read * PRICE_PER_MTOK_INPUT * READ_MULT
        + regular * PRICE_PER_MTOK_INPUT
    ) / 1_000_000


def main() -> None:
    client = Anthropic()
    system = large_system_prompt()

    questions = [
        "What does Status 0042 mean?",
        "Which SOP chapter applies to Status 0100?",
    ]

    total_creation = total_read = total_regular = 0
    no_cache_input_total = 0

    for i, q in enumerate(questions, 1):
        response = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=512,
            system=[
                {
                    "type": "text",
                    "text": system,
                    "cache_control": {"type": "ephemeral"},  # 5-min default
                }
            ],
            messages=[{"role": "user", "content": q}],
        )
        u = response.usage
        print(
            f"[call {i}] input={u.input_tokens}  "
            f"cache_creation={u.cache_creation_input_tokens}  "
            f"cache_read={u.cache_read_input_tokens}  "
            f"output={u.output_tokens}"
        )

        total_creation += u.cache_creation_input_tokens
        total_read += u.cache_read_input_tokens
        total_regular += u.input_tokens
        # Counterfactual: if NO caching, every call would have full system
        # in the regular input bucket.
        no_cache_input_total += (
            u.cache_creation_input_tokens
            + u.cache_read_input_tokens
            + u.input_tokens
        )

    print("\n" + "=" * 60)
    print(f"Totals → creation={total_creation}, read={total_read}, regular={total_regular}")

    cached_cost = cost_for(total_creation, total_read, total_regular)
    uncached_cost = no_cache_input_total * PRICE_PER_MTOK_INPUT / 1_000_000
    saved = uncached_cost - cached_cost
    pct = (saved / uncached_cost * 100) if uncached_cost else 0

    print(f"Cost without caching: ${uncached_cost:.6f}")
    print(f"Cost with caching:    ${cached_cost:.6f}")
    print(f"Saved:                ${saved:.6f}  ({pct:.1f}%)")


if __name__ == "__main__":
    main()
