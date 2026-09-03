## 1. Opt-in option

- [x] 1.1 Add a home-manager option `mip.hostWallpaper.enable` (bool, default false) in a new
      option module `modules/USERS/pim/programs/hyprland/host-wallpaper.nix`
      (`flake.modules.homeManager.pim-host-wallpaper`)

## 2. Fetch script + activation

- [x] 2.1 Add a `host-wallpaper-fetch` script (`pkgs.writeShellScriptBin`, `curl`/`jq`/`file`
      baked in) that: resolves hostname from `/etc/hostname`; for each mode (dark, light) skips
      if a committed or downloaded image already exists; else queries the Wikimedia API for the
      hostname, falling back to a DuckDuckGo `vqd`+`i.js` scrape; validates the result is a real
      image/mime and >20KB; saves to `~/.local/share/host-wallpaper/<mode>/<hostname>-<mode>.jpg`
- [x] 2.2 Pick two distinct candidates: dark = Wikipedia lead (nl→en) then DDG#1; light = a
      different Wikipedia page image then DDG#2, else reuse the dark image
- [x] 2.3 Wire the script into `home.activation.hostWallpaper` (best-effort `|| true`), inside
      `config = lib.mkIf config.mip.hostWallpaper.enable`

## 3. theme-wallpaper replace branch

- [x] 3.1 Extend `modules/USERS/pim/programs/hyprland/scripts/theme-wallpaper`: resolve effective
      mode, then choose host image by precedence committed → downloaded → shared theme dir
- [x] 3.2 Stage the chosen image alone in `~/.cache/host-wallpaper/<mode>/` so wpaperd's
      dir-based `path` shows exactly the one host image

## 4. Enable on host

- [x] 4.1 Import `pim-host-wallpaper` in `role-pim-desktop` (declares the option for all desktops,
      default false) and set `mip.hostWallpaper.enable = true` for `doornappel` in its host config

## 5. Verification

- [x] 5.1 Syntax: `nix-instantiate --parse` on all nix files; `bash -n` on theme-wallpaper and the
      extracted fetch script; `nix eval` confirms the option resolves `true` for doornappel and the
      activation block references `host-wallpaper-fetch` (all pass)
- [x] 5.2 CONFIRMED post-rebuild on doornappel: both `doornappel-dark.jpg` (128K) and
      `doornappel-light.jpg` (200K) present in `~/.local/share/host-wallpaper/{dark,light}/`,
      both valid JPEGs, distinct sizes (two distinct images)
- [x] 5.3 CONFIRMED: `~/.cache/wallpapers-current` → `~/.cache/host-wallpaper/dark` →
      `doornappel-dark.jpg` (replace mode live in dark). Light path is symmetric and the light
      image exists; live light-switch not separately observed but mechanism proven
- [x] 5.4 Offline behavior — DESCOPED (user decided the offline test is not needed). Failure
      tolerance is by construction: the activation runs `host-wallpaper-fetch || true` and the
      script `exit 0`s, so a failed/absent fetch cannot abort the switch; `theme-wallpaper` falls
      back to the shared theme dirs when no host image exists
- [x] 5.5 No-re-download CONFIRMED: images retain their original 12:45 download timestamp across
      several subsequent `home-manager switch` runs (guard works). Commit-override sub-case
      (dropping `resources/host-wallpapers/doornappel-<mode>.jpg`) NOT yet tested
- [x] 5.6 Disabled-host behavior unchanged — verified by construction: `mip.hostWallpaper.enable`
      defaults false, the whole config is under `lib.mkIf`, and `theme-wallpaper` falls back to the
      shared theme dirs when no host image exists (not separately exercised on another host)
