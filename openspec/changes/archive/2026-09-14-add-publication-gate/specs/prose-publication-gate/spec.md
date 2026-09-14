## Purpose

The check that prose passes before it leaves my hands, covering the rules a
reader has to judge rather than the ones a script can decide, so text going to
someone else in Dutch or English does not read as machine-written.

## ADDED Requirements

### Requirement: The Gate Runs On Text, Not On Tool Calls
The gate SHALL examine files by reading them, regardless of how they came to
exist. It SHALL NOT depend on the text having been produced by a particular tool,
because prose written through a shell redirection is prose all the same.

#### Scenario: Prose written outside the editing tools
- **WHEN** a document was produced by a shell redirection rather than by an
  editing tool, and the gate is run on it
- **THEN** it SHALL be checked in full, exactly as if it had been edited

#### Scenario: Deciding what to check without being told
- **WHEN** the gate is run without naming any file
- **THEN** it SHALL check the prose files that differ from the last commit

### Requirement: The Mechanical Half Fails The Gate
The gate SHALL run the typography check over every file first, and SHALL fail
when any file hits a blocking rule. This half SHALL be decided entirely by the
checker, so that passing or failing never depends on a reading.

#### Scenario: A document with a blocking typography hit
- **WHEN** a file contains an em dash outside code
- **THEN** the gate SHALL fail
- **AND** it SHALL name the file and the line

#### Scenario: Clean typography
- **WHEN** no file hits a blocking rule
- **THEN** the gate SHALL proceed to the reading half

### Requirement: The Judgement Half Reports And Does Not Fail
The gate SHALL review each file against the imported guides for the patterns that
need a reader, and SHALL report what it finds together with the passage it found
it in. It SHALL NOT fail on these findings, and SHALL NOT rewrite the text on its
own, because the repair for such a finding depends on meaning.

#### Scenario: A finding that needs a reader
- **WHEN** the review finds a pattern such as a forced triad or a staged run-up
- **THEN** it SHALL report the finding with the passage and what the guide says
- **AND** the gate SHALL NOT fail on account of it
- **AND** the text SHALL NOT be changed without the reader agreeing

#### Scenario: One repair does not fit every hit
- **WHEN** several occurrences of the same pattern are reported
- **THEN** each SHALL be reported separately with its own passage, rather than
  offered a single replacement

### Requirement: Guides Apply In The Language Of The Text
The gate SHALL apply the general guide to text in any language, and SHALL apply
the Dutch guide in addition when the text is Dutch. It SHALL NOT require being
told which language a document is in.

#### Scenario: A Dutch document
- **WHEN** the text under review is Dutch
- **THEN** both the general guide and the Dutch guide SHALL inform the review

#### Scenario: An English document
- **WHEN** the text under review is English
- **THEN** the general guide SHALL inform the review

### Requirement: Imported Guidance Is Amended Where It Does Not Apply
The system SHALL record, alongside the imported guides, the rules within them
that do not apply here, and the review SHALL honour those amendments. A guide
adopted without stating its exceptions would make the text worse in the places
where its advice is wrong for this material.

#### Scenario: Technical vocabulary in Dutch text
- **WHEN** Dutch text uses a term that is the accepted name for the thing in its
  field, and the Dutch guide would have it translated
- **THEN** the review SHALL leave the term alone
- **AND** the amendment SHALL say so in writing rather than relying on judgement
  in the moment

#### Scenario: A guide that breaks a local rule
- **WHEN** an imported guide's own text or advice conflicts with a rule this
  system already enforces
- **THEN** the local rule SHALL win
- **AND** the conflict SHALL be recorded in the amendments

### Requirement: A Draft To Be Copied Is Written To A File
Prose produced for the user to copy SHALL be written to a file rather than
presented only in a reply, so that it passes the same gate as anything else. A
reply cannot be failed after it has been shown, so the habit is what puts the
text within reach of the gate.

#### Scenario: Asking for something to send
- **WHEN** the user asks for prose intended to go to someone else
- **THEN** it SHALL be written to a file
- **AND** the user SHALL be told where, so it can be gated and copied from there
