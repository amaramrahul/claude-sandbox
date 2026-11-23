# claude-sandbox

## Overview

Runs [Claude Code](https://claude.com/claude-code) in YOLO mode (`--dangerously-skip-permissions`) inside a Docker container, so it can work freely without touching the rest of your machine.

- One persistent container per working folder. Running `claude-sandbox` in the same folder again reattaches to it.
- The current folder is mounted at the same path, and `~/.claude` and `~/.claude.json` are shared, so your login and settings carry over.
- The container user mirrors your host UID, GID, username and home, so files it creates are owned by you.
- Claude Code runs inside `tmux`, so detaching and reattaching works.

## Installing

Requirements: Linux, `bash`, `curl`, and Docker.

```sh
git clone https://github.com/amaramrahul/claude-sandbox.git
cd claude-sandbox
./install.sh                      # installs under ~/.local
./install.sh --prefix /usr/local  # or system-wide (run with sudo)
./install.sh --uninstall          # remove it again (add the same --prefix if you used one)
```

This copies the `claude-sandbox` command to `<prefix>/bin` and its `Dockerfile` and `entrypoint.sh` to `<prefix>/share/claude-sandbox`, so the clone can be deleted afterwards. Make sure `<prefix>/bin` (by default `~/.local/bin`) is on your `PATH`. If you previously installed with a symlink, just run `install.sh` again to replace it. To update, pull and re-run `install.sh`.

The image is built on first run and rebuilt whenever the Claude Code version changes.

## Usage

```sh
cd ~/some/project
claude-sandbox                  # start Claude Code, or reattach to this folder's container
claude-sandbox -c               # arguments are passed through to `claude`
CLAUDE_CODE_VERSION=2.1.288 claude-sandbox   # pin a version (also disables auto-update)
claude-sandbox --disable-host-ssh-agent-forwarding      # don't forward the host SSH agent
claude-sandbox --disable-host-claude-config-mapping     # don't mount ~/.claude and ~/.claude.json
claude-sandbox --disable-host-known-hosts-mapping       # don't mount ~/.ssh/known_hosts
```

- Without `CLAUDE_CODE_VERSION`, the latest stable release is used for new containers.
- If a container already exists and you pass arguments, you are asked whether to remove it and start fresh. Otherwise the arguments are ignored.
- The host SSH agent (`SSH_AUTH_SOCK`) is forwarded and `~/.claude`/`~/.claude.json` are mounted by default, as is `~/.ssh/known_hosts` (read-only, only if it exists); the three `--disable-*` flags turn these off. They are not passed to `claude`.
- These options apply only when a container is created. A reused container keeps its original mounts, and its agent socket goes stale if the host's `SSH_AUTH_SOCK` changes (e.g. a new login session); remove the container to recreate it.
- `known_hosts` is read-only, so new host keys accepted in the container are not saved; with the mapping disabled (or no host file), the first connection to a host asks you to confirm its key.
- Containers are not removed on exit. Clean up with `docker rm claude-sandbox-<folder>-<hash>`, and old images with `docker rmi claude-sandbox:<version>`.

### Security notes

The container is not a hard security boundary.

- The current folder and `~/.claude` (which holds your credentials) are writable from inside it.
- Network access is unrestricted.
- The forwarded SSH agent lets anything in the container *use* (not read) your loaded keys while it runs. Use `--disable-host-ssh-agent-forwarding` to avoid this.
- Your git and ssh config files are not available inside the container.
