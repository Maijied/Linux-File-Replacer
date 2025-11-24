#!/bin/bash
set -euo pipefail

# Simple per-user installer (copies desktop file and makes launcher executable)
APP_DIR="$HOME/DbReplacer"
DESKTOP_SRC="$APP_DIR/DbReplacer.desktop"
LAUNCHER_SRC="$APP_DIR/replace_db_config.sh"
APPLICATIONS_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/48x48/apps"

echo "Installing Laravel DB Config Switcher (user mode)..."

if [[ ! -d "$APP_DIR" ]]; then
	echo "ERROR: Expected application folder not found: $APP_DIR" >&2
	echo "Place the app files in $APP_DIR and re-run this script." >&2
	exit 2
fi

mkdir -p "$APPLICATIONS_DIR" "$ICON_DIR"

if [[ -f "$DESKTOP_SRC" ]]; then
	cp "$DESKTOP_SRC" "$APPLICATIONS_DIR/"
	chmod 0755 "$APPLICATIONS_DIR/DbReplacer.desktop" || true
else
	echo "Warning: desktop file not found at $DESKTOP_SRC" >&2
fi

if [[ -f "$LAUNCHER_SRC" ]]; then
	chmod 0755 "$LAUNCHER_SRC"
else
	echo "Warning: launcher not found at $LAUNCHER_SRC" >&2
fi

# If an icon exists in the app folder, copy it to user icons so desktop can find it
if [[ -f "$APP_DIR/dbreplacer.png" ]]; then
	cp "$APP_DIR/dbreplacer.png" "$ICON_DIR/" || true
fi

echo "✅ Installed (user mode). Look for 'Laravel DB Config Switcher' in your app menu." 


