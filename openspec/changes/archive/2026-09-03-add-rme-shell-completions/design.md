## Context

`rme --help` exposes `rme completion <shell>` (prints a script) and `rme completion install`
(auto-installs). The generated scripts are thin wrappers:

```
fish │ complete -c rme -f -a '(rme --completions)'
zsh  │ #compdef rme
     │ _rme() { compadd $(rme --completions) }
     │ compdef _rme rme
```

The decisive property: **`rme --completions` is per-directory dynamic** — it reads the local
`RUNME.sh`. Running it in `~/mipnix` lists that repo's commands; another repo lists its own.
So the wrapper must call `rme --completions` at completion time; a static list would be wrong.

## Decisions

### Decision 1: Wire completions declaratively; never use `rme completion install`
`rme completion install` mutates the home directory imperatively, which conflicts with a
home-manager-managed setup (it would fight the generation symlinks / be non-reproducible).
Instead we ship the wrapper scripts through home-manager.

- **Choice**: hand-place the (stable, tiny) wrapper scripts via home-manager options.
- **Alternative rejected**: an activation script running `rme completion install` — imperative,
  non-declarative, redundant with what home-manager already does well.

### Decision 2: Fish via a lazy `completions/rme.fish` file (Option A)
Fish auto-loads `~/.config/fish/completions/NAME.fish` on demand (first tab of `rme`), so a
completions file has zero startup cost and is picked up without restarting the shell.

- **Choice**: `xdg.configFile."fish/completions/rme.fish".text = "complete -c rme -f -a '(rme --completions)'";`
  (`xdg.configFile` is already used in this config — beandex, huphop.)
- **Alternative rejected**: `programs.fish.interactiveShellInit` — runs the `complete` on every
  shell start (eager), clutters the init block, and needs a new shell to take effect.

### Decision 3: Zsh via `initContent` after oh-my-zsh's compinit
oh-my-zsh already runs `compinit`, so `compdef` is available in `programs.zsh.initContent`.
Adding the function + `compdef` there avoids managing an fpath `_rme` file.

- **Choice**: append `_rme() { compadd $(rme --completions) }` and `compdef _rme rme` to
  `initContent`.
- **Alternative rejected**: a `_rme` file dropped into an fpath directory — more machinery for
  no gain given compinit is already set up. Note: unlike fish, zsh loads this at shell init, so
  a new zsh session is needed after `hm switch`.

### Decision 4: rme-specific, not a generic completions framework
Only one tool needs this today. A reusable `{cmd; fishLine; zshLine}` helper would be
over-engineering for a single consumer.

- **Choice**: inline, rme-specific wiring.
- **Alternative deferred**: generalize into a small helper if a second custom CLI (drs, jjay)
  later wants the same treatment.

## Notes / caveats
- `rme` must be on `PATH` at completion time — satisfied by `shellstuff-cli.nix`.
- In a directory with no `RUNME.sh`, `rme --completions` yields nothing → no suggestions
  (expected, not a failure).
