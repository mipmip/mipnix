{ inputs, ... } : {
  flake.modules.homeManager.vibecoding-codex = { config, unstable, ... }: {

    #    home.packages = [
    #      (unstable.codex.overrideAttrs {
    #        dontCargoUseSystemLibs = true;
    #      })
    #    ];
    #
    #    home.file."${config.home.homeDirectory}/.codex/config.yaml".text = ''
    #      model: o4-mini
    #      provider: openai
    #    '';

  };
}
