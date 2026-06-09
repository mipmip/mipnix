## Why

Claude Code should be available when working interactively on the `durer` server over SSH.
Today Claude Code lives only in `role-pim-cli-full` (a desktop role); the `pim@durer` home
configuration uses only `role-pim-cli-minimal`, so Claude Code is absent there.

`durer` is the **first of several** servers that will be used as interactive development
hosts (cf. mosh-server work in mipnix-jnc9, deployment tooling in mipnix-nbpu). Rather than
a one-off import on `durer`, this introduces a reusable "dev server" layer so each future
server gets the same tooling with a single import — while keeping `role-pim-cli-minimal`
lean for non-dev hosts (e.g. the aarch64 Raspberry Pis harry-pi / hurry-pi).

Related task: [mipnix-fpw8](.beans/mipnix-fpw8--claude-op-durer-voor-pimj.md)

## What Changes

- Add a new home-manager role `role-pim-cli-server-dev`: an **additive** layer (sibling to
  `minimal`/`full`, matching the existing role style where roles list their own leaf
  modules and are composed at the home-config level) that provides interactive
  development-on-a-server tooling. Initially it imports `vibecoding-claude-code-config`.
- Wire it into the `pim@durer` home configuration alongside the existing
  `role-pim-cli-minimal` (i.e. `imports = [ role-pim-cli-minimal, role-pim-cli-server-dev ]`).
- Establish the membership rule for the role so future servers opt in the same way and the
  role does not bloat into "cli-full minus GUI".

## Capabilities

### New Capabilities

- `pim-server-dev-role`: A reusable, additive home-manager role that layers interactive
  remote-development tooling (Claude Code now; mosh and similar later) onto a server's base
  CLI environment, imported alongside `role-pim-cli-minimal`.

### Modified Capabilities

<!-- None: no existing spec's requirements change. The durer wiring is a consumer of the
     new role, not a change to an existing capability's behavior. -->

## Impact

- New file `modules/ROLES/home-pim-cli-server-dev.nix` defining
  `flake.modules.homeManager.role-pim-cli-server-dev`.
- `modules/HOSTS/durer-server/configuration.nix`: add `role-pim-cli-server-dev` to the
  `pim@durer` home config imports.
- Reuses the existing `vibecoding-claude-code-config` module (`unstable.claude-code` +
  `mip:` commands); no change to that module.
- `role-pim-cli-minimal` is left untouched, so non-dev hosts (including aarch64 Pis) are
  unaffected.
- Known constraint: `unstable.claude-code` must be available for the host's architecture;
  fine for x86_64 `durer`, a portability caveat for any future aarch64 dev server.
