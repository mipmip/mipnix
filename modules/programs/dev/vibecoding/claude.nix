{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config = { unstable, ... }: {

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;

      commands = {

        "mip:flaker" = ''
          ---
          description: creates a flake.nix for the current project
          ---
          check which programming langauge is used for this project and use the instructions from https://github.com/mipmip/agent-do-it-my-way for make a flake for this project-type. If the language is not listed create a flake in the spirit of add-flake-to-nodejs-project.md.
        '';

        "mip:translate" = ''
          ---
          argument-hint: [message]
          description: translates between Dutch and English
          ---
          Translate the following between Dutch and English. Auto-detect
          the source language. Keep the tone and register of the original.

          the following can be
            - a text fragment -> translate in this session
            - a file path -> translate the complete file overwriting the existing text
            - a file path with range -> translate the text withing the range overwriting the existing text

          $ARGUMENTS
        '';
      };

    };
  };

}

