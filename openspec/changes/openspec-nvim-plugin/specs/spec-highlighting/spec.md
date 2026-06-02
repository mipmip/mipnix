## ADDED Requirements

### Requirement: Requirement heading highlight
The `### Requirement:` prefix and the requirement name SHALL be highlighted with distinct capture groups: `@type.openspec` for the prefix and `@string.openspec` for the name.

#### Scenario: Requirement heading colors
- **WHEN** a spec file contains `### Requirement: wifi-icon`
- **THEN** `### Requirement:` SHALL be highlighted as `@type.openspec` and `wifi-icon` as `@string.openspec`

### Requirement: Scenario heading highlight
The `#### Scenario:` prefix and the scenario name SHALL be highlighted with distinct capture groups: `@function.openspec` for the prefix and `@string.openspec` for the name.

#### Scenario: Scenario heading colors
- **WHEN** a spec file contains `#### Scenario: battery at 75%`
- **THEN** `#### Scenario:` SHALL be highlighted as `@function.openspec` and `battery at 75%` as `@string.openspec`

### Requirement: Normative keyword highlight
The keywords `SHALL`, `MUST`, `SHALL NOT`, and `MUST NOT` within requirement bodies SHALL be highlighted as `@keyword.openspec`.

#### Scenario: SHALL keyword
- **WHEN** a requirement body contains "The bar SHALL display"
- **THEN** `SHALL` SHALL be highlighted as `@keyword.openspec`

#### Scenario: SHALL NOT keyword
- **WHEN** a requirement body contains "SHALL NOT be displayed"
- **THEN** `SHALL NOT` SHALL be highlighted as `@keyword.openspec`

### Requirement: Condition keyword highlight
The `WHEN` keyword at the start of condition lines SHALL be highlighted as `@conditional.openspec`. The `THEN` keyword at the start of assertion lines SHALL be highlighted as `@property.openspec`. The `AND` keyword at the start of continuation lines SHALL be highlighted as `@operator.openspec`.

#### Scenario: WHEN highlighted
- **WHEN** a scenario contains a line with `WHEN the battery is charging`
- **THEN** `WHEN` SHALL be highlighted as `@conditional.openspec`

#### Scenario: THEN highlighted
- **WHEN** a scenario contains a line with `THEN the bar SHALL display`
- **THEN** `THEN` SHALL be highlighted as `@property.openspec`

#### Scenario: AND highlighted
- **WHEN** a scenario contains a line with `AND the icon changes`
- **THEN** `AND` SHALL be highlighted as `@operator.openspec`

### Requirement: Delta section header highlight
The delta section headers (`## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`, `## RENAMED Requirements`) SHALL be highlighted as `@label.openspec`.

#### Scenario: ADDED header
- **WHEN** a spec file contains `## ADDED Requirements`
- **THEN** it SHALL be highlighted as `@label.openspec`

### Requirement: Default highlight group links
Each openspec highlight group SHALL be linked to a standard treesitter group by default, so the plugin works with any colorscheme without custom configuration.

#### Scenario: Default links applied
- **WHEN** the plugin is loaded without user highlight overrides
- **THEN** `@keyword.openspec` SHALL link to `@keyword`, `@type.openspec` to `@type`, `@function.openspec` to `@function`, `@conditional.openspec` to `@conditional`, `@property.openspec` to `@property`, `@operator.openspec` to `@operator`, `@label.openspec` to `@label`, and `@string.openspec` to `@string`
