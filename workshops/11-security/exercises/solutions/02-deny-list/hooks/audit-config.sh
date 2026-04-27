#!/bin/bash
# audit-config.sh — ConfigChange hook.
# Logs which settings file was modified, when, and the source.

set -euo pipefail

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.config_source // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LOG_DIR="${HOME}/audit"
mkdir -p "$LOG_DIR"
echo "[$TIMESTAMP] config_source=$SOURCE" >> "$LOG_DIR/claude-config.log"

# Optional: send to syslog as well
command -v logger >/dev/null && logger -t claude-config "settings modified: source=$SOURCE"

exit 0
