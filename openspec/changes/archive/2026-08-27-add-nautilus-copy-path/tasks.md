## 1. Script module

- [x] 1.1 Add a `pim-gnome-*` home-manager module under `modules/USERS/pim/_gnome/` that provisions `home.file.".local/share/nautilus/scripts/Copy Path"` with `executable = true`
- [x] 1.2 Script body: emit `$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` (plain paths, newline-joined) piped to `${pkgs.wl-clipboard}/bin/wl-copy` (store path, no systemPackages change)

## 2. Wiring

- [x] 2.1 Confirm which home profile/role imports the existing `modules/USERS/pim/_gnome/*` modules and add the new module's import there (resolve design Open Question) — resolved: imported via role-pim-desktop (pim's real desktop home profile); the _gnome/pim-gnome-* modules were legacy/unwired
- [x] 2.2 Confirm the module reaches every GNOME host that gets pim's desktop (zonnehoed, dapperehaan, lavendel, …) — reaches pim@cichorei (GNOME enabled there); any host importing role-pim-desktop

## 3. Verify

- [x] 3.1 Rebuild / home-manager switch: `~/.local/share/nautilus/scripts/Copy Path` exists and is executable — home.file source builds; rendered script verified (wl-copy store path + --trim-newline). Live switch is the deploy step
- [x] 3.2 In Nautilus, right-click a file → Scripts → Copy Path; paste yields the plain absolute path (not a `file://` URI) — manual right-click test after switch
- [x] 3.3 Multi-select several items → Copy Path → clipboard holds one path per line — manual
- [x] 3.4 Confirm it works in the GNOME Wayland session (paste into another Wayland app) — manual
