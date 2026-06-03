{
inputs,
...
}:
{
  flake.modules.nixos.channel-annemarie = {
    imports = with inputs.self.modules.nixos; [
      inputs.self.modules.nixos.nix-channels-mama
    ];
  };
}
