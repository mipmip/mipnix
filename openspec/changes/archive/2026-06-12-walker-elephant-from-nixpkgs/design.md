## Context

Walker and Elephant are currently consumed as flake inputs:

```
flake.nix:
  walker = { url = "github:abenz1267/walker"; inputs.elephant.follows = "elephant"; };
  elephant.url = "github:abenz1267/elephant";
```

Neither follows the project `nixpkgs`, so each pulls its own (`nixpkgs_22`, `nixpkgs_5` in
the lock). They're consumed in `modules/USERS/pim/programs/hyprland/default.nix`:

- `imports = [ inputs.walker.homeManagerModules.default ]` — provides `programs.walker`
  and `programs.elephant` options.
- `programs.elephant = { providers = [...]; settings = {...}; }` — custom backend config
  (incl. `desktopapplications.launch_prefix = "uwsm app --"`, calc icon, min_scores).
- `programs.walker = { enable = true; runAsService = true; }`.
- `home.packages = [ inputs.walker.packages.<sys>.default ]` — the walker binary.
- `modules/nix/cli.nix` adds the `walker.cachix.org` binary cache + trusted key.

Verified facts:
- nixpkgs 26.05 ships `pkgs.walker` (2.16.2) and `pkgs.elephant` (2.21.0).
- home-manager `release-26.05` (the project's pinned input) ships **`services.walker`**
  (not `programs.walker`): `enable`, `package` (defaults to `pkgs.walker`), `settings`
  (→ `~/.config/walker/config.toml`), `theme`, `systemd.enable` (runs
  `walker --gapplication-service` as a user service).
- home-manager `release-26.05` has **no elephant module** (confirmed across all HM sources
  in the store). The elephant HM option exists only on newer/master HM, not the pinned
  release.

User direction: prefer the **nixpkgs/home-manager golden path** with defaults; custom
config can be re-added declaratively later.

## Goals / Non-Goals

**Goals:**
- Install Walker + Elephant purely from official nixpkgs/home-manager.
- Remove the `walker`/`elephant` flake inputs and the extra nixpkgs they pull.
- Keep the launcher working (mipbar button, SPACE keybind) — `walker`/`elephant` on PATH.

**Non-Goals:**
- Preserving the bespoke Elephant provider/settings config (intentionally dropped for
  defaults; re-add later if missed).
- Bumping the home-manager input off `release-26.05` to get an elephant module.
- Changing the mipbar launcher button behavior or keybinds.

## Decisions

### Walker via `services.walker` (official HM module), defaults

Replace `programs.walker { enable; runAsService = true; }` with:

```
services.walker = {
  enable = true;
  systemd.enable = true;   # runs `walker --gapplication-service` as a user service
};
```

`package` defaults to `pkgs.walker` (26.05). Omit `settings`/`theme` (golden-path defaults).

**Why**: this is the official module name in `release-26.05` (`programs.walker` does not
exist there). `systemd.enable` supersedes both the old `runAsService` and the
`exec-once = walker --gapplication-service` autostart line.

### Elephant via `pkgs.elephant` package, default config

Add `pkgs.elephant` to `home.packages`; **delete** the `programs.elephant { ... }` block.

**Why**: `release-26.05` home-manager has no elephant module, and the golden-path direction
is "package + defaults". Hand-writing `~/.config/elephant/elephant.toml` or bumping HM for
the module are both rejected (re-introduce the custom config / widen blast radius).

**Consequence**: the custom providers and `uwsm app --` launch prefix are dropped. If app
launching needs the uwsm scoping, that's the first thing to re-add (as `elephant.toml` via
`xdg.configFile`) — noted as a follow-up, out of scope here.

### Remove the walker.cachix.org binary cache

Drop the substituter + trusted key from `modules/nix/cli.nix`.

**Why**: packages now come from nixpkgs (`cache.nixos.org`); the custom cache for the
upstream flake build is obsolete.

### Launcher / daemon ordering

Elephant is Walker's backend daemon. Keep `exec-once = elephant` in autostart unless the
`services.walker` service is found to spawn elephant itself. This must be verified live:
open the launcher and confirm results appear (not an empty launcher).

## Risks / Trade-offs

- **[Risk] Empty launcher if elephant isn't running** → walker opens but returns no
  results. *Mitigation*: keep `exec-once = elephant`; verify the launcher returns results
  after deploy; adjust ordering if needed.
- **[Risk] `services.walker` schema differs from old `programs.walker`** → option names
  changed (`runAsService` → `systemd.enable`). *Mitigation*: use the verified `release-26.05`
  schema; build will fail loudly on a wrong option name.
- **[Risk] 26.05 versions lag upstream** → walker 2.16.2 / elephant 2.21.0 may be behind
  the flakes. *Mitigation*: accepted per the golden-path choice; bump via nixpkgs later.
- **[Trade-off] Lost custom Elephant config** → accepted; re-add declaratively if missed.

## Migration Plan

1. Remove `walker` + `elephant` inputs from `flake.nix`.
2. In `default.nix`: drop the walker HM-module import; `services.walker { enable;
   systemd.enable; }`; delete `programs.elephant`; `home.packages` += `pkgs.elephant`,
   drop `inputs.walker.packages...`.
3. Remove the redundant `exec-once = walker --gapplication-service` from autostart.conf.
4. Remove the walker.cachix.org cache from `cli.nix`.
5. Build the laptop home/system config; confirm it evaluates and walker/elephant resolve
   to pkgs.* (26.05).
6. Deploy; verify: launcher opens via the mipbar button + SPACE, returns results, and the
   walker user service is active.

**Rollback**: restore the inputs and the `programs.walker`/`programs.elephant` config,
re-add the cachix cache; rebuild.

## Resolved During Implementation

- **`systemd.enable` does NOT work in this session.** `services.walker`'s systemd user
  service is `WantedBy = graphical-session.target`, but this Hyprland session does not
  populate that target (no uwsm/systemd integration) — confirmed live:
  `systemctl --user is-active graphical-session.target` → `inactive`, and the walker
  service sat `enabled` but `inactive (dead)`. So `systemd.enable = false`; Walker is
  launched via `exec-once = walker --gapplication-service` in `autostart.conf` instead.
  The `services.walker` module still provides the package + config; only its (non-firing)
  systemd unit is disabled.
- `exec-once = elephant` is kept (Elephant is Walker's backend daemon; safe default).
