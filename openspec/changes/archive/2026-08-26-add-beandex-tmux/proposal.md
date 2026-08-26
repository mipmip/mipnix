## Why

Tickets live in beans, but they scatter across many repos. Today tmux only reaches
the *single* project under the current pane (`prefix + B` → `beans-tui-popup` →
`beans tui` for the `.beans.yml` at/above cwd). There is no cross-repo view: to look
at another project's tickets you have to `cd` there first. `beandex`
(github:mipmip/beandex) is the index tier above `beans` — it scans configured
directories, lists every repo that has beans tickets (counts, open, last-updated),
and launches `beans tui` for the one you pick, returning you to the index afterward.
This wires it into the flake, manages its (mandatory) config declaratively, and binds
it to a tmux popup as a sibling to `B`.

Bean: [mipnix-r67e](../../.beans/mipnix-r67e--integrate-beandex-in-tmux.md)

## What Changes

- Add `beandex` as a flake input (`github:mipmip/beandex`), following the existing
  `teejay`/`linny` input pattern.
- Add a dedicated home-manager module `pim-beandex` (`modules/USERS/pim/programs/beandex.nix`)
  that:
  - installs `inputs.beandex.packages.${system}.default`, and
  - writes `~/.config/beandex/config.yaml` declaratively (beandex errors out without
    it), with a single scan path: `~` at `max_depth: 2` — matching where pim's repos
    live (`~/<short>.<owner>/<repo>`, per the huphop clone pattern).
- Bind `beandex` to a tmux popup in `modules/USERS/pim/programs/tmux/default.nix`:
  `bind D popup -E -w 90% -h 90% 'beandex'`. `D` = "beanDex", uppercase like the
  popup family (S/G/T/B/P/O) and adjacent to `B` (single-repo beans). No
  `-d '#{pane_current_path}'` — beandex reads its config's scan paths, not cwd.
- Activate `pim-beandex` in the `cli-full` role (`modules/ROLES/home-pim-cli-full.nix`),
  alongside `pim-huphop`.

## Capabilities

### Added Capabilities
- `beandex-tmux`: a cross-repo beans index is available as a tmux popup, with its
  scan configuration managed declaratively so the popup never opens onto an error.

## Impact

- `flake.nix` — new `beandex` input.
- `modules/USERS/pim/programs/beandex.nix` — new module `pim-beandex` (package + config).
- `modules/USERS/pim/programs/tmux/default.nix` — one `bind D` line.
- `modules/ROLES/home-pim-cli-full.nix` — import `pim-beandex`.
- No secrets. `beans` is already on PATH (used by `beans-tui-popup`), so beandex's
  "launch beans for selected repo" needs no extra wiring.
