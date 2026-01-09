{ inputs, ... } : {
  flake.modules.nixos.cobol-main = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      jdk17
    ];
  };
}
