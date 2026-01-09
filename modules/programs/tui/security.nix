{ inputs, ... } : {
  flake.modules.nixos.tui-security = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      openssl
      apg
    ];
  };
}
