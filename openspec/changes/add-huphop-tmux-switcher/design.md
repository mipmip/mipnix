## Context

`hup` (huphop) is a multi-provider git portfolio manager with a TUI. Its
`multiplex` mode is a stripped-down layout meant to be driven from inside tmux:
you pick a repo, it clones on demand, then it runs a per-repo `switch_command`.
Today there is no tmux entry point for it, and its config is a hand-written
`~/.config/huphop/config.yaml` outside home-manager.

The existing `prefix + S` smug launcher (`smg` in
`modules/USERS/pim/programs/shellstuff-cli.nix`) is the proven analogue:
`smug list | gum filter` to pick, then `smug start` + `tmux switch -t`. huphop's
TUI replaces the "list + clone" half; a `switch_command` wrapper replaces the
"create + switch" half. The `huphop` flake input and `hup` binary are already
wired into the home profile.

How huphop executes `switch_command` (verified against huphop source,
`internal/tui/multiplex.go` + `update.go`):

- The string is a Go `text/template` with `missingkey=error`, given fields:
  `.BaseDir .Provider .Type .Short .Host .Owner .OwnerLower .Repo .RepoLower`
  and `.Target` (the resolved local checkout path).
- The rendered string is split with POSIX-ish quote parsing (single/double
  quotes, backslash) and executed **directly via `exec.Command`, without a
  shell** — so `&&`, `;`, `|`, `$()`, globs and env-expansion are unavailable.
- It runs while Bubble Tea still owns the TTY (it is not `tea.ExecProcess`); on
  success the TUI quits (exit 0), which closes the `popup -E`. On failure the TUI
  stays open and shows a status error.

## Goals / Non-Goals

**Goals:**
- A `prefix + G` tmux popup that opens `hup tui --mode multiplex --flatlist`.
- huphop config generated from Nix, reproducing the current working file except
  the multiplex `switch_command`.
- A hermetic switch wrapper implementing session-per-org / window-per-repo, with
  create-or-switch idempotency.

**Non-Goals:**
- Changing huphop itself (under active development).
- Auth/token setup or adding providers.
- Reworking the `management` mode or the smug/`smg` launcher.

## Decisions

### Wrapper binary instead of inline shell in YAML

Because `switch_command` is exec'd without a shell, all branching
(has-session? has-window? switch) must live in a single executable. We ship a
`pkgs.writeShellScriptBin "hup-tmux-switch"` and reference it by store path in
the generated YAML. Alternative — a one-shot `tmux if-shell`/`run-shell`
expression — is rejected: it cannot be expressed as a single no-shell argv and
would still need a wrapper.

### Reference the wrapper by Nix store path (hermetic)

The generated `switch_command` embeds `${hup-tmux-switch}/bin/hup-tmux-switch`
rather than a bare `hup-tmux-switch`, so it resolves regardless of the huphop
process's PATH. This is why the config must be Nix-generated (`pkgs.formats.yaml`)
rather than a static file: the store path is only known at build time.

### Model B — session per org, window per repo

Rendered `switch_command`:

```
'${hup-tmux-switch}/bin/hup-tmux-switch' '{{.Short}}' '{{.OwnerLower}}' '{{.Repo}}' '{{.Target}}'
```

Wrapper (references `${pkgs.tmux}/bin/tmux`):

```sh
short="$1"; owner="$2"; repo="$3"; target="$4"
sess=$(printf '%s->%s' "$short" "$owner" | tr ':.' '--')   # e.g. gh->technative-b-v
win=$(printf  '%s' "$repo"               | tr ':.' '--')

if ! tmux has-session -t "=$sess" 2>/dev/null; then
  tmux new-session -d -s "$sess" -n "$win" -c "$target"
elif ! tmux list-windows -t "=$sess" -F '#W' | grep -qx "$win"; then
  tmux new-window  -d -t "=$sess" -n "$win" -c "$target"
fi
tmux switch-client -t "=$sess:$win"
```

Chosen over "session per repo" (Model A) because it groups an org's repos as
windows under one session — `prefix + s` then shows a clean org→repo tree — and
matches the intent of naming both a session (org) and a window (repo). The `=`
prefix forces exact-name matching; `tr ':.' '--'` keeps names out of tmux's
`session:window.pane` target grammar.

### Popup and binding shape

`bind G popup -E -w 80% -h 80% 'hup tui --mode multiplex --flatlist'`, placed next
to `bind S popup -E smg`. `G` (git mnemonic) is currently unbound. `popup -E`
mirrors the smug launcher and closes on TUI exit.

### Preserve current config verbatim (one exception)

The generated YAML reproduces the current working config — `base_dir: ~`,
`clone_pattern_tpl: "{{.BaseDir}}/{{.Short}}.{{.OwnerLower}}/{{.Repo}}"`, the
`github` provider (`username: mipmip`, ssh, `auth.cli: gh`,
`env: SKULL2_GITHUB_TOKEN`, `all_owners: true`, `include_forks: true`), and both
modes with `multiplex` footer `[switch_hint, filter]` — changing only
`switch_command`.

## Risks / Trade-offs

- [`switch-client` from inside a popup might not move the client] → The existing
  `smg` popup already switches sessions the same way, so the pattern is proven;
  manual verification is in tasks.
- [Wrapper runs while Bubble Tea owns the TTY] → Mitigated by only issuing tmux
  server commands (no UI, no TTY needed); `new-session -d` is detached.
- [home-manager takes over the hand-written config] → Intended, but the new file
  overwrites local tweaks on switch. Content is captured verbatim first to avoid
  regressions.
- [Legacy `SKULL2_GITHUB_TOKEN` env name] → Left as-is because gh-CLI auth is what
  actually works; flagged as an optional future cleanup, out of scope here.
- [`.Target` empty if huphop reports no checkout path] → Then `-c` gets an empty
  dir and tmux falls back to the default; acceptable, surfaced during manual test.

## Open Questions

None — all decisions locked during exploration.
