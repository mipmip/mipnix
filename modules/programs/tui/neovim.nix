{ inputs, ... } : {
  flake.modules.nixos.tui-neovim = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
    ];
  };
}
