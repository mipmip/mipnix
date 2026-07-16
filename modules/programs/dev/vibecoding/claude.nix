{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config = { unstable, ... }: {

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      commands = import ./_cc-commands.nix;
      settings =  {
        includeCoAuthoredBy = false;
        statusLine = {
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
          type = "command";
        };

      };

    };
  };
}

