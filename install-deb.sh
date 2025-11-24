#!/usr/bin/env bash
set -euo pipefail

# install-deb.sh - helper to copy a local .deb to /tmp and install it with apt
# Usage: ./install-deb.sh [path/to/package.deb]

DEB_PATH="${1:-./dbreplacer-1.0.deb}"

usage(){
    cat <<EOF
Usage: $0 [path/to/package.deb]

This script copies the specified .deb to /tmp, fixes ownership and perms,
and runs 'sudo apt install /tmp/<package>.deb' so APT can read the file
without sandbox permission errors.

Example:
  ./install-deb.sh ./dbreplacer-1.0.deb
  sudo will be required to copy and install the package.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ ! -f "$DEB_PATH" ]; then
    echo "Error: file not found: $DEB_PATH" >&2
    usage
    exit 2
fi

DEST="/tmp/$(basename "$DEB_PATH")"

echo "Copying $DEB_PATH -> $DEST"
sudo cp -- "$DEB_PATH" "$DEST"

echo "Setting ownership to root:root and perms to 644 on $DEST"
sudo chown root:root "$DEST"
sudo chmod 644 "$DEST"

echo "Installing via apt: sudo apt install $DEST"
sudo apt install "$DEST"

echo "Done. Installed package from $DEST"

exit 0
