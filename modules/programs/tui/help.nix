{ inputs, ... } : {
  flake.modules.nixos.tui-help = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      cheat
      entr
    ];
  };
}
