#!/usr/bin/env bash
# Solution: вправа 1 — claude -p locally
# Запускати з директорії 01-print-basic/

set -euo pipefail

# Step 1: prepare sample
cat > sample.txt <<'EOF'
The auth module handles JWT validation, token refresh, and rate limiting.
It uses Redis for session storage and Postgres for user records.
Session tokens expire after 1 hour; refresh tokens after 30 days.
On failed authentication, the module logs to Datadog and increments a counter.
The middleware runs before all /api/v1/* routes except /api/v1/public.
EOF

echo "=== Step 2: text mode ==="
claude -p "Summarize this file in 2 sentences" sample.txt
echo

echo "=== Step 3: JSON mode + jq ==="
claude -p "Summarize this file in 2 sentences" sample.txt \
  --output-format json | jq -r '.result'
echo

echo "=== Step 4: bare mode timing ==="
echo "--- with --bare ---"
time claude --bare -p "Summarize this file in 2 sentences" sample.txt \
  --allowedTools "Read"
echo
echo "--- without --bare ---"
time claude -p "Summarize this file in 2 sentences" sample.txt
echo

echo "=== Step 5: max-turns ==="
claude -p "Refactor this file extensively" sample.txt --max-turns 1 || echo "(exited as expected)"
echo

echo "=== Step 6: production pattern with cost ==="
result=$(claude -p "Summarize" sample.txt --output-format json)
echo "Cost: \$$(echo "$result" | jq -r '.total_cost_usd')"
echo "Turns: $(echo "$result" | jq -r '.num_turns')"
echo "Session: $(echo "$result" | jq -r '.session_id')"
echo "---"
echo "$result" | jq -r '.result'
