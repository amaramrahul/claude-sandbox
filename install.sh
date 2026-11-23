#!/usr/bin/env bash
# install.sh [--prefix DIR] [--uninstall] - install claude-sandbox for the current user.
#
# Installs to $PREFIX/bin/claude-sandbox and $PREFIX/share/claude-sandbox/
# (Dockerfile, entrypoint.sh). PREFIX defaults to ~/.local; set it with
# --prefix or the PREFIX environment variable (e.g. /usr/local, run via sudo).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--prefix DIR] [--uninstall]

  --prefix DIR   install under DIR (default: $PREFIX or ~/.local)
  --uninstall    remove a previous installation
  -h, --help     show this help
EOF
}

src_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
prefix="${PREFIX:-$HOME/.local}"
action=install

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo "install.sh: --prefix needs a directory" >&2; exit 2; }
      prefix="$2"; shift 2 ;;
    --prefix=*)
      prefix="${1#--prefix=}"
      [ -n "$prefix" ] || { echo "install.sh: --prefix needs a directory" >&2; exit 2; }
      shift ;;
    --uninstall) action=uninstall; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "install.sh: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$prefix" ] || { echo "install.sh: empty prefix" >&2; exit 2; }

bin_dir="$prefix/bin"
share_dir="$prefix/share/claude-sandbox"

if [ "$action" = uninstall ]; then
  rm -f "$bin_dir/claude-sandbox"
  rm -rf "$share_dir"
  rmdir "$prefix/share" "$bin_dir" 2>/dev/null || true
  echo "Removed claude-sandbox from $prefix."
  echo "Containers and images are left alone; remove them with 'docker rm claude-sandbox-<folder>-<hash>' and 'docker rmi claude-sandbox:<version>'."
  exit 0
fi

for f in claude-sandbox Dockerfile entrypoint.sh; do
  [ -f "$src_dir/$f" ] || { echo "install.sh: missing $src_dir/$f" >&2; exit 1; }
done

# Remove first so an old symlink install is replaced, not written through into the clone.
rm -f "$bin_dir/claude-sandbox" "$share_dir/Dockerfile" "$share_dir/entrypoint.sh"

install -d "$bin_dir" "$share_dir"
install -m 755 "$src_dir/claude-sandbox" "$bin_dir/claude-sandbox"
install -m 644 "$src_dir/Dockerfile" "$src_dir/entrypoint.sh" "$share_dir/"

echo "Installed:"
echo "  $bin_dir/claude-sandbox"
echo "  $share_dir/{Dockerfile,entrypoint.sh}"

command -v docker >/dev/null 2>&1 || echo "Note: Docker is required but 'docker' was not found on PATH." >&2
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "Note: $bin_dir is not on your PATH; add it, e.g. export PATH=\"$bin_dir:\$PATH\"" >&2 ;;
esac
