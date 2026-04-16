## ADDED Requirements

### Requirement: Detect jj-managed repositories
The prompt SHALL detect if the current working directory is inside a jj-managed repository by running `jj root --ignore-working-copy`. When detection succeeds, the prompt SHALL use jj info instead of git info.

#### Scenario: Inside a jj repo
- **WHEN** the current directory is inside a jj-managed repository
- **THEN** the prompt SHALL display jj repository information and SHALL NOT display git prompt information

#### Scenario: Outside a jj repo
- **WHEN** the current directory is not inside a jj-managed repository
- **THEN** the prompt SHALL fall back to the existing git prompt behavior

#### Scenario: Colocated git+jj repo
- **WHEN** the current directory is inside a repository managed by both git and jj
- **THEN** jj prompt information SHALL take priority over git prompt information

### Requirement: Display jj change ID
The prompt SHALL display the shortest unique prefix of the current working-copy change ID, obtained via `jj log -r @ --no-graph -T 'change_id.shortest()' --ignore-working-copy`.

#### Scenario: Show change ID
- **WHEN** inside a jj repo
- **THEN** the prompt SHALL display the shortest unique change ID prefix (e.g., `kp` or `kpqv`)

### Requirement: Display jj bookmarks
The prompt SHALL display any bookmarks pointing to the current working-copy change.

#### Scenario: Change has bookmarks
- **WHEN** the current jj change has one or more bookmarks
- **THEN** the prompt SHALL display the bookmark names after the change ID

#### Scenario: Change has no bookmarks
- **WHEN** the current jj change has no bookmarks
- **THEN** the prompt SHALL display only the change ID without bookmark info

### Requirement: Display jj working-copy status
The prompt SHALL indicate whether the working copy has modifications and whether there are conflicts.

#### Scenario: Working copy is modified
- **WHEN** the current jj change is not empty (has file changes)
- **THEN** the prompt SHALL display a dirty indicator ("✗" in yellow)

#### Scenario: Working copy is empty
- **WHEN** the current jj change is empty (no file changes)
- **THEN** the prompt SHALL NOT display the dirty indicator

#### Scenario: Working copy has conflicts
- **WHEN** the current jj change has conflicts
- **THEN** the prompt SHALL display a conflict indicator ("⚠" in bold yellow)

### Requirement: Prompt performance
The prompt SHALL remain responsive by using `--ignore-working-copy` on all jj commands to avoid triggering working-copy snapshots during prompt rendering.

#### Scenario: Fast prompt rendering
- **WHEN** rendering the prompt in a jj repo
- **THEN** all jj commands SHALL use the `--ignore-working-copy` flag
