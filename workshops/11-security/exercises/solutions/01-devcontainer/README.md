# Solution: 01-devcontainer

Робочий setup. Build:

```bash
docker build -t claude-sandbox .
docker run --rm -it \
  --cap-add=NET_ADMIN --cap-add=NET_RAW \
  -v claude-code-config:/home/node/.claude \
  claude-sandbox bash
# Усередині:
sudo /usr/local/bin/init-firewall.sh
curl -m 5 https://example.com    # FAIL
curl -m 5 https://api.github.com/zen  # OK
claude --version
```

## Що додано порівняно зі starter

- Dockerfile: `iptables ipset dnsutils sudo curl jq` + `npm install -g @anthropic-ai/claude-code`
- devcontainer.json: `runArgs` з NET_ADMIN/NET_RAW, mounts, postCreateCommand
- init-firewall.sh: default-deny, DNS/SSH allow, ipset allowlist, REJECT з ICMP, self-test

## Trade-offs

- DNS allow (53) — теоретично канал exfiltration через DNS tunneling. Для більшості use case-ів прийнятно.
- SSH allow (22) — потрібно для git clone via SSH. Якщо тільки HTTPS — приберіть.
- `pypi.org` додано як приклад для Python-проєктів. Для JS-only проєктів зайве.

## Подальші кроки

- Додати OTel collector domain (для team-deployments)
- Pin specific Claude Code version у Dockerfile (`@anthropic-ai/claude-code@1.x.y`)
- Додати GitHub IP ranges via API call (динамічно) — як у Anthropic-офіційному скрипті
