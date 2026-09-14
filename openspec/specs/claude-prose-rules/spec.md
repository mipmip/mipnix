# claude-prose-rules Specification

## Purpose
Defines the writing rules Claude Code follows in every project on this machine,
and the mechanical check that enforces the subset of them that admits no
exception, so the rules hold without depending on the model remembering them.

## Requirements

### Requirement: Rules Available In Every Session
The system SHALL make the writing rules available to Claude Code in every
project, as separate documents grouped by concern rather than as one block of
text, so a rule can be added, changed or removed on its own.

#### Scenario: Starting a session in any repository
- **WHEN** Claude Code starts in any directory on this machine
- **THEN** the writing rules SHALL be present in its memory without the user
  asking for them
- **AND** each concern SHALL be a separate document

### Requirement: Unconditional Typography Rules Are Enforced
The system SHALL reject prose written to a file that contains an em dash, an en
dash, a double hyphen used as a dash, or a curly quotation mark. Rejection SHALL
name the offending lines and SHALL require correction before work continues.
These marks SHALL be rejected regardless of the file's purpose, because no
context calls for them.

#### Scenario: Prose written with an em dash
- **WHEN** Claude writes or edits a prose file whose text contains an em dash
- **THEN** the write SHALL be reported as failed
- **AND** the report SHALL name the line and show the offending text
- **AND** Claude SHALL correct the file before continuing

#### Scenario: Dashes inside code and paths
- **WHEN** the file contains dashes or hyphens inside a fenced code block,
  inline code, a command, a filesystem path or a URL
- **THEN** those SHALL NOT be reported
- **AND** the write SHALL succeed if nothing outside those regions violates a rule

#### Scenario: A source file is written
- **WHEN** Claude writes a file that is not one of the recognised prose types
- **THEN** no typography check SHALL run against it

### Requirement: Filler Words Are Reported, Not Forbidden
The system SHALL report filler words in prose written to a file, together with
the sentence they occur in, and SHALL NOT fail the write. A word on the list
carries meaning in some sentences and is a verbal tic in others, so the decision
SHALL rest with a reader rather than with the check.

#### Scenario: A filler word that carries meaning
- **WHEN** the prose contains a listed word used for its meaning, as in "dat is
  eigenlijk niet waar"
- **THEN** the occurrence SHALL be reported with its sentence
- **AND** the write SHALL NOT be failed on account of it

#### Scenario: A filler word used as a tic
- **WHEN** the prose contains a listed word that adds nothing, as in "dat is
  eigenlijk best goed"
- **THEN** the occurrence SHALL be reported with its sentence so it can be removed

### Requirement: The Check Does Not Depend On The Ambient Environment
The check SHALL run from a self-contained executable whose interpreter is
resolved at build time. It SHALL NOT require any language runtime to be present
on PATH, and SHALL NOT fail or block a session when the surrounding environment
lacks one.

#### Scenario: A session in a shell without node or python on PATH
- **WHEN** Claude writes a prose file from a shell whose PATH contains no
  language runtime
- **THEN** the check SHALL still run and report normally

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
