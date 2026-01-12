{ inputs, ... } : {
  flake.modules.nixos.desktop-minecraft = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.prismlauncher
      pkgs.jdk17
      pkgs.minecraft
      pkgs.minecraft-server
    ];
  };
}
