{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config = { unstable, ... }: {

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;

      commands = {

        "mip:1shotpoc" = ''
          ---
          description: creates a new project based on the existing context my way
          ---
          Can you create a set of artifacts I can use to let claude code
          autonomously build the PoC which could serve as an alpha base for
          later development.

          We will use beans as internal ticket system for milestones and epics.
          Run `beans init` to setup and `beans prime` to undestand how it
          works. Claude Code should administer the milestones and epics.
          Milestone title should start with an incremental two digit
          number:starting with `01`

          We will use OpenSpec for creating proposals and keeping track of all
          tasks within an epic. OpenSpec needs to be fully setup before the
          project can take off. start with `openspec init.

          We need thourough testing and e2e testcases to prove our PoC is
          working as it should.

          The PoC need to work with nix and nix flakes from the start. Do
          not use flake-utils but plain nix to setup supported architectures.

          We will use jj for version control. Pim will give you the url of the
          remote repository. You should commit after every archival of a
          openspec change. Commit as Pim Snel, no self promotion.
        '';

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

