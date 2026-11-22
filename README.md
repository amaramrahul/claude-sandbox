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
ln -s "$PWD/claude-sandbox/claude-sandbox" ~/.local/bin/claude-sandbox   # any directory on your PATH
```

The image is built on first run and rebuilt whenever the Claude Code version changes.

## Usage

```sh
cd ~/some/project
claude-sandbox                  # start Claude Code, or reattach to this folder's container
claude-sandbox -c               # arguments are passed through to `claude`
CLAUDE_CODE_VERSION=2.1.288 claude-sandbox   # pin a version (also disables auto-update)
```

- Without `CLAUDE_CODE_VERSION`, the latest stable release is used for new containers.
- If a container already exists and you pass arguments, you are asked whether to remove it and start fresh. Otherwise the arguments are ignored.
- Containers are not removed on exit. Clean up with `docker rm claude-sandbox-<folder>-<hash>`, and old images with `docker rmi claude-sandbox:<version>`.

### Security notes

The container is not a hard security boundary.

- The current folder and `~/.claude` (which holds your credentials) are writable from inside it.
- Network access is unrestricted.
- Your git and ssh config are not available inside the container, so commit and push from the host.
