{
inputs,
...
}:
{
  flake.modules.homeManager.pim-atuin = { unstable, ... } : {

    programs.atuin = {
      enable = true;
      package = unstable.atuin;
      enableZshIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      daemon = {
        enable = true;
      };
      settings = {
        auto_sync = true;
        daemon.sync_frequency = 300;  # seconden — sync gebeurt nu via de daemon
        #sync_address = "https://api.atuin.sh";
        sync_address = "https://atuin.tools.technative.cloud";
        search_mode = "fuzzy";
        dialect = "us";
        filter_mode = "host";
        common_prefix = [
          "ls"
          "cd"
          "z"
          "grep"
          "vi"
        ];
        common_subcommands = [
          "bmc"
          "race"
        ];
        secrets_filter = true;
        history_filter = [
          "^export.*KEY"
          "^export.*TOKEN"
        ];

        # Atuin Threads: sessies van AI-agents (Claude Code, opencode, codex) worden door de
        # daemon vastgelegd in de encrypted record store en meegesynct, zodat je ze op de
        # andere machine kunt doorzoeken (atuin threads) en hervatten (atuin resume).
        threads = {
          capture = true;
          # Ook tool-calls met input/output bewaren (secrets geredigeerd); zonder dit blijft
          # alleen de toolnaam over en is een hervatte thread niet meer dan een samenvatting.
          capture_tools = true;
        };
      };
    };
  };
}
