## 1. Opt-in option

- [ ] 1.1 Add a home-manager option `mip.hostWallpaper.enable` (bool, default false) in a new
      option module under `modules/USERS/pim/programs/hyprland/`

## 2. Fetch script + activation

- [ ] 2.1 Add a `host-wallpaper-fetch` script (`pkgs.writeShellScriptBin`, with `curl`/`jq` in
      PATH) that: resolves hostname via `hostnamectl --static`; for each mode (dark, light) skips
      if a committed or downloaded image already exists; else queries the Wikimedia API for the
      hostname, falling back to a DuckDuckGo `vqd`+`i.js` scrape; validates the result is a real
      image; saves to `~/.local/share/host-wallpaper/<mode>/<hostname>-<mode>.jpg`
- [ ] 2.2 Pick two distinct candidates for the dark/light slots (optionally bias the query per mode)
- [ ] 2.3 Wire the script into `home.activation` (best-effort: wrap so failure never aborts the
      switch), gated on `mip.hostWallpaper.enable`

## 3. theme-wallpaper replace branch

- [ ] 3.1 Extend `modules/USERS/pim/programs/hyprland/scripts/theme-wallpaper` so that when the
      feature is enabled it targets the host image dir for the selected mode (precedence:
      committed `resources/host-wallpapers/<hostname>-<mode>.jpg` → downloaded → shared theme dir)
- [ ] 3.2 Ensure a one-image dir layout so wpaperd's dir-based `path` keeps working

## 4. Enable on host

- [ ] 4.1 Set `mip.hostWallpaper.enable = true` for the desktop host (e.g. `doornappel`)

## 5. Verification

- [ ] 5.1 Nix syntax-check changed/added files (`nix-instantiate --parse`)
- [ ] 5.2 Post-switch on an enabled host with network: two images `<hostname>-dark.jpg` /
      `<hostname>-light.jpg` appear in the mutable dir
- [ ] 5.3 `theme-wallpaper dark` / `light` switches between the two host images
- [ ] 5.4 Simulate offline: `home-manager switch` still succeeds; wallpaper falls back to theme dirs
- [ ] 5.5 Second switch does not re-download; committing an image overrides the downloaded one
- [ ] 5.6 On a disabled host, behavior is unchanged (shared theme wallpapers)
