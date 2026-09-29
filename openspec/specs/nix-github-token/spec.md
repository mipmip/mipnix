# nix-github-token Specification

## Purpose
TBD - created by archiving change add-nix-github-token. Update Purpose after archive.

## Requirements

### Requirement: GitHub token available to the age secret on pim's laptops
`secrets/ghi-token.age` SHALL be encrypted to the host keys of `cichorei`, `doornappel` and `peterspav` in addition to the user keys it already carries, so those hosts can decrypt it at activation.

#### Scenario: Recipients in secrets.nix
- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `ghi-token.age` SHALL have `publicKeys` containing `pim`, `annemarie`, `cichorei`, `doornappel` and `peterspav`

#### Scenario: Hosts that do not build flake inputs
- **WHEN** a server such as `durer`, `dapperehaan`, `harry` or `hurry` is evaluated
- **THEN** it SHALL NOT be a recipient, because its closure is built on a laptop and copied over, so it never fetches flake inputs itself

### Requirement: Token rendered into nix.conf include files
A NixOS module SHALL render the decrypted token into two nix.conf fragments, each holding a single `access-tokens = github.com=<token>` line: `/etc/nix/access-tokens.conf` owned by `root:root`, and `/home/pim/.config/nix/access-tokens.conf` owned by `pim:users`. Both SHALL have mode `600`.

#### Scenario: Activation renders both fragments
- **WHEN** a host importing the module activates
- **THEN** both files SHALL exist with mode `600` and the correct owner, and each SHALL contain one `access-tokens = github.com=` line

#### Scenario: Rendering runs after decryption
- **WHEN** the activation script runs
- **THEN** it SHALL run after agenix has decrypted `ghi-token.age`, so the token is readable when the fragments are written

#### Scenario: Token absent from the nix store
- **WHEN** the system closure is inspected
- **THEN** the token SHALL NOT appear in any world-readable store path, because the fragments are written at activation rather than built

### Requirement: nix.conf includes the token fragment optionally
The system nix configuration SHALL include `/etc/nix/access-tokens.conf` and pim's home-manager nix configuration SHALL include `/home/pim/.config/nix/access-tokens.conf`, both through nix's tolerant `!include` form.

#### Scenario: Fragment present
- **WHEN** nix starts on a host where the fragment exists
- **THEN** it SHALL apply the `access-tokens` setting from the fragment

#### Scenario: Fragment missing
- **WHEN** nix starts on a host where the fragment does not exist
- **THEN** nix SHALL run normally, because `!include` ignores a missing file

### Requirement: Authenticated GitHub fetches
With the fragment in place, fetching a `github:` flake input SHALL use the authenticated GitHub API rate limit rather than the per-IP anonymous one.

#### Scenario: Updating an input as pim
- **WHEN** pim runs `nix flake update <input>` for a `github:` input on one of the three laptops
- **THEN** the fetch SHALL NOT fail with `HTTP error 403` reporting an exceeded rate limit

#### Scenario: Rebuilding as root
- **WHEN** `nixos-rebuild` fetches `github:` inputs as root
- **THEN** it SHALL use the same token through `/etc/nix/access-tokens.conf`
