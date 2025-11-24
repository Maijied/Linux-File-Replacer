#!/bin/bash
set -euo pipefail

PURGE=0
if [[ "${1:-}" == "--purge" ]]; then
	PURGE=1
fi

echo "Uninstalling Laravel DB Config Switcher (user mode)..."

# Remove desktop entry from user applications
if [[ -f "$HOME/.local/share/applications/DbReplacer.desktop" ]]; then
	rm -f "$HOME/.local/share/applications/DbReplacer.desktop"
	echo "Removed desktop entry from $HOME/.local/share/applications"
else
	echo "No desktop entry found in $HOME/.local/share/applications"
fi

# Remove user icon copies if present
ICON48="$HOME/.local/share/icons/hicolor/48x48/apps/dbreplacer.png"
ICON32="$HOME/.local/share/icons/hicolor/32x32/apps/dbreplacer.png"
if [[ -f "$ICON48" ]]; then
	rm -f "$ICON48" && echo "Removed user icon $ICON48"
fi
if [[ -f "$ICON32" ]]; then
	rm -f "$ICON32" && echo "Removed user icon $ICON32"
fi

# Remove saved config paths (but keep backups unless --purge)
if [[ -f "$HOME/.dbreplacer_config" ]] || [[ -f "$HOME/.dbreplacer_target" ]]; then
	rm -f "$HOME/.dbreplacer_config" "$HOME/.dbreplacer_target"
	echo "Removed saved config pointers (~/.dbreplacer_config, ~/.dbreplacer_target)"
else
	echo "No saved config pointers found"
fi

# Remove app folder if present
if [[ -d "$HOME/DbReplacer" ]]; then
	rm -rf "$HOME/DbReplacer"
	echo "Removed $HOME/DbReplacer"
else
	echo "No $HOME/DbReplacer folder found"
fi

if [[ "$PURGE" -eq 1 ]]; then
	# Purge backups as requested
	if [[ -d "$HOME/.dbreplacer_backups" ]]; then
		rm -rf "$HOME/.dbreplacer_backups"
		echo "Purged backups at $HOME/.dbreplacer_backups"
	else
		echo "No backups directory to purge"
	fi
fi

echo "✅ Uninstall completed. Run 'gtk-update-icon-cache' or log out/in to refresh menus if needed."

