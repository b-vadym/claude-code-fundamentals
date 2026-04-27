#!/usr/bin/env bash
# Solution: вправа 2 — readonly diff review with structured output
# Usage: ./review.sh path/to/diff.patch

set -euo pipefail

DIFF_FILE="${1:-../02-pr-diff-review/sample-diff.patch}"
SCHEMA_FILE="${SCHEMA_FILE:-../02-pr-diff-review/schema.json}"

if [[ ! -f "$DIFF_FILE" ]]; then
  echo "Error: diff file not found: $DIFF_FILE" >&2
  exit 1
fi
if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "Error: schema file not found: $SCHEMA_FILE" >&2
  exit 1
fi

cat "$DIFF_FILE" | claude -p \
  --append-system-prompt "You are a senior code reviewer. Analyze the diff and identify bugs, security issues, and style problems. Output JSON matching the schema with one comment per issue. If diff is fine, return empty comments array." \
  --permission-mode plan \
  --output-format json \
  --json-schema "$(cat "$SCHEMA_FILE")" \
  --max-turns 1 \
  > review.json

# Pretty-print findings
echo "=== Findings ==="
jq -r '.structured_output.comments[] | "\(.severity | ascii_upcase): \(.file):\(.line) — \(.comment)"' review.json

# Cost report
echo
echo "=== Stats ==="
echo "Cost: \$$(jq -r '.total_cost_usd' review.json)"
echo "Turns: $(jq -r '.num_turns' review.json)"

# Severity-based exit
if jq -e '.structured_output.comments[] | select(.severity == "error")' review.json > /dev/null; then
  echo
  echo "FAIL: critical issues found"
  exit 1
fi

echo
echo "OK: no critical issues"
