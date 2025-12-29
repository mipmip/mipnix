{ lib, ... } : {

  options.nixos.nixUtils.enable = lib.mkEnableOption "enable nix tools";
  options.nixos.nixpkgsDev.enable = lib.mkEnableOption "enable nixpkgsDev tools";
  options.nixos.nixRemoteBuilds.enable = lib.mkEnableOption "enable nix tools";

}
