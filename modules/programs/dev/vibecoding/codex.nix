{ inputs, ... } : {
  flake.modules.homeManager.vibecoding-codex = { config, pkgs, ... }: {

    home.packages = [
      pkgs.codex
    ];

    home.file."${config.home.homeDirectory}/.codex/config.yaml".text = ''
          model: o4-mini
          provider: openai
    '';

  };
}
