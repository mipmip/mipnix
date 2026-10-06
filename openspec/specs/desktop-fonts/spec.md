# desktop-fonts Specification

## Purpose
Defines which typefaces the desktop hosts make available, and how fonts that are
absent from nixpkgs get packaged and wired in. Font *availability* is the concern
here; which family an application actually picks for a generic alias
(`sans-serif`, `serif`, `monospace`) is governed by the fontconfig defaults, and
adding a font never changes those by itself.

## Requirements

### Requirement: Clear Sans Font Availability
The system SHALL make the Clear Sans typeface available to all applications on
hosts that enable the desktop font module, packaged from source because Clear
Sans is not present in nixpkgs.

Clear Sans is Intel's OpenType UI typeface (Apache-2.0). Upstream
(`github.com/intel/clear-sans`) publishes no git tags and no GitHub releases —
the font binaries live directly in the repository tree — and Intel has formally
discontinued the project, so the package SHALL pin an explicit commit rather
than track a branch.

#### Scenario: Clear Sans resolves through fontconfig
- **WHEN** an application queries fontconfig for the family "Clear Sans" on a
  host with the `desktop-utils-fonts` module enabled
- **THEN** fontconfig SHALL report a matching font file from the Clear Sans
  package
- **AND** `fc-list` SHALL list the Regular, Italic, Bold, BoldItalic, Medium,
  MediumItalic, Light and Thin styles

#### Scenario: Font package is pinned and reproducible
- **WHEN** the Clear Sans package is evaluated
- **THEN** its source SHALL be fetched from a pinned upstream commit with a
  recorded content hash
- **AND** the build SHALL install only the TTF outputs into
  `share/fonts/truetype`, ignoring the upstream EOT/SVG/WOFF web formats

#### Scenario: Default sans-serif is unchanged
- **WHEN** an application requests the generic `sans-serif` family
- **THEN** fontconfig SHALL continue to resolve the pre-existing default chain
  and SHALL NOT substitute Clear Sans

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
