# Tasks

## 1. Shared ssh agent

- [x] 1.1 Create `modules/USERS/pim/programs/ssh/default.nix` with `pim-ssh`: plain
  `services.ssh-agent`, the stale-socket `ExecStartPre`, session-wide
  `SSH_AUTH_SOCK`, `AddKeysToAgent yes`, and a Linux guard; verify with
  `nix flake check --no-build` or an eval of `pim-ssh` that the options exist
- [x] 1.2 Import `pim-ssh` from `role-pim-cli-minimal`; verify that a CLI-only host
  evaluates the module and that `SSH_AUTH_SOCK` is `%t/ssh-agent` in its
  home configuration
- [x] 1.3 Remove the agent, stale-socket and `AddKeysToAgent` settings from
  `pim-mipbar`, keeping the gcr mask and askpass package; verify the desktop host
  still evaluates and that the agent settings come from `pim-ssh`
- [x] 1.4 Confirm that no session-wide `SSH_ASKPASS` or `SSH_ASKPASS_REQUIRE` is
  exported on a CLI host; verify with `grep` over the generated environment and a
  login shell where the variables are unset

## 2. Status helpers

- [x] 2.1 Add `packages/ssh-key-state/ssh-key-state.sh` and expose it as
  `packages.ssh-key-state`; it prints the four states and the fingerprint, handles a
  missing public key, and bounds the sign check; verify each branch with stub
  `ssh-add`/`ssh-keygen` on `PATH`
- [x] 2.2 Switch `packages/mipbar/widget/SshKey.tsx` to `SSH_KEY_STATE` for both the
  poll and the fingerprint, inject the store path in `flake.nix`, and declare it in
  `env.d.ts`; verify the bundle builds and the widget still shows all four states
- [x] 2.3 Add `tmux-ssh-key` with the 5 second cache, the `--clear` operation and
  the four icon/colour pairs; verify the cache, the clear and the fallback state
  with a stub `ssh-key-state` on `PATH`
- [x] 2.4 Add `tmux-dirty-repos` with the 60 second cache, icon and count, and empty
  output on zero; verify the count, hidden-zero and failed-scan cases with a stub
  `drs` on `PATH`
- [x] 2.5 Add `ssh-key-unlock`: report loaded, load when unloaded, wait on no agent
  or missing key, force `SSH_ASKPASS_REQUIRE=never`, clear the key cache and redraw
  the client; verify the four branches with stubs for `ssh-add`, `tmux` and
  `tmux-ssh-key`
- [x] 2.6 Add a `checks.tmux-status` flake check that runs the shared command and
  the three helpers against stubs and asserts their output; verify with
  `nix build .#checks.x86_64-linux.tmux-status`

## 3. Status bar wiring

- [x] 3.1 Append `#(tmux-ssh-key)` and `#(tmux-dirty-repos)` to `status-right` and
  install the helpers in `home.packages`; verify with `tmux -L test show -g
  status-right` that both commands appear
- [x] 3.2 Set `status-interval` to 15; verify with `tmux -L test show -g
  status-interval`
- [x] 3.3 Add the `prefix + U` binding to `binds.nix` through the hotkey registry;
  verify it appears in the generated bindings and in the `prefix + ?` menu
- [x] 3.4 Start a throwaway tmux server with the generated config and confirm the
  two segments render and that `prefix + U` opens the unlock popup

## 4. Integration

- [x] 4.1 Build a desktop home configuration and a CLI-only home configuration;
  verify both builds succeed
- [ ] 4.2 On a CLI-only host, confirm `ssh-add -l` reports an empty agent, load the
  key with `prefix + U`, and confirm the lock segment turns green without a manual
  redraw
- [ ] 4.3 Confirm `gh` or git over ssh uses the loaded key without a passphrase
  prompt
