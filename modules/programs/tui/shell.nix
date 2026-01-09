{ inputs, ... } : {
  flake.modules.nixos.tui-shell = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      tmux
      nushell
    ];
  };
}
