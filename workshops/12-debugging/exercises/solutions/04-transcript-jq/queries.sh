#!/bin/bash
# Solution — jq queries for the session.jsonl investigation.
#
# Run from inside exercises/04-transcript-jq/:
#   bash ../solutions/04-transcript-jq/queries.sh

set -euo pipefail
SESSION="${1:-starter/session.jsonl}"

echo "=== Q1: На якому line compact_boundary? ==="
# `grep -n` показує line number разом з line. Беремо line-num частину.
COMPACT_LINE=$(grep -n '"compact_boundary"' "$SESSION" | cut -d: -f1)
echo "compact_boundary знайдено на line: $COMPACT_LINE"
echo "--- Подія повністю ---"
sed -n "${COMPACT_LINE}p" "$SESSION" | jq .
echo

echo "=== Q2: Початковий 5-кроковий план юзера ==="
# Перший user message — головний план.
jq -r 'select(.type == "user") | .message.content' "$SESSION" | head -1
echo

echo "=== Q3: Tool calls ДО compaction ==="
# Беремо перші N рядків, де N = compact_line - 1, потім фільтруємо tool_use.
head -n "$((COMPACT_LINE - 1))" "$SESSION" \
  | jq -r 'select(.type == "assistant") | .message.content[]?
           | select(.type == "tool_use") | "\(.name): \(.input | tostring | .[:80])"'
echo

echo "=== Q4: Tool calls ПІСЛЯ compaction ==="
# Беремо рядки починаючи з compact_line + 1.
tail -n "+$((COMPACT_LINE + 1))" "$SESSION" \
  | jq -r 'select(.type == "assistant") | .message.content[]?
           | select(.type == "tool_use") | "\(.name): \(.input | tostring | .[:80])"'
echo

echo "=== Bonus: усі hook outputs ==="
jq -r 'select(.type == "system" and ((.subtype // "") | startswith("hook_")))
       | "\(.subtype) [\(.hook)] exit=\(.exit_code) → \(.stdout)"' "$SESSION"
echo

echo "=== Інсайт ==="
cat <<'EOF'
ДО compaction Claude:
  - прочитав src/legacy/payment.py
  - extract PaymentValidator (Edit)
  - створив tests/test_payment_validator.py
  - запустив pytest на новому файлі — pass

Compaction summary каже:
  "PaymentValidator class extracted. Tests written and passing.
   Continuing with documentation updates and integration work."

ПІСЛЯ compaction Claude:
  - зробив pytest (full suite) — НЕ було у плані
  - оголосив "refactor complete" — НЕ було ні docs, ні commit, ні PR

Це класичне «забуття» після compaction: summary узагальнила
(«documentation updates and integration work»), а конкретні кроки
(«5: open PR titled 'Refactor payment validation' against develop»)
розчинились. Юзер мусив повторити план явно.

Mitigation:
  - юзер міг винести план у CLAUDE.md як standing instruction
  - або викликати skill з `disable-model-invocation: true` що тримає чек-ліст
  - або зробити /compact <focus> з явним «keep the original 5-step plan verbatim»
EOF
