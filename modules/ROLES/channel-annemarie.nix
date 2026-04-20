{
inputs,
...
}:
{
  flake.modules.nixos.channel-default = {
    imports = with inputs.self.modules.nixos; [
      inputs.self.modules.nixos.nix-channels-mama
    ];
  };
}
