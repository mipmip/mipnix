## Why

`@mellena1/opencode-go-usage` puts the OpenCode Go quota windows (5-hour,
weekly, monthly) in opencode's session sidebar. The subscription is there and
the endpoint answers:

```
GET https://opencode.ai/zen/go/v1/usage
  Authorization: Bearer <access token from opencode.db>   ->  HTTP 200
```

The plugin still shows nothing, because it cannot find the credential. Its
resolution order was written for opencode 1:

```
resolveApiKey() looks for            v2 actually has
──────────────────────────────       ──────────────────────────────────
~/.local/share/opencode/auth.json -> opencode.db, table `credential`
  { "opencode": { key: … } }          integration_id = 'opencode'   (name matches)
                                      value = {"type":"oauth","access":…,
  entry.key ?? entry.apiKey        ->           "refresh":…,"expires":…}
                                      no .key, no .apiKey
```

Two independent v1 assumptions: the file does not exist any more, and the
credential is an OAuth pair rather than a static key. So even a plugin that
read the database would find nothing under the field names it asks for.

The plugin is otherwise correct for v2: `sidebar.content` is a real v2 TUI slot
(`packages/plugin/src/tui/context.ts:200`) and no Go toolchain is involved,
despite the name.

## What Changes

- Add `@mellena1/opencode-go-usage` to `programs.opencode.settings.plugins` as
  an entry with options, not a bare string.
- Wrap opencode in a shell wrapper that, on every start, reads the active
  credential from `opencode.db` and writes its `.access` field to
  `$XDG_RUNTIME_DIR/opencode-go-key` with mode 0600.
- Point the plugin at that file through opencode's own config substitution:
  `options.apiKey = "{file:{env:XDG_RUNTIME_DIR}/opencode-go-key}"`. The env
  pass runs before the file pass (`config/variable.ts:26`), so the nesting
  resolves and the uid is never hardcoded.
- Use `options.apiKey` rather than `OPENCODE_API_KEY`, because the environment
  variable is not plugin-scoped: opencode reads it itself and prefers it over
  the OAuth connection (`packages/core/src/plugin/provider/opencode.ts:339`),
  which would change how the opencode provider authenticates for actual model
  traffic.

## Capabilities

### New Capabilities

None. This extends how opencode is provisioned.

### Modified Capabilities

- `opencode-provisioning`: gains the plugin and the credential plumbing that
  makes it work. The capability currently covers the pin, the build override
  and the settings.

## Impact

- `modules/programs/dev/vibecoding/opencode.nix`: the plugin entry, and a
  `symlinkJoin` plus `makeWrapper` around the package that the `src` override
  already produces.
- No change to `secrets/`. The credential already exists on the machine, in
  `opencode.db` with mode 0600, maintained by opencode itself. Nothing new is
  encrypted, copied into the store, or added to `secrets.nix`.

Constraints:

- Depends on `pin-opencode-2`. The plugin targets v2 only, and the wrapper sits
  on the package that change introduces.
- The wrapper cannot be another `wrapProgram` on the same binary. Upstream wraps
  with `makeBinaryWrapper`, which does not support `--run` (its setup hook says
  so explicitly), so a shell wrapper has to go around it.
- The access token expires. The one on this machine has roughly 30 days left.
  The wrapper re-reads the database on every start, so a refresh is picked up by
  restarting opencode; a refresh during a long session leaves the widget
  showing stale numbers and a note until the next start.
- `opencode auth` is the only thing that should ever write this credential. The
  wrapper reads it and must never write it back.
- The plugin's peer dependencies (`@opentui/core`, `@opentui/solid`,
  `solid-js`) cannot be verified until opencode 2 actually runs; a TUI plugin
  resolving its own copy of solid-js beside opencode's is a known hazard for
  this kind of plugin. This change is the first chance to find out.
- Related to `mipnix-gh55`, which asks the same question of the two plugins
  already configured. This is the third.
