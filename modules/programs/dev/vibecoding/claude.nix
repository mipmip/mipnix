{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config = { unstable, ... }: {

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      commands = {
        "mip:translate" = ''
          ---
          argument-hint: [message]
          description: translates between Dutch and English
          ---
          Translate the following text between Dutch and English. Auto-detect
          the source language. Keep the tone and register of the original.

          $ARGUMENTS
        '';
      };

    };
  };

}

