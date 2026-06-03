## ADDED Requirements

### Requirement: Grammar parses requirements
The grammar SHALL parse `### Requirement: <name>` headings into `requirement` nodes containing a `requirement_name` child with the name text.

#### Scenario: Simple requirement
- **WHEN** a spec file contains `### Requirement: wifi-icon`
- **THEN** the AST SHALL contain a `(requirement (requirement_name))` node where `requirement_name` captures `wifi-icon`

#### Scenario: Requirement with body
- **WHEN** a spec file contains a `### Requirement:` heading followed by prose text
- **THEN** the AST SHALL contain a `(requirement (requirement_name) (requirement_body))` node

### Requirement: Grammar parses scenarios
The grammar SHALL parse `#### Scenario: <name>` headings into `scenario` nodes nested under their parent `requirement`, containing a `scenario_name` child.

#### Scenario: Scenario with WHEN/THEN
- **WHEN** a spec file contains `#### Scenario: battery at 75%` followed by WHEN and THEN lines
- **THEN** the AST SHALL contain a `(scenario (scenario_name) (condition) (assertion))` node

#### Scenario: Multiple scenarios per requirement
- **WHEN** a requirement contains three `#### Scenario:` blocks
- **THEN** the AST SHALL contain three `scenario` nodes nested under that `requirement`

### Requirement: Grammar parses normative keywords
The grammar SHALL recognize `SHALL`, `MUST`, `SHALL NOT`, and `MUST NOT` as `keyword` nodes within requirement bodies.

#### Scenario: SHALL in requirement body
- **WHEN** a requirement body contains "The bar SHALL display"
- **THEN** `SHALL` SHALL be parsed as a `(keyword)` node

#### Scenario: SHALL NOT
- **WHEN** a requirement body contains "SHALL NOT be displayed"
- **THEN** `SHALL NOT` SHALL be parsed as a single `(keyword)` node

### Requirement: Grammar parses conditions and assertions
The grammar SHALL parse lines starting with `WHEN` or `- **WHEN**` as `condition` nodes and lines starting with `THEN` or `- **THEN**` as `assertion` nodes within scenarios. Lines starting with `AND` or `- **AND**` SHALL be parsed as continuation nodes of the preceding condition or assertion.

#### Scenario: WHEN line
- **WHEN** a scenario contains a line starting with `WHEN` or `- **WHEN**`
- **THEN** it SHALL be parsed as a `(condition)` node

#### Scenario: THEN line
- **WHEN** a scenario contains a line starting with `THEN` or `- **THEN**`
- **THEN** it SHALL be parsed as an `(assertion)` node

#### Scenario: Bare keyword format
- **WHEN** a scenario uses `WHEN the battery is at 75%` without markdown bold markers
- **THEN** it SHALL still be parsed as a `(condition)` node

### Requirement: Grammar parses delta sections
The grammar SHALL parse `## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`, and `## RENAMED Requirements` as `delta_section` nodes with a `delta_header` child identifying the operation type.

#### Scenario: ADDED section
- **WHEN** a spec file contains `## ADDED Requirements` followed by requirement blocks
- **THEN** the AST SHALL contain a `(delta_section (delta_header))` node wrapping those requirements

#### Scenario: Spec without delta sections
- **WHEN** a spec file contains requirements without delta section headers
- **THEN** the requirements SHALL be parsed as top-level `requirement` nodes

### Requirement: Markdown injection for prose
The grammar SHALL support markdown injection in `requirement_body` nodes via `injections.scm`, so that inline markdown formatting (bold, code, links) is highlighted within prose content.

#### Scenario: Bold text in requirement body
- **WHEN** a requirement body contains `**important**`
- **THEN** neovim SHALL render it with markdown bold highlighting

#### Scenario: Inline code in requirement body
- **WHEN** a requirement body contains `` `openspec/changes/archive` ``
- **THEN** neovim SHALL render it with markdown code highlighting
