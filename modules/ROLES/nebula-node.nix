{
  inputs,
  ...
}:
{
  flake.modules.nixos.role-nebula-node = {
    imports = with inputs.self.modules.nixos; [
      networking-nebula
    ];
  };
}

