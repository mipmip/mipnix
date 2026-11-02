## Context

mipnix already keeps flake-level registries of plain data that hosts fill
from their own files and others read: `flake.nebulaNodes`,
`flake.resticRepos`, `flake.syncthingDevices`. They exist so that consumers
never evaluate another host's `nixosConfiguration`, which would create an
evaluation cycle. dapperehaan serves the other nebula-only UIs (Grafana on
`:3000`, Backrest on `:9898`). The design handoff in `lobby-design/` fixes
the look of the page, the CLI output and the JSON contract between them.

## Goals / Non-Goals

**Goals:**

- One place, in the browser and in the terminal, that lists every service
  with its host, how it is reached, its URL and where it is configured.
- Adding a service means adding one entry next to its configuration.
- The CLI works without dapperehaan.

**Non-Goals:**

- Up/down status per service (later: a blackbox exporter over the registry).
- Authentication on the page; nebula membership is the access control.
- Deriving services automatically from `services.*.enable`.
- Feeding Uptime Kuma or Grafana from the registry.

## Decisions

- **Registry option `flake.lobby.services`**, an attrset of submodules with
  `title` (defaults to the key), `description`, `host`, `url` (nullable),
  `access` (enum `nebula`, `lan`, `public`, `tunnel`, `local`) and
  `category`. Defined like `nebula-nodes-option.nix`, so it merges across
  modules. Rejected: reading `services.*.enable` from every host, which
  misses custom units such as Backrest and cannot tell how a service is
  reached.
- **Source location from `builtins.unsafeGetAttrPos`**, taken on the entry's
  key where it is defined and stored relative to the repository root as
  `file:line`. If the position cannot be found, `source` is null rather than
  failing the build.
- **URLs built from configured values where possible.** A module that sets a
  port or binds a nebula address uses those same values in its entry, so the
  URL cannot drift from the configuration.
- **One JSON file is the contract.** Shape as in
  `lobby-design/README.md`: `generated.commit` from
  `self.shortRev or self.dirtyShortRev`, `generated.date` from
  `self.lastModifiedDate`, and `services` with the computed `source`. `<` in
  values is escaped as `<` so the JSON is safe inside a `<script>`
  element.
- **Page from the design template.** `lobby-design/reference/index.template.html`
  moves to `packages/lobby/` and the JSON replaces `@REGISTRY_JSON@` in a
  `runCommand`. The Google Fonts link is replaced by IBM Plex woff2 files
  from `pkgs.ibm-plex` served next to `index.html`, so the page needs no
  internet access.
- **nginx on dapperehaan**, listening on `192.168.100.2:80` only, with
  `server_name lobby`, ordered after `nebula@mesh.service` like Grafana.
- **`lobby` name through the nebula module.** The module that writes every
  node into `networking.extraHosts` from `flake.nebulaNodes` adds `lobby` as
  an alias of dapperehaan's address, so the name stays derived from the
  registry rather than restated.
- **CLI as a shell script with `jq`** over the baked-in JSON, matching
  `lobby-design/reference/cli-output.txt`: grouped list (categories
  alphabetically, services by key), colours only on a TTY, `gum filter`
  picker on a TTY when gum is present, `show`, `open` via `xdg-open` or
  `open`, `--json`, and close-match suggestions (shared prefix or edit
  distance of at most 2) for unknown names.
- **Non-NixOS entries in `modules/lobby/manual.nix`.** piethein's DSM has no
  module of its own, so it is registered there.

## Risks / Trade-offs

- An entry can be forgotten when a service is added. Mitigation: the
  proposal's tasks register every current service, and a later check can
  compare enabled known services against the registry.
- `unsafeGetAttrPos` is an internal builtin. It has been stable for years;
  if it ever returns null the page shows no source rather than breaking.
- The page lists internal addresses. It is reachable over nebula only, the
  same exposure as Grafana and Backrest.
- Every mesh member rebuilds once for the `lobby` hosts entry.

## Open Questions

- Immich's listen address and access type: the design example shows an
  invented nebula address; stinkie's nebula IP is `192.168.100.17`.
- The Vaultwarden domain, which lives in a secret today.
- Whether linny-mcp belongs in the list (it has no web UI for people).
