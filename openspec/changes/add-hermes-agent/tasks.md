## 1. Prerequisites

- [x] 1.1 Archive `remove-openclaw` first.
- [x] 1.2 pim creates an OpenCode Go API key in the OpenCode Zen console.
- [x] 1.3 Create `@hermes` on Tuwunel (done with `tuwunel --maintenance --execute "users create-user ..."`); pim's Matrix ID is `@pim:nuremberg.pimsnel.com`.
- [x] 1.4 Decide the default model: `glm-5.2`.

## 2. Secrets

- [x] 2.0 `hermes-matrix-password.age` (`MATRIX_PASSWORD=...`, pim and peterspav) holds the generated bot password.
- [x] 2.1 `hermes-env.age` (`OPENCODE_GO_API_KEY=...`, pim and peterspav); checked against `/zen/go/v1/usage` (HTTP 200).
- [x] 2.1a Add `hermes-dashboard-token.age` (pim, peterspav) with a random token.
- [x] 2.1b Configure image generation with the `openai-codex` provider and TTS with `edge` in `settings`.
- [ ] 2.2 Add peterspav to the recipients of `restic-ssh-key.age` and `restic-repo-pw.age`; pim runs `agenix -r`.

## 3. Hermes

- [x] 3.1 Add the `hermes-agent` flake input (no `follows`) and import its NixOS module on peterspav.
- [x] 3.2 Configure `services.hermes-agent`: `settings.model` (provider `custom`, Go base URL, default model), `environmentFiles`, Matrix variables in `environment`.
- [x] 3.3 Read the Matrix plugin and toolset configuration in the Hermes source; set the user-ID variable and disable vision, web summarization and mixture of agents.
- [x] 3.4 Configure the backend: mode `dashboard`, host `192.168.100.16`, port 9119, `waitFor = "interface"`, `interfaceName = "nebula.mesh"`, `sessionTokenFile` from the secret.
- [x] 3.5 Register `hermes` in lobby.

## 4. peterspav as a server

- [x] 4.1 logind: ignore lid switch (also on external power and docked) and idle action.
- [x] 4.2 Disable GNOME automatic suspend for GDM and for pim's session.

## 5. Backup

- [x] 5.1 Import `backup-restic-piethein` on peterspav with a `peterspav-hermes` dataset; add a `prepareCommand` that copies live SQLite files with `.backup` when the state directory has them.

## 6. Build and deploy

- [x] 6.1 `git add` new files; build peterspav and check the secrets are not in the closure.
- [ ] 6.2 Rebuild peterspav (`rme up_machine` on peterspav, or `nixos-rebuild --target-host`).

## 7. Verify

- [ ] 7.1 After a reboot without login, the Hermes service is active.
- [ ] 7.2 pim's direct message to `@hermes` gets a reply from the Go model; a message from another account gets none.
- [ ] 7.3 The dashboard opens from a mesh member with the token and does not answer on peterspav's LAN address.
- [ ] 7.4 With the lid closed for ten minutes, peterspav stays reachable.
- [ ] 7.5 The first `peterspav-hermes` snapshot exists on piethein and appears in Backrest.
- [ ] 7.6 `lobby show hermes` shows the dashboard.
- [ ] 7.7 pim runs `hermes auth add openai-codex` on peterspav; asking `@hermes` for an image returns one.
- [ ] 7.8 A spoken reply (Edge TTS) arrives in Matrix as audio.
