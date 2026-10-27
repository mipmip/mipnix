{ inputs, ... } : {
  flake.modules.homeManager.vibecoding-opencode = { pkgs, lib, ... }:
    let
      agentRules = import ./_agent-rules.nix { inherit lib; };

      opencodeUnwrapped =
        inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode;

      # opencode keeps the OAuth credential in its database, not in auth.json,
      # so @mellena1/opencode-go-usage cannot find it on its own. This script
      # copies the active row's access token to $XDG_RUNTIME_DIR on every start.
      #
      # It encodes opencode's auth schema: the `credential` table, the
      # `integration_id`/`active` columns, and the `access` field of the JSON
      # `value`. A future opencode that moves any of those makes the extraction
      # come up empty, which hides the widget and leaves opencode working.
      #
      # Every failure exits 0 with no file: a missing runtime directory, an
      # absent database, no active row, or JSON without an access token.
      extractGoUsageToken = pkgs.writeShellScript "opencode-go-usage-token" ''
        token_file="''${XDG_RUNTIME_DIR:-}/opencode-go-key"

        [ -n "''${XDG_RUNTIME_DIR:-}" ] || exit 0
        rm -f "$token_file" 2>/dev/null || exit 0

        database="''${XDG_DATA_HOME:-$HOME/.local/share}/opencode/opencode.db"
        [ -r "$database" ] || exit 0

        access="$(${pkgs.sqlite}/bin/sqlite3 -readonly "$database" \
          "select value from credential where integration_id = 'opencode' and active = 1 limit 1" \
          2>/dev/null | ${pkgs.jq}/bin/jq -r '.access // empty' 2>/dev/null)"
        [ -n "$access" ] || exit 0

        umask 077
        temporary="$token_file.tmp.$$"
        { printf '%s' "$access" > "$temporary"; } 2>/dev/null || { rm -f "$temporary" 2>/dev/null; exit 0; }
        mv -f "$temporary" "$token_file" 2>/dev/null || rm -f "$temporary" 2>/dev/null
        exit 0
      '';

      # makeBinaryWrapper has no --run, so the extraction needs a shell wrapper
      # around the binary wrapper that nixpkgs already puts on the executable.
      opencode = pkgs.symlinkJoin {
        name = "opencode-${opencodeUnwrapped.version}-with-go-usage";
        paths = [ opencodeUnwrapped ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/opencode --run ${lib.escapeShellArg (toString extractGoUsageToken)}
        '';
      };
    in
    {
    programs.opencode = {
      enable = true;
      package = opencode;
      agents   = {};

      # The same attribute set Claude Code gets. No translation: opencode
      # derives a command's name by stripping the `commands/` prefix and the
      # `.md` suffix from its path, and matches the text up to the first
      # whitespace after the slash, so `mip:ship.md` answers to /mip:ship here
      # too. Frontmatter it has no key for, such as `argument-hint`, is ignored
      # rather than rejected.
      commands = import ./_agent-commands.nix;

      # opencode 2 reads AGENTS.md and nothing else: the ~/.claude/CLAUDE.md
      # fallback that opencode 1 had is gone from the source. It is also the
      # only channel that inlines text unconditionally, because `instructions`
      # is in the config schema with no consumer and `references` renders a
      # catalogue of paths the agent may read. So the rules are concatenated in
      # here rather than pointed at. Each keeps its own heading, which is as
      # much of claude.nix's one-file-per-concern arrangement as survives.
      context = lib.concatStringsSep "\n" (
        [ (import ./_agent-context.nix) ] ++ lib.attrValues agentRules
      );

      # Deliberately unset: opencode scans ~/.claude/skills/<name>/SKILL.md
      # itself, so declaring the skills again would write a second copy of each
      # for no gain. See claude.nix, which declares them.

      # No `tui` block. opencode 2 retired tui.json: it reads the file once as
      # legacy input, writes ~/.config/opencode/cli.json, and owns that file
      # from then on. Declaring cli.json from Nix would make the theme and the
      # other in-application settings read-only and break changing them in the
      # TUI, so the theme is deliberately not declarative here.

      settings = {
        share = "disabled";

        # Not "auto". A store-installed binary cannot replace itself, and
        # upstream's wrapper, unlike the nixpkgs one, does not set
        # OPENCODE_DISABLE_AUTOUPDATE. Updating is `nix flake update unstable`.
        update = "disable";

        plugins = [
          "@tarquinen/opencode-dcp@latest"
          "@mohak34/opencode-notifier@latest"
          "${inputs.opencode-beans.packages.${pkgs.stdenv.hostPlatform.system}.default}/plugins/beans-stats"
          "${inputs.opencode-openspec-sidepanel.packages.${pkgs.stdenv.hostPlatform.system}.default}/plugins/openspec-stats"
          {
            package = "@mellena1/opencode-go-usage@latest";
            options.apiKey = "{file:{env:XDG_RUNTIME_DIR}/opencode-go-key}";
          }
        ];
        providers = {
          anthropic = {
            options = {
              baseURL = "https://api.anthropic.com/v1";
            };
          };
          amazon-bedrock = {
            options = {
              region = "eu-central-1";
              profile = "technative_pg-playground_pim";
            };
          };
        };
      };
      themes = {};
    };
  };

}
