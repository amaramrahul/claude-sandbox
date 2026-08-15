#!/usr/bin/env bash
# Runs as root; creates/adjusts the container user to match the host user
# passed in via env vars, then drops privileges and execs the real command.
set -euo pipefail

HOST_UID="${HOST_UID:-0}"
HOST_GID="${HOST_GID:-0}"
HOST_USER="${HOST_USER:-root}"
HOST_HOME="${HOST_HOME:-/root}"

getent group "$HOST_GID" >/dev/null 2>&1 || groupadd -g "$HOST_GID" "$HOST_USER"
getent passwd "$HOST_UID" >/dev/null 2>&1 || useradd -u "$HOST_UID" -g "$HOST_GID" -d "$HOST_HOME" -m -s /bin/bash "$HOST_USER"

export HOME="$HOST_HOME"
export PATH="$CLAUDE_INSTALL_HOME/.local/bin:$HOST_HOME/.local/bin:$PATH"

# This container is always a throwaway sandbox, so tell Claude Code it's
# safe to bypass its root/sudo guard on --dangerously-skip-permissions
# (which otherwise refuses to start when HOST_UID is 0).
export IS_SANDBOX=1

exec setpriv --reuid="$HOST_UID" --regid="$HOST_GID" --init-groups "$@"
