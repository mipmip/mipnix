## ADDED Requirements

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
