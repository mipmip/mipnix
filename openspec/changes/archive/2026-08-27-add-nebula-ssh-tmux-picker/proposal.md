## Why

Connecting to a nebula host over SSH today means remembering (or looking up) its
overlay IP by hand — the mesh has no name resolution and each host's `/etc/hosts`
only knows itself. There is no single place in Nix that lists every nebula node
with its IP: server IPs are duplicated across `extraHosts` and `deploy.nix`, and at
least one laptop (`cichorei`) has no IP in the Nix configs at all — it lives only
inside its encrypted certificate. A `Prefix + H` tmux picker would make "jump to a
host" one keystroke, but only once the host list has a cheap, complete, build-time
source of truth to draw from.

## What Changes

- Introduce `flake.nebulaNodes` — a single-source-of-truth registry mapping each
  active nebula node's name to its overlay IP, assembled from per-host contributions
  (the same merge pattern as `flake.deploy`, see `modules/nix/deploy-option.nix`).
- Each active nebula host declares its IP **once** via `flake.nebulaNodes.<name>`;
  its `networking.extraHosts` nebula self-line is rewired to derive from the
  registry so no name/IP is repeated. `cichorei`'s currently-missing IP is captured
  from its certificate and added to the registry.
- Add a `self.lib.nebulaHosts` helper (sibling to `n`/`makeDeployNode` in
  `modules/nix/helpers.nix`) that folds `self.nebulaNodes` into a picker-ready list.
- Add a `Prefix + H` tmux binding in the `pim-tmux` home-manager module that opens
  an `fzf` popup of all nebula hosts and, on selection, opens (or reuses) a
  per-host window in a dedicated `nebula-prive` session running `ssh pim@<ip>`.

## Capabilities

### New Capabilities
- `nebula-ssh-tmux-picker`: A `Prefix + H` tmux popup that lists every nebula host
  via `fzf` and connects with SSH into a window-per-host `nebula-prive` session.

### Modified Capabilities
- `nebula-mesh-topology`: Adds a single-source node-IP registry (`flake.nebulaNodes`)
  from which each host's `extraHosts` nebula entry is derived, extending the existing
  lighthouse-registry topology model to cover every node.

## Impact

- New file: the `flake.nebulaNodes` option module (mirrors `deploy-option.nix`).
- `modules/nix/helpers.nix` — adds the `nebulaHosts` helper.
- Per-host `networking.nix` / `nebula.nix` for `durer`, `dapperehaan`, `hurry`,
  `harry`, `lavendel`, `cichorei` — each declares `flake.nebulaNodes.<name>` and
  derives its `extraHosts` nebula line from the registry.
- `modules/USERS/pim/programs/tmux/default.nix` — new `nebula-ssh` launcher script
  and `bind H` popup.
- Requires capturing `cichorei`'s nebula IP once via `./RUNME.sh nebula_hosts`
  (decrypts the certificates; needs the SSH-key passphrase).
- No change to the running mesh, secrets, or deploy targets; `peterspav` (nebula
  commented out) and `_lego2` (excluded by `import-tree`) are out of scope.
