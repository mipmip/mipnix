{
  inputs,
  ...
}:
{

  flake.modules.nixos.system-default = {
    imports = [
      inputs.self.modules.nixos.nix-channels

    ];


  };
}
