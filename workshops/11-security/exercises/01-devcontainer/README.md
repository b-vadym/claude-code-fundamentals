# Вправа 1 — Devcontainer для Claude Code

**Мета:** робочий devcontainer, де Claude Code запускається з firewall-обмеженням мережі (default-deny outbound + allowlist).

**Час:** 15 хв.

## Кроки

1. **Огляд starter/**

   ```bash
   ls starter/
   # Dockerfile  devcontainer.json  init-firewall.sh
   ```

   `Dockerfile` — Node 20 base, але бракує security-tools.
   `devcontainer.json` — є базові поля, але без capabilities.
   `init-firewall.sh` — TODO у скрипті.

2. **Допиши `Dockerfile`:** додай `iptables`, `ipset`, `dnsutils`, `sudo`, `claude-code` (через npm).

   ```dockerfile
   RUN apt-get update && apt-get install -y \
       iptables ipset dnsutils sudo curl jq \
       && rm -rf /var/lib/apt/lists/*

   RUN npm install -g @anthropic-ai/claude-code
   ```

3. **Допиши `devcontainer.json`:**

   - `runArgs`: `["--cap-add=NET_ADMIN", "--cap-add=NET_RAW"]`
   - `mounts` для `~/.claude` і shell history (volume)
   - `postCreateCommand`: запустити `init-firewall.sh` з sudo
   - `remoteUser: "node"` (не root)

4. **Допиши `init-firewall.sh`:** додай свій домен у allowlist (наприклад `pypi.org` або `crates.io` — залежно від мови).

5. **Build & test:**

   ```bash
   # У VS Code: Cmd+Shift+P → "Reopen in Container"
   # Або CLI:
   docker build -t claude-sandbox .

   # Тест firewall всередині контейнера:
   curl -m 5 https://example.com         # має FAIL (timeout)
   curl -m 5 https://api.github.com/zen  # має SUCCEED
   ```

6. **Тест Claude Code:**

   ```bash
   claude --version       # має показати версію
   # Спробуй початкову сесію
   claude
   ```

## Очікуваний результат

- Контейнер build-иться без помилок
- `iptables -L | head -20` показує DROP як default, ACCEPT для allowlisted
- `curl https://example.com` failed з 5-секундним timeout
- `curl https://api.github.com/zen` повертає випадкову quote
- Claude Code запускається

## Чого НЕ треба робити (з docs)

- ❌ Не додавай `--privileged` — занадто широко
- ❌ Не давай `/var/run/docker.sock` як mount — full host access
- ❌ Не використовуй `--dangerously-skip-permissions` outside of trusted-repo сесій

## Якщо не вийшло

- `iptables: command not found` → не додав у Dockerfile
- `Operation not permitted` при iptables → бракує `NET_ADMIN`
- DNS не резолвить → додай `--cap-add=NET_RAW` теж
- `solutions/01-devcontainer/` — повний робочий setup

## Bonus

Додай `denied-domains` ipset для відомих C2-серверів (порожній за замовчуванням). Для команди — додай OTel collector як allowed domain.
