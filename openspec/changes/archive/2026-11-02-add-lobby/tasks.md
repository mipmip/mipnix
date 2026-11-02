## 1. Registry

- [x] 1.1 Add `modules/lobby/option.nix` with `lobby.services` (submodule: `title` defaulting to the key, `description`, `host`, `url` nullable, `access` enum, `category`).
- [x] 1.2 Compute `source` per entry with `builtins.unsafeGetAttrPos`, made relative to the repository root; null when unknown.
- [x] 1.3 Generate the JSON (`generated.commit`, `generated.date`, `services`), escaping `<` as `<`; expose it as a flake output so both consumers use the same file.

## 2. Page

- [x] 2.1 Move `lobby-design/reference/index.template.html` to `packages/lobby/`; replace the Google Fonts link with `@font-face` rules for IBM Plex woff2 files from `pkgs.ibm-plex`.
- [x] 2.2 Build the page with `runCommand`: substitute `@REGISTRY_JSON@`, copy `lobby.json` and the fonts next to `index.html`.
- [x] 2.3 Add a NixOS module serving it with nginx on dapperehaan's nebula IP port 80, `server_name lobby`, after `nebula@mesh.service`; import it in dapperehaan.
- [x] 2.4 Add `lobby` as an alias of dapperehaan in the nebula module's generated `networking.extraHosts`.

## 3. CLI

- [x] 3.1 Write `packages/lobby/lobby.sh` (jq over the baked-in JSON): grouped list, colours only on a TTY, `show`, `open`, `--json`, close-match suggestions.
- [x] 3.2 Add the `gum filter` picker on a TTY when gum is available.
- [x] 3.3 Package it as `lobby` and install it through the home-manager CLI role.

## 4. Register services

- [x] 4.1 Resolve the open questions: Immich access and address, Vaultwarden domain, linny-mcp in or out.
- [x] 4.2 Add entries in their own modules: Grafana, Prometheus, Backrest, linny-mcp, Samba, Syncthing, Immich, Uptime Kuma, Vaultwarden, Tuwunel, umami, voorzetramenshop, studio-mint, pimsnel.com sites. Build URLs from configured ports and `flake.nebulaNodes` where possible.
- [x] 4.3 Add piethein's DSM in `modules/lobby/manual.nix`.

## 5. Build and deploy

- [x] 5.1 Build dapperehaan and this laptop; compare `lobby` output with `lobby-design/reference/cli-output.txt`.
- [x] 5.2 Deploy dapperehaan; rebuild this laptop.

## 6. Verify

- [ ] 6.1 `http://lobby/` from this laptop shows every service with source locations; filter and host buttons work.
- [x] 6.2 The page loads with the network tab showing no external requests.
- [x] 6.3 Port 80 on dapperehaan's LAN address does not serve the page.
- [ ] 6.4 `lobby`, `lobby show grafana`, `lobby open grafana`, `lobby open grafan`, `lobby open samba` and `lobby | cat` behave as in the CLI reference.
- [x] 6.5 The page at 390px width shows stacked cards without horizontal scroll.
