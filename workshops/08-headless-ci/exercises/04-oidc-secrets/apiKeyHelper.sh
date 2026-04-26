#!/usr/bin/env bash
# Mock apiKeyHelper — simulates fetching API key from Vault.
# In production replace body with: vault kv get -field=key secret/anthropic
#
# Contract (per https://code.claude.com/docs/en/authentication#credential-management):
#   - Output API key on stdout (one line, no trailing space)
#   - Exit 0 on success
#   - Called every 5 min by Claude Code, or on HTTP 401
#   - Override TTL: CLAUDE_CODE_API_KEY_HELPER_TTL_MS

set -euo pipefail

# ---- production version (commented) ----
# vault kv get -field=key secret/anthropic
# ---- mock version ----
echo "sk-ant-mock-$(date +%s)-DO_NOT_USE_FOR_REAL_REQUESTS"
