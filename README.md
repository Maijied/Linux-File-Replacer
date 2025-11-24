# DbReplacer — Laravel DB Config Switcher (desktop)

A small desktop utility (Zenity + Bash) packaged as a Debian package that swaps a Laravel
`config/database.php` by copying one of three template files:
`database.local.php`, `database.beta.php`, or `database.live.php`.

Requirements
---
- Linux desktop (tested on Ubuntu 18.04, 20.04, 22.04 and later)
- `bash` and `zenity` (package `zenity` is a runtime dependency)

Install
---
System-wide (.deb)
```bash
# build (developer) then install
fakeroot dpkg-deb --build /path/to/dbreplacer-1.0
sudo dpkg -i /path/to/dbreplacer-1.0.deb
# after install (postinst runs by default) you can refresh caches manually:
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
sudo update-desktop-database /usr/share/applications
```

Per-user (no .deb)
```bash
# Place the app folder at ~/DbReplacer and run the short installer
bash ~/DbReplacer/install.sh
# To remove user copy:
bash ~/DbReplacer/uninstall.sh        # keeps backups
bash ~/DbReplacer/uninstall.sh --purge  # also removes backups
```

Uninstall
---
System package (remove)
```bash
sudo dpkg -r dbreplacer        # removes package, runs maintainer scripts
sudo dpkg -P dbreplacer        # purge (if you want to remove package config files)
```

Usage
---
Graphical (menu)
- After installing the package, open your desktop app menu and search for "Laravel DB Config Switcher".
- Click the app to open the Zenity GUI and choose the template and target folder.

From terminal
- Interactive GUI (from terminal):
```bash
dbreplacer           # opens the Zenity GUI (Exec entry points to wrapper)
```
- Non-interactive (scriptable) — useful for CI or testing:
```bash
# supply overrides OR create ~/.dbreplacer_config and ~/.dbreplacer_target
DB_DIR_OVERRIDE=/path/to/templates DB_TARGET_OVERRIDE=/path/to/laravel/config dbreplacer --apply Local
```

Backups
---
- When replacing, the tool creates timestamped backups in `~/.dbreplacer_backups` (keeps last 20).
- To purge backups manually:
```bash
rm -rf ~/.dbreplacer_backups
```

Developer: build & test
---
- Prereqs for building locally:
  ```bash
  sudo apt update
  sudo apt install fakeroot dpkg-dev librsvg2-bin
  ```

Note: the packages above are **build-time** and developer helpers. If you only want
to install the application (not build it), prefer installing the produced `.deb` with
APT so runtime dependencies are resolved automatically. For example:

```bash
# installs the package and pulls any declared runtime dependencies (e.g. zenity)
sudo apt install ./dbreplacer-1.0.deb

# or if you used dpkg and see missing dependencies:
sudo dpkg -i ./dbreplacer-1.0.deb
sudo apt-get install -f
```

Build-only tools like `fakeroot` and `dpkg-dev` are not installed by the .deb — they
are only required if you build locally.
- Build and install (developer):
```bash
fakeroot dpkg-deb --build /path/to/dbreplacer-1.0
sudo dpkg -i /path/to/dbreplacer-1.0.deb
```
- Run acceptance test (after install) — creates temporary folders and runs non-interactive apply:
```bash
sudo cp tests/run_acceptance.sh /tmp && bash /tmp/run_acceptance.sh
```

Icons
---
- Icons are installed to `usr/share/icons/hicolor`:
  - scalable SVG: `usr/share/icons/hicolor/scalable/apps/dbreplacer.svg`
  - raster fallbacks: `usr/share/icons/hicolor/48x48/apps/dbreplacer.png`, `32x32`.
- If icons do not appear immediately, refresh caches or log out/in.

Local .deb install helper
---
- If you distribute the `.deb` file directly, APT runs a sandboxed helper as
  the `_apt` user which must be able to read and traverse the directory where
  the `.deb` lives. If the file is in a non-world-traversable directory
  (for example a private home directory), you may see this warning when
  installing locally:

  ```
  N: Download is performed unsandboxed as root as file '/home/user/pack.deb'
  couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
  ```

- To avoid that warning and to ensure `apt` can read the file, copy the
  `.deb` to a world-accessible directory (for example `/tmp`) before running
  `apt install`. Example:

  ```bash
  sudo cp ./dbreplacer-1.0.deb /tmp/
  sudo apt install /tmp/dbreplacer-1.0.deb
  ```

- Helper script: a convenience script `install-deb.sh` is included at the
  project root. It copies the .deb to `/tmp`, sets ownership to `root:root`
  and permissions to `644`, then runs `sudo apt install /tmp/<file>.deb`.

  Usage:
  ```bash
  ./install-deb.sh ./dbreplacer-1.0.deb
  # or
  ./install-deb.sh /path/to/other-package.deb
  ```

  This is useful when sharing a .deb with teammates who run the installer
  locally from their machine.

Security note
---
- The shipped templates under `opt/dbreplacer/` include example credentials. Remove or sanitize those examples before publishing or sharing the .deb publicly.

Support & next steps
---
- If you want I can:
  - Replace credentials in templates with placeholders,
  - Add CI to build the .deb and run the acceptance test automatically,
  - Publish a release tarball or help prepare a PPA packaging workflow.

---
Questions or changes? Tell me which of the above you'd like next.
# DbReplacer — Laravel DB Config Switcher (desktop)

Small desktop tool (Zenity + Bash) packaged as a Debian package to switch Laravel `database.php` from pre-made templates.

Build & install (developer)
---
- Install build helpers:
```bash
sudo apt update
sudo apt install fakeroot dpkg-dev librsvg2-bin
```
- Build the package:
```bash
fakeroot dpkg-deb --build /home/you/dbreplacer-1.0
sudo dpkg -i /home/you/dbreplacer-1.0.deb
```

Icon notes
---
- Icons are provided as scalable SVG (`usr/share/icons/hicolor/scalable/apps/dbreplacer.svg`) and raster fallbacks (`48x48`, `32x32`) under `usr/share/icons/hicolor`.
- After install, refresh caches (usually run by `postinst` but you can run manually):
```bash
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
sudo update-desktop-database /usr/share/applications
```

Security note
---
- The template files in `opt/dbreplacer/` contain example connection credentials. Treat these as discoverable sensitive data — remove or replace with placeholders before publishing publicly.

Testing (acceptance)
---
- A small acceptance test script is provided at `tests/run_acceptance.sh`. It creates a temporary HOME, template folder, and target config folder, then runs the installed `replace_db_config.sh` in non-interactive mode to verify backup behavior.

Non-interactive usage
---
You can run the launcher headless to apply a template:
```bash
# set overrides OR create ~/.dbreplacer_config and ~/.dbreplacer_target
DB_DIR_OVERRIDE=/path/to/templates DB_TARGET_OVERRIDE=/path/to/laravel/config /usr/local/bin/replace_db_config.sh --apply Local
```

If you want me to scrub credentials from templates, add tests, or publish to a PPA/source, tell me and I will help.
