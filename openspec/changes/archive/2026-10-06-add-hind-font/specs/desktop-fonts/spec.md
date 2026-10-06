## ADDED Requirements

### Requirement: Hind Font Availability
The system SHALL make the Hind typeface available to all applications on hosts
that enable the desktop font module.

Hind has no package of its own in nixpkgs. It ships inside `google-fonts`, whose
full output is the entire Google Fonts catalogue, so the package SHALL be
narrowed to the single family through its `fonts` argument rather than pulled in
whole.

#### Scenario: Hind resolves through fontconfig
- **WHEN** an application queries fontconfig for the family "Hind" on a host
  with the `desktop-utils-fonts` module enabled
- **THEN** fontconfig SHALL report a matching font file from the narrowed
  `google-fonts` package
- **AND** `fc-list` SHALL list the Light, Regular, Medium, SemiBold and Bold
  styles

#### Scenario: Catalogue is not installed wholesale
- **WHEN** the font package is evaluated
- **THEN** it SHALL install only the Hind family
- **AND** it SHALL NOT install the related but distinct families that share the
  name prefix, such as Hind Siliguri or Hind Madurai

#### Scenario: Default sans-serif is unchanged
- **WHEN** an application requests the generic `sans-serif` family
- **THEN** fontconfig SHALL continue to resolve the pre-existing default chain
  and SHALL NOT substitute Hind
