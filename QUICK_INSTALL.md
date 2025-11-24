DbReplacer — Desktop tool to switch Laravel database configs (Zenity + Bash)

Overview
---
DbReplacer is a small desktop utility that swaps a Laravel `config/database.php`
using environment templates. It provides a Zenity GUI for interactive use and a
non-interactive `--apply` mode for scripting and CI. Distributed as a `.deb`.

Key features
---
- Simple Zenity GUI to pick templates and a target Laravel project.
- Non-interactive `--apply <Local|Beta|Live>` mode for automation.
- Timestamped backups saved in `~/.dbreplacer_backups` (keeps the last 20).
- Packaged as a Debian `.deb` with icons and desktop integration.
- Includes `install-deb.sh` helper to install the `.deb` safely from `/tmp`.

Quick install (recipient)
---
Copy to `/tmp` and install with APT so runtime dependencies are resolved:

```bash
sudo cp ./dbreplacer-1.0.deb /tmp/
sudo apt install /tmp/dbreplacer-1.0.deb
```

Or, if you distribute the helper script alongside the .deb:

```bash
./install-deb.sh ./dbreplacer-1.0.deb
```

Quick usage
---
- GUI: `dbreplacer`
- Non-interactive:
```bash
DB_DIR_OVERRIDE=/path/to/templates DB_TARGET_OVERRIDE=/path/to/laravel/config dbreplacer --apply Local
```

Notes
---
- The `.deb` should declare runtime dependencies (e.g. `zenity`) so APT can
  install them automatically. If you see `_apt` sandbox warnings when installing
  from a private home directory, copy the `.deb` to `/tmp` first.

Topics: debian, zenity, bash, laravel, desktop-utility
