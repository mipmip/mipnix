## Context

mipnix composes user environments from home-manager "roles" under `modules/ROLES/`. The two
CLI roles are **siblings, not a hierarchy**: `role-pim-cli-full` does not import
`role-pim-cli-minimal` — each role lists its own leaf modules, and consumers compose roles
at the home-config level (e.g. `makeHomeConf { imports = [ <roles...> ] }`).

- `role-pim-cli-minimal`: base CLI (git, fish, fzf, tmux, shellstuff, aliases, vim). Used by
  servers and the aarch64 Raspberry Pis.
- `role-pim-cli-full`: desktop CLI; the only place `vibecoding-claude-code-config` is
  currently imported (alongside opencode, codex, neovim, etc.).
- `vibecoding-claude-code-config`: enables `programs.claude-code` (`unstable.claude-code`)
  plus custom `mip:` slash commands. Reusable as-is.
- `pim@durer` home config currently imports only `role-pim-cli-minimal`.

`durer` is the first of several intended interactive dev servers (see mipnix-jnc9 mosh,
mipnix-nbpu deployment tooling).

## Goals / Non-Goals

**Goals:**
- Make Claude Code available in the `pim@durer` SSH environment.
- Capture "tooling for interactive development on a server" as a reusable, named role so
  future servers opt in with a single import.
- Keep `role-pim-cli-minimal` lean so non-dev hosts (incl. aarch64 Pis) are unaffected.

**Non-Goals:**
- Creating a new OS/home user (the bean's "pimj" is shorthand for `pim`).
- Any Claude-as-a-service / headless-agent / Matrix-bot functionality on durer.
- Changing `vibecoding-claude-code-config` itself.
- Adding GUI/desktop tooling or the full set of cli-full-only tools to servers.

## Decisions

### New additive sibling role `role-pim-cli-server-dev`

Create `flake.modules.homeManager.role-pim-cli-server-dev` that imports the dev-on-server
tooling (initially just `vibecoding-claude-code-config`). It is **additive**: it does not
re-import `role-pim-cli-minimal`; consumers import both.

**Why**: matches the existing sibling-role convention (full doesn't extend minimal), keeps
each role's leaf-module list explicit, and makes the consumer's intent readable
(`imports = [ minimal, server-dev ]` = "a server I develop on").

**Alternatives considered**:
- *One-off import of `vibecoding-claude-code-config` directly in durer's config* — rejected:
  "several dev servers" means the set would be duplicated per host.
- *Add Claude to `role-pim-cli-minimal`* — rejected: pushes the heavy `unstable.claude-code`
  onto every minimal host, including aarch64 Pis where it may not build and isn't wanted.
- *Make server-dev extend minimal (single import)* — rejected: breaks the established
  sibling-role style; the additive form mirrors how durer already composes roles.

### Membership rule (boundary to prevent bloat)

`role-pim-cli-server-dev` = the additive layer of tools for **interactive development on a
remote server over SSH**. In scope: Claude Code now; mosh and similar remote-dev ergonomics
later (mipnix-jnc9). Out of scope: anything desirable on *every* server (belongs in
`minimal`), GUI/desktop tooling, and the heavier cli-full-only tools (opencode, codex)
unless explicitly confirmed as used on servers.

**Why**: with several servers adopting it, an unbounded role drifts into "cli-full minus
GUI". A crisp rule keeps it intentional.

### Wire into durer as an additional import

`pim@durer` becomes `imports = [ role-pim-cli-minimal, role-pim-cli-server-dev ]`. Future
servers adopt the same two-line pattern.

## Risks / Trade-offs

- **[Risk] `unstable.claude-code` architecture availability** → fine for x86_64 `durer`;
  a future aarch64 dev server may not have a working `unstable.claude-code`.
  *Mitigation*: documented as a constraint; revisit (per-arch guard) if/when an ARM dev
  server adopts the role.
- **[Risk] Role bloat over time** → "several servers" invites piling tools in.
  *Mitigation*: the explicit membership rule above; add to it only deliberately.
- **[Trade-off] New role vs. one-off** → slightly more structure now for a one-server need,
  justified by the stated multi-server trajectory. If that trajectory reverses, the role is
  still harmless (a thin wrapper around one module).

## Migration Plan

1. Add `modules/ROLES/home-pim-cli-server-dev.nix` defining the role.
2. Append `role-pim-cli-server-dev` to `pim@durer` imports in
   `modules/HOSTS/durer-server/configuration.nix`.
3. Deploy to durer; confirm `claude` is on PATH and the `mip:` commands are present.

**Rollback**: remove the import from durer's config (and the role file); rebuild. No state.

## Open Questions

- Final role name: `role-pim-cli-server-dev` vs. `role-pim-server-dev`. (Leaning to the
  former for consistency with the `pim-cli-*` family.) Resolve at implementation.
