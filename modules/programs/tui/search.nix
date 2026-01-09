{ inputs, ... } : {
  flake.modules.nixos.tui-search = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      fd
      ripgrep
    ];
  };
}
