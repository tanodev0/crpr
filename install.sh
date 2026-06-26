#!/usr/bin/env bash
#
# Installer for sprout on macOS / Linux.
# Copies the `sprout` script into a directory on your PATH.
#
# Usage:
#   ./install.sh            # installs to ~/.local/bin
#   PREFIX=/usr/local ./install.sh   # installs to /usr/local/bin (may need sudo)

set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SRC_DIR/sprout"

# Default install location: ~/.local/bin (no sudo needed).
BIN_DIR="${PREFIX:+$PREFIX/bin}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

if [ ! -f "$SRC" ]; then
  echo "Error: could not find 'sprout' next to this installer." >&2
  exit 1
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$SRC" "$BIN_DIR/sprout"
echo "Installed: $BIN_DIR/sprout"

# Check whether the target dir is on PATH.
case ":$PATH:" in
  *":$BIN_DIR:"*)
    echo "'$BIN_DIR' is already on your PATH. You're ready: try 'sprout --help'."
    ;;
  *)
    echo
    echo "'$BIN_DIR' is not on your PATH. Add this line to your shell profile"
    echo "(~/.zshrc or ~/.bashrc) and restart your terminal:"
    echo
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac
