{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config =
    { pkgs, lib, unstable, ... }:
    let
      # The PostToolUse checker. Referenced by store path, never by a bare
      # interpreter name: programs.claude-code.hooks writes its files without an
      # executable bit, and naming `python3` in the command would make the hook
      # die silently in any shell that lacks it.
      proseLint = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".prose-lint;

      # One source of truth for the word list: the same JSON the linter reads is
      # rendered into the rule file, so the two can never drift apart.
      fillerWords = builtins.fromJSON (
        builtins.readFile ../../../../packages/prose-lint/filler-words.json
      );
      renderWords = words: lib.concatMapStringsSep "\n" (w: "- ${w}") words;
    in
    {

    # The checker is also a tool you can run yourself: `prose-lint FILE...`.
    # Same derivation the hook uses, so there is one of it, not two.
    home.packages = [ proseLint ];

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      commands = import ./_cc-commands.nix;

      # Writing rules, one file per concern. Every markdown file in
      # ~/.claude/rules/ is loaded as memory automatically, which is why these
      # do not live in the `context` blob below.
      # humanizer keeps its SKILL.md at the repository root, so one file is
      # enough. The Dutch guide's SKILL.md refers to the 25 KB reference beside
      # it by name, so that one needs the whole directory.
      skills = {
        humanizer = "${inputs.humanizer}/SKILL.md";
        writing-clearly-and-concisely-dutch =
          "${inputs.dutch-style-guide}/skills/writing-clearly-and-concisely-dutch";
      };

      rules = {
        prose-review-amendments = ''
          # Where the imported writing guides do not apply

          Two guides are installed as skills: `humanizer` for any language, and
          `writing-clearly-and-concisely-dutch` for Dutch. Read them through the
          amendments below. A guide adopted without stating its exceptions makes
          the text worse in the places where its advice is wrong for this
          material.

          ## A technical term keeps its accepted name

          The Dutch guide treats an English word as a red flag whenever a Dutch
          alternative exists, and rejects "it is a technical term" as an excuse.
          That does not apply here. When a term is the accepted name for the
          thing in its field, it stays: flake, input, lock, closure, derivation,
          store path, commit, merge, pull request.

          Translate a word that is merely borrowed, not one that names the
          thing. "Performance" becomes "prestaties" in ordinary prose; a
          `nix flake update` does not become "nix vlok bijwerken".

          ## The vocabulary list is English only

          humanizer's rule 12 lists overused English words, and says itself that
          it is the skill's only vocabulary list. Do not look for Dutch
          equivalents of it. Every other rule in humanizer applies to both
          languages, as its rule 1 states.

          ## A local rule wins

          Where a guide conflicts with the rules in `prose-typography.md` or
          `prose-filler-words.md`, the local rule wins. The Dutch guide is itself
          an example: it uses the em dash nineteen times, including in its own
          rule headings. Follow what it says about sentence construction, not
          what its punctuation does.

          ## Prose meant to be copied goes to a file

          When the user asks for prose to send to someone else, write it to a
          file and say where it is, rather than showing it only in a reply. A
          reply cannot be checked before it appears; a file can. Then run the
          gate on it.
        '';

        prose-typography = ''
          # Prose typography

          These marks are never wanted. Not in a blog post, not in a spec, not in
          a commit message, and in neither Dutch nor English. There is no context
          that calls for them, so there is no exception to weigh.

          - The em dash `—` (U+2014). Name the relation instead ("because",
            "but", "for example"), use a comma, a colon or parentheses, or write
            two sentences.
          - The en dash `–` (U+2013). In a range a plain hyphen does the job.
            Anywhere else, rewrite.
          - A spaced double hyphen used as a dash. Same rule as the em dash.
          - Curly quotation marks. Use straight quotes.

          Dashes and hyphens inside code blocks, inline code, commands, paths and
          URLs are not prose and are left alone.

          A hook checks this after every write to a prose file and fails the
          write when it finds a hit, so treat it as settled rather than as
          advice.
        '';

        prose-filler-words = ''
          # Filler words

          Use a word from this list only when it carries meaning. Drop it when it
          is a verbal tic. The same word can be either:

          - "dat is eigenlijk niet waar" corrects a claim, so it stays.
          - "dat is eigenlijk best goed" says nothing, so it goes.

          A hook reports these with the sentence they sit in. It does not fail
          the write, because only a reader can tell the two cases apart.

          ## Dutch

          ${renderWords fillerWords.nl}

          ## English

          ${renderWords fillerWords.en}
        '';
      };
      context = import ./_cc-CLAUDEmd.nix;
      settings =  {
        includeCoAuthoredBy = false;
        feedbackSurveyRate = 0;

        # Registration lives here, not in programs.claude-code.hooks: that option
        # only drops the file into ~/.claude/hooks/ and never registers it.
        hooks.PostToolUse = [
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = "${proseLint}/bin/prose-lint";
              }
            ];
          }
        ];
        statusLine = {
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
          type = "command";
        };

      };

    };
  };
}

