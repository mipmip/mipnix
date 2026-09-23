## Why

`rme` (the RUNME.sh command launcher) ships shell completions via
`rme completion <shell>`, but they are not wired into the home-manager config, so
tab-completing `rme <cmd>` does nothing. `rme completion install` exists but is
imperative (it writes into the home directory at runtime), which is the wrong fit for a
declarative setup. The completion scripts are tiny and defer to `rme --completions` at
runtime, so completions stay correct per-directory (they read the local `RUNME.sh`)
without baking a static list. Fish is the primary shell and zsh is also configured; both
should get completions declaratively via `hm switch`.

## What Changes

- Add a fish completion file `~/.config/fish/completions/rme.fish` via `xdg.configFile`
  containing the dynamic one-liner `complete -c rme -f -a '(rme --completions)'`. Fish
  lazy-loads it on first tab of `rme` — no shell restart needed.
- Add zsh completion wiring in `programs.zsh.initContent`:
  `_rme() { compadd $(rme --completions) }` + `compdef _rme rme` (compinit is already run
  by oh-my-zsh).
- Do NOT use `rme completion install`, and do NOT bake a static command list — both would
  break the per-directory dynamic behavior.

## Capabilities

### New Capabilities
- `rme-shell-completions`: declarative fish and zsh tab-completion for `rme`, driven by the
  runtime `rme --completions` so suggestions reflect the current directory's `RUNME.sh`.

### Modified Capabilities
- (none)

## Impact

- **Code**:
  - `modules/USERS/pim/programs/fish/default.nix` — add
    `xdg.configFile."fish/completions/rme.fish".text`.
  - `modules/USERS/pim/programs/zsh/default.nix` — append the `_rme`/`compdef` lines to
    `programs.zsh.initContent`.
- **Dependencies**: `rme` (already installed via `shellstuff-cli.nix`).
- **Systems**: fish and zsh interactive shells for user `pim`.
- **Risk**: Low, additive. In directories without a `RUNME.sh`, `rme --completions` returns
  nothing and no suggestions appear (expected).
