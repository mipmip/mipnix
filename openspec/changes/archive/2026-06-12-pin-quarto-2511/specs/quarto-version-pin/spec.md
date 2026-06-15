# Quarto Version Pin

## ADDED Requirements

### Requirement: quarto-pinned-to-2511

Quarto SHALL be provided from the nixpkgs 25.11 release (version 1.7.34) via the apps overlay, not from the default 26.05 nixpkgs (1.9.37), as a temporary workaround for a 1.9.x regression.

#### Scenario: quarto resolves to the pinned version

- **WHEN** `quarto --version` is run on a host using the apps overlay
- **THEN** it SHALL report `1.7.34` (the nixpkgs 25.11 release), not `1.9.37`

#### Scenario: consumers get the pinned build without change

- **WHEN** a consumer references `quarto` (e.g. `modules/programs/tex/tex.nix` or the mipvim quarto plugin)
- **THEN** it SHALL receive the pinned 1.7.34 build, with no change required at the consumption site

### Requirement: quarto-extras-preserved

The pinned Quarto SHALL retain the project's R and Python extras, sourced from the same 25.11 release for a consistent stack.

#### Scenario: R and Python extras present

- **WHEN** the pinned Quarto is built
- **THEN** it SHALL include `reticulate` (R) and the Python packages `plotly`, `numpy`, `pandas`, `matplotlib`, and `tabulate`, all from nixpkgs 25.11

### Requirement: pin-is-revertible

The pin SHALL be a localized, documented, temporary workaround that can be reverted by returning the overlay to the default (26.05) Quarto once the 1.9.x regression is resolved.

#### Scenario: revert path

- **WHEN** the 1.9.x regression is no longer a problem
- **THEN** reverting the overlay's quarto base from `nixpkgs-2511` back to `prev` SHALL restore the default 26.05 Quarto with the same extras
