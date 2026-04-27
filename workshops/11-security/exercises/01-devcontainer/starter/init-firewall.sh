#!/bin/bash
# init-firewall.sh — default-deny outbound, allowlist via ipset
# Based on anthropics/claude-code/.devcontainer/init-firewall.sh

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

# TODO 6: set default policies to DROP
# iptables -P INPUT DROP
# iptables -P FORWARD DROP
# iptables -P OUTPUT DROP

# TODO 7: allow DNS (UDP 53)
# iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# TODO 8: allow SSH (TCP 22)
# iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established/related
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Create ipset for allowed domains
ipset create allowed-domains hash:net family inet hashsize 1024 maxelem 65536

# TODO 9: add at least these domains to allowed-domains
# api.github.com, registry.npmjs.org, api.anthropic.com,
# statsig.anthropic.com, sentry.io
# Plus ONE language-specific domain of your choice (e.g., pypi.org)

ALLOWED_HOSTS=(
  "api.github.com"
  "registry.npmjs.org"
  "api.anthropic.com"
  # "statsig.anthropic.com"
  # "sentry.io"
  # TODO: add more
)

for host in "${ALLOWED_HOSTS[@]}"; do
  IPS=$(dig +short "$host" | grep -E '^[0-9.]+$' || true)
  for ip in $IPS; do
    ipset add allowed-domains "$ip" 2>/dev/null || true
  done
done

# Allow outbound to allowlisted IPs
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# TODO 10: REJECT all other outbound (with helpful message)
# iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

echo "Firewall initialized:"
iptables -L OUTPUT -n --line-numbers | head -20
echo ""
echo "Allowed domains in ipset:"
ipset list allowed-domains | head -20
