## Context

RUNME.sh serves as the task runner for the mipnix repo. It already contains `new_nebula_node` which uses `gum` for interactive prompts and generates encrypted certificates. Adding a new NixOS host currently requires manually creating 3 files with the correct flake module wrapper pattern — something that's easy to get wrong.

The NixOS installer generates `/etc/nixos/hardware-configuration.nix` with a standard shape:
```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ ... ];
  boot.initrd.availableKernelModules = [ ... ];
  fileSystems."/" = { ... };
  ...
}
```

This needs to be re-wrapped into the project's `flake.modules.nixos.<hostname>` pattern.

## Goals / Non-Goals

**Goals:**
- One-command scaffolding of a new host directory with valid, minimal configuration
- Auto-wrap hardware-configuration.nix into the flake module pattern
- Optionally chain into `new_nebula_node` for nebula setup
- Consistent UX with existing `new_nebula_node` (gum prompts, confirmation, success message)

**Non-Goals:**
- Generating a full desktop or server configuration (user adds modules manually)
- Supporting non-NixOS hosts (nix-on-droid, pinephone have different patterns)
- Modifying flake.nix (import-tree auto-discovers new directories)

## Decisions

### 1. Hardware.nix auto-wrapping via sed

Extract the body content from `/etc/nixos/hardware-configuration.nix` by:
1. Removing the function signature line(s) — everything up to and including the first standalone `{`
2. Removing the final closing `}`
3. Wrapping the extracted body in the `flake.modules.nixos.<hostname>` pattern

**Alternative considered**: Importing the raw file via `import ./hardware-generated.nix`. Rejected because it doesn't match existing host conventions and makes the file harder to extend later.

**Alternative considered**: Using `nix eval` to parse. Overkill for this use case.

### 2. Minimal configuration.nix imports

The generated `configuration.nix` includes only the base modules present across all hosts:
- `system-default`
- `system-locale`
- `hm-nixos`
- `nix-cli`
- `user-pim`

These are the common denominator across server (harry) and desktop (lego2) hosts.

### 3. Directory naming convention

Follow existing pattern: `<hostname>-<type>` where type is user-provided (laptop, pi, server, etc.). The hostname inside nix files is just the short name.

### 4. Nebula integration

After generating the host files, if the user opts in, call `new_nebula_node` which handles its own interactive flow. This keeps the functions decoupled.

## Risks / Trade-offs

- **[sed extraction fragility]** → The NixOS hardware-configuration.nix format has been stable for years. The extraction targets a simple pattern (strip function args + outer braces). A comment in the generated file tells the user to review.
- **[stateVersion hardcoded to 25.11]** → Will need updating when the flake moves to a new nixpkgs channel. Acceptable since it's a single string to change.
- **[Must run on target machine]** → The function reads `/etc/nixos/hardware-configuration.nix` which only exists on the machine where NixOS was installed. This is the intended workflow — you run this on the freshly installed machine after cloning the repo.
