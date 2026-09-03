# host-wallpaper Specification

## Purpose
TBD - created by archiving change add-host-wallpaper. Update Purpose after archive.

## Requirements

### Requirement: Opt-in per host
The feature SHALL be gated by a `mip.hostWallpaper.enable` option. When disabled, wallpaper
behavior SHALL be identical to the pre-existing theme-wallpaper behavior.

#### Scenario: Disabled host
- **WHEN** `mip.hostWallpaper.enable` is false (or unset)
- **THEN** no host image is downloaded and `theme-wallpaper` SHALL use the shared theme dirs as before

#### Scenario: Enabled desktop host
- **WHEN** `mip.hostWallpaper.enable` is true on a Hyprland desktop host
- **THEN** the host-wallpaper fetch and the replace-mode wallpaper switching SHALL be active

### Requirement: First-run download of two host images
On an enabled host, a best-effort `home.activation` step SHALL, only when the target images are
absent, download two distinct images and save them as `<hostname>-dark.jpg` and
`<hostname>-light.jpg` in a mutable directory. The hostname SHALL be resolved at runtime.

#### Scenario: First activation with network
- **WHEN** `home-manager switch` runs on an enabled host and the host images do not yet exist
- **THEN** two images SHALL be downloaded and saved as `<hostname>-dark.jpg` and `<hostname>-light.jpg`

#### Scenario: Images already present
- **WHEN** the host images already exist
- **THEN** the activation step SHALL NOT download again

#### Scenario: Self-retry after offline switch
- **WHEN** a previous activation failed to download (e.g. offline) and the images are still absent
- **THEN** a subsequent `home-manager switch` SHALL attempt the download again

### Requirement: Activation never breaks the switch
The fetch step SHALL be best-effort: any network, scrape, or validation failure SHALL NOT cause
`home-manager switch` to fail.

#### Scenario: Download fails
- **WHEN** the fetch cannot obtain a valid image
- **THEN** `home-manager switch` SHALL still complete successfully and wallpaper SHALL fall back to the theme wallpapers

### Requirement: Image source precedence Wikipedia then DuckDuckGo
The fetch SHALL query Wikipedia (Wikimedia API) first and SHALL fall back to a DuckDuckGo image
search only when Wikipedia yields no usable image.

#### Scenario: Wikipedia has an image
- **WHEN** the Wikimedia API returns a usable image for the hostname term
- **THEN** that source SHALL be used and DuckDuckGo SHALL NOT be queried

#### Scenario: Wikipedia yields nothing
- **WHEN** Wikipedia returns no usable image
- **THEN** the DuckDuckGo image scrape SHALL be used as fallback

#### Scenario: Downloaded file is validated
- **WHEN** a candidate is downloaded
- **THEN** it SHALL be rejected if it is not a valid, non-trivial image (e.g. an HTML error or tiny thumbnail)

### Requirement: Hybrid precedence committed over downloaded
For each mode, a committed image at `resources/host-wallpapers/<hostname>-<mode>.jpg` SHALL take
precedence over a downloaded one, which SHALL take precedence over the shared theme wallpapers.
When a committed image exists, no download SHALL occur for that mode.

#### Scenario: Committed image present
- **WHEN** a committed image exists for the current mode
- **THEN** it SHALL be used and no download SHALL happen for that mode

#### Scenario: Only downloaded image present
- **WHEN** no committed image exists but a downloaded one does
- **THEN** the downloaded image SHALL be used

### Requirement: Replace mode preserves dark/light switching
On an enabled host, `theme-wallpaper dark|light|init` SHALL point `~/.cache/wallpapers-current` at
the host's image for the selected mode, keeping the existing dark/light switch semantics.

#### Scenario: Switch to dark
- **WHEN** `theme-wallpaper dark` runs on an enabled host
- **THEN** the wallpaper SHALL become the host's dark image

#### Scenario: Switch to light
- **WHEN** `theme-wallpaper light` runs on an enabled host
- **THEN** the wallpaper SHALL become the host's light image

#### Scenario: Host image missing
- **WHEN** an enabled host has no host image for the selected mode (download failed, none committed)
- **THEN** `theme-wallpaper` SHALL fall back to the shared theme wallpaper dir for that mode
