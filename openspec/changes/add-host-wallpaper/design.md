## Context

Existing wallpaper flow: `theme-wallpaper dark|light|init` repoints the symlink
`~/.cache/wallpapers-current` at `resources/wallpapers-{dark,light}/` (dirs of committed images);
wpaperd renders whatever that symlink points to. This change layers a per-host, hostname-derived
wallpaper on top, reusing that symlink mechanism so the dark/light switch keeps working.

```
  first `hm switch` (activation, best-effort)
     │  hostname = hostnamectl --static
     ▼
  host-wallpaper fetch  ──Wikipedia (Wikimedia API)──▶ candidate image URLs
     │                     └─(none/error)─▶ DuckDuckGo i.js scrape (fallback)
     ▼   pick 2 distinct → save
  ~/.local/share/host-wallpaper/{dark,light}/<hostname>-<mode>.jpg   (mutable)
     │
  theme-wallpaper dark|light   (opted-in host → points symlink at host dir, else theme dir)
     ▼
  ~/.cache/wallpapers-current ─▶ host dark|light dir ─▶ wpaperd
```

## Decisions

### Decision 1: Two images, slotted dark/light (replace mode)
Per the request: exactly two images per host, `<hostname>-dark.jpg` and `<hostname>-light.jpg`,
each living in its own one-file dir so wpaperd's dir-based config is unchanged. On opted-in hosts
these *replace* the cycled theme wallpapers; the dark/light switch simply chooses which host image
shows.

- **Choice**: two distinct search results assigned to the dark and light slots (they represent the
  host; brightness correspondence is best-effort). Optionally bias with a query suffix ("night"/"day").
- **Alternative rejected**: download one image and derive dark/light variants with ImageMagick —
  cleaner brightness match, but the request is explicitly two downloads. Kept as a possible future toggle.
- **Alternative rejected**: augment the rotation (add host image among others) — the intent is that
  the background *is* the hostname, so replace fits.

### Decision 2: Wikipedia primary, DuckDuckGo fallback
Wikimedia has a real, stable, token-free JSON API and, for real-word hostnames (`doornappel` = Datura),
returns a relevant, licensed lead/article image. DuckDuckGo has no official image API (scrape the
`vqd` token then `i.js`), so it is brittle — used only when Wikipedia yields nothing.

- **Choice**: try Wikipedia first; fall back to DDG; if both fail, leave images absent (theme fallback).
- **Alternative rejected**: DDG-only — fragile and prone to silent breakage.

### Decision 3: Hybrid precedence (committed > downloaded > theme)
Auto-download gives instant gratification; committing the winner makes it reproducible. Resolution
order for each mode: `resources/host-wallpapers/<hostname>-<mode>.jpg` (committed) → the downloaded
file → the shared theme dir (fallback). If a committed image exists, no download happens.

- **Choice**: precedence chain as above.
- **Alternative rejected**: pure download (never reproducible) or pure commit (loses the zero-effort magic).

### Decision 4: Fetch at activation, best-effort and guarded
`home.activation` runs on every `hm switch`; guard with `[ -f <img> ]` so it downloads only the
first time (and self-retries on later switches if the machine was offline). The block MUST NOT fail
activation — network/scrape errors are swallowed (`|| true`), so a failed fetch never breaks
`hm switch`; wpaperd falls back to theme wallpapers until a later switch succeeds.

- **Choice**: guarded, best-effort activation script; hostname read at runtime (no Nix threading).
- **Alternative rejected**: build-time fetch (FOD) — impossible for a dynamically-searched image
  (unknown/changing hash). exec-once at login — activation matches "at home-manager the first time".

### Decision 5: Opt-in per host
Only desktop Hyprland hosts want this. A `mip.hostWallpaper.enable` option gates both the activation
fetch and the `theme-wallpaper` replace branch; when false, behavior is exactly as today.

- **Choice**: per-host `enable` flag, set on `doornappel` (and future desktops).
- **Note**: `doornappel` is not yet a host in the repo; enabling it there may require host scaffolding
  (out of scope here beyond flipping the flag).

## Storage & tooling notes
- Downloaded images live in a mutable dir (`~/.local/share/host-wallpaper/{dark,light}/`), never an
  HM-managed store path (those are read-only symlinks).
- Script deps: `curl` + `jq` for the Wikimedia JSON; a size/format sanity check (reject tiny/HTML
  responses) before accepting a download.
- Wikipedia may expose only one usable image → the second slot falls back to DDG or reuses the first;
  documented as an accepted edge case.
