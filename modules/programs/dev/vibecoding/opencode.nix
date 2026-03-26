{ inputs, ... } : {
  flake.modules.homeManager.vibecoding-opencode = { lib, config, unstable, ... }: {
    programs.opencode = {
      enable = true;
      package = unstable.opencode;
      agents   = {};
      commands = {};
      settings = {
        theme = "system";
        autoshare = false;
        autoupdate = true;
        plugin = [
          "@tarquinen/opencode-dcp@latest"
          "@mohak34/opencode-notifier@latest"
        ];
        provider = {
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
