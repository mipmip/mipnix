---
# mipnix-jdmy
title: publication gate for generated prose
status: completed
openspec-link: openspec/changes/archive/2026-09-14-add-publication-gate
type: feature
priority: normal
tags:
    - claude-code
    - writing
created_at: 2026-09-14T16:16:32Z
updated_at: 2026-09-14T18:30:53Z
blocked_by:
    - mipnix-pdlz
---

Anything Claude generates that leaves my hands as my writing has to pass a gate
first. Publication is not a directory, it is a moment: prose generated and
written straight into a file that is a publication source, or a draft shown in
chat for me to copy. I communicate outward in both Dutch and English, so the
gate has to cover both.

The mechanical half of this lives in [[mipnix-pdlz]]. What is
left here is the half a script cannot decide: passive voice, forced triads, the
"not X but Y" formula, inflated significance, staged run-ups, openers and
sign-offs. That needs a reading pass with the guides alongside, not a grep.

One finding shapes the whole design. The two halves of my own definition are not
equally enforceable, measured in SimpleEnglish's `lint_hook.py`:

- prose written to a file: PostToolUse, exit 2, violations go back to the model,
  which must fix them. Hard.
- a draft shown in chat: the Stop hook does receive `last_assistant_message`, so
  inspection works, but it returns 0 and only emits a systemMessage. Blocking
  there risks an answer/reject/answer loop, and the reply is already on screen
  either way. Soft, by design, and not worth fighting.

So the answer is a working agreement rather than a mechanism: a draft meant for
copying gets written to a file instead of pasted into the chat. Then both halves
of the definition collapse onto the one gate that can actually hold, and I get
diffs and versions of my drafts for free.

Which rules apply, decided while exploring:

- **humanizer as the base, both languages.** It is the only one of the four
  written to be language-neutral ("The formula appears in every language; treat
  the equivalent construction the same way"), and it says itself that rule 12 is
  its only English-specific list.
- **dutch-style-guide for Dutch sentence construction only**: length, passive
  voice, superlatives. Reject its term translation (performance to prestaties,
  retry to opnieuw proberen, payload to berichtinhoud). In text about flakes,
  locks and closures that costs accuracy. Note it also breaks my em-dash rule
  nineteen times in its own headings.
- **SimpleEnglish for English technical documents only.** Its DOCUMENT section
  (ASD-STE100, condition before command, one word one meaning) is useful. Reject
  its REPLY section outright: it forbids headers, lists, bold, tables and more
  than five sentences per answer, which collides head-on with my own CLAUDE.md
  rule about aligning markdown table borders.
- **i-have-adhd is not part of this.** It shapes the form of a chat answer, not
  the quality of prose, and must never gate publication.

Open: whether the gate is a slash command I invoke at the publication moment
(the shape that matches how scripts/ship-change.sh already works for code) or a
hook that fires on every write of a prose file. The first has no false
positives and needs me to remember it; the second is automatic and will fire on
drafts I never intended to publish.
