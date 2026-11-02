# nix-metrics Specification

## Purpose
Expose facts about each host's NixOS installation and Nix store to
Prometheus, and show them in Grafana next to the other host metrics.

## Requirements

### Requirement: Systems record their mipnix revision

Every NixOS system built through `makeNixos` SHALL record the git revision
of the mipnix flake it was built from as `system.configurationRevision`.

#### Scenario: Clean build

- **WHEN** a host is built from a clean checkout
- **THEN** `nixos-version --json` on that host reports the commit as
  `configurationRevision`

#### Scenario: Dirty build

- **WHEN** a host is built from a tree with uncommitted changes
- **THEN** the reported revision is marked dirty

### Requirement: NixOS facts are exported hourly

Every nebula node SHALL export, at least hourly, its configuration revision,
NixOS version, nixpkgs revision, time of the last system switch, whether a
reboot is required, the number of system generations, the number of
home-manager generations per user, and the closure size of the current
system.

#### Scenario: After a switch

- **WHEN** a host switches to a new configuration
- **THEN** within an hour Prometheus shows the new revision and a switch
  time within that hour

#### Scenario: Kernel changed without reboot

- **WHEN** a switch installs a kernel, initrd or kernel modules that differ
  from the booted system
- **THEN** `nixos_reboot_required` is 1 for that host until it reboots

#### Scenario: Generations accumulate

- **WHEN** a host has 40 system generations
- **THEN** `nixos_system_generations` for that host is 40

### Requirement: Store size is exported daily

Every nebula node SHALL export, at least daily, the size of `/nix/store` in
bytes and its number of paths. The measurement SHALL run at idle I/O
priority and SHALL NOT delay the hourly facts.

#### Scenario: Daily measurement

- **WHEN** the daily job has run
- **THEN** `nix_store_size_bytes` and `nix_store_paths` are available for
  that host

#### Scenario: Slow measurement

- **WHEN** the store measurement takes several minutes
- **THEN** the hourly facts are still written on time

### Requirement: Exported files are never read half-written

Each collection job SHALL write its metrics to a temporary file and move it
into the textfile directory in one step.

#### Scenario: Scrape during collection

- **WHEN** Prometheus scrapes while a job is writing
- **THEN** it reads either the previous complete file or the new complete
  file

### Requirement: NixOS dashboard

Grafana SHALL provide a provisioned "NixOS" dashboard listing every host
with its revision, NixOS version, time since last switch, reboot needed,
generation counts, closure size and store size, plus store size over time.

#### Scenario: Stale host

- **WHEN** a host last switched more than 14 days ago
- **THEN** its switch age is highlighted on the dashboard

#### Scenario: Reboot pending

- **WHEN** a host has `nixos_reboot_required` set to 1
- **THEN** the dashboard highlights it

#### Scenario: Last garbage collection

- **WHEN** a host has a `nix-gc` timer
- **THEN** the dashboard shows when it last ran
