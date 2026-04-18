{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [

      nix-cli
      nix-age
      system-locale
      hm-nixos
      services-core
      shell-core
      dev-lang-python
      dev-infra-dataformat
      user-pim
      editors-vim
      system-luks
      tui-system
    ];
  };
}
