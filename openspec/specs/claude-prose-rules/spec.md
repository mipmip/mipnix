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
