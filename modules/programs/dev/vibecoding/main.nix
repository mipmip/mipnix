{ inputs, ... } : {
  flake.modules.nixos.vibecoding-main = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.claude-code
      pkgs.unstable.beads

      inputs.openspec.packages."${pkgs.stdenv.hostPlatform.system}".default

      ## util programs used by agents
      tree
    ];
  };

  flake.modules.homeManager.vibecoding-opencode = { lib, config, unstable, ... }: {
    programs.opencode = {
      enable = true;
      package = unstable.opencode;
      agents   = {};
      commands = {};
      settings = {
        theme = "opencode";
        autoshare = false;
        autoupdate = true;
        plugin = ["@tarquinen/opencode-dcp@latest"];
        provider = {
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
