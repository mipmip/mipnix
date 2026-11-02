## Context

See proposal.md for motivation. What was established by reading the v2 source,
the plugin's published tarball, and the live database:

- The credential lives in `opencode.db`, table `credential`, one active row:
  `integration_id = 'opencode'`, `label = 'Personal'`, `active = 1`. Its `value`
  is JSON with `type` (`oauth`), `methodID` (`device`), `access`, `refresh`,
  `expires` and a `metadata` object carrying `accountID`, `email`, `orgID`,
  `orgName` and `server`. There is no `key` and no `apiKey` field.
- The `account` and `control_account` tables hold no rows; the OAuth pair is in
  `credential.value`.
- Sending the whole JSON blob as a bearer token returns HTTP 401. Sending only
  `.access` returns HTTP 200. So the access token is the usable credential and
  the endpoint accepts it directly.
- `expires` is a millisecond epoch, currently about 30 days out.
- The database runs in WAL mode (`opencode.db-wal` is present and large), so a
  reader does not block while opencode is running.
- `config/variable.ts:26` substitutes `{env:VAR}` across the whole config text
  first, then `{file:path}` over the result. `{file:…}` trims the file content,
  JSON-escapes it, and expands a leading `~/`.
- `tui.tsx:211` reads `ctx.options`, and `resolveApiKey(options)` checks
  `options.apiKey` before the environment and before auth.json, so a plugin
  option is enough on its own.
- `provider/opencode.ts:339` reads `process.env.OPENCODE_API_KEY` and prefers it
  over `snapshot.connection`, the OAuth login.
- The upstream package is wrapped with `makeBinaryWrapper`. Its setup hook
  documents `--chdir` as the replacement for `--run "cd DIR"`, confirming that
  `--run` is unavailable.
- With no key resolvable the widget hides itself rather than erroring, per its
  README. Failure is silent and harmless.

## Goals / Non-Goals

**Goals:**

- The quota windows show up in the sidebar.
- No credential in the Nix store.
- No change to how opencode itself authenticates for model traffic.
- The credential keeps a single owner: `opencode auth`.

**Non-Goals:**

- A static Go API key. Whether the console issues one could not be established
  from the repository or the docs, and this approach does not need one.
- Fixing the plugin's resolution order. Worth an upstream report, not a fork.
- Verifying the other two configured plugins. That is `mipnix-gh55`.
- Surviving a token refresh mid-session without a restart.

## Decisions

### Feed the plugin through `options.apiKey`, not the environment

`OPENCODE_API_KEY` looks like the obvious channel and is the wrong one. It is
read by opencode itself, ahead of the OAuth connection:

```js
const hasKey = Boolean(
  process.env.OPENCODE_API_KEY || snapshot.connection || item.provider.settings?.apiKey
)
```

Setting it would make the opencode provider authenticate with whatever the
wrapper exported, for real model traffic, not only for a sidebar widget. The
value in question is an OAuth access token being passed where opencode expects
an API key, which is asking for a confusing failure.

`options.apiKey` reaches only this plugin. Same credential, no blast radius.

### Reference the file from the config, so the token never enters the store

```nix
options.apiKey = "{file:{env:XDG_RUNTIME_DIR}/opencode-go-key}";
```

The generated `opencode.json` contains that literal string and nothing secret.
opencode resolves it at config load: the env pass rewrites the inner token
first, leaving `{file:/run/user/1000/opencode-go-key}`, which the file pass then
reads and trims. The uid is never written down.

`$XDG_RUNTIME_DIR` is tmpfs at `/run/user/1000`, mode 0700 and owned by the
user, so the copy disappears at logout and is unreadable by anyone else.

Rejected: `~/.cache` or `/tmp/<keyname>`, the path the agenix secrets in
`modules/USERS/pim/agenix-pim.nix` use. Those are on disk and survive a reboot,
which is right for an agenix-managed secret and wrong for a copy of a token
that something else already owns.

### A shell wrapper around the binary wrapper

`makeBinaryWrapper` cannot run a command before exec, so the token extraction
cannot be another `wrapProgram` on the existing binary:

```nix
symlinkJoin {
  paths = [ opencodeWithSrcFix ];
  nativeBuildInputs = [ makeWrapper ];        # the shell one, which has --run
  postBuild = ''wrapProgram $out/bin/opencode --run '<extract the token>' '';
}
```

Two wrapper layers, which costs a process on startup and nothing else. The
`--run` body needs `sqlite3` and `jq` by store path, the same discipline
`claude.nix` already applies to `prose-lint`: never a bare interpreter name.

The extraction has to tolerate every way it can come up empty, a missing
database, no active row, a schema that changed under it, and still let opencode
start. A failed extraction means no file, which means the widget hides itself.
That is the correct outcome and it must not be an error.

### Read the database, never write it

The wrapper only ever runs a `select`. opencode owns this row and refreshes it;
a second writer would be a way to corrupt an auth state that is otherwise
self-maintaining. Reading is safe concurrently because of WAL.

## Risks / Trade-offs

- A refresh during a long session leaves the exported token stale. The widget
  keeps its last known values and adds a note, so the failure is visible and
  mild. With roughly 30 days of validity this should be rare.
- The wrapper encodes opencode's auth schema: a table name, a column, and a
  JSON field. A future version can move it again, exactly as v2 moved it out of
  auth.json. When that happens the widget goes quiet rather than breaking
  opencode, because an empty extraction is a hidden widget.
- A second copy of the token exists while a session runs. On tmpfs, 0600, inside
  a 0700 directory, gone at logout.
- `sqlite` and `jq` join opencode's runtime closure.
- The peer dependency question is still open and this change is what will
  answer it.

## Open Questions

- Should the resolution order be reported upstream? A one-line note that v2
  keeps credentials in `opencode.db` and that `.access` is usable would let this
  wrapper be deleted. Worth a bean either way.
