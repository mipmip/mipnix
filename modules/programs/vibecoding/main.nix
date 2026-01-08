{
  flake.modules.nixos.vibecoding-main = { pkgs, unstable, ... }: {
    environment.systemPackages = with pkgs; [
      unstable.claude-code
    ];
  };
}
