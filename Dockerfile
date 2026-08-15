FROM debian:trixie

ARG CLAUDE_CODE_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates tmux util-linux \
      vim netcat-openbsd wget curl ntpsec less git net-tools psmisc trash-cli dnsutils \
 && rm -rf /var/lib/apt/lists/*

# Claude Code is installed once, at build time, into a fixed location so the
# image itself stays generic; the actual host user/home is applied at
# container start by entrypoint.sh, not baked in here.
ENV CLAUDE_INSTALL_HOME=/opt/claude-code
RUN mkdir -p "$CLAUDE_INSTALL_HOME" \
 && export HOME="$CLAUDE_INSTALL_HOME" \
 && curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
