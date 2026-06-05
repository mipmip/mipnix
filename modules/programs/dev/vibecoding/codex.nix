{ inputs, ... } : {
  flake.modules.homeManager.vibecoding-codex = { config, unstable, ... }: {

    home.packages = [
      unstable.codex
    ];

    home.file."${config.home.homeDirectory}/.codex/config.yaml".text = ''
      model: o4-mini
      provider: openai
    '';

  };
}
