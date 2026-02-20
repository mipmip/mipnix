{ inputs, ... } : {
  flake.modules.nixos.vibecoding-main = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      #pkgs.unstable.claude-code
      #pkgs.unstable.beads

      inputs.openspec.packages."${pkgs.stdenv.hostPlatform.system}".default

      ## util programs used by agents
      tree

      ## notification support for claude-code
      libnotify  # provides notify-send
    ];
  };

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

  flake.modules.homeManager.vibecoding-claude-code-config = { ... }: {
    programs.claude-code = {
      enable = true;

      #notifications = {
      #  enable = true;
      #  verboseMode = false;  # Set to true for notifications on every tool call
      #};

      # Optional: Add MCP servers here
      mcpServers = {
        # Example: Filesystem MCP server
        # filesystem = {
        #   command = "${pkgs.nodejs}/bin/npx";
        #   args = [ "-y" "@modelcontextprotocol/server-filesystem" "/home/pim" ];
        # };
      };

      # Optional: Custom hooks
      #customHooks = {
      #  # Example: Play sound on error
      #  # onError = {
      #  #   command = "${pkgs.sox}/bin/play";
      #  #   args = [ "/path/to/error.wav" ];
      #  # };
      #};
    };
  };

}
