# lobby — design handoff

Design for the lobby web page and CLI (bean `mipnix-65y7`). This folder belongs next to
that bean; the bean's briefing is the spec, this folder is the look and the expected output.

## Contents

| Path | What it is |
|------|------------|
| `reference/index.template.html` | **The page to ship.** One self-contained HTML file: CSS, light/dark via `prefers-color-scheme`, filter box and host buttons in a small inline script. Contains the placeholder `@REGISTRY_JSON@`. |
| `reference/index.preview.html` | The same page with the example registry filled in. Open it in a browser to see the target. |
| `reference/lobby.example.json` | Example registry JSON, the shape the page and CLI both read. |
| `reference/cli-output.txt` | Expected CLI output for `lobby`, `lobby show`, `lobby open` (incl. errors), `--json`. |
| `canvas/*.dc.html` | The original design-canvas source (desktop light, phone dark, CLI). For reference only; they need the design tool's runtime and won't render standalone. |

The example JSON uses **invented** line numbers, an invented Immich/Uptime Kuma address and a
placeholder Vaultwarden domain. Real values come from the registry; check Immich's listen
address and access, the Vaultwarden domain, and whether linny-mcp belongs (see the bean).

## Data contract

The page and CLI both consume one JSON file generated at build time:

```json
{
  "generated": { "commit": "<short rev>", "date": "YYYY-MM-DD" },
  "services": {
    "<key>": {
      "title": "Grafana",            // optional, defaults to <key>   (addition to the bean's schema)
      "description": "…",
      "host": "dapperehaan",
      "url": "http://192.168.100.2:3000",   // or null: no web UI, shown as "no web UI", not a link
      "access": "nebula",            // nebula | lan | public | tunnel | local  (also the CSS class)
      "category": "monitoring",      // free text, lowercase; page capitalises the first letter
      "source": "modules/services/monitoring/grafana.nix:42"   // from builtins.unsafeGetAttrPos, repo-relative
    }
  }
}
```

- `services` is the `flake.lobby.services` attrset as-is, plus the computed `source`.
- Sorting: categories alphabetically, services by key within each category (attrset order).
- `generated.commit`: `self.shortRev or self.dirtyShortRev or "dirty"`; date from `self.lastModifiedDate`.

## Building the page in Nix

```nix
pkgs.runCommand "lobby-web" { } ''
  mkdir -p $out
  cp ${registryJson} $out/lobby.json
  substitute ${./index.template.html} $out/index.html \
    --replace-fail '@REGISTRY_JSON@' "$(cat ${registryJson})"
''
```

`registryJson` = `pkgs.writeText "lobby.json" (builtins.toJSON { generated = …; services = …; })`.
JSON inside `<script type="application/json">` is safe as long as no value contains `</script`;
escape `<` as `<` when generating if you want to be strict.
Serve `$out` with nginx on dapperehaan, listening on `192.168.100.2:80` only, `server_name lobby`.

**Fonts:** the template links Google Fonts for IBM Plex. On a nebula-only page you may prefer
to drop that `<link>` (falls back to system fonts) or ship the woff2 files from `pkgs.ibm-plex`
next to `index.html` with `@font-face` rules. The design was made with Plex Mono + Plex Sans.

## Visual spec

- Layout: max-width 1120px, 16px side gutters, single column. Each service is one row that
  wraps into a stacked card below ~700px. No horizontal scroll at 390px.
- Type: IBM Plex Mono for the wordmark, keys, hosts, URLs, sources, badges; IBM Plex Sans for
  text. Wordmark 40/600, service name 16/600, body 15, meta 12–13.
- Row: name (link) + `lobby open <key>` hint · description below · host + access badge ·
  URL with source file:line below.
- Access badges are told apart by **style and label**, not colour alone:
  nebula = tinted green fill, lan = outline, public = solid ink, tunnel = dashed outline,
  local = muted grey fill.
- Colours are CSS variables at the top of the template; light and dark sets are both there.
  Accent (links, nebula): `#16614F` light / `#7DD8BC` dark. All text pairs pass 4.5:1.
- Touch targets (search, host buttons) are 44px high.

## CLI notes

See `reference/cli-output.txt`. A shell script with `jq` over the baked-in JSON is enough:
`lobby` lists grouped output (and offers `gum filter` on a TTY), `show`, `open`
(`xdg-open` / `open` on macOS), `--json`. Unknown key → exit 1 with close matches
(e.g. keys that share a prefix, or edit distance ≤ 2).
