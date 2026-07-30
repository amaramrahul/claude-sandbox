FROM debian:trixie

ARG HOST_USER
ARG HOST_UID
ARG HOST_GID
ARG HOST_HOME
ARG CLAUDE_CODE_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates tmux \
      vim netcat-openbsd wget curl ntpsec less git net-tools psmisc trash-cli dnsutils \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${HOST_GID}" "${HOST_USER}" \
 && useradd -u "${HOST_UID}" -g "${HOST_GID}" -d "${HOST_HOME}" -m -s /bin/bash "${HOST_USER}"

USER ${HOST_USER}
ENV HOME=${HOST_HOME}
ENV PATH=${HOST_HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Without this Claude Code updates itself in the background and the pin stops meaning anything.
ENV DISABLE_AUTOUPDATER=1

RUN curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}"
