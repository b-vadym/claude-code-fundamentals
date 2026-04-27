#!/bin/bash
# init-firewall.sh — default-deny outbound, allowlist via ipset.
# Based on anthropics/claude-code/.devcontainer/init-firewall.sh.

set -euo pipefail
IFS=$'\n\t'

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# Default-deny
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# DNS and SSH
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Established/related
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allowlist
ipset create allowed-domains hash:net family inet hashsize 1024 maxelem 65536

ALLOWED_HOSTS=(
  "api.github.com"
  "github.com"
  "registry.npmjs.org"
  "api.anthropic.com"
  "statsig.anthropic.com"
  "sentry.io"
  "marketplace.visualstudio.com"
  "vscode.blob.core.windows.net"
  "update.code.visualstudio.com"
  "pypi.org"
)

for host in "${ALLOWED_HOSTS[@]}"; do
  IPS=$(dig +short "$host" | grep -E '^[0-9.]+$' || true)
  for ip in $IPS; do
    ipset add allowed-domains "$ip" 2>/dev/null || true
  done
done

# Allow outbound to allowlisted IPs
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# Reject everything else with helpful ICMP message
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# Verification
echo "=== Firewall initialized ==="
iptables -L OUTPUT -n --line-numbers | head -20
echo ""
echo "=== Allowed domains in ipset ==="
ipset list allowed-domains | head -20

# Self-test
echo ""
echo "=== Self-test ==="
if curl --connect-timeout 5 -s -o /dev/null https://example.com; then
  echo "FAIL: example.com should be blocked"
  exit 1
else
  echo "OK: example.com blocked"
fi

if curl --connect-timeout 5 -s -o /dev/null https://api.github.com/zen; then
  echo "OK: api.github.com reachable"
else
  echo "FAIL: api.github.com should be reachable (DNS may be slow)"
fi
