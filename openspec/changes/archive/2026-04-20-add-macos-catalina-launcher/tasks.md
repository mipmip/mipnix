## 1. Fix annemarie@lavendel config

- [x] 1.1 Add `username = "annemarie"` and `homedir = "/home/annemarie"` to the `annemarie@lavendel` makeHomeConf call in `annemarie-core.nix`

## 2. Create macos-catalina module

- [x] 2.1 Create `modules/USERS/annemarie/macos-catalina/` directory
- [x] 2.2 Add a macOS icon PNG file to the module directory
- [x] 2.3 Create `default.nix` with `flake.modules.homeManager.annemarie-macos-catalina` exporting:
  - `home.file` for the wrapper script at `~/.local/bin/start-macos-catalina.sh` (executable)
  - `home.file` for the icon at `~/.local/share/icons/macos-catalina.png`
  - `xdg.desktopEntries.macos-catalina` with `terminal = true`, icon `macos-catalina`, exec pointing to the wrapper script

## 3. Wire up the module

- [x] 3.1 Add `annemarie-macos-catalina` to the imports list in the `annemarie` home-manager module in `annemarie-core.nix`
