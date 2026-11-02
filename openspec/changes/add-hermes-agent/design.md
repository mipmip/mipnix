## Context

Hermes Agent ships a flake with a NixOS module (`services.hermes-agent`):
declarative `settings` written to Hermes' config, `environmentFiles` for
secrets, a `backend.mode` of `none`, `serve` or `dashboard`, and a Matrix
platform plugin configured through `MATRIX_*` variables
(`plugins/platforms/matrix/plugin.yaml`). OpenCode Go exposes an
OpenAI-compatible endpoint at `https://opencode.ai/zen/go/v1`; its model list
on 2026-11-02 includes glm-5.3, kimi-k3, qwen3.8-max and deepseek-v4-pro.
opencode itself authenticates with an OAuth token in `opencode.db`, which is
not a key another tool can use. Tuwunel on durer has registration and
federation off. peterspav is a GNOME laptop with its firewall disabled and
nebula address `192.168.100.16`.

## Goals / Non-Goals

**Goals:**

- Hermes runs unattended on peterspav, survives reboots, and answers pim on
  Matrix.
- The dashboard is reachable from mesh members only and requires a token.
- Secrets never enter the Nix store.
- Hermes' memory and skills survive a reinstall of peterspav.

**Non-Goals:**

- Other messaging platforms, voice, or the Hermes Desktop application.
- Models outside OpenCode Go, or an OpenRouter account.
- Container mode (`container.enable`): the plain systemd service is enough.
- Public access to the dashboard.

## Decisions

- **NixOS module, not home-manager.** An always-on service belongs to the
  system: it starts at boot without a login session, and the module creates
  its own user and state directory.
- **Flake input without `follows`.** Hermes pins a Python lock against its
  own nixpkgs; forcing mipnix' nixpkgs risks a broken Python closure for no
  gain on a single host.
- **Model through the `custom` provider.** `settings.model` sets provider
  `custom`, `base_url = "https://opencode.ai/zen/go/v1"` and default model
  `glm-5.2`, which speaks `/chat/completions`.
  Anthropic-format models on Go (MiniMax) are out, since the custom provider
  does not speak `/v1/messages`.
- **A Go API key, not opencode's token.** pim creates an API key in the
  OpenCode Zen console under the Go subscription. It goes into
  `hermes-env.age` as `OPENAI_API_KEY`. The bot password is in
  `hermes-matrix-password.age` as `MATRIX_PASSWORD`. The service reads both
  through `environmentFiles`.
- **Matrix as `@hermes:nuremberg.pimsnel.com`.** Non-secret variables
  (`MATRIX_HOMESERVER`, the user ID, `MATRIX_ALLOWED_USERS` set to
  `@pim:nuremberg.pimsnel.com`) go into `environment`; the password into the secret file.
  `MATRIX_ALLOW_ALL_USERS` stays off.
- **Dashboard on the nebula address.** `backend.mode = "dashboard"`,
  `backend.host = "192.168.100.16"`, port 9119, `waitFor = "interface"` on
  `nebula.mesh` so a boot race with nebula does not fail the unit. Binding a
  non-loopback address turns on the dashboard's authentication gate; the
  token comes from `hermes-dashboard-token.age` through
  `backend.sessionTokenFile`. With the host firewall off, the bind address is
  what keeps the dashboard off the LAN.
- **OpenRouter-only tools disabled** in `settings`, so a request never
  silently fails on a missing key.
- **Server power behaviour:** logind ignores the lid switch and idle, and
  GNOME's automatic suspend is turned off for the login screen and pim's
  session. The desktop stays usable.
- **Backup:** peterspav imports `backup-restic-piethein` with a dataset for
  Hermes' state directory (daily 7, weekly 5, monthly 12, yearly unlimited).
  Hermes keeps its state in SQLite, so the dataset dumps it consistently
  first if the state directory holds live database files, as the Grafana
  dataset does.
- **lobby entry** `hermes` with the dashboard URL, category `tools`, access
  `nebula`.

## Risks / Trade-offs

- Hermes changes fast (a release cadence of days). Pinning the input and
  updating deliberately keeps peterspav stable; the cost is lagging behind.
- An agent with tools on an always-on machine can act without supervision.
  The allowlist limits who can instruct it; tool permissions follow Hermes'
  defaults and are revisited after first use.
- Quota is shared with opencode; heavy agent use can exhaust the 5-hour
  window for interactive coding.
- Adding peterspav to the restic secrets needs a rekey with pim's key.

## Open Questions

- Exact settings keys for disabling the OpenRouter tools and the variable
  that carries the Matrix user ID; both are read from the Hermes source at
  implementation time.
