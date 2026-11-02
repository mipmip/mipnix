## Why

Pim wants an always-on agent to talk to from the phone and laptops over
Matrix, with a dashboard to see what it does. peterspav has the most power
of the machines and becomes a server. The OpenCode Go subscription already
pays for capable open models behind an OpenAI-compatible endpoint, so the
agent can use that instead of a separate model account.

## What Changes

- Add the `hermes-agent` flake (github:NousResearch/hermes-agent) as an
  input and run its NixOS module on peterspav as an always-on service.
- Point the model at OpenCode Go: provider `custom`, base URL
  `https://opencode.ai/zen/go/v1`, default model `glm-5.2`, with the
  OpenCode Go API key from agenix as `OPENCODE_GO_API_KEY`.
- Use the existing OpenAI key for image generation and speech.
- Enable the Matrix gateway as `@hermes` on Tuwunel
  (nuremberg.pimsnel.com), answering only pim.
- Run the dashboard backend on peterspav's nebula address, behind the
  dashboard's authentication gate, and register it in lobby.
- Turn off the tools that call OpenRouter on their own (vision, web
  summarization, mixture of agents), since no OpenRouter key exists.
- Make peterspav behave as a server: no suspend on lid close or idle.
- Back up Hermes' state to piethein with restic.

## Capabilities

### New Capabilities

- `hermes-agent`: the always-on Hermes Agent on peterspav, its model
  provider, Matrix gateway, dashboard and state backup.

### Modified Capabilities

- `host-backups`: configured targets gain peterspav's Hermes state.

## Impact

- `flake.nix` and `flake.lock`: new input `hermes-agent`.
- `modules/HOSTS/peterspav-laptop/`: Hermes service, power settings,
  restic dataset, lobby entry.
- `secrets/secrets.nix`: new `hermes-env.age`, `hermes-matrix-password.age`
  and `hermes-dashboard-token.age` (pim, peterspav); peterspav added as a
  recipient of `restic-ssh-key.age` and `restic-repo-pw.age`, which needs a
  rekey by pim.
- Tuwunel on durer: the `@hermes` account, created on 2026-11-02 with an
  admin command because registration is off.
- Shares the OpenCode Go quota (5-hour, weekly, monthly) with opencode.
- Builds after `remove-openclaw`, which clears the previous Matrix bot.
