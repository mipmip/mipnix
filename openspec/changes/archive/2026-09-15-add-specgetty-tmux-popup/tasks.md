## 1. Update the input

- [x] 1.1 In `flake.nix`, point `specgetty.url` at `github:speclib/specgetty`.
- [x] 1.2 Updated the lock for that input only:
      `github:mipmip/specgetty/6b30460` (2 April 2026, v0.2.0) becomes
      `github:speclib/specgetty/5624fbb` (15 September 2026).
      That revision is main, not the v0.3.0 tag: upstream pushed a
      planning-artifacts commit 16 minutes after releasing, so main is v0.3.0
      plus documentation. The built package reports `specgetty version 0.3.0`,
      which is what the spec asks for. Left tracking main rather than pinning
      the tag, since every other input in this flake tracks its branch.

## 2. Bind the popup

- [x] 2.1 Added the `customBinds` entry: group `tools`, key `A`, description
      "specgetty, openspec projects", and
      `popup -E -d '#{pane_current_path}' -w 90% -h 90% 'spg'`.

## 3. Verification

- [x] 3.1 Built the generated tmux config: `bind A` is present, the menu carries
      the `A` entry and now holds 14 entries, and the config parses with empty
      stderr. Diffed `list-keys -T prefix` against before (whitespace
      normalised): `A` is added and `?` grew its new entry; every other binding
      is byte-identical.
- [x] 3.2 Built the package from the updated input: `spg --version` reports
      0.3.0, `--help` lists `--view` with default `single`, and `--zoom` is
      gone.
- [x] 3.3 Ran 0.3.0 against the existing `~/.config/specgetty/config.yml`: the
      `scandirs` and `followsymlinks` keys are accepted and the scan runs.
      (The three `no such file` errors on the `$HOME/c*`, `$HOME/gh.*` and
      `$HOME/tc*` glob entries appear identically under the installed 0.2.0, so
      they are pre-existing and not caused by this change.)
- [x] 3.4 In a real tmux session on the generated config, `prefix + A` opens a
      popup, confirmed by a second `display-popup` no-opping against the client,
      and `q` closes it.
- [x] 3.5 Ran spg at `/home/pim/mipnix` and at
      `/home/pim/mipnix/openspec/specs/jj-prompt`: both open the `mipnix`
      project, so the walk up from a deep subdirectory works.
- [x] 3.6 Ran spg at `/tmp`: it draws "No OpenSpec project here. Open the
      project picker? (y/n)" and stays up, so nothing flashes past and no
      wrapper script is needed.
- [x] 3.7 Opened the `prefix + ?` menu and pressed `A`: the same popup opens.
