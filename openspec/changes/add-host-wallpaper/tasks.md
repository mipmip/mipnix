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
- [ ] 5.2 Post-switch on doornappel with network: two images `<hostname>-dark.jpg` /
      `<hostname>-light.jpg` appear in `~/.local/share/host-wallpaper/` (NEEDS REBUILD + NETWORK)
- [ ] 5.3 `theme-wallpaper dark` / `light` switches between the two host images (NEEDS REBUILD)
- [ ] 5.4 Simulate offline: `home-manager switch` still succeeds; wallpaper falls back to theme dirs
      (NEEDS REBUILD)
- [ ] 5.5 Second switch does not re-download; committing an image overrides the downloaded one
      (NEEDS REBUILD)
- [ ] 5.6 On a disabled host, behavior is unchanged (option defaults false → mkIf no-op; verified
      by construction, confirm post-switch)
