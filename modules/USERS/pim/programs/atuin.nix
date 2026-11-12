{
  flake.modules.homeManager.pim-atuin = { unstable, ... } : {

    programs.atuin = {
      enable = true;
      package = unstable.atuin;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      daemon = {
        enable = true;
      };
      settings = {
        auto_sync = true;
        daemon.sync_frequency = 300;
        sync_address = "https://atuin.tools.technative.cloud";
        search_mode = "fuzzy";
        dialect = "us";
        filter_mode = "host";
        ui = {
          columns = ["time" "host" "directory" "command"];
        };
        tmux = {
          enabled = true;
          width = "80%";
          height = "60%";
        };
        common_prefix = [
          "ls"
          "cd"
          "grep"
          "nvim"
        ];
        common_subcommands = [
          "bmc"
          "race"
          "jj"
          "git"
          "nix"
          "npm"
        ];
        secrets_filter = true;
        history_filter = [
          "^export.*KEY"
          "^export.*TOKEN"
        ];

        threads = {
          capture = true;
          capture_tools = true;
        };
      };
    };
  };
}
