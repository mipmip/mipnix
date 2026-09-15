## Context

See proposal.md, Why.

Three files are involved, none of them deeply:

```
  flake.nix          specgetty.url = "github:mipmip/specgetty"   (line 59)
  flake.lock         rev 6b30460, 2 April 2026, v0.2.0
  tmux/default.nix   customBinds = [ ... ]   one entry to add
```

The specgetty module itself (`modules/USERS/pim/programs/specgetty/default.nix`)
takes the package from `inputs.specgetty.packages.<system>.specgetty`. Upstream
v0.3.0 still exposes both `specgetty` and `default`, so the attribute path keeps
working.

The binding rides on the registry shipped in `add-tmux-bind-registry`: one entry
declares the key, the description and the command, and the module emits both the
`bind` line and the `prefix + ?` menu entry from it.

## Goals / Non-Goals

**Goals:**

- Name the current owner of the repository in the input.
- Get to v0.3.0, whose default view is the behaviour the binding wants.
- Open specgetty on the project the pane is standing in, in one keystroke.

**Non-Goals:**

- Adopting v0.3.0's new config keys (`edit_command`, `change_fields`). The
  defaults are fine and the current config needs no edit to stay valid.
- Moving the specgetty module out of `pim-git`, or switching its config from
  `home.file` to `xdg.configFile`. Both are worth doing and neither belongs in a
  change about a version bump and a key.
- A launcher script. Not needed, see below.
- Generating `config.yml` from Nix the way huphop's config is generated.

## Decisions

### Why the update and the binding are one change

v0.3.0 removed `--zoom`, which is how v0.2.0 opens the project at the working
directory. Their own test asserts the flag is gone:

```
  t.Errorf("flag %q is still defined; --zoom was removed with zoom mode", name)
  t.Error("--view is missing; it replaces --zoom")
```

| | v0.2.0, installed | v0.3.0, after this change |
| ---------------- | --------------------- | --------------------------- |
| current project  | `spg --zoom`          | `spg` |
| explicit path    | `spg --zoom --path X` | `spg --path X` |
| every project    | `spg`                 | `spg --view all` |

Note the last row: plain `spg` means opposite things either side of the update.
Shipping the binding first would put a `--zoom` command in the registry, have it
break on the very next lock update, and in the window between, plain `spg` would
scan the whole disk instead of opening the project underfoot.

### No launcher script

`beans-tui-popup` exists because `beans tui` fails in a directory with no
project and a `popup -E` closes the instant its command exits, so the failure
would flash past unread. The wrapper searches upward for `.beans.yml` and, when
that fails, prints the working directory and `beans check` output and waits for
a keypress.

specgetty v0.3.0 needs none of that, because it does both halves itself:

```
   spg in a pane at ~/some/deep/dir
          │
          ▼
   findOpenSpecProject(cwd)         walks UP looking for openspec/
          │
    ┌─────┴──────┐
    ▼            ▼
  found       not found
    │            │
    ▼            ▼
 single view   project picker opens
```

The fallback is deliberate upstream, commented in their `Run` as "Nothing to
show and nothing asked for. Offer the picker rather than opening an empty view
with no explanation."

This is also what the registry's own design argued for: an unusable context is
the launcher's business, not the menu's. Here the launcher does the job, so the
binding stays a single line.

### The command is plain `spg`, not `spg --view single`

`--view` defaults to `single`, so the flag adds nothing today. It is worth
stating the alternative: spelling it out would survive a future change of
default. Rejected because `--view single` is not self-explanatory either, the
registry entry carries a description that says what it does, and every other
tool binding in the registry runs its tool the way it is run by hand.

### `A` for the key

The mnemonic letters are all taken: `S` is smug, `P` is the shell popup, `G` is
huphop, so `s`, `p` and `g` are gone. The tools group is uppercase by
convention, which leaves `A F I J K N Q U V W X Y Z`, none of which mean
anything here.

`A` is chosen as a free key with no meaning to lose, sitting next to `S` on the
keyboard. The cost of a non-mnemonic key is now low: `prefix + ?` lists every
binding with its description, so the key can be looked up rather than
remembered, which is what the registry was for.

### Size at 90%, matching beans

specgetty is a full-screen TUI with a list and a document panel, like
`beans tui` at `-w 90% -h 90%` and unlike the narrower pickers. The popup takes
`-d '#{pane_current_path}'` so the tool resolves the project from the pane, not
from wherever the tmux server was started.

## Risks / Trade-offs

- **v0.3.0 is hours old** (released 15 September 2026, pushed the same day) and
  is a large release: change export, a project picker with a disk cache, content
  search, scrolling fixes throughout. Updating to it is a bigger jump than the
  binding needs. Mitigation: the binding exercises the startup path, and the
  verification opens it from a project and from a non-project directory.
- **The picker caches to `~/.cache/specgetty/projects.yaml`** on first use. New
  state outside the Nix store, written by the tool, not managed here. It
  refreshes with `r` and is not on the path this binding uses unless the pane
  is outside a project.
- **The input changes owner.** `mipmip/specgetty` currently redirects to
  `speclib/specgetty`, so the old URL still resolves; this change stops relying
  on that. If the redirect were ever dropped, the old lock would stop fetching.
- **Fourteen entries in the menu.** The measured floor rises from 16 rows to 17.
  Recorded so the trend is visible, not because it bites yet.
