## 1. Prerequisites

- [ ] 1.1 Archive `remove-openclaw` first.
- [ ] 1.2 pim creates an OpenCode Go API key in the OpenCode Zen console.
- [x] 1.3 Create `@hermes` on Tuwunel (done with `tuwunel --maintenance --execute "users create-user ..."`); pim's Matrix ID is `@pim:nuremberg.pimsnel.com`.
- [x] 1.4 Decide the default model: `glm-5.2`.

## 2. Secrets

- [x] 2.0 `hermes-matrix-password.age` (`MATRIX_PASSWORD=...`, pim and peterspav) holds the generated bot password.
- [ ] 2.1 Add `hermes-env.age` (`OPENAI_API_KEY=...`) and `hermes-dashboard-token.age` to `secrets/secrets.nix` for pim and peterspav; pim encrypts the values.
- [ ] 2.2 Add peterspav to the recipients of `restic-ssh-key.age` and `restic-repo-pw.age`; pim runs `agenix -r`.

## 3. Hermes

- [ ] 3.1 Add the `hermes-agent` flake input (no `follows`) and import its NixOS module on peterspav.
- [ ] 3.2 Configure `services.hermes-agent`: `settings.model` (provider `custom`, Go base URL, default model), `environmentFiles`, Matrix variables in `environment`.
- [ ] 3.3 Read the Matrix plugin and toolset configuration in the Hermes source; set the user-ID variable and disable vision, web summarization and mixture of agents.
- [ ] 3.4 Configure the backend: mode `dashboard`, host `192.168.100.16`, port 9119, `waitFor = "interface"`, `interfaceName = "nebula.mesh"`, `sessionTokenFile` from the secret.
- [ ] 3.5 Register `hermes` in lobby.

## 4. peterspav as a server

- [ ] 4.1 logind: ignore lid switch (also on external power and docked) and idle action.
- [ ] 4.2 Disable GNOME automatic suspend for GDM and for pim's session.

## 5. Backup

- [ ] 5.1 Import `backup-restic-piethein` on peterspav with a `peterspav-hermes` dataset; add a `prepareCommand` that copies live SQLite files with `.backup` when the state directory has them.

## 6. Build and deploy

- [ ] 6.1 `git add` new files; build peterspav and check the secrets are not in the closure.
- [ ] 6.2 Rebuild peterspav (`rme up_machine` on peterspav, or `nixos-rebuild --target-host`).

## 7. Verify

- [ ] 7.1 After a reboot without login, the Hermes service is active.
- [ ] 7.2 pim's direct message to `@hermes` gets a reply from the Go model; a message from another account gets none.
- [ ] 7.3 The dashboard opens from a mesh member with the token and does not answer on peterspav's LAN address.
- [ ] 7.4 With the lid closed for ten minutes, peterspav stays reachable.
- [ ] 7.5 The first `peterspav-hermes` snapshot exists on piethein and appears in Backrest.
- [ ] 7.6 `lobby show hermes` shows the dashboard.
