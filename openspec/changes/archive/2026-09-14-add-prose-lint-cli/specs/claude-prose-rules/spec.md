## ADDED Requirements

### Requirement: The Check Is Runnable By Hand
The checker SHALL be available as a command on the user's PATH that takes one or
more file paths and reports on them, so an existing document can be checked
without first being rewritten. Today the checker exists only as a hook, which
means a file is examined only when something writes to it, and text that was
already there is never looked at.

The command SHALL apply the same rules and the same code carve-out as the hook,
and SHALL exit non-zero when a blocking rule is hit, so it can gate a script.
Adding this SHALL NOT change how the hook behaves.

#### Scenario: Checking a document that nobody is editing
- **WHEN** the user runs the command with the path of an existing file
- **THEN** it SHALL report the same findings the hook would report for that file
- **AND** it SHALL exit non-zero if any blocking rule was hit, and zero otherwise

#### Scenario: Checking several files at once
- **WHEN** the user runs the command with more than one path
- **THEN** each file SHALL be reported separately
- **AND** the exit status SHALL be non-zero if any of them hit a blocking rule

#### Scenario: The hook still works
- **WHEN** Claude writes a prose file
- **THEN** the hook SHALL behave exactly as before, reading its event from
  standard input and failing the write on a blocking rule

### Requirement: An Explicit Request Is Not Filtered By File Type
When a file is named on the command line, the system SHALL check it whatever its
extension. The file-type filter exists to stop the hook from firing on source
files by itself, not to refuse a direct request.

#### Scenario: Naming a file the hook would skip
- **WHEN** the user runs the command with the path of a file whose extension is
  not one of the recognised prose types
- **THEN** it SHALL be checked and reported on
