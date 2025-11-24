#!/bin/bash
set -euo pipefail
# Acceptance test: runs the installed replace_db_config.sh in non-interactive mode

TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

TEST_HOME="$TMPROOT/home"
mkdir -p "$TEST_HOME"

TEMPLATES="$TMPROOT/templates"
TARGET="$TMPROOT/target"
mkdir -p "$TEMPLATES" "$TARGET"

# create small template files (do not change originals in repo)
echo "<?php return ['env' => 'local'];" > "$TEMPLATES/database.local.php"
echo "<?php return ['env' => 'beta'];" > "$TEMPLATES/database.beta.php"
echo "<?php return ['env' => 'live'];" > "$TEMPLATES/database.live.php"

# Run the installed script in non-interactive mode using a fake HOME so backups live under TMPROOT
export DB_DIR_OVERRIDE="$TEMPLATES"
export DB_TARGET_OVERRIDE="$TARGET"
export HOME="$TEST_HOME"

echo "Running non-interactive apply (Local) against temp target: $TARGET"
/usr/local/bin/replace_db_config.sh --apply Local

echo "Checking results..."
if [[ ! -f "$TARGET/database.php" ]]; then
  echo "FAIL: target file not created" >&2
  exit 1
fi

echo "Target file contents:" && cat "$TARGET/database.php"

echo "Checking backup directory in fake home..."
if compgen -G "$TEST_HOME/.dbreplacer_backups/database.php.*" > /dev/null; then
  echo "Backup(s) created:" && ls -l "$TEST_HOME/.dbreplacer_backups/"
else
  echo "No previous database.php existed so no backup is expected.";
fi

echo "Acceptance test completed successfully. Temporary data in $TMPROOT will be removed."
