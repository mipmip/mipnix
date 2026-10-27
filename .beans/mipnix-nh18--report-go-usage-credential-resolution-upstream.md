---
# mipnix-nh18
title: report go-usage credential resolution upstream
status: todo
type: task
priority: normal
tags:
    - upstream
created_at: 2026-10-27T14:33:16Z
updated_at: 2026-10-27T14:33:16Z
---

`@mellena1/opencode-go-usage` 0.2.0 resolves the API key from
`~/.local/share/opencode/auth.json` and reads `entry.key ?? entry.apiKey`.
opencode 2.1.1 no longer writes that file. It keeps the OpenCode Console
credential in `opencode.db`, table `credential`, row `integration_id =
'opencode'`, `active = 1`, `label = 'Personal'`. The `value` column holds
JSON:

    {"type":"oauth","methodID":"device","access":"st_...","refresh":"rt_...","expires":...,"metadata":{...}}

The OAuth `access` field works as a bearer token against
`GET https://opencode.ai/zen/go/v1/usage`. It returned 200 and the three
quota windows, so the plugin does not need the wrapper that currently
extracts the token on mipnix. Reading the credential from `opencode.db`
when `auth.json` is absent would let the plugin work without external help.

Suggest order: `options.apiKey`, then `ctx.integration.connection.active`,
then `opencode.db` by `integration_id` / `active`, then legacy `auth.json`.

Second finding, unrelated to the key: the refresh command registers a
keymap layer with `mode: "base"`, while opencode 2.1.1's command palette
queries `getCommandEntries({visibility: "reachable"})` and built-in
plugins register `mode: "global"`. The `ctrl+alt+g` binding works, but
`Go usage refresh` never appears in `ctrl+p`. A global-mode layer would
fix it. The plugin source already notes that the base layer may stay
inactive on beta hosts.
