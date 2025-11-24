Purpose
---
This repository packages a small desktop utility (Zenity + Bash) as a Debian package to switch Laravel `database.php` configurations by copying one of three template files into the app's config folder.

Quick architecture overview
---
- **Packaging root**: top-level folder is the deb build tree (contains `DEBIAN/` + `opt/` + `usr/` + `share/`). Build with `dpkg-deb --build <folder>`.
- **Runtime app**: `opt/dbreplacer/` — contains `install.sh`, `uninstall.sh`, and three template files: `database.local.php`, `database.beta.php`, `database.live.php`.
- **Launcher**: `usr/local/bin/replace_db_config.sh` — the interactive Zenity script that: reads `~/.dbreplacer_config` and `~/.dbreplacer_target`, shows a GUI, and copies a chosen template to `<target>/database.php`.
- **Desktop integration**: `share/applications/DbReplacer.desktop` and `share/icons/...` — installer places a .desktop entry for menu launch.

Key behaviors & data flow (what an agent must know)
---
- The Zenity script expects two persisted paths in the user home:
  - `~/.dbreplacer_config` — path to the folder that contains the three `database.*.php` templates.
  - `~/.dbreplacer_target` — path to the Laravel `config/` folder (the script will copy to `<target>/database.php`).
- Template filenames are significant and must match exactly: `database.local.php`, `database.beta.php`, `database.live.php`.
- Replacement is a plain `cp $TEMPLATE_FILE $TARGET_FILE` operation — there is no merge or templating. Tests or code changes should preserve that semantics.
- The GUI offers buttons to change those folders; the script writes the selected paths to the above dotfiles.

Developer workflows and useful commands
---
- To run the UI without installing the .deb (quick dev):
  - `bash usr/local/bin/replace_db_config.sh`
- To install locally (what `install.sh` does for a single user):
  - From a cloned tree run `bash opt/dbreplacer/install.sh` (it copies the .desktop to `~/.local/share/applications` and makes scripts executable).
- To build the Debian package from the parent folder:
  - `dpkg-deb --build /path/to/dbreplacer-1.0`
  - Install with `sudo dpkg -i dbreplacer-1.0.deb`
- To test replacement manually (no GUI):
  - `cp opt/dbreplacer/database.beta.php /path/to/your/laravel/config/database.php`
- To set paths programmatically (mimic GUI choices):
  - `echo /path/to/templates > ~/.dbreplacer_config`
  - `echo /path/to/laravel/config > ~/.dbreplacer_target`

Project-specific patterns and conventions
---
- Small, POSIX-style shell scripts with Zenity for GUI. Keep changes simple and avoid introducing heavy dependencies.
- The repo includes hard-coded example credentials inside the `opt/dbreplacer/database.*.php` templates. Treat them as discoverable sensitive data — avoid leaking new secrets and consider removing or replacing them when modifying templates.
- The `install.sh` and `uninstall.sh` target the user's home (`~/DbReplacer`) rather than system-wide install paths; CI or system packaging uses the `DEBIAN/` metadata instead.
- The package `DEBIAN/control` lists real runtime dependencies: `zenity, bash`. Use that file to update dependency expectations.

Integration points to be careful about
---
- File overwrite: replacement writes to `<target>/database.php` and will replace the file without prompting. Code changes must preserve atomicity (use `mv`/tmp files if adding safety).
- Desktop entry: `share/applications/DbReplacer.desktop` path and permissions must be correct for GNOME/KDE to show the app.
- Environment differences: Installer assumes a Linux desktop user environment with Zenity and `$HOME` GUI session.

Where to look for examples
---
- Installer behavior: `opt/dbreplacer/install.sh`
- Uninstall / cleanup: `opt/dbreplacer/uninstall.sh`
- Launcher / UI: `usr/local/bin/replace_db_config.sh` (main logic and UX)
- Templates: `opt/dbreplacer/database.local.php`, `opt/dbreplacer/database.beta.php`, `opt/dbreplacer/database.live.php`
- Package metadata: `DEBIAN/control`

What I will not do automatically
---
- Remove or sanitize credentials found in templates without explicit instruction.
- Change UX semantics (e.g., add confirmation dialogs) without tests or your approval.

If something is unclear
---
- Tell me whether you want:
  - Credentials scrubbed from templates and replaced with placeholders.
  - A safety/backup step before `cp` (e.g., make a timestamped backup of `database.php`).
  - A system-wide install flow (instead of user-level `install.sh`).

Examples you can copy-paste
---
- Build & install .deb:
```
dpkg-deb --build /home/you/dbreplacer-1.0
sudo dpkg -i dbreplacer-1.0.deb
```
- Set paths without GUI:
```
echo /home/you/templates > ~/.dbreplacer_config
echo /var/www/myapp/config > ~/.dbreplacer_target
bash usr/local/bin/replace_db_config.sh
```

---
Ask me to iterate if you'd like different emphasis (security, packaging, or adding tests).
