{ inputs, ... } : {
  flake.modules.nixos.granny = { pkgs, ... }: {
    imports = [
    ];

    environment.systemPackages = with pkgs; [
    ];
  };
}






