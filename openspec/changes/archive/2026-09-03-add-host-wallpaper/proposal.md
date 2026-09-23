## Why

Desktop machines running Hyprland should wear their identity: the wallpaper should represent
the host's name (e.g. `doornappel` → thorn-apple imagery). Today wallpapers come from
committed theme directories (`resources/wallpapers-{dark,light}/`) cycled by wpaperd via the
`theme-wallpaper` symlink script. There is no per-host, name-derived wallpaper. This change
adds an opt-in feature that, on first `home-manager` activation, downloads two host images
(a dark and a light variant) named after the hostname, and makes the desktop show them —
while keeping the existing dark/light theme switching intact.

## What Changes

- Add a `host-wallpaper` fetch script run from a best-effort `home.activation` block. On first
  activation (and only if the images are absent), it resolves the hostname at runtime, searches
  Wikipedia (Wikimedia API) for the term, falls back to a DuckDuckGo image scrape, and saves two
  distinct results as `<hostname>-dark.jpg` and `<hostname>-light.jpg` in a mutable dir.
- Extend `theme-wallpaper` so that on opted-in hosts it points `~/.cache/wallpapers-current` at
  the host's dark/light image (replace mode) instead of the cycled theme dirs — preserving the
  dark/light switch.
- Add an opt-in option (e.g. `mip.hostWallpaper.enable`) so only desktop Hyprland hosts use it;
  everything else keeps today's behavior.
- Hybrid precedence: a committed image (`resources/host-wallpapers/<hostname>-<mode>.jpg`) wins
  over a downloaded one, which wins over the existing theme wallpapers as fallback.

## Capabilities

### New Capabilities
- `host-wallpaper`: opt-in, per-host Hyprland wallpaper derived from the hostname — first-run
  download (Wikipedia → DuckDuckGo fallback) of a dark and light image, shown in replace mode via
  the existing `theme-wallpaper` dark/light switcher, with committed-image override.

### Modified Capabilities
- `theme-wallpapers`: on opted-in hosts, the dark/light target becomes the host image dir rather
  than the shared theme dirs (behavior unchanged when the feature is disabled).

## Impact

- **Code**:
  - `modules/USERS/pim/programs/hyprland/scripts/theme-wallpaper` — branch to host images when enabled.
  - `modules/USERS/pim/programs/hyprland/` (new `host-wallpaper` fetch script + `home.activation`).
  - a new home-manager option module for `mip.hostWallpaper.enable`.
  - enable the option on the desktop host(s) (e.g. `doornappel`).
- **Dependencies**: `curl`, `jq` (Wikimedia JSON), and an image tool for validation; all from nixpkgs.
- **Systems**: Hyprland desktop hosts for user `pim`.
- **Risks**: Impure network fetch at activation (mitigated: best-effort, guarded, self-retrying,
  falls back to theme wallpapers). DuckDuckGo scraping is brittle (mitigated: Wikipedia is primary).
  Search results may be low quality/irrelevant (mitigated by the commit-to-pin hybrid path).
