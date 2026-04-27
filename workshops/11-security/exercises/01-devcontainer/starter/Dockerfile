FROM node:20

# TODO 1: install iptables, ipset, dnsutils, sudo, jq, curl
# RUN apt-get update && apt-get install -y ...

# TODO 2: install Claude Code via npm
# RUN npm install -g @anthropic-ai/claude-code

# Persist shell history
ARG USERNAME=node
RUN mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME:$USERNAME /commandhistory

# Persist Claude config
RUN mkdir -p /home/$USERNAME/.claude \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.claude

# Allow node user to run firewall init via sudo without password
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh
RUN echo "$USERNAME ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
    > /etc/sudoers.d/init-firewall \
    && chmod 0440 /etc/sudoers.d/init-firewall

USER $USERNAME
WORKDIR /workspaces
