## Context

The nebula mesh is an overlay network with no name resolution: to SSH to a node you
need its `192.168.100.x` IP, and each host's `/etc/hosts` (via
`networking.extraHosts`) only lists itself. The repo already has proven tmux popup
launchers in `modules/USERS/pim/programs/tmux/default.nix` (`bind S` → smug,
`bind G` → huphop, `bind B` → beans), and `flake.deploy.nodes` shows the merge
pattern for assembling a per-host contributed registry
(`modules/nix/deploy-option.nix` + each host's `deploy.nix` via `self.lib.n` /
`makeDeployNode` in `modules/nix/helpers.nix`).

The node-IP data is currently fragmented:

| node        | in-Nix IP source                     |
|-------------|--------------------------------------|
| durer       | `extraHosts` + `deploy.nix`          |
| dapperehaan | `extraHosts` + `deploy.nix`          |
| hurry       | `extraHosts` + `deploy.nix`          |
| harry       | `extraHosts` + `deploy.nix`          |
| lavendel    | `extraHosts` only                    |
| cichorei    | **none** — only in the encrypted cert|

`flake.deploy.nodes` is clean and structured but covers only the four push-deploy
servers. `cichorei`'s IP is not in Nix at all, so "derive the picker list from
existing confs" is impossible for it without a new declaration. The authoritative
`nebula_hosts` RUNME command (`RUNME.d/00-helpers.sh` → `_nebula_ips_from_certs`)
reads the truth from the certs, but it decrypts `secrets/nebula-*.crt.age` and needs
the SSH-key passphrase — unacceptable on a per-keystroke hot path.

## Goals / Non-Goals

**Goals:**
- A `Prefix + H` `fzf` popup that lists every active nebula host and SSHes into the
  chosen one, window-per-host, in a dedicated `nebula-prive` session.
- One build-time, decryption-free source of truth (`flake.nebulaNodes`) for node →
  IP, with no name/IP repeated across artifacts.
- Fold the currently-missing `cichorei` IP into that registry so laptops are covered.

**Non-Goals:**
- Changing the running mesh, certificates, secrets, or lighthouse topology.
- Migrating `deploy.nix` server IPs onto the new registry (possible follow-up, not
  required here — the registry stays the sole source for the picker either way).
- Mesh-wide hostname resolution (making `ssh durer` work everywhere); the picker
  connects by IP, so this is out of scope.
- Including `peterspav` (nebula role commented out) or `_lego2` (excluded by
  `import-tree`).

## Decisions

### `flake.nebulaNodes` as a merged per-host registry (not a central list)

Add a mergeable `flake.nebulaNodes` option module mirroring `deploy-option.nix`
(`lazyAttrsOf` so multiple modules contribute without collision). Each active host
declares `flake.nebulaNodes.<name> = "<ip>"` from its own file. Chosen over a single
hand-written attrset because the IP already lives per-host today — a central list
would duplicate it. Chosen over parsing `nixosConfigurations.*.networking.extraHosts`
because that forces a full system evaluation of every host and risks an
`inputs.self` recursion loop when read from a home-manager module.

### `extraHosts` derives from the registry

Each host's nebula `extraHosts` self-line is rewritten to consume
`flake.nebulaNodes.<self>` instead of a hard-coded IP literal, so the IP is declared
exactly once (in the registry). This satisfies the "no repetition" constraint and
means a future IP change is a one-line registry edit.

### `self.lib.nebulaHosts` helper feeds the picker

A helper beside `n`/`makeDeployNode` in `helpers.nix` folds `flake.nebulaNodes` into
a `"<name> <ip>"` list. The `pim-tmux` module reads `self.lib.nebulaHosts` at build
time and bakes the lines into a `pkgs.writeShellScriptBin "nebula-ssh"`. Because
`flake.nebulaNodes` is literal strings only, reading it from the home-manager module
does not force a system eval and does not recurse — this is the key reason the
registry is literal data, not derived from `config`.

### Picker binding and connect flow (window-per-host, create-or-select)

`bind H popup -E -w <w> -h <h> nebula-ssh`, placed beside the existing `bind S/G/B`.
`H` (capital) is currently unbound. The `nebula-ssh` script:

```
choice=$(printf '%s\n' "$HOSTS" | fzf ...) || exit 0   # ESC/empty → clean close
name=<field1>; ip=<field2>
tmux has-session -t "=nebula-prive" 2>/dev/null || tmux new-session -d -s nebula-prive
if tmux list-windows -t "=nebula-prive" -F '#W' | grep -qx "$name"; then :   # reuse
else tmux new-window -d -t "=nebula-prive" -n "$name" "ssh pim@$ip"; fi
tmux switch-client -t "=nebula-prive:$name"
```

`fzf` (not `gum filter`) per the requested picker. `popup -E` mirrors the smug/hup
launchers and closes on exit. The `=` target prefix forces exact-name matching.
Create-or-select (rather than always-new-window) is chosen to match the huphop
`hup-tmux-switch` idempotency idiom and avoid stacking duplicate `ssh` windows.

### SSH user is a single constant

The script connects as `pim@<ip>` (the `deploy` `sshUser` and the nebula sshd
`authorized_users` are both `pim`). Kept as one constant in the script rather than a
per-node field, so the registry stays a plain name→IP map.

## Risks / Trade-offs

- **`cichorei`'s IP must be captured by hand** → It is not in Nix; run
  `./RUNME.sh nebula_hosts` once (decrypts certs, needs the SSH passphrase) and copy
  the value into `flake.nebulaNodes.cichorei`. A tasks step covers this; the value is
  not guessed.
- **List freshness is build-time** → A node added after the last `nixos-rebuild`
  won't appear until the next rebuild. Acceptable: adding a node already requires a
  rebuild, and the authoritative `nebula_hosts` command remains for ad-hoc lookups.
- **`inputs.self` recursion when reading the registry** → Mitigated by keeping
  `flake.nebulaNodes` literal strings (no dependence on `config`), so evaluating it
  from the home-manager module cannot cycle back through the system config.
- **A dead `ssh` leaves an idle window** → When the connection drops the window's
  shell exits per tmux defaults; reconnect re-selects or recreates it. No special
  `remain-on-exit` handling planned.
- **`switch-client` from inside a `popup -E`** → Already proven by the existing smug
  (`bind S`) launcher that switches sessions the same way; verified manually in tasks.

## Migration Plan

1. Add the `flake.nebulaNodes` option module and the `self.lib.nebulaHosts` helper.
2. For each active host, add its `flake.nebulaNodes.<name>` entry and rewire its
   `extraHosts` nebula line to derive from it; capture and add `cichorei`'s IP.
3. Add the `nebula-ssh` script and `bind H` to `pim-tmux`.
4. `nixos-rebuild` / home-manager switch; verify `Prefix + H` lists all six nodes
   and connects. Rollback is a straight revert — no runtime mesh state changes.

## Open Questions

- Popup size (`-w`/`-h`): follow the 80%/80% used by `bind G`, or a smaller box
  since the list is short? (Default: match existing launchers unless it feels large.)
