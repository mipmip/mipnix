{ pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    tmux
    nushell
  ];
}

