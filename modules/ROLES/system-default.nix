{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [

      inputs.self.modules.nixos.nix-channels
      nix-cli
      nix-age
      system-locale
      hm-nixos
      services-core
      shell-core
      dev-lang-python
      dev-infra-dataformat
      user-pim
      networking-nebula
      editors-vim
      system-luks
    ];
  };
}
