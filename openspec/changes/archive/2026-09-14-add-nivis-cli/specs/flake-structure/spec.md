## MODIFIED Requirements

### Requirement: External Input Minimization
The system SHALL decide between a local package and an external flake input by
how the package is developed, not by who maintains it. Components co-developed
with this repository — changed in the same commit as the configuration that
consumes them, with no release cycle of their own — SHALL be integrated as local
packages under `packages/`. Standalone tools that carry their own versioning and
release cycle SHALL be consumed as external flake inputs, whether they are
personally maintained or third-party, so that upgrading them is a flake update
rather than a source-tree edit.

#### Scenario: Co-developed component
- **WHEN** a package is edited in lockstep with the modules that consume it and
  publishes no releases of its own
- **THEN** it SHALL be integrated as a local package under `packages/`
- **AND** it SHALL be referenced through `inputs.self.packages.${system}.<name>`

#### Scenario: Personal package dependency
- **WHEN** a package is personally maintained (e.g., `mipmip/*` repositories) and
  is developed in its own repository with its own release cycle
- **THEN** it SHALL be consumed as an external flake input rather than vendored
  into `packages/`
- **AND** the input SHALL be referenced by a remote URI, never a filesystem path,
  so the configuration builds on hosts without a local working copy
- **AND** the input SHOULD declare `inputs.nixpkgs.follows` unless it is known
  not to build against this repository's nixpkgs
