## Why

Services run on dapperehaan, durer, hurry, stinkie and piethein, each reached
in its own way: nebula only, LAN, public domain, a cloudflared tunnel, or
localhost. Finding where one runs and how to open it means reading host
files, and no overview stays current by itself.

Related task: [mipnix-65y7](../../../.beans/mipnix-65y7--lobby-central-services-map-with-web-page-and-cli.md)

## What Changes

- Add a flake-level registry, `lobby.services`, filled with one entry
  per service in the module that configures it. Each entry records the file
  and line where it is defined.
- Generate one JSON file from the registry at build time.
- Serve a static page built from that JSON at `http://lobby/` on
  dapperehaan, nebula only, following the design in `lobby-design/`.
- Add a `lobby` command on the global PATH with the JSON baked in: list,
  `show`, `open` and `--json`.
- Make `lobby` resolve to dapperehaan's nebula address on every mesh member.
- Register the current services, including piethein's DSM, which is not a
  NixOS host.

## Capabilities

### New Capabilities

- `lobby`: the services registry, the generated JSON, the web page and the
  CLI.

### Modified Capabilities

None.

## Impact

- New: `modules/lobby/` (registry option, JSON generation, manual entries),
  `packages/lobby/` (page template and CLI).
- One registry entry added to each module that configures a listed
  service: Grafana, Prometheus, Backrest, linny-mcp, Samba, Syncthing,
  Immich, Uptime Kuma, Vaultwarden, Tuwunel, umami, voorzetramenshop and the
  durer sites.
- The nebula module's generated `networking.extraHosts` gains a `lobby`
  alias, so every mesh member changes once.
- dapperehaan gains nginx on `192.168.100.2:80`.
- The CLI is installed through the home-manager desktop and CLI roles.
