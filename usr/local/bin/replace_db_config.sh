#!/bin/bash

CONFIG_FILE="$HOME/.dbreplacer_config"
DB_TARGET_CONFIG="$HOME/.dbreplacer_target"

# Non-interactive mode support:
# Usage: replace_db_config.sh --apply <Local|Beta|Live>
# Set DB_DIR_OVERRIDE and DB_TARGET_OVERRIDE env vars to override paths.
NONINTERACTIVE=0
if [[ "$1" == "--apply" ]] && [[ -n "$2" ]]; then
    NONINTERACTIVE=1
    NONINTERACTIVE_CHOICE="$2"
fi

DB_DIR=""
DB_TARGET_DIR=""
if [ -f "$CONFIG_FILE" ]; then
    DB_DIR=$(cat "$CONFIG_FILE")
fi
if [ -f "$DB_TARGET_CONFIG" ]; then
    DB_TARGET_DIR=$(cat "$DB_TARGET_CONFIG")
fi

# If overrides are provided via env, prefer them
if [[ -n "$DB_DIR_OVERRIDE" ]]; then
    DB_DIR="$DB_DIR_OVERRIDE"
fi
if [[ -n "$DB_TARGET_OVERRIDE" ]]; then
    DB_TARGET_DIR="$DB_TARGET_OVERRIDE"
fi

# If running non-interactively, perform the chosen replacement and exit
if [[ "$NONINTERACTIVE" -eq 1 ]]; then
    DB_CHOICE="$NONINTERACTIVE_CHOICE"
    case "$DB_CHOICE" in
        "Local") TEMPLATE_FILE="$DB_DIR/database.local.php" ;;
        "Beta") TEMPLATE_FILE="$DB_DIR/database.beta.php" ;;
        "Live") TEMPLATE_FILE="$DB_DIR/database.live.php" ;;
        *) echo "Unknown choice: $DB_CHOICE" >&2; exit 2 ;;
    esac

    if [[ -z "$DB_DIR" ]] || [[ -z "$DB_TARGET_DIR" ]]; then
        echo "Templates or target not set. Use DB_DIR_OVERRIDE and DB_TARGET_OVERRIDE or create config files." >&2
        exit 3
    fi

    TARGET_FILE="$DB_TARGET_DIR/database.php"
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "Template not found: $TEMPLATE_FILE" >&2
        exit 4
    fi

    if [[ -f "$TARGET_FILE" ]]; then
        BACKUP_DIR="$HOME/.dbreplacer_backups"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="$BACKUP_DIR/database.php.$TIMESTAMP"
        cp "$TARGET_FILE" "$BACKUP_FILE"
        (ls -1t "$BACKUP_DIR"/database.php.* 2>/dev/null | sed -n '21,$p' | xargs -r rm -f) || true
    fi

    cp "$TEMPLATE_FILE" "$TARGET_FILE"
    if [[ $? -eq 0 ]]; then
        echo "OK: $TARGET_FILE updated with $DB_CHOICE; backup (if any) in $BACKUP_DIR"
        exit 0
    else
        echo "Replacement failed." >&2
        exit 5
    fi
fi

INFO_ICON="ℹ️"
FOLDER_ICON="📁"

while true; do
    SHOW_DB_DIR="${DB_DIR:-<Not set>}"
    SHOW_DB_TARGET_DIR="${DB_TARGET_DIR:-<Not set>}"

    # Info bar with icons
    INFO_TEXT="$INFO_ICON  Template Folder: $FOLDER_ICON  $SHOW_DB_DIR\n$INFO_ICON  Database Folder: $FOLDER_ICON  $SHOW_DB_TARGET_DIR"

    DB_CHOICE=$(zenity --list \
        --radiolist \
        --title="Laravel DB Config Switcher" \
        --text="$INFO_TEXT" \
        --column="Pick" --column="Database Environment" \
        TRUE "Local" FALSE "Beta" FALSE "Live" \
        --ok-label="Replace Config" \
        --extra-button="Change Template Folder" \
        --extra-button="Change Database Folder" \
        --cancel-label="Exit" \
        --width=700 --height=520)

    if [[ -z "$DB_CHOICE" ]]; then
        break
    fi

    if [[ "$DB_CHOICE" == "Change Template Folder" ]]; then
        NEW_DB_DIR=$(zenity --file-selection --directory --title="Choose Template Folder" --height=520 --width=700)
        if [[ -n "$NEW_DB_DIR" ]]; then
            DB_DIR="$NEW_DB_DIR"
            echo "$DB_DIR" > "$CONFIG_FILE"
        fi
        continue
    fi

    if [[ "$DB_CHOICE" == "Change Database Folder" ]]; then
        NEW_DB_TARGET_DIR=$(zenity --file-selection --directory --title="Choose Database Folder" --height=520 --width=700)
        if [[ -n "$NEW_DB_TARGET_DIR" ]]; then
            DB_TARGET_DIR="$NEW_DB_TARGET_DIR"
            echo "$DB_TARGET_DIR" > "$DB_TARGET_CONFIG"
        fi
        continue
    fi

    if [[ -z "$DB_DIR" ]] || [[ -z "$DB_TARGET_DIR" ]]; then
        zenity --error --width=700 --text="Please set BOTH template and database folders first."
        continue
    fi

    case "$DB_CHOICE" in
        "Local") TEMPLATE_FILE="$DB_DIR/database.local.php" ;;
        "Beta") TEMPLATE_FILE="$DB_DIR/database.beta.php" ;;
        "Live") TEMPLATE_FILE="$DB_DIR/database.live.php" ;;
        *) continue ;;
    esac

    TARGET_FILE="$DB_TARGET_DIR/database.php"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        zenity --error --text="Template not found:\n$TEMPLATE_FILE"
        continue
    fi

    # Create a timestamped backup of existing database.php (safety)
    if [[ -f "$TARGET_FILE" ]]; then
        BACKUP_DIR="$HOME/.dbreplacer_backups"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="$BACKUP_DIR/database.php.$TIMESTAMP"
        cp "$TARGET_FILE" "$BACKUP_FILE"
        # Keep last 20 backups (optional housekeeping)
        (ls -1t "$BACKUP_DIR"/database.php.* 2>/dev/null | sed -n '21,$p' | xargs -r rm -f) || true
    fi

    cp "$TEMPLATE_FILE" "$TARGET_FILE"
    if [[ $? -eq 0 ]]; then
        zenity --info --width=700 --text="✅ Work Done!\n\n$TARGET_FILE updated with $DB_CHOICE configuration.\nBackup (if any) saved to $BACKUP_DIR"
    else
        zenity --error --text="Replacement failed."
    fi
done

