{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      inputs.self.modules.nixos.nix-channels

      system-locale
      hm-nixos
      services-core
      shell-core
      dev-lang-python
      networking-nebula
      dev-infra-dataformat
      user-pim
    ];
  };
}
