{ inputs, ... } : {
  flake.modules.nixos.editors-vim = { config, pkgs, ... }: {
    environment.sessionVariables = {
      EDITOR = "vim";
    };
  };
}
